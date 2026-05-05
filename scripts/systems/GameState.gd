extends Node
# 전역 게임 상태 싱글톤 (autoload)
# 기획서 6.1 참조

signal money_changed(new_amount: int)
signal reputation_changed(new_reputation: int)
signal day_started(day: int)
signal day_ended(day: int)
signal region_changed(region_id: String)
signal menu_unlock_event(menu_id: String)
signal staff_list_changed

# === 핵심 상태 ===
var money: int = 5000000  # 시작 자금: 500만원
var current_day: int = 0  # start_new_day() 첫 호출에서 1로 증가
var current_region: String = "nowon"
var reputation: float = 50.0  # 0-100

# === 가게 운영 ===
var menu_unlocked: Array[String] = []
var menu_active: Array[String] = []  # 현재 판매 중인 메뉴
var menu_prices: Dictionary = {}  # menu_id → custom_price (없으면 base_price)
var staff_list: Array = []  # Staff 인스턴스
var table_count: int = 6

# === 전략 ===
var active_strategies: Dictionary = {}  # strategy_id → days_remaining

# === 마케팅 ===
var marketing_flags: Dictionary = {
	"instagram_ad": false,  # 월 50만원
	"blog_review": false,
	"delivery_app": false   # 월 50만원
}

# === 평판/단골 ===
var regulars_count: int = 0
var review_scores: Array[float] = []  # 최근 100개 리뷰 (1-5)

# === 통계 ===
var stats: Dictionary = {
	"total_revenue": 0,
	"total_cost": 0,
	"total_customers": 0,
	"happy_customers": 0,
	"angry_customers": 0
}

# === 일일 ===
var daily_revenue: int = 0
var daily_customer_count: int = 0
var daily_cost_breakdown: Dictionary = {}

func _ready() -> void:
	_init_starting_state()

func _init_starting_state() -> void:
	# 시작 메뉴 잠금 해제
	for id in Menus.STARTING_UNLOCKED:
		if not menu_unlocked.has(id):
			menu_unlocked.append(id)
			menu_active.append(id)
	# 시작 알바 1명 (신입)
	if staff_list.is_empty():
		staff_list.append(Staff.new(Staff.Level.ROOKIE, "김알바"))

# === 자금 ===
func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)

func spend_money(amount: int) -> bool:
	if money < amount:
		return false
	money -= amount
	money_changed.emit(money)
	return true

# === 평판 ===
func add_review(score: float) -> void:
	review_scores.append(clamp(score, 1.0, 5.0))
	if review_scores.size() > 100:
		review_scores.pop_front()
	_recompute_reputation()

func _recompute_reputation() -> void:
	if review_scores.is_empty():
		return
	var sum = 0.0
	for s in review_scores:
		sum += s
	var avg_5 = sum / review_scores.size()
	# 1-5 평점을 0-100 평판으로 매핑 + 기존 평판과 가중 평균
	var target = (avg_5 - 1.0) / 4.0 * 100.0
	reputation = lerp(reputation, target, 0.1)
	reputation = clamp(reputation, 0.0, 100.0)
	reputation_changed.emit(int(reputation))

func boost_reputation(amount: float) -> void:
	reputation = clamp(reputation + amount, 0.0, 100.0)
	reputation_changed.emit(int(reputation))

func get_star_rating() -> float:
	if review_scores.is_empty():
		return 3.0
	var sum = 0.0
	for s in review_scores:
		sum += s
	return sum / review_scores.size()

# === 메뉴 잠금 해제 ===
func try_unlock_menus_by_reputation() -> void:
	for id in Menus.REPUTATION_LOCKS.keys():
		var required = Menus.REPUTATION_LOCKS[id]
		if reputation >= required and not menu_unlocked.has(id):
			menu_unlocked.append(id)
			menu_unlock_event.emit(id)

# === 메뉴 가격 ===
func get_menu_price(menu_id: String) -> int:
	if menu_prices.has(menu_id):
		return menu_prices[menu_id]
	var menu = Menus.get_menu(menu_id)
	return int(menu.get("base_price", 0))

func set_menu_price(menu_id: String, price: int) -> void:
	menu_prices[menu_id] = price

# === 메뉴 활성/비활성 토글 ===
func toggle_menu_active(menu_id: String) -> void:
	if menu_active.has(menu_id):
		menu_active.erase(menu_id)
	elif menu_unlocked.has(menu_id):
		menu_active.append(menu_id)

# === 알바 ===
func hire_staff(staff: Staff) -> bool:
	staff_list.append(staff)
	staff_list_changed.emit()
	return true

func fire_staff(index: int) -> void:
	if index >= 0 and index < staff_list.size():
		staff_list.remove_at(index)
		staff_list_changed.emit()

# 알바 중 가능한 최고 등급 (메뉴 제작 가능 여부 체크용)
func get_max_staff_level() -> int:
	var lvl = 0
	for s in staff_list:
		if s.level + 1 > lvl:  # enum은 0부터 시작 → 등급은 1,2,3
			lvl = s.level + 1
	return lvl

# === 전략 ===
func activate_strategy(strategy_id: String) -> bool:
	var s = Strategies.get_strategy(strategy_id)
	if s.is_empty():
		return false
	if not spend_money(int(s.cost)):
		return false
	active_strategies[strategy_id] = int(s.duration)
	# 즉시 효과 적용 (평판 부스트 등)
	if s.effects.has("reputation_boost"):
		boost_reputation(float(s.effects.reputation_boost))
	return true

func is_strategy_active(strategy_id: String, hour: int = -1) -> bool:
	if not active_strategies.has(strategy_id):
		return false
	var s = Strategies.get_strategy(strategy_id)
	if hour >= 0 and not s.active_hours.is_empty():
		return hour in s.active_hours
	return true

func tick_strategies_one_day() -> void:
	var to_remove = []
	for id in active_strategies.keys():
		active_strategies[id] -= 1
		if active_strategies[id] <= 0:
			to_remove.append(id)
	for id in to_remove:
		active_strategies.erase(id)

# === 마케팅 ===
func toggle_marketing(key: String) -> void:
	if marketing_flags.has(key):
		marketing_flags[key] = not marketing_flags[key]

func get_marketing_monthly_cost() -> int:
	var c = 0
	if marketing_flags.get("instagram_ad", false):
		c += 500000
	if marketing_flags.get("delivery_app", false):
		c += 500000
	return c

# === 일일 정산 ===
func reset_daily() -> void:
	daily_revenue = 0
	daily_customer_count = 0
	daily_cost_breakdown = {
		"ingredient": 0,
		"staff": 0,
		"marketing": 0,
		"rent": 0
	}

func add_daily_revenue(amount: int) -> void:
	daily_revenue += amount
	stats.total_revenue += amount
	add_money(amount)

func add_daily_cost(category: String, amount: int) -> void:
	daily_cost_breakdown[category] = daily_cost_breakdown.get(category, 0) + amount
	stats.total_cost += amount

func count_customer(happy: bool) -> void:
	daily_customer_count += 1
	stats.total_customers += 1
	if happy:
		stats.happy_customers += 1
	else:
		stats.angry_customers += 1

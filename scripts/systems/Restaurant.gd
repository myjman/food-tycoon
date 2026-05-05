extends Node
# 가게 운영 싱글톤 (autoload)
# 일일 정산 / 비용 차감 / 단골 처리

signal order_placed(menu_id: String, customer_id: int)
signal order_completed(menu_id: String, customer_id: int)

func _ready() -> void:
	pass

# === 주문 처리 ===
# 손님이 주문할 메뉴를 결정 (가격/인기/예산 고려)
func decide_customer_order(customer) -> String:
	var region = Regions.get_region(GameState.current_region)
	var candidates: Array = []
	for menu_id in GameState.menu_active:
		var menu = Menus.get_menu(menu_id)
		if menu.is_empty():
			continue
		# 알바 등급 체크
		if not Menus.can_be_cooked_by_level(menu_id, GameState.get_max_staff_level()):
			continue
		# 예산 체크
		var price = GameState.get_menu_price(menu_id)
		var effective_price = _apply_strategy_price_for_customer(price, customer, TimeSystem.current_hour)
		if effective_price > customer.budget:
			continue
		candidates.append({
			"id": menu_id,
			"price": effective_price,
			"weight": _calc_menu_weight(menu_id, customer, region)
		})
	if candidates.is_empty():
		return ""
	# 가중 랜덤
	var total_w = 0.0
	for c in candidates:
		total_w += c.weight
	var roll = randf() * total_w
	var acc = 0.0
	for c in candidates:
		acc += c.weight
		if roll <= acc:
			return c.id
	return candidates[0].id

func _calc_menu_weight(menu_id: String, customer, region: Dictionary) -> float:
	var menu = Menus.get_menu(menu_id)
	var w = 1.0
	# 지역 인기도
	var pop_by_region = menu.get("popularity_by_region", {})
	w *= float(pop_by_region.get(GameState.current_region, 1.0))
	# 손님 선호 (간단)
	var prefs = customer.preferences
	if prefs.has("price_weight") and float(prefs.price_weight) > 0.4:
		# 가성비 손님 → 싼 메뉴 가중
		w *= clamp(8000.0 / max(menu.base_price, 1), 0.3, 2.0)
	if prefs.has("tradition_weight") and float(prefs.tradition_weight) > 0.3:
		# 어르신 → 한식 선호
		if menu.category == "korean":
			w *= 1.8
		elif menu.category == "western":
			w *= 0.4
	if prefs.has("speed_weight") and float(prefs.speed_weight) > 0.3:
		# 직장인 → 빠른 메뉴 선호
		w *= clamp(120.0 / max(menu.cooking_time, 1), 0.4, 2.0)
	# 인기 메뉴 보너스
	if region.popular_menus.has(menu_id):
		w *= 1.5
	if region.unpopular_menus.has(menu_id):
		w *= 0.4
	return w

func _apply_strategy_price_for_customer(price: int, customer, hour: int) -> int:
	var p = float(price)
	# 점심 할인
	if GameState.is_strategy_active("lunch_discount", hour):
		var s = Strategies.get_strategy("lunch_discount")
		p *= float(s.effects.get("price_multiplier", 1.0))
	# 학생 할인
	if GameState.is_strategy_active("student_discount") and customer.is_student():
		var s2 = Strategies.get_strategy("student_discount")
		p *= float(s2.effects.get("price_multiplier_for_students", 1.0))
	return int(p)

# === 결제 ===
func process_payment(menu_id: String, customer) -> int:
	var price = GameState.get_menu_price(menu_id)
	var effective_price = _apply_strategy_price_for_customer(price, customer, TimeSystem.current_hour)
	# 만족도에 따른 팁
	var tip = 0
	if customer.satisfaction >= 80:
		tip = int(effective_price * 0.10)
	# 결제
	GameState.add_daily_revenue(effective_price + tip)
	# 재료비 차감
	var menu = Menus.get_menu(menu_id)
	var cost = int(effective_price * float(menu.get("ingredient_cost_ratio", 0.3)))
	GameState.add_daily_cost("ingredient", cost)
	GameState.spend_money(cost)
	# 리뷰
	var stars = _satisfaction_to_stars(customer.satisfaction)
	GameState.add_review(stars)
	# 단골 가능성
	if customer.satisfaction >= 80:
		var roll_threshold = 0.15
		if GameState.is_strategy_active("loyalty_coupon"):
			var s3 = Strategies.get_strategy("loyalty_coupon")
			roll_threshold *= float(s3.effects.get("regular_chance", 1.0))
		if randf() < roll_threshold:
			GameState.regulars_count += 1
	GameState.count_customer(customer.satisfaction >= 60)
	return effective_price + tip

func _satisfaction_to_stars(s: int) -> float:
	# 100 → 5점, 0 → 1점
	return clamp(1.0 + (float(s) / 100.0) * 4.0, 1.0, 5.0)

# === 일일 정산 (마감 시 호출) ===
func close_day_and_settle() -> Dictionary:
	# 알바 인건비 (영업시간 13시간 기준)
	var staff_cost = 0
	for s in GameState.staff_list:
		if s.monthly_salary > 0:
			# 월급제 → 1/30
			staff_cost += int(s.monthly_salary / 30.0)
		else:
			staff_cost += int(s.hourly_wage * 13)
	GameState.add_daily_cost("staff", staff_cost)
	GameState.spend_money(staff_cost)

	# 마케팅비 (월 → 일)
	var marketing_cost = int(GameState.get_marketing_monthly_cost() / 30.0)
	GameState.add_daily_cost("marketing", marketing_cost)
	GameState.spend_money(marketing_cost)

	# 월세 (일할)
	var region = Regions.get_region(GameState.current_region)
	var rent_daily = int(int(region.get("rent_per_month", 0)) / 30.0)
	GameState.add_daily_cost("rent", rent_daily)
	GameState.spend_money(rent_daily)

	# 전략 카운터 감소
	GameState.tick_strategies_one_day()

	# 메뉴 잠금 해제 체크
	GameState.try_unlock_menus_by_reputation()

	# 결과 반환
	var report = {
		"day": GameState.current_day,
		"revenue": GameState.daily_revenue,
		"cost_breakdown": GameState.daily_cost_breakdown.duplicate(),
		"customer_count": GameState.daily_customer_count,
		"net_profit": GameState.daily_revenue - _sum_costs(),
		"reputation": GameState.reputation,
		"star_rating": GameState.get_star_rating(),
		"regulars_count": GameState.regulars_count
	}
	var b = GameState.daily_cost_breakdown
	print("[DAY %d 정산] 매출 %d / 비용 %d (재료 %d, 인건 %d, 마케팅 %d, 월세 %d) / 순이익 %d / 손님 %d명 / 별점 %.2f / 단골 %d / 잔액 %d" % [
		report.day, report.revenue, _sum_costs(),
		int(b.get("ingredient", 0)), int(b.get("staff", 0)),
		int(b.get("marketing", 0)), int(b.get("rent", 0)),
		report.net_profit, report.customer_count, report.star_rating,
		report.regulars_count, GameState.money
	])
	return report

func _sum_costs() -> int:
	var total = 0
	for k in GameState.daily_cost_breakdown.keys():
		total += int(GameState.daily_cost_breakdown[k])
	return total

func start_new_day() -> void:
	GameState.current_day += 1
	GameState.reset_daily()
	TimeSystem.start_day()
	# 자동 저장
	SaveSystem.save_game()

extends Control
class_name Customer

# 손님 (기획서 6.4 + 5.2.5 상태머신)

enum Type { STUDENT, OFFICE_WORKER, FAMILY, ELDERLY }
enum State { ENTERING, SEEKING_TABLE, ORDERING, WAITING_FOOD, EATING, PAYING, LEAVING, LEFT_ANGRY }

signal state_changed(new_state: int)
signal departed(satisfied: bool)

const VISUAL_SIZE := Vector2(28, 28)

var customer_type: int = Type.STUDENT
var budget: int = 8000
var patience: float = 100.0
var max_patience: float = 100.0
var preferences: Dictionary = {}

var current_state: int = State.ENTERING
var ordered_menu: String = ""
var satisfaction: int = 100
var wait_seconds: float = 0.0
var assigned_staff: Staff = null
var cooking_progress: float = 0.0
var cooking_total: float = 0.0

# 시각 노드
var visual: ColorRect = null
var progress_bar: ColorRect = null
var status_label: Label = null
var assigned_table_index: int = -1

func setup(type: int) -> void:
	customer_type = type
	_setup_preferences()
	current_state = State.ENTERING

func _ready() -> void:
	# 자기 사이즈 설정
	custom_minimum_size = VISUAL_SIZE
	size = VISUAL_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 본체 색상
	visual = ColorRect.new()
	visual.size = VISUAL_SIZE
	visual.color = _color_for_type()
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(visual)

	# 상태 라벨 (이모지)
	status_label = Label.new()
	status_label.text = ""
	status_label.position = Vector2(-2, -22)
	status_label.size = Vector2(60, 18)
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(status_label)

	# 진행률 바 (음식 완성도)
	var bar_bg = ColorRect.new()
	bar_bg.size = Vector2(VISUAL_SIZE.x, 4)
	bar_bg.position = Vector2(0, VISUAL_SIZE.y + 2)
	bar_bg.color = Color(0, 0, 0, 0.4)
	bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bar_bg)

	progress_bar = ColorRect.new()
	progress_bar.size = Vector2(0, 4)
	progress_bar.position = Vector2(0, VISUAL_SIZE.y + 2)
	progress_bar.color = Color(0.4, 1.0, 0.4, 1.0)
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(progress_bar)

func _color_for_type() -> Color:
	match customer_type:
		Type.STUDENT: return Color(1.0, 0.85, 0.20)  # 노랑
		Type.OFFICE_WORKER: return Color(0.30, 0.55, 1.0)  # 파랑
		Type.FAMILY: return Color(0.40, 0.85, 0.50)  # 초록
		Type.ELDERLY: return Color(0.75, 0.75, 0.80)  # 회색
	return Color.WHITE

func _setup_preferences() -> void:
	match customer_type:
		Type.STUDENT:
			budget = randi_range(5000, 12000)
			max_patience = 80.0
			preferences = {"price_weight": 0.5, "quantity_weight": 0.3, "quality_weight": 0.2}
		Type.OFFICE_WORKER:
			budget = randi_range(8000, 18000)
			max_patience = 60.0
			preferences = {"speed_weight": 0.5, "quality_weight": 0.3, "price_weight": 0.2}
		Type.FAMILY:
			budget = randi_range(20000, 50000)
			max_patience = 100.0
			preferences = {"variety_weight": 0.4, "kid_friendly": 0.3, "quality_weight": 0.3}
		Type.ELDERLY:
			budget = randi_range(8000, 15000)
			max_patience = 90.0
			preferences = {"tradition_weight": 0.5, "softness_weight": 0.3, "service_weight": 0.2}
	patience = max_patience

func is_student() -> bool:
	return customer_type == Type.STUDENT

func get_type_name() -> String:
	match customer_type:
		Type.STUDENT: return "학생"
		Type.OFFICE_WORKER: return "직장인"
		Type.FAMILY: return "가족"
		Type.ELDERLY: return "어르신"
	return "?"

func _physics_process(delta: float) -> void:
	if TimeSystem.is_paused or not TimeSystem.is_running:
		return
	var game_minutes_per_real_second: float = 60.0 / TimeSystem.REAL_SECONDS_PER_HOUR
	var dt_game_min: float = delta * game_minutes_per_real_second
	match current_state:
		State.SEEKING_TABLE:
			_update_status_label("...")
		State.ORDERING:
			_update_status_label("📝")
		State.WAITING_FOOD:
			wait_seconds += dt_game_min
			patience -= dt_game_min
			if cooking_total > 0:
				cooking_progress = clamp(wait_seconds / cooking_total, 0.0, 1.0)
				if progress_bar:
					progress_bar.size.x = VISUAL_SIZE.x * cooking_progress
				_update_status_label("🍳" if cooking_progress < 0.5 else "🍱")
				if cooking_progress >= 1.0:
					_start_eating()
			if patience <= 0:
				_leave_angry()
		State.EATING:
			wait_seconds += dt_game_min
			_update_status_label("😋")
			if wait_seconds > cooking_total + 10.0:
				_pay_and_leave()

func _update_status_label(text: String) -> void:
	if status_label and status_label.text != text:
		status_label.text = text

func change_state(s: int) -> void:
	current_state = s
	state_changed.emit(s)

func move_to(target: Vector2, duration: float = 0.7) -> void:
	var tw = create_tween()
	tw.tween_property(self, "position", target, duration).set_trans(Tween.TRANS_SINE)

func seat_at_table() -> void:
	change_state(State.ORDERING)
	ordered_menu = Restaurant.decide_customer_order(self)
	if ordered_menu.is_empty():
		_leave_angry()
		return
	var menu = Menus.get_menu(ordered_menu)
	cooking_total = float(menu.cooking_time)
	assigned_staff = _find_capable_staff(ordered_menu)
	if assigned_staff == null:
		_leave_angry()
		return
	cooking_total /= assigned_staff.cooking_speed_multiplier
	change_state(State.WAITING_FOOD)
	wait_seconds = 0.0

func _find_capable_staff(menu_id: String) -> Staff:
	var capable = []
	for s in GameState.staff_list:
		if s.can_cook(menu_id):
			capable.append(s)
	if capable.is_empty():
		return null
	return capable[randi() % capable.size()]

func _start_eating() -> void:
	var ratio = clamp(patience / max_patience, 0.0, 1.0)
	satisfaction = int(clamp(50.0 + ratio * 50.0, 0, 100))
	change_state(State.EATING)
	wait_seconds = cooking_total

func _pay_and_leave() -> void:
	change_state(State.PAYING)
	Restaurant.process_payment(ordered_menu, self)
	change_state(State.LEAVING)
	departed.emit(satisfaction >= 60)
	_animate_leave_then_free(satisfaction >= 60)

func _leave_angry() -> void:
	satisfaction = 0
	GameState.add_review(1.0)
	change_state(State.LEFT_ANGRY)
	GameState.count_customer(false)
	_update_status_label("😡")
	departed.emit(false)
	_animate_leave_then_free(false)

func _animate_leave_then_free(happy: bool) -> void:
	# 만족 표시 후 입구로 이동 → 제거
	_update_status_label("😊" if happy else "😡")
	if visual:
		visual.color = visual.color.lightened(0.2) if happy else Color(0.6, 0.2, 0.2)
	var tw = create_tween()
	tw.tween_property(self, "position", CustomerSpawner.ENTRANCE_POSITION, 0.6)
	tw.tween_callback(queue_free)

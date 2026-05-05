extends Node
class_name CustomerSpawner

# 손님 생성기 (메인 씬에 부착)
# 시간 + 지역 데이터 → 손님 자동 생성

signal customer_spawned(customer)

# 테이블/입구 좌표 (Main.tscn의 GameView 좌표계 기준)
const TABLE_POSITIONS: Array = [
	Vector2(216, 156),  # T1
	Vector2(576, 156),  # T2
	Vector2(936, 156),  # T3
	Vector2(216, 246),  # T4
	Vector2(576, 246),  # T5
	Vector2(936, 246),  # T6
]
const ENTRANCE_POSITION: Vector2 = Vector2(626, 326)

@export var customer_scene: PackedScene
var customers_layer: Control = null  # Main에서 주입

var occupied_tables: int = 0
var max_tables: int = 6
var seeking_queue: Array = []
var table_occupants: Array = [null, null, null, null, null, null]

var _spawn_timer: float = 0.0
var _spawn_interval: float = 5.0

func _ready() -> void:
	max_tables = min(GameState.table_count, TABLE_POSITIONS.size())
	TimeSystem.hour_passed.connect(_on_hour_passed)
	TimeSystem.day_opened.connect(_on_day_opened)

func _on_day_opened(_day: int) -> void:
	occupied_tables = 0
	seeking_queue.clear()
	table_occupants = [null, null, null, null, null, null]
	_recalc_spawn_interval()

func _on_hour_passed(_h: int) -> void:
	_recalc_spawn_interval()

func _recalc_spawn_interval() -> void:
	var region_id = GameState.current_region
	var base = Regions.get_base_customers_per_hour(region_id)
	var multiplier = Regions.get_hour_traffic_multiplier(region_id, TimeSystem.current_hour)

	var rep_mul = clamp(GameState.reputation / 50.0, 0.3, 2.0)

	var mkt_mul = 1.0
	if GameState.marketing_flags.get("instagram_ad", false):
		mkt_mul *= 1.2
	if GameState.marketing_flags.get("delivery_app", false):
		mkt_mul *= 1.15

	if GameState.is_strategy_active("instagram_marketing"):
		mkt_mul *= 1.3

	var per_hour = base * multiplier * rep_mul * mkt_mul
	if per_hour < 0.1:
		per_hour = 0.1

	var per_real_second = per_hour / TimeSystem.REAL_SECONDS_PER_HOUR
	if per_real_second <= 0:
		_spawn_interval = 999.0
	else:
		_spawn_interval = 1.0 / per_real_second

func _process(delta: float) -> void:
	if not TimeSystem.is_running or TimeSystem.is_paused:
		return
	_spawn_timer += delta
	if _spawn_timer >= _spawn_interval:
		_spawn_timer = 0.0
		_try_spawn()
	_process_seeking()

func _try_spawn() -> void:
	var demo = Regions.pick_customer_demographic(GameState.current_region)
	var type_int: int = Customer.Type.STUDENT
	match demo:
		"STUDENT": type_int = Customer.Type.STUDENT
		"OFFICE_WORKER": type_int = Customer.Type.OFFICE_WORKER
		"FAMILY": type_int = Customer.Type.FAMILY
		"ELDERLY": type_int = Customer.Type.ELDERLY

	var c: Customer
	if customer_scene:
		c = customer_scene.instantiate()
	else:
		c = Customer.new()

	# 평판 너무 낮으면 안 들어옴
	if GameState.reputation < 20.0 and randf() < 0.5:
		c.queue_free()
		return

	c.setup(type_int)
	# 입구 위치에서 시작
	c.position = ENTRANCE_POSITION
	# 손님을 게임 화면 레이어에 추가 (없으면 fallback)
	if customers_layer:
		customers_layer.add_child(c)
	else:
		add_child(c)
	c.departed.connect(_on_customer_departed.bind(c))

	customer_spawned.emit(c)
	c.change_state(Customer.State.SEEKING_TABLE)
	seeking_queue.append(c)

func _process_seeking() -> void:
	while not seeking_queue.is_empty() and occupied_tables < max_tables:
		var c = seeking_queue.pop_front()
		if not is_instance_valid(c):
			continue
		# 빈 테이블 찾기
		var idx = _find_free_table()
		if idx < 0:
			seeking_queue.push_front(c)
			break
		table_occupants[idx] = c
		c.assigned_table_index = idx
		occupied_tables += 1
		# 테이블로 이동 → 도착 후 주문
		var target = TABLE_POSITIONS[idx]
		c.move_to(target, 0.8)
		# 도착 후 주문 시작
		var t = c.create_tween()
		t.tween_interval(0.85)
		t.tween_callback(func():
			if is_instance_valid(c):
				c.seat_at_table()
		)

func _find_free_table() -> int:
	for i in range(max_tables):
		if table_occupants[i] == null:
			return i
	return -1

func _on_customer_departed(_satisfied: bool, c: Customer) -> void:
	if c.assigned_table_index >= 0 and c.assigned_table_index < table_occupants.size():
		if table_occupants[c.assigned_table_index] == c:
			table_occupants[c.assigned_table_index] = null
	occupied_tables = max(0, occupied_tables - 1)

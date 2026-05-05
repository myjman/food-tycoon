extends Node
# 메인 게임 씬 컨트롤러

@onready var money_label: Label = $UI/TopBar/HBox/MoneyLabel
@onready var time_label: Label = $UI/TopBar/HBox/TimeLabel
@onready var rep_label: Label = $UI/TopBar/HBox/ReputationLabel
@onready var day_label: Label = $UI/TopBar/HBox/DayLabel
@onready var region_label: Label = $UI/TopBar/HBox/RegionLabel
@onready var customer_count_label: Label = $UI/TopBar/HBox/CustomerCountLabel
@onready var pause_button: Button = $UI/TopBar/HBox/PauseButton

@onready var status_log: RichTextLabel = $UI/CenterArea/StatusLog
@onready var spawner: CustomerSpawner = $Spawner
@onready var customers_layer: Control = $UI/CenterArea/GameView/CustomersLayer
@onready var staff_container: HBoxContainer = $UI/CenterArea/GameView/Kitchen/StaffContainer

# 패널들 (열고 닫는 식)
@onready var menu_panel: Control = $UI/Panels/MenuManager
@onready var staff_panel: Control = $UI/Panels/StaffManager
@onready var strategy_panel: Control = $UI/Panels/StrategyPanel
@onready var day_end_panel: Control = $UI/Panels/DayEndReport
@onready var region_panel: Control = $UI/Panels/RegionTransfer

func _ready() -> void:
	_connect_signals()
	_close_all_panels()
	_refresh_top_bar()
	# Spawner에 customers_layer 주입
	spawner.customers_layer = customers_layer
	_refresh_staff_visuals()
	# 시작 시 자동저장 있으면 로드 시도
	if SaveSystem.has_save():
		pass
	_log("[color=#88ff88]환영합니다! 노원/상계에서 작은 가게를 시작합니다.[/color]")
	_log("자금 500만원, 김알바(신입) 1명, 분식 메뉴(김밥/떡볶이/라면) 활성화.")
	# 자동 시작
	Restaurant.start_new_day()
	_log("Day 1 시작! 9:00 가게 오픈.")

func _refresh_staff_visuals() -> void:
	if not staff_container:
		return
	for ch in staff_container.get_children():
		ch.queue_free()
	for s in GameState.staff_list:
		var box = VBoxContainer.new()
		var rect = ColorRect.new()
		rect.custom_minimum_size = Vector2(36, 30)
		rect.color = _staff_color(s.level)
		var lbl = Label.new()
		lbl.text = s.name
		lbl.add_theme_font_size_override("font_size", 10)
		box.add_child(rect)
		box.add_child(lbl)
		staff_container.add_child(box)

func _staff_color(level: int) -> Color:
	match level:
		0: return Color(0.85, 0.65, 0.35)  # 신입 (베이지)
		1: return Color(0.40, 0.75, 0.85)  # 경험 (하늘)
		2: return Color(0.95, 0.40, 0.35)  # 셰프 (빨강)
	return Color.WHITE

func _connect_signals() -> void:
	GameState.money_changed.connect(_on_money_changed)
	GameState.reputation_changed.connect(_on_reputation_changed)
	GameState.staff_list_changed.connect(_refresh_staff_visuals)
	TimeSystem.hour_passed.connect(_on_hour_passed)
	TimeSystem.day_opened.connect(_on_day_opened)
	TimeSystem.day_closed.connect(_on_day_closed)
	pause_button.pressed.connect(_on_pause_pressed)

	$UI/BottomBar/HBox/MenuButton.pressed.connect(func(): _toggle_panel(menu_panel))
	$UI/BottomBar/HBox/StaffButton.pressed.connect(func(): _toggle_panel(staff_panel))
	$UI/BottomBar/HBox/StrategyButton.pressed.connect(func(): _toggle_panel(strategy_panel))
	$UI/BottomBar/HBox/RegionButton.pressed.connect(func(): _toggle_panel(region_panel))
	$UI/BottomBar/HBox/SaveButton.pressed.connect(_on_save_pressed)

	spawner.customer_spawned.connect(_on_customer_spawned)

func _process(_delta: float) -> void:
	time_label.text = "⏰ " + TimeSystem.get_time_string()
	customer_count_label.text = "👥 " + str(GameState.daily_customer_count)

func _refresh_top_bar() -> void:
	money_label.text = "💰 " + _format_money(GameState.money)
	rep_label.text = "⭐ %.1f" % GameState.get_star_rating()
	day_label.text = "Day " + str(GameState.current_day)
	var region = Regions.get_region(GameState.current_region)
	region_label.text = "📍 " + String(region.get("name", "?"))

func _on_money_changed(_amount: int) -> void:
	money_label.text = "💰 " + _format_money(GameState.money)

func _on_reputation_changed(_rep: int) -> void:
	rep_label.text = "⭐ %.1f" % GameState.get_star_rating()

func _on_hour_passed(h: int) -> void:
	if h == 12:
		_log("🍽 점심시간! 손님이 몰립니다.")
	elif h == 18:
		_log("🌆 저녁시간 시작.")
	elif h == 21:
		_log("🌃 마감 1시간 전.")

func _on_day_opened(d: int) -> void:
	_refresh_top_bar()
	_log("[color=#88ddff]=== Day %d 영업 시작 ===[/color]" % d)

func _on_day_closed(d: int) -> void:
	_log("[color=#ffaaaa]=== Day %d 마감 ===[/color]" % d)
	var report = Restaurant.close_day_and_settle()
	_show_day_end_report(report)

func _on_customer_spawned(c: Customer) -> void:
	c.departed.connect(func(satisfied):
		var emoji = "😊" if satisfied else "😡"
		_log("%s %s 손님 (%s 주문) 떠남" % [emoji, c.get_type_name(), _menu_name(c.ordered_menu)])
	)

func _menu_name(id: String) -> String:
	if id.is_empty():
		return "주문 없음"
	var m = Menus.get_menu(id)
	return String(m.get("name", id))

func _on_pause_pressed() -> void:
	TimeSystem.pause(not TimeSystem.is_paused)
	pause_button.text = "▶" if TimeSystem.is_paused else "⏸"

func _on_save_pressed() -> void:
	if SaveSystem.save_game():
		_log("💾 게임 저장 완료")
	else:
		_log("[color=red]저장 실패[/color]")

func _toggle_panel(panel: Control) -> void:
	var was_visible = panel.visible
	_close_all_panels()
	panel.visible = not was_visible
	if panel.visible and panel.has_method("refresh"):
		panel.refresh()
	# 패널 열려있으면 일시정지
	TimeSystem.pause(panel.visible)
	pause_button.text = "▶" if TimeSystem.is_paused else "⏸"

func _close_all_panels() -> void:
	for p in [menu_panel, staff_panel, strategy_panel, day_end_panel, region_panel]:
		if p:
			p.visible = false

func _show_day_end_report(report: Dictionary) -> void:
	_close_all_panels()
	day_end_panel.visible = true
	if day_end_panel.has_method("show_report"):
		day_end_panel.show_report(report)
	TimeSystem.pause(true)

func _log(text: String) -> void:
	status_log.append_text(text + "\n")

func _format_money(amount: int) -> String:
	# 1,234,567 형식
	var s = str(abs(amount))
	var out = ""
	var c = 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	if amount < 0:
		out = "-" + out
	return out + "원"

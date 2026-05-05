extends Control
# 전략 카드 패널 (기획서 7.4)

@onready var active_list: VBoxContainer = $Margin/VBox/Scroll/Content/ActiveList
@onready var available_list: VBoxContainer = $Margin/VBox/Scroll/Content/AvailableList
@onready var marketing_list: VBoxContainer = $Margin/VBox/Scroll/Content/MarketingList
@onready var close_btn: Button = $Margin/VBox/Header/CloseButton

func _ready() -> void:
	close_btn.pressed.connect(func(): visible = false)

func refresh() -> void:
	for c in active_list.get_children(): c.queue_free()
	for c in available_list.get_children(): c.queue_free()
	for c in marketing_list.get_children(): c.queue_free()

	# 활성 전략
	for id in GameState.active_strategies.keys():
		var s = Strategies.get_strategy(id)
		var lbl = Label.new()
		lbl.text = "✓ %s — %d일 남음" % [s.name, GameState.active_strategies[id]]
		lbl.modulate = Color(0.7, 1.0, 0.7)
		active_list.add_child(lbl)
	if GameState.active_strategies.is_empty():
		var none = Label.new()
		none.text = "(활성 전략 없음)"
		none.modulate = Color(0.6, 0.6, 0.6)
		active_list.add_child(none)

	# 사용 가능 전략
	for id in Strategies.get_all_ids():
		if GameState.active_strategies.has(id):
			continue
		available_list.add_child(_make_strategy_row(id))

	# 마케팅 토글
	for key in [{"id": "instagram_ad", "name": "인스타 광고", "desc": "월 50만원, 손님 +20%"},
				{"id": "blog_review", "name": "블로그 체험단 (단발)", "desc": "100만원, 평판 +5"},
				{"id": "delivery_app", "name": "배달앱 입점", "desc": "월 50만원, 새 고객층 +15%"}]:
		marketing_list.add_child(_make_marketing_row(key))

func _make_strategy_row(id: String) -> Control:
	var s = Strategies.get_strategy(id)
	var box = VBoxContainer.new()
	box.size_flags_horizontal = SIZE_EXPAND_FILL

	var top = HBoxContainer.new()
	var name_lbl = Label.new()
	name_lbl.text = "🎯 " + String(s.name)
	name_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
	top.add_child(name_lbl)

	var btn = Button.new()
	if int(s.cost) > 0:
		btn.text = "활성화 (%s원)" % _format(int(s.cost))
	else:
		btn.text = "활성화 (무료)"
	btn.pressed.connect(func():
		if GameState.activate_strategy(id):
			refresh()
	)
	top.add_child(btn)

	box.add_child(top)

	var desc = Label.new()
	desc.text = String(s.description)
	desc.modulate = Color(0.7, 0.7, 0.7)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(desc)

	var sep = HSeparator.new()
	box.add_child(sep)
	return box

func _make_marketing_row(info: Dictionary) -> Control:
	var box = HBoxContainer.new()
	box.size_flags_horizontal = SIZE_EXPAND_FILL

	var lbl = Label.new()
	lbl.text = "%s — %s" % [info.name, info.desc]
	lbl.size_flags_horizontal = SIZE_EXPAND_FILL
	box.add_child(lbl)

	var key = String(info.id)
	if key == "blog_review":
		# 단발성: 활성화 버튼
		var btn = Button.new()
		btn.text = "실행 (1,000,000원)"
		btn.pressed.connect(func():
			if GameState.spend_money(1000000):
				GameState.boost_reputation(5.0)
				refresh()
		)
		box.add_child(btn)
	else:
		var toggle = CheckBox.new()
		toggle.button_pressed = GameState.marketing_flags.get(key, false)
		toggle.toggled.connect(func(_p): GameState.toggle_marketing(key))
		box.add_child(toggle)
	return box

func _format(n: int) -> String:
	var s = str(abs(n))
	var out = ""
	var c = 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return out

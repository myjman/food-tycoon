extends Control
# 메뉴 관리 패널 (기획서 7.2)

@onready var unlocked_list: VBoxContainer = $Margin/VBox/Scroll/Content/UnlockedList
@onready var locked_list: VBoxContainer = $Margin/VBox/Scroll/Content/LockedList
@onready var close_btn: Button = $Margin/VBox/Header/CloseButton

func _ready() -> void:
	close_btn.pressed.connect(func(): visible = false)

func refresh() -> void:
	# 기존 항목 삭제
	for c in unlocked_list.get_children():
		c.queue_free()
	for c in locked_list.get_children():
		c.queue_free()

	for menu_id in Menus.get_all_ids():
		if GameState.menu_unlocked.has(menu_id):
			unlocked_list.add_child(_make_menu_row(menu_id, true))
		else:
			locked_list.add_child(_make_menu_row(menu_id, false))

func _make_menu_row(menu_id: String, unlocked: bool) -> Control:
	var menu = Menus.get_menu(menu_id)
	var box = HBoxContainer.new()
	box.size_flags_horizontal = SIZE_EXPAND_FILL

	var name_label = Label.new()
	name_label.text = String(menu.name)
	name_label.custom_minimum_size = Vector2(120, 0)
	box.add_child(name_label)

	if unlocked:
		# 가격 (편집 가능)
		var price_spin = SpinBox.new()
		price_spin.min_value = 1000
		price_spin.max_value = 100000
		price_spin.step = 500
		price_spin.value = GameState.get_menu_price(menu_id)
		price_spin.custom_minimum_size = Vector2(120, 0)
		price_spin.value_changed.connect(func(v): GameState.set_menu_price(menu_id, int(v)))
		box.add_child(price_spin)

		# 활성/비활성 토글
		var toggle = CheckBox.new()
		toggle.text = "판매중"
		toggle.button_pressed = GameState.menu_active.has(menu_id)
		toggle.toggled.connect(func(_p): GameState.toggle_menu_active(menu_id))
		box.add_child(toggle)

		# 카테고리 표시
		var cat_label = Label.new()
		cat_label.text = "[%s]" % _category_name(String(menu.category))
		cat_label.modulate = Color(0.7, 0.7, 0.7)
		box.add_child(cat_label)

		# 알바 등급 필요
		var lvl_label = Label.new()
		lvl_label.text = "Lv.%d 필요" % int(menu.required_staff_level)
		lvl_label.modulate = Color(0.6, 0.6, 1.0)
		box.add_child(lvl_label)
	else:
		# 잠금 사유
		var reason = Label.new()
		var rep_required = Menus.REPUTATION_LOCKS.get(menu_id, 0)
		if rep_required > 0:
			reason.text = "🔒 평판 %d 필요 (현재 %.0f)" % [rep_required, GameState.reputation]
		else:
			reason.text = "🔒 잠금"
		reason.modulate = Color(0.7, 0.7, 0.7)
		box.add_child(reason)

	return box

func _category_name(cat: String) -> String:
	match cat:
		"snack": return "분식"
		"korean": return "한식"
		"western": return "양식"
		"dessert": return "디저트"
	return cat

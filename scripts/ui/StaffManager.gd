extends Control
# 알바 관리 패널 (기획서 7.3)

@onready var current_list: VBoxContainer = $Margin/VBox/Scroll/Content/CurrentList
@onready var hire_list: VBoxContainer = $Margin/VBox/Scroll/Content/HireList
@onready var close_btn: Button = $Margin/VBox/Header/CloseButton

func _ready() -> void:
	close_btn.pressed.connect(func(): visible = false)

func refresh() -> void:
	for c in current_list.get_children():
		c.queue_free()
	for c in hire_list.get_children():
		c.queue_free()

	# 현재 알바
	for i in range(GameState.staff_list.size()):
		current_list.add_child(_make_current_row(GameState.staff_list[i], i))

	# 채용 가능
	for level in [Staff.Level.ROOKIE, Staff.Level.EXPERIENCED, Staff.Level.CHEF]:
		hire_list.add_child(_make_hire_row(level))

func _make_current_row(staff: Staff, index: int) -> Control:
	var box = HBoxContainer.new()
	box.size_flags_horizontal = SIZE_EXPAND_FILL

	var info = Label.new()
	var wage_str = ""
	if staff.monthly_salary > 0:
		wage_str = "월 %s원" % _format(staff.monthly_salary)
	else:
		wage_str = "시급 %s원" % _format(staff.hourly_wage)
	info.text = "%s %s (%s) | %s" % [_emoji_for(staff.level), staff.name, staff.get_level_name(), wage_str]
	info.size_flags_horizontal = SIZE_EXPAND_FILL
	box.add_child(info)

	var fire_btn = Button.new()
	fire_btn.text = "해고"
	fire_btn.pressed.connect(func():
		GameState.fire_staff(index)
		refresh()
	)
	box.add_child(fire_btn)
	return box

func _make_hire_row(level: int) -> Control:
	var staff = Staff.new(level, _gen_random_name())
	var box = HBoxContainer.new()
	box.size_flags_horizontal = SIZE_EXPAND_FILL

	var info = Label.new()
	var wage_str = ""
	if staff.monthly_salary > 0:
		wage_str = "월급 %s원" % _format(staff.monthly_salary)
	else:
		wage_str = "시급 %s원" % _format(staff.hourly_wage)
	info.text = "%s %s | %s | 가능: %s" % [
		_emoji_for(level),
		staff.get_level_name(),
		wage_str,
		", ".join(staff.allowed_categories.map(func(c): return _category_name(c)))
	]
	info.size_flags_horizontal = SIZE_EXPAND_FILL
	box.add_child(info)

	var hire_cost = staff.get_hire_cost()
	var hire_btn = Button.new()
	if hire_cost > 0:
		hire_btn.text = "채용 (%s원)" % _format(hire_cost)
	else:
		hire_btn.text = "채용 (무료)"
	hire_btn.pressed.connect(func():
		var new_staff = Staff.new(level, _gen_random_name())
		var cost = new_staff.get_hire_cost()
		if cost > 0 and not GameState.spend_money(cost):
			return
		GameState.hire_staff(new_staff)
		refresh()
	)
	box.add_child(hire_btn)
	return box

func _emoji_for(level: int) -> String:
	match level:
		Staff.Level.ROOKIE: return "👶"
		Staff.Level.EXPERIENCED: return "🧑‍🍳"
		Staff.Level.CHEF: return "👨‍🍳"
	return "?"

func _category_name(cat: String) -> String:
	match cat:
		"snack": return "분식"
		"korean": return "한식"
		"western": return "양식"
		"dessert": return "디저트"
	return cat

const NAMES = ["김알바", "이학생", "박경험", "최셰프", "정아르", "강민수", "윤주방", "한주임"]
func _gen_random_name() -> String:
	return NAMES[randi() % NAMES.size()]

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

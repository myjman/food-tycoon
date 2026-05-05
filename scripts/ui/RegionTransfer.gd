extends Control
# 지역 이전 패널 (기획서 7.6)

@onready var current_label: Label = $Margin/VBox/CurrentLabel
@onready var region_list: VBoxContainer = $Margin/VBox/Scroll/Content/RegionList
@onready var close_btn: Button = $Margin/VBox/Header/CloseButton

func _ready() -> void:
	close_btn.pressed.connect(func(): visible = false)

func refresh() -> void:
	var current = Regions.get_region(GameState.current_region)
	current_label.text = "현재: %s (월세 %s원/월)" % [current.name, _format(int(current.rent_per_month))]

	for c in region_list.get_children():
		c.queue_free()

	for region_id in Regions.get_all_ids():
		if region_id == GameState.current_region:
			continue
		region_list.add_child(_make_region_row(region_id))

func _make_region_row(region_id: String) -> Control:
	var r = Regions.get_region(region_id)
	var box = VBoxContainer.new()
	box.size_flags_horizontal = SIZE_EXPAND_FILL

	var name_lbl = Label.new()
	name_lbl.text = "🏪 " + String(r.name) + "  (" + String(r.type) + ")"
	name_lbl.add_theme_font_size_override("font_size", 18)
	box.add_child(name_lbl)

	var info = Label.new()
	info.text = "유동인구: %s | 객단가: %s원 | 월세: %s원/월" % [
		_format(int(r.floating_population)),
		_format(int(r.avg_spending)),
		_format(int(r.rent_per_month))
	]
	box.add_child(info)

	var desc = Label.new()
	desc.text = String(r.description)
	desc.modulate = Color(0.8, 0.8, 0.8)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(desc)

	var bottom = HBoxContainer.new()
	var cost_lbl = Label.new()
	cost_lbl.text = "이전 비용: %s원" % _format(int(r.transfer_cost))
	cost_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
	bottom.add_child(cost_lbl)

	var btn = Button.new()
	var rep_required = float(r.reputation_required)
	if GameState.reputation < rep_required:
		btn.text = "🔒 평판 %d 필요" % int(rep_required)
		btn.disabled = true
	elif GameState.money < int(r.transfer_cost):
		btn.text = "자금 부족"
		btn.disabled = true
	else:
		btn.text = "이전"
		btn.pressed.connect(func(): _transfer_to(region_id))
	bottom.add_child(btn)

	box.add_child(bottom)

	var sep = HSeparator.new()
	box.add_child(sep)
	return box

func _transfer_to(region_id: String) -> void:
	var r = Regions.get_region(region_id)
	if not GameState.spend_money(int(r.transfer_cost)):
		return
	GameState.current_region = region_id
	refresh()
	GameState.region_changed.emit(region_id)
	visible = false

func _format(n: int) -> String:
	var s = str(abs(n))
	var out = ""
	var c = 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	if n < 0:
		out = "-" + out
	return out

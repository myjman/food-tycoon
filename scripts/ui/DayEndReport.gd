extends Control
# 일일 정산 화면 (기획서 7.5)

@onready var content: RichTextLabel = $Margin/VBox/Content
@onready var next_btn: Button = $Margin/VBox/NextDayButton

func _ready() -> void:
	next_btn.pressed.connect(_on_next_day)

func show_report(report: Dictionary) -> void:
	visible = true
	var rev = int(report.get("revenue", 0))
	var costs: Dictionary = report.get("cost_breakdown", {})
	var ingredient = int(costs.get("ingredient", 0))
	var staff_c = int(costs.get("staff", 0))
	var marketing_c = int(costs.get("marketing", 0))
	var rent_c = int(costs.get("rent", 0))
	var net = int(report.get("net_profit", 0))
	var customers = int(report.get("customer_count", 0))
	var avg = 0
	if customers > 0:
		avg = int(rev / float(customers))
	var stars = float(report.get("star_rating", 3.0))
	var regulars = int(report.get("regulars_count", 0))

	var text = "[center][b]Day %d 마감[/b][/center]\n\n" % int(report.get("day", 0))
	text += "[b]=== 오늘의 매출 ===[/b]\n"
	text += "총 매출: [color=green]+%s원[/color]\n" % _format(rev)
	text += "손님 수: %d명\n" % customers
	text += "평균 객단가: %s원\n\n" % _format(avg)
	text += "[b]=== 오늘의 비용 ===[/b]\n"
	text += "재료비: [color=red]-%s원[/color]\n" % _format(ingredient)
	text += "알바 인건비: [color=red]-%s원[/color]\n" % _format(staff_c)
	text += "마케팅: [color=red]-%s원[/color]\n" % _format(marketing_c)
	text += "월세 (1/30): [color=red]-%s원[/color]\n\n" % _format(rent_c)
	text += "[b]=== 순이익 ===[/b]\n"
	var net_color = "green" if net >= 0 else "red"
	text += "💰 [color=%s]%s%s원[/color]\n\n" % [net_color, ("+" if net >= 0 else ""), _format(net)]
	text += "[b]=== 평판 ===[/b]\n"
	text += "⭐ %.1f / 5.0\n" % stars
	text += "단골: %d명\n" % regulars
	content.text = text

func _on_next_day() -> void:
	visible = false
	Restaurant.start_new_day()

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

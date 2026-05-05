extends RefCounted
class_name Staff

# 알바 (기획서 6.5)
# Level: 0 = ROOKIE / 1 = EXPERIENCED / 2 = CHEF
enum Level { ROOKIE, EXPERIENCED, CHEF }

var name: String = "알바"
var level: int = Level.ROOKIE
var hourly_wage: int = 0
var monthly_salary: int = 0
var cooking_speed_multiplier: float = 1.0
var allowed_categories: Array = []

func _init(staff_level: int = Level.ROOKIE, staff_name: String = "알바") -> void:
	level = staff_level
	name = staff_name
	match level:
		Level.ROOKIE:
			hourly_wage = 9860  # 2026 최저시급
			cooking_speed_multiplier = 0.8
			allowed_categories = ["snack"]
		Level.EXPERIENCED:
			hourly_wage = 12000
			cooking_speed_multiplier = 1.0
			allowed_categories = ["snack", "korean", "western"]
		Level.CHEF:
			hourly_wage = 0
			monthly_salary = 2500000
			cooking_speed_multiplier = 1.5
			allowed_categories = ["snack", "korean", "western", "dessert"]

func get_level_name() -> String:
	match level:
		Level.ROOKIE: return "신입"
		Level.EXPERIENCED: return "경험"
		Level.CHEF: return "셰프"
	return "?"

func can_cook(menu_id: String) -> bool:
	var menu = Menus.get_menu(menu_id)
	if menu.is_empty():
		return false
	return allowed_categories.has(menu.category)

# 채용 비용 (즉시 차감되는 채용 수수료)
func get_hire_cost() -> int:
	match level:
		Level.ROOKIE: return 0
		Level.EXPERIENCED: return 200000
		Level.CHEF: return 1000000
	return 0

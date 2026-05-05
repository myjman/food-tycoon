extends Node
class_name Menus

# 메뉴 데이터 (정적 상수)
# 기획서 6.3 참조
# category: snack(분식) / korean(한식) / western(양식) / dessert(디저트/카페)
# required_staff_level: 1(신입+) / 2(경험+) / 3(셰프 필수)
# popularity_by_region: 지역별 인기 배수 (1.0 기준)

const DATA = {
	"kimbap": {
		"name": "김밥",
		"category": "snack",
		"base_price": 4000,
		"cooking_time": 30,
		"ingredient_cost_ratio": 0.30,
		"required_staff_level": 1,
		"popularity_by_region": {"nowon": 1.2, "sinchon": 1.5, "gangnam": 0.8},
		"description": "한국 분식의 기본. 빠르고 가성비 좋음."
	},
	"tteokbokki": {
		"name": "떡볶이",
		"category": "snack",
		"base_price": 5000,
		"cooking_time": 60,
		"ingredient_cost_ratio": 0.25,
		"required_staff_level": 1,
		"popularity_by_region": {"nowon": 1.0, "sinchon": 1.8, "gangnam": 0.5},
		"description": "학생들이 환장하는 매콤달콤."
	},
	"ramen": {
		"name": "라면",
		"category": "snack",
		"base_price": 4500,
		"cooking_time": 45,
		"ingredient_cost_ratio": 0.20,
		"required_staff_level": 1,
		"popularity_by_region": {"nowon": 1.1, "sinchon": 1.3, "gangnam": 0.6},
		"description": "끓이기만 하면 끝. 마진 최강."
	},
	"kimchi_jjigae": {
		"name": "김치찌개",
		"category": "korean",
		"base_price": 9000,
		"cooking_time": 180,
		"ingredient_cost_ratio": 0.30,
		"required_staff_level": 2,
		"popularity_by_region": {"nowon": 1.3, "sinchon": 0.9, "gangnam": 1.4},
		"description": "직장인 점심의 영원한 친구."
	},
	"doenjang_jjigae": {
		"name": "된장찌개",
		"category": "korean",
		"base_price": 8500,
		"cooking_time": 200,
		"ingredient_cost_ratio": 0.28,
		"required_staff_level": 2,
		"popularity_by_region": {"nowon": 1.4, "sinchon": 0.8, "gangnam": 1.2},
		"description": "어르신과 가족 단골이 좋아함."
	},
	"bibimbap": {
		"name": "비빔밥",
		"category": "korean",
		"base_price": 10000,
		"cooking_time": 150,
		"ingredient_cost_ratio": 0.32,
		"required_staff_level": 2,
		"popularity_by_region": {"nowon": 1.0, "sinchon": 0.9, "gangnam": 1.3},
		"description": "건강식 이미지. 외국인도 환영."
	},
	"burger": {
		"name": "수제버거",
		"category": "western",
		"base_price": 12000,
		"cooking_time": 240,
		"ingredient_cost_ratio": 0.35,
		"required_staff_level": 2,
		"popularity_by_region": {"nowon": 0.8, "sinchon": 1.5, "gangnam": 1.3},
		"description": "젊은층 인기 메뉴. 재료비 부담은 있음."
	},
	"pasta": {
		"name": "파스타",
		"category": "western",
		"base_price": 15000,
		"cooking_time": 300,
		"ingredient_cost_ratio": 0.30,
		"required_staff_level": 3,
		"popularity_by_region": {"nowon": 0.5, "sinchon": 1.2, "gangnam": 1.6},
		"description": "셰프 필수. 객단가 ↑."
	},
	"americano": {
		"name": "아메리카노",
		"category": "dessert",
		"base_price": 4500,
		"cooking_time": 30,
		"ingredient_cost_ratio": 0.15,
		"required_staff_level": 1,
		"popularity_by_region": {"nowon": 0.9, "sinchon": 1.3, "gangnam": 1.5},
		"description": "직장인 필수템. 마진 최고."
	},
	"cake": {
		"name": "케이크",
		"category": "dessert",
		"base_price": 7000,
		"cooking_time": 60,
		"ingredient_cost_ratio": 0.40,
		"required_staff_level": 3,
		"popularity_by_region": {"nowon": 0.8, "sinchon": 1.2, "gangnam": 1.4},
		"description": "셰프 필요. 디저트 카페 분위기 +."
	}
}

# 시작 시 잠금 해제된 메뉴
const STARTING_UNLOCKED = ["kimbap", "tteokbokki", "ramen"]

# 평판 잠금 조건 (특정 메뉴는 평판으로 잠금 해제)
const REPUTATION_LOCKS = {
	"bibimbap": 60,
	"pasta": 70,
	"cake": 75
}

static func get_menu(id: String) -> Dictionary:
	return DATA.get(id, {})

static func get_all_ids() -> Array:
	return DATA.keys()

# 지역별 가격 보정 (지역 객단가 영향)
static func get_effective_price(menu_id: String, region_id: String) -> int:
	var menu = DATA.get(menu_id, {})
	if menu.is_empty():
		return 0
	return int(menu.base_price)

# 메뉴 만들 수 있는지 (알바 등급 체크)
static func can_be_cooked_by_level(menu_id: String, staff_level: int) -> bool:
	var menu = DATA.get(menu_id, {})
	if menu.is_empty():
		return false
	return staff_level >= menu.required_staff_level

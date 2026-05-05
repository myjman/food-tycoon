extends Node
class_name Regions

# 지역 데이터 (정적 상수)
# 기획서 6.2 참조

const DATA = {
	"nowon": {
		"name": "노원/상계",
		"type": "주택가",
		"floating_population": 15000,
		"peak_hours": [12, 13, 18, 19, 20],
		"demographics": {
			"family": 0.50,
			"elderly": 0.30,
			"student": 0.15,
			"office_worker": 0.05
		},
		"avg_spending": 8000,
		"rent_per_month": 500000,
		"popular_menus": ["kimbap", "ramen", "kimchi_jjigae", "doenjang_jjigae"],
		"unpopular_menus": ["pasta"],
		"competition": 45,
		"transfer_cost": 0,  # 시작 지역
		"reputation_required": 0,
		"description": "조용한 주택가. 단골 위주로 안정적이지만 매출 한계."
	},
	"sinchon": {
		"name": "신촌/이대",
		"type": "대학가",
		"floating_population": 50000,
		"peak_hours": [12, 13, 19, 20, 21, 22],
		"demographics": {
			"student": 0.75,
			"office_worker": 0.15,
			"family": 0.10
		},
		"avg_spending": 8000,
		"rent_per_month": 3500000,
		"popular_menus": ["tteokbokki", "kimbap", "ramen", "burger"],
		"unpopular_menus": [],
		"competition": 142,
		"special_events": {
			"exam_period": -0.4,
			"vacation": -0.6
		},
		"transfer_cost": 5000000,
		"reputation_required": 50,
		"description": "20대 학생 비율 75%. 가성비 핵심."
	},
	"gangnam": {
		"name": "강남역",
		"type": "사무실/번화가",
		"floating_population": 460000,
		"peak_hours": [12, 13, 18, 19, 20],
		"demographics": {
			"office_worker": 0.55,
			"young_adult": 0.30,
			"tourist": 0.15
		},
		"avg_spending": 18000,
		"rent_per_month": 15000000,
		"popular_menus": ["kimchi_jjigae", "bibimbap", "pasta", "burger", "americano"],
		"unpopular_menus": [],
		"competition": 350,
		"peak_multiplier": 3.0,
		"transfer_cost": 30000000,
		"reputation_required": 70,
		"description": "직장인 객단가 높음. 점심+저녁 회식 폭증."
	}
}

# young_adult / tourist 같은 직군은 office_worker로 매핑 (MVP 단순화)
const DEMOGRAPHIC_TO_CUSTOMER_TYPE = {
	"family": "FAMILY",
	"elderly": "ELDERLY",
	"student": "STUDENT",
	"office_worker": "OFFICE_WORKER",
	"young_adult": "OFFICE_WORKER",
	"tourist": "OFFICE_WORKER"
}

static func get_region(id: String) -> Dictionary:
	return DATA.get(id, {})

static func get_all_ids() -> Array:
	return DATA.keys()

# 지역별 손님 종류 가중 랜덤 추출
static func pick_customer_demographic(region_id: String) -> String:
	var region = DATA.get(region_id, {})
	if region.is_empty():
		return "STUDENT"
	var demos = region.get("demographics", {})
	var roll = randf()
	var acc = 0.0
	for key in demos.keys():
		acc += demos[key]
		if roll <= acc:
			return DEMOGRAPHIC_TO_CUSTOMER_TYPE.get(key, "STUDENT")
	return "STUDENT"

# 시간대별 손님 빈도 배수 (피크 vs 비피크)
static func get_hour_traffic_multiplier(region_id: String, hour: int) -> float:
	var region = DATA.get(region_id, {})
	if region.is_empty():
		return 1.0
	var peaks = region.get("peak_hours", [])
	if hour in peaks:
		return float(region.get("peak_multiplier", 2.0))
	return 1.0

# 시간당 기본 손님 수 (유동인구 기반)
static func get_base_customers_per_hour(region_id: String) -> float:
	var region = DATA.get(region_id, {})
	if region.is_empty():
		return 5.0
	# 유동인구의 0.04% 정도가 한 시간에 가게로 들어옴 (밸런싱 변수)
	return float(region.floating_population) * 0.0004

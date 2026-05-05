extends Node
class_name Strategies

# 전략 카드 데이터 (기획서 6.6)
# duration: 일 단위 (1 = 오늘 하루만)
# cost: 활성화 즉시 차감되는 비용 (원)

const DATA = {
	"lunch_discount": {
		"name": "점심 할인",
		"description": "11:30-13:30 동안 모든 메뉴 20% 할인",
		"active_hours": [11, 12, 13],
		"effects": {
			"price_multiplier": 0.8,
			"office_worker_attraction": 1.3
		},
		"duration": 1,
		"cost": 0
	},
	"student_discount": {
		"name": "학생 할인",
		"description": "학생 손님에게 30% 할인. 학생 +50%",
		"active_hours": [],  # 종일
		"effects": {
			"price_multiplier_for_students": 0.7,
			"student_attraction": 1.5
		},
		"duration": 1,
		"cost": 0
	},
	"instagram_marketing": {
		"name": "인스타 마케팅",
		"description": "1주일간 SNS 광고. 젊은층 +30% / 바이럴 가능",
		"active_hours": [],
		"effects": {
			"young_attraction": 1.3,
			"viral_chance": 0.05
		},
		"duration": 7,
		"cost": 500000
	},
	"blog_review": {
		"name": "블로그 체험단",
		"description": "블로거 5명 초청. 평판 +10 (1회성)",
		"active_hours": [],
		"effects": {
			"reputation_boost": 10
		},
		"duration": 1,
		"cost": 1000000
	},
	"loyalty_coupon": {
		"name": "단골 쿠폰",
		"description": "단골 재방문률 ↑. 한 달간 적용",
		"active_hours": [],
		"effects": {
			"regular_chance": 1.5
		},
		"duration": 30,
		"cost": 0
	}
}

static func get_strategy(id: String) -> Dictionary:
	return DATA.get(id, {})

static func get_all_ids() -> Array:
	return DATA.keys()

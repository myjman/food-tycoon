# 한국식 음식 장사 타이쿤 - 게임 기획서 (GDD)

> **문서 목적**: Claude Code에 넘겨서 실제 개발을 시작하기 위한 정식 기획서
> **작성일**: 2026년 5월
> **버전**: MVP v0.1

---

## 📋 목차

1. [게임 개요](#1-게임-개요)
2. [기술 스택](#2-기술-스택)
3. [핵심 게임플레이 루프](#3-핵심-게임플레이-루프)
4. [MVP 범위 정의](#4-mvp-범위-정의)
5. [시스템 설계](#5-시스템-설계)
6. [데이터 구조](#6-데이터-구조)
7. [화면 구성 (와이어프레임)](#7-화면-구성)
8. [개발 마일스톤](#8-개발-마일스톤)
9. [확장 로드맵 (출시 후)](#9-확장-로드맵)
10. [Claude Code 작업 지시서](#10-claude-code-작업-지시서)

---

## 1. 게임 개요

### 1.1 한 줄 설명
**한국 자영업자의 현실을 담은 픽셀 아트 음식 장사 시뮬레이션 게임**

### 1.2 장르
- 매니지먼트 시뮬레이션 (Tycoon/Management)
- 픽셀 아트 (롤러코스터 타이쿤 1 영감)
- 전략 (Strategy)

### 1.3 타겟 유저
- **1차 타겟**: 자영업/창업에 관심 있는 한국 20-40대
- **2차 타겟**: 한국 콘텐츠를 좋아하는 글로벌 인디 게임 유저
- **참고 게임**: Cook Serve Delicious!, Game Dev Tycoon, 풍년상회

### 1.4 핵심 가치 제안 (Why this game?)

**다른 음식 타이쿤과 차별화되는 점**:

1. **한국 자영업의 현실 반영**
   - 유동인구별 월세 차등 시스템 (외국 게임에 없음)
   - 한국식 알바 문화 (시급, 4대보험, 시험기간 등)
   - 실제 서울 상권 데이터 기반

2. **지역 분석이 핵심 게임플레이**
   - 단순히 가게 짓는 게 아닌 "어디에, 누구에게, 무엇을 팔지" 결정
   - 같은 메뉴라도 지역에 따라 매출 천차만별

3. **AI 풍 분석 시스템**
   - 실제 데이터 기반으로 "AI가 분석한 것처럼" 보이는 시스템
   - 플레이어가 데이터 보고 전략 수립

4. **역전 전략 시스템**
   - "신촌에 한우 오마카세" 같은 무모한 도전도 전략으로 가능
   - 점심 할인, SNS 마케팅 등 다양한 전략 카드로 역전 가능

### 1.5 출시 계획

| 단계 | 플랫폼 | 가격 | 시점 |
|------|--------|------|------|
| 알파 테스트 | Cloudflare Pages (웹) | 무료 | 1-3개월 |
| 베타 테스트 | itch.io (웹) | 무료 또는 후원 | 4-6개월 |
| 정식 출시 | Steam (PC) | 5,000-15,000원 | 6-12개월 |
| 확장 | Steam Early Access → 1.0 | 가격 인상 가능 | 12개월+ |

---

## 2. 기술 스택

### 2.1 게임 엔진
- **엔진**: Godot 4.x (최신 안정 버전)
- **언어**: GDScript
- **이유**: 무료, 가벼움, Cloudflare Pages 호환, AI 코딩 친화적

### 2.2 배포 환경

#### 개발/테스트
- **코드 저장**: GitHub
- **자동 배포**: Cloudflare Pages
- **URL 형태**: `https://food-tycoon.pages.dev`

#### 정식 출시
- **플랫폼**: Steam
- **빌드**: Windows / macOS / Linux 데스크톱 빌드

### 2.3 그래픽 스타일
- **스타일**: 2D 픽셀 아트 (롤러코스터 타이쿤 1 영감)
- **시점**: 아이소메트릭 (45도 비스듬한 위에서)
- **해상도**: 16x16 또는 32x32 픽셀 타일 기반

### 2.4 에셋 출처
- **무료 에셋**:
  - Kenney.nl (CC0)
  - Itch.io 픽셀 아트 팩
  - OpenGameArt
- **자체 제작**: 한국 특유의 디테일 (간판, 메뉴 아이콘 등)

### 2.5 필수 헤더 설정 (Cloudflare Pages)

`_headers` 파일을 빌드 폴더에 추가:
```
/*
  Cross-Origin-Embedder-Policy: require-corp
  Cross-Origin-Opener-Policy: same-origin
```

이게 있어야 Godot 4의 멀티스레딩 기능이 웹에서 정상 작동.

---

## 3. 핵심 게임플레이 루프

### 3.1 메인 루프 (1일 단위)

```
[아침 9시 - 가게 오픈]
  ↓
[손님 자동 입장 - 시간대별 다름]
  ↓
[알바가 주문 받음 → 음식 제작]
  ↓
[음식 서빙 → 결제]
  ↓
[저녁 22시 - 가게 마감]
  ↓
[일일 정산]
  - 매출 / 비용 / 순이익
  - 평점 / 리뷰
  - 단골 변동
  ↓
[다음 날 준비]
  - 메뉴 조정
  - 알바 관리
  - 마케팅 전략
```

### 3.2 메타 루프 (장기 진행)

```
[변두리 작은 가게 시작]
  ↓
[돈 모으기 + 평판 쌓기]
  ↓
[전략 결정 (3가지 분기)]
  ├─ 분기 A: 같은 자리에서 확장 (단골 강화)
  ├─ 분기 B: 더 좋은 지역으로 이전 (도전)
  └─ 분기 C: 체인점 확장 (자본 사업)
  ↓
[새 도전 (지역/메뉴/타겟)]
  ↓
[반복 → 엔드게임]
```

### 3.3 결정의 순간들

플레이어가 게임에서 자주 마주하는 결정:

1. **메뉴 가격**: 싸게 팔까, 비싸게 팔까?
2. **알바 채용**: 비싼 셰프 vs 싼 학생 알바?
3. **마케팅 비용**: 광고할까, 그 돈 모아둘까?
4. **이사 결정**: 안전한 동네 vs 위험하지만 큰 매출?
5. **메뉴 추가**: 인기 메뉴만 vs 다양화?
6. **위기 대응**: 옆가게 경쟁 시작 → 어떻게?

---

## 4. MVP 범위 정의

### 4.1 MVP 목적
**"3-6개월 안에 출시 가능한 최소 기능 게임"**

핵심 재미를 보여주는 데 필요한 최소한만 포함. 출시 후 반응 보고 확장.

### 4.2 MVP에 들어가는 것

#### ✅ 포함

**지역 시스템 (3개)**
1. **노원/상계** - 변두리, 가족/어르신, 월세 저렴
2. **신촌/이대** - 대학가, 학생, 가성비 중요
3. **강남역** - 사무실/번화가, 직장인, 객단가 높음

**메뉴 시스템 (10개)**
- 분식: 김밥, 떡볶이, 라면 (3개)
- 한식: 김치찌개, 된장찌개, 비빔밥 (3개)
- 양식: 수제버거, 파스타 (2개)
- 디저트/카페: 아메리카노, 케이크 (2개)

**알바 시스템 (3등급)**
1. **신입 알바** (시급 9,860원) - 분식만 가능
2. **경험 알바** (시급 12,000원) - 분식 + 한식
3. **셰프** (월급 250만원) - 모든 메뉴

**손님 시스템 (4종)**
1. **대학생** - 가성비, 양 많아야 함
2. **직장인** - 빠른 서빙, 점심
3. **가족** - 다양한 메뉴, 어린이 OK
4. **어르신** - 전통 한식, 부드러움

**전략 카드 (5종)**
1. **점심 할인** - 특정 시간대 가격 할인
2. **학생 할인** - 학생증 제시 시 할인
3. **SNS 마케팅** - 비용 들이고 손님 +20%
4. **블로그 체험단** - 평판 ↑
5. **단골 쿠폰** - 재방문률 ↑

**마케팅 시스템 (간단)**
- 인스타 광고 (월 50만원, 젊은층 +20%)
- 블로그 체험단 (1회 100만원, 평판 ↑)
- 배달앱 입점 (월 50만원, 새 고객층)

**경제 시스템**
- 일일 매출/비용 정산
- 월세 자동 차감
- 알바 인건비 자동 차감
- 재료비 (매출의 30%)

**평판/리뷰 시스템 (간단)**
- 별점 (1-5점)
- 평균 평점이 손님 유입에 영향
- 4점 이상이면 단골 증가

**저장/로드 시스템**
- 자동 저장 (매일 마감 시)
- 수동 저장/로드

#### ❌ MVP에서 제외 (확장 단계)

- 레시피 개발 시스템
- AI 분석 시스템 (대신 단순 매칭)
- 시즌 트렌드 시스템
- 체인점/프랜차이즈
- 이벤트 시스템 (TV 출연, 위기 등)
- 인플루언서 마케팅
- 12개 이상의 지역
- 고급 메뉴 (오마카세 등)
- 시간대별 정밀한 손님 시뮬레이션

### 4.3 MVP 성공 지표

- **동작**: 1일 사이클이 끝까지 완주됨
- **재미**: 베타 테스터가 3일 이상 플레이
- **전략**: 적어도 2-3가지 다른 플레이 스타일 가능
- **밸런스**: 노원에서 시작해서 강남까지 갈 수 있음 (가능하지만 어려움)

---

## 5. 시스템 설계

### 5.1 시스템 다이어그램

```
┌─────────────────────────────────────────┐
│           GameManager (싱글톤)            │
│  - 게임 상태 (자금, 시간, 평판)            │
│  - 일일 정산 처리                         │
│  - 저장/로드                              │
└─────────────────────────────────────────┘
              ↓ 관리
┌─────────────┬───────────────┬──────────────┐
│             │               │              │
↓             ↓               ↓              ↓
[Restaurant]  [Region]    [TimeSystem]  [UI]
   ↓             ↓             ↓
┌─────┐    ┌────────┐    [낮/밤 사이클]
│Staff│    │Customer│
│Menu │    │Spawner │
│Tables│   └────────┘
└─────┘         ↓
              [Customer]
              - 종류 (학생/직장인/등)
              - 주문 → 만족도 → 결제
```

### 5.2 핵심 시스템들

#### 5.2.1 GameManager
**역할**: 게임 전체 상태 관리

**주요 기능**:
- 현재 자금 추적
- 게임 시간 (1일 = 5분 실시간)
- 평판 점수
- 저장/로드
- 씬 전환

#### 5.2.2 Restaurant (가게)
**역할**: 가게 운영 정보

**주요 기능**:
- 위치 (어느 Region)
- 메뉴 리스트
- 알바 리스트
- 테이블 수
- 일일 매출 누적

#### 5.2.3 Region (지역)
**역할**: 지역별 특성

**주요 데이터**:
- 유동인구 (시간대별)
- 인구 구성 (학생/직장인/가족 비율)
- 평균 객단가
- 월세
- 인기/비인기 메뉴

#### 5.2.4 CustomerSpawner
**역할**: 시간대에 맞춰 손님 생성

**로직**:
- 현재 시간 + 지역 데이터 → 손님 종류 결정
- 손님 빈도 계산
- Customer 인스턴스 생성

#### 5.2.5 Customer (손님)
**역할**: 개별 손님의 행동

**상태 머신**:
```
입장 → 자리 찾기 → 주문 → 대기 → 식사 → 결제 → 퇴장
                              ↓
                          (인내심 0)
                              ↓
                          화내며 퇴장
```

#### 5.2.6 Staff (알바)
**역할**: 음식 제작

**주요 데이터**:
- 등급 (신입/경험/셰프)
- 만들 수 있는 메뉴
- 제작 속도
- 시급/월급

**로직**:
- 주문 큐에서 작업 가져옴
- 메뉴별 제작 시간 동안 작업
- 완성 → 서빙

#### 5.2.7 Menu (메뉴)
**역할**: 메뉴 정보

**주요 데이터**:
- 이름
- 분류 (분식/한식/양식/등)
- 가격
- 제작 시간
- 재료비 (매출의 30% 기본)
- 인기 지역/타겟

#### 5.2.8 StrategyCard (전략)
**역할**: 플레이어가 활성화하는 전략

**예시**:
```
점심 할인 카드:
- 활성화 시간: 11:30-13:30
- 효과: 모든 메뉴 -20%
- 결과: 직장인 손님 +30%, 마진 -20%
```

### 5.3 시스템 간 상호작용

#### 핵심 시나리오: 손님 한 명의 흐름

```
1. CustomerSpawner가 Customer 생성
   - Region 데이터 기반으로 종류 결정
   
2. Customer가 Restaurant 도착
   - 가게 평판 확인 → 들어올지 결정
   - 메뉴 가격 확인 → 예산 초과면 떠남
   
3. 빈 테이블 찾기
   - 없으면 잠시 대기 → 인내심 소모
   - 인내심 0 → 떠남
   
4. 주문
   - 자기 취향 + 가격대 + 메뉴 인기도 고려
   
5. 알바가 주문 큐에서 가져감
   - 만들 수 있는 등급 알바인지 체크
   - 못 만들면 손님 화남
   
6. 제작 시간 동안 대기
   - 기다리는 동안 인내심 ↓
   - 너무 늦으면 만족도 ↓
   
7. 음식 서빙 → 식사
   - 만족도에 따라 별점 결정
   
8. 결제 + 팁
   - 만족도 80%↑: 정가 + 팁
   - 만족도 50% 이하: 정가만
   - 만족도 30% 이하: 환불 요구 가능
   
9. 퇴장
   - 만족하면 단골 가능성 ↑
   - 불만이면 평판 ↓
```

---

## 6. 데이터 구조

### 6.1 GameState (전역 상태)

```gdscript
# GameState.gd
class_name GameState extends Resource

@export var money: int = 5000000  # 시작 자금: 500만원
@export var current_day: int = 1
@export var current_hour: int = 9  # 게임 시작 시간
@export var reputation: int = 50  # 0-100
@export var current_region: String = "nowon"
@export var menu_unlocked: Array[String] = ["kimbap", "ramen", "tteokbokki"]
@export var staff: Array[Staff] = []
@export var active_strategies: Array[String] = []
@export var stats: Dictionary = {
    "total_revenue": 0,
    "total_customers": 0,
    "regulars_count": 0
}
```

### 6.2 Region 데이터

```gdscript
# regions.gd - 정적 데이터
const REGIONS = {
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
        "unpopular_menus": ["pasta", "expensive_korean"],
        "competition": 45,
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
        "unpopular_menus": ["expensive_korean", "premium_steak"],
        "competition": 142,
        "special_events": {
            "exam_period": -0.4,  # 시험기간 매출 -40%
            "vacation": -0.6      # 방학 매출 -60%
        },
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
        "popular_menus": ["kimchi_jjigae", "bibimbap", "pasta", "burger"],
        "unpopular_menus": ["cheap_street_food"],
        "competition": 350,
        "peak_multiplier": 3.0,  # 점심시간 매출 3배
        "description": "직장인 객단가 높음. 점심+저녁 회식 폭증."
    }
}
```

### 6.3 Menu 데이터

```gdscript
# menus.gd
const MENUS = {
    "kimbap": {
        "name": "김밥",
        "category": "snack",
        "base_price": 4000,
        "cooking_time": 30,  # 초
        "ingredient_cost_ratio": 0.3,
        "required_staff_level": 1,  # 신입 가능
        "popularity_by_region": {
            "nowon": 1.2,
            "sinchon": 1.5,
            "gangnam": 0.8
        }
    },
    
    "tteokbokki": {
        "name": "떡볶이",
        "category": "snack",
        "base_price": 5000,
        "cooking_time": 60,
        "ingredient_cost_ratio": 0.25,
        "required_staff_level": 1,
        "popularity_by_region": {
            "nowon": 1.0,
            "sinchon": 1.8,
            "gangnam": 0.5
        }
    },
    
    "kimchi_jjigae": {
        "name": "김치찌개",
        "category": "korean",
        "base_price": 9000,
        "cooking_time": 180,
        "ingredient_cost_ratio": 0.3,
        "required_staff_level": 2,  # 경험 알바 이상
        "popularity_by_region": {
            "nowon": 1.3,
            "sinchon": 0.9,
            "gangnam": 1.4
        }
    },
    
    "burger": {
        "name": "수제버거",
        "category": "western",
        "base_price": 12000,
        "cooking_time": 240,
        "ingredient_cost_ratio": 0.35,
        "required_staff_level": 2,
        "popularity_by_region": {
            "nowon": 0.8,
            "sinchon": 1.5,
            "gangnam": 1.3
        }
    },
    
    "pasta": {
        "name": "파스타",
        "category": "western",
        "base_price": 15000,
        "cooking_time": 300,
        "ingredient_cost_ratio": 0.3,
        "required_staff_level": 3,  # 셰프 필수
        "popularity_by_region": {
            "nowon": 0.5,
            "sinchon": 1.2,
            "gangnam": 1.6
        }
    }
    # ... 나머지 메뉴들
}
```

### 6.4 Customer 데이터

```gdscript
# Customer.gd
class_name Customer extends Node2D

enum CustomerType { STUDENT, OFFICE_WORKER, FAMILY, ELDERLY }

@export var customer_type: CustomerType
@export var budget: int  # 예산
@export var patience: int = 100  # 인내심 (초)
@export var preferences: Dictionary  # 선호도

var current_state: String = "entering"
var ordered_menu: String = ""
var satisfaction: int = 100

func _init(type: CustomerType):
    customer_type = type
    setup_preferences()

func setup_preferences():
    match customer_type:
        CustomerType.STUDENT:
            budget = randi_range(5000, 12000)
            preferences = {
                "price_weight": 0.5,    # 가격 매우 중요
                "quantity_weight": 0.3, # 양 중요
                "quality_weight": 0.2
            }
        CustomerType.OFFICE_WORKER:
            budget = randi_range(8000, 18000)
            preferences = {
                "speed_weight": 0.5,    # 빠른 서빙 중요
                "quality_weight": 0.3,
                "price_weight": 0.2
            }
        CustomerType.FAMILY:
            budget = randi_range(20000, 50000)  # 가족 단위
            preferences = {
                "variety_weight": 0.4,  # 다양한 메뉴
                "kid_friendly": 0.3,
                "quality_weight": 0.3
            }
        CustomerType.ELDERLY:
            budget = randi_range(8000, 15000)
            preferences = {
                "tradition_weight": 0.5, # 전통 한식
                "softness_weight": 0.3,
                "service_weight": 0.2
            }
```

### 6.5 Staff 데이터

```gdscript
# Staff.gd
class_name Staff extends Resource

enum Level { ROOKIE, EXPERIENCED, CHEF }

@export var name: String
@export var level: Level
@export var hourly_wage: int
@export var monthly_salary: int = 0  # 셰프는 월급제
@export var cooking_speed_multiplier: float = 1.0
@export var allowed_categories: Array[String] = []

func _init(staff_level: Level):
    level = staff_level
    match level:
        Level.ROOKIE:
            hourly_wage = 9860  # 2026년 최저시급
            cooking_speed_multiplier = 0.8
            allowed_categories = ["snack"]
            
        Level.EXPERIENCED:
            hourly_wage = 12000
            cooking_speed_multiplier = 1.0
            allowed_categories = ["snack", "korean", "western"]
            
        Level.CHEF:
            hourly_wage = 0
            monthly_salary = 2500000  # 250만원
            cooking_speed_multiplier = 1.5
            allowed_categories = ["snack", "korean", "western", "dessert"]
```

### 6.6 StrategyCard 데이터

```gdscript
# strategies.gd
const STRATEGIES = {
    "lunch_discount": {
        "name": "점심 할인",
        "description": "11:30-13:30 동안 모든 메뉴 20% 할인",
        "active_hours": [11, 12, 13],
        "effects": {
            "price_multiplier": 0.8,
            "office_worker_attraction": 1.3
        },
        "duration": 1,  # 1일 지속
        "cost": 0  # 카드 활성화 비용
    },
    
    "student_discount": {
        "name": "학생 할인",
        "description": "학생증 제시 시 30% 할인",
        "effects": {
            "price_multiplier_for_students": 0.7,
            "student_attraction": 1.5
        },
        "duration": 1,
        "cost": 0
    },
    
    "instagram_marketing": {
        "name": "인스타 마케팅",
        "description": "1주일간 SNS 광고. 젊은층 +30%",
        "effects": {
            "young_attraction": 1.3,
            "viral_chance": 0.05
        },
        "duration": 7,
        "cost": 500000  # 50만원
    },
    
    "blog_review": {
        "name": "블로그 체험단",
        "description": "블로거 5명 초청. 평판 +10",
        "effects": {
            "reputation_boost": 10
        },
        "duration": 1,  # 1회성
        "cost": 1000000  # 100만원
    },
    
    "loyalty_coupon": {
        "name": "단골 쿠폰",
        "description": "10번 방문 시 1번 무료. 재방문률 ↑",
        "effects": {
            "regular_chance": 1.5
        },
        "duration": 30,  # 한 달
        "cost": 0  # 마진에서 차감
    }
}
```

---

## 7. 화면 구성

### 7.1 메인 게임 화면

```
┌─────────────────────────────────────────────┐
│ [로고] [💰 5,000,000원] [⏰ 14:30] [⭐ 4.2] │ ← 상단 바
├─────────────────────────────────────────────┤
│                                             │
│                                             │
│         [아이소메트릭 가게 화면]              │
│                                             │
│         🪑 🪑 🪑                             │
│         🪑 🪑 🪑                             │
│              👨‍🍳 ← 알바                      │
│              [주방]                          │
│                                             │
│         👤 ← 손님                            │
│                                             │
├─────────────────────────────────────────────┤
│ [메뉴] [알바] [전략] [통계] [설정]            │ ← 하단 메뉴
└─────────────────────────────────────────────┘
```

### 7.2 메뉴 관리 화면

```
┌─────────────────────────────────────────────┐
│ 메뉴 관리                            [닫기]  │
├─────────────────────────────────────────────┤
│ ┌─────────┬─────────┬─────────┐             │
│ │ 김밥    │ 떡볶이  │ 라면    │             │
│ │ 4,000원 │ 5,000원 │ 4,500원 │             │
│ │ [활성]  │ [활성]  │ [활성]  │             │
│ │ 인기★★★│ 인기★★★★│ 인기★★ │             │
│ └─────────┴─────────┴─────────┘             │
│                                             │
│ [+ 메뉴 추가]                               │
│                                             │
│ === 잠금 메뉴 ===                           │
│ • 김치찌개 (필요: 경험 알바)                 │
│ • 비빔밥 (필요: 평판 60+)                    │
└─────────────────────────────────────────────┘
```

### 7.3 알바 관리 화면

```
┌─────────────────────────────────────────────┐
│ 알바 관리                            [닫기]  │
├─────────────────────────────────────────────┤
│ ┌─────────────────────────────────┐         │
│ │ 👨 김알바 (신입)                 │         │
│ │ 시급: 9,860원                    │         │
│ │ 가능 메뉴: 분식                  │         │
│ │ 속도: ⚡⚡                        │         │
│ │ [해고]                           │         │
│ └─────────────────────────────────┘         │
│                                             │
│ === 채용 가능 ===                           │
│ ┌─────────────────────────────────┐         │
│ │ 👩 이경험 (경험)                 │         │
│ │ 시급: 12,000원                   │         │
│ │ 가능 메뉴: 분식, 한식, 양식       │         │
│ │ 속도: ⚡⚡⚡                       │         │
│ │ [채용]                           │         │
│ └─────────────────────────────────┘         │
└─────────────────────────────────────────────┘
```

### 7.4 전략 카드 화면

```
┌─────────────────────────────────────────────┐
│ 전략                                 [닫기]  │
├─────────────────────────────────────────────┤
│ === 활성 전략 ===                           │
│ • 점심 할인 (오늘 적용 중)                   │
│                                             │
│ === 사용 가능 전략 ===                      │
│ ┌─────────────────────────────────┐         │
│ │ 🍱 학생 할인                     │         │
│ │ 학생증 제시 시 30% 할인          │         │
│ │ 비용: 무료                       │         │
│ │ 효과: 학생 +50%                  │         │
│ │ [활성화]                         │         │
│ └─────────────────────────────────┘         │
│                                             │
│ ┌─────────────────────────────────┐         │
│ │ 📱 인스타 마케팅                 │         │
│ │ 1주일 SNS 광고                   │         │
│ │ 비용: 500,000원                  │         │
│ │ 효과: 젊은층 +30%                │         │
│ │ [활성화]                         │         │
│ └─────────────────────────────────┘         │
└─────────────────────────────────────────────┘
```

### 7.5 일일 정산 화면

```
┌─────────────────────────────────────────────┐
│ Day 5 마감                                   │
├─────────────────────────────────────────────┤
│                                             │
│ === 오늘의 매출 ===                         │
│ 총 매출:        +850,000원                   │
│ 손님 수:         42명                        │
│ 평균 객단가:     20,238원                    │
│                                             │
│ === 오늘의 비용 ===                         │
│ 재료비:         -255,000원 (30%)             │
│ 알바 인건비:    -120,000원                   │
│ 마케팅:         -50,000원                    │
│ 일일 월세:      -16,667원 (월세 1/30)        │
│                                             │
│ === 순이익 ===                              │
│ 💰 +408,333원                                │
│                                             │
│ === 평판 변화 ===                           │
│ ⭐ 4.2 → 4.3 (+0.1)                         │
│ 단골 +3명                                   │
│                                             │
│ [다음 날]                                   │
└─────────────────────────────────────────────┘
```

### 7.6 지역 이전 화면

```
┌─────────────────────────────────────────────┐
│ 지역 이전                            [닫기]  │
├─────────────────────────────────────────────┤
│ === 현재 위치 ===                           │
│ 노원/상계 (월세 50만원/월)                   │
│                                             │
│ === 이전 가능 지역 ===                      │
│ ┌─────────────────────────────────┐         │
│ │ 🎓 신촌/이대                     │         │
│ │ 유동인구: ★★★★★                 │         │
│ │ 주요 인구: 학생 75%              │         │
│ │ 평균 객단가: 8,000원             │         │
│ │ 월세: 350만원/월                 │         │
│ │ 이전 비용: 5,000,000원           │         │
│ │ ⚠ 시험기간/방학 매출 ↓          │         │
│ │ [이전]                           │         │
│ └─────────────────────────────────┘         │
│                                             │
│ ┌─────────────────────────────────┐         │
│ │ 🏢 강남역                        │         │
│ │ 유동인구: ★★★★★                 │         │
│ │ 주요 인구: 직장인 55%            │         │
│ │ 평균 객단가: 18,000원            │         │
│ │ 월세: 1500만원/월 ⚠              │         │
│ │ 이전 비용: 30,000,000원 (잠금)   │         │
│ │ 🔒 평판 70 이상 필요             │         │
│ └─────────────────────────────────┘         │
└─────────────────────────────────────────────┘
```

---

## 8. 개발 마일스톤

### 8.1 Phase 0: 환경 셋업 (1주)

**목표**: 개발 환경 + 자동 배포 파이프라인 구축

- [ ] Godot 4 설치
- [ ] GitHub 저장소 생성
- [ ] Cloudflare Pages 연동
- [ ] `_headers` 파일 설정
- [ ] Hello World 씬 + 첫 배포
- [ ] URL 동작 확인

**결과물**: `https://food-tycoon.pages.dev` 에서 빈 게임 실행됨

---

### 8.2 Phase 1: 핵심 시스템 (4주)

**목표**: 손님 1명 → 주문 → 결제 사이클 동작

#### Week 1: 기반 구조
- [ ] 프로젝트 폴더 구조
- [ ] GameState 싱글톤
- [ ] 시간 시스템 (1일 = 5분)
- [ ] 기본 UI (자금, 시간 표시)

#### Week 2: 가게 + 메뉴
- [ ] Restaurant 클래스
- [ ] Menu 데이터 정의 (10개)
- [ ] 메뉴 관리 UI
- [ ] 1개 지역 (노원) 데이터

#### Week 3: 알바 + 손님
- [ ] Staff 클래스 (3등급)
- [ ] Customer 클래스
- [ ] CustomerSpawner
- [ ] 손님 상태 머신 (입장 → 주문 → 결제)

#### Week 4: 게임 사이클
- [ ] 1일 사이클 완성
- [ ] 일일 정산 화면
- [ ] 자동 저장
- [ ] 첫 베타 빌드

**결과물**: 노원에서 1일 운영 가능한 게임

---

### 8.3 Phase 2: 콘텐츠 확장 (4주)

**목표**: 3개 지역 + 모든 MVP 기능

#### Week 5-6: 지역 시스템
- [ ] Region 데이터 (3개)
- [ ] 지역별 손님 구성 차이
- [ ] 지역 이전 시스템
- [ ] 지역별 월세

#### Week 7: 전략 카드
- [ ] StrategyCard 시스템
- [ ] 전략 카드 5종 구현
- [ ] 전략 효과 적용 로직

#### Week 8: 마케팅 + 평판
- [ ] 마케팅 시스템
- [ ] 평판/리뷰 시스템
- [ ] 단골 시스템

**결과물**: 노원 → 신촌 → 강남까지 진행 가능

---

### 8.4 Phase 3: 폴리싱 (4주)

**목표**: 출시 가능한 퀄리티

#### Week 9-10: 비주얼
- [ ] 픽셀 아트 에셋 적용
- [ ] 아이소메트릭 그리드
- [ ] 캐릭터 애니메이션
- [ ] UI 디자인 개선

#### Week 11: 사운드
- [ ] BGM 추가
- [ ] 효과음 (주문, 결제, 만족 등)

#### Week 12: 밸런싱 + 버그 수정
- [ ] 경제 밸런스 조정
- [ ] 베타 테스터 피드백 반영
- [ ] 버그 수정

**결과물**: itch.io 또는 Steam 출시 가능한 1.0 버전

---

### 8.5 전체 일정 요약

```
Phase 0: 셋업           [1주차]
Phase 1: 핵심 시스템    [2-5주차]
Phase 2: 콘텐츠 확장    [6-9주차]
Phase 3: 폴리싱         [10-13주차]

총 개발 기간: 약 3개월 (MVP)
```

---

## 9. 확장 로드맵 (출시 후)

MVP 출시 후 유저 피드백 보고 추가할 기능들:

### 9.1 v1.1: 더 많은 지역
- 홍대, 명동, 잠실, 청담, 종로 등 추가 (10개+)
- 지역별 특수 이벤트

### 9.2 v1.2: 레시피 개발 시스템
- 재료 조합으로 신메뉴 개발
- 레시피 카드 수집

### 9.3 v1.3: AI 분석 시스템
- 진짜 AI 풍 상권 분석 화면
- 데이터 기반 추천 시스템

### 9.4 v1.4: 시즌/트렌드 시스템
- 분기별 트렌드 메뉴 (탕후루, 약과 등)
- 시즌별 매출 변동

### 9.5 v1.5: 인플루언서/방송 시스템
- 유튜버 협찬
- 백종원 출연 시스템
- TV 출연 이벤트

### 9.6 v2.0: 체인점 확장
- 여러 지점 동시 운영
- 본사 시스템
- 프랜차이즈

### 9.7 v2.1: 글로벌 진출
- 부산, 제주 등 한국 다른 지역
- 일본, 미국 진출 (장기)

---

## 10. Claude Code 작업 지시서

### 10.1 작업 시작 전 준비사항 (사용자가 직접)

```markdown
1. Godot 4 설치
   - https://godotengine.org/download
   - Standard 버전 (Mono X)

2. GitHub 계정 + 새 저장소
   - 저장소 이름: food-tycoon (또는 원하는 이름)
   - Private 또는 Public 선택

3. Cloudflare Pages 계정
   - 이미 있다고 하셨으니 OK

4. Claude Code 설치
   - npm install -g @anthropic-ai/claude-code
```

### 10.2 Claude Code에 전달할 첫 지시

```markdown
@Claude Code

한국식 음식 장사 타이쿤 게임을 Godot 4 + GDScript로 만들어 주세요.

기획서: [이 문서 첨부]

Phase 0부터 시작합시다:

1. Godot 4 프로젝트 초기 셋업
2. 폴더 구조 생성:
   - scenes/
   - scripts/
   - assets/
   - data/
3. .gitignore 파일 생성
4. README.md 작성
5. 빈 메인 씬 (Main.tscn) 생성
6. "음식 타이쿤 시작!" 라벨이 있는 씬
7. Web Export 설정
8. _headers 파일 생성 (Cloudflare Pages용)
9. Git 초기화 + 첫 커밋

이 단계가 완료되면 다음 단계로 넘어갑시다.
```

### 10.3 Phase별 작업 지시 (참고)

#### Phase 1 시작 시
```markdown
Phase 1: 핵심 시스템 구현 시작.

Week 1 작업:
1. GameState 싱글톤 구현 (기획서 6.1 참조)
2. 시간 시스템 (TimeManager)
3. 기본 상단 UI (자금, 시간, 평판)
4. 메인 씬 레이아웃

코드 작성 시 한국어 주석 포함해 주세요.
```

#### Phase 2 시작 시
```markdown
Phase 2: 지역 시스템 구현 시작.

기획서 6.2의 REGIONS 데이터를 사용해 주세요.
지역 이전 화면은 7.6 와이어프레임 참조.
```

### 10.4 주의사항

**Claude Code에 전달할 때**:

1. **이 기획서 전체를 컨텍스트로 제공**
2. **한 번에 너무 많은 작업 요구하지 말기** (Phase 단위로 진행)
3. **각 단계마다 동작 확인 후 다음 단계**
4. **에셋(이미지, 사운드)은 사용자가 직접 다운로드**
5. **Claude Code는 코드만 작성, 에셋 통합은 사용자 도움 필요**

### 10.5 단계별 체크포인트

각 단계 완료 후 확인할 것:

#### Phase 0 완료 체크
- [ ] Godot에서 프로젝트 열림
- [ ] 빈 씬 실행 시 라벨 보임
- [ ] git push 가능
- [ ] Cloudflare Pages에서 URL 접속 시 게임 보임

#### Phase 1 완료 체크
- [ ] 시간이 흐름 (1일 = 5분)
- [ ] 자금 표시됨
- [ ] 손님이 입장 → 주문 → 결제 가능
- [ ] 알바가 음식 만듦
- [ ] 1일 마감 시 정산 화면

#### Phase 2 완료 체크
- [ ] 3개 지역 모두 진입 가능
- [ ] 지역별 손님 구성 다름
- [ ] 전략 카드 5개 사용 가능
- [ ] 평판 시스템 동작

#### Phase 3 완료 체크
- [ ] 픽셀 아트 적용됨
- [ ] 사운드 재생됨
- [ ] 밸런스 OK (노원→강남 진행 가능)
- [ ] Cloudflare Pages에 배포된 URL이 안정적으로 동작

---

## 📋 부록: 빠른 시작 가이드

### A.1 환경 셋업 (1시간)

```bash
# 1. 프로젝트 폴더 생성
mkdir food-tycoon
cd food-tycoon

# 2. Godot에서 새 프로젝트 (GUI에서)

# 3. Git 초기화
git init
git remote add origin https://github.com/USERNAME/food-tycoon.git

# 4. .gitignore 생성
cat > .gitignore << EOF
.godot/
.import/
build/
*.tmp
.DS_Store
EOF

# 5. 첫 커밋
git add .
git commit -m "Initial Godot project"
git push -u origin main
```

### A.2 Cloudflare Pages 셋업

```
1. https://dash.cloudflare.com 접속
2. Pages → Create a project
3. Connect to GitHub → food-tycoon 저장소 선택
4. Build settings:
   - Framework preset: None
   - Build command: (Godot CLI 빌드 명령 - 별도 설정)
   - Build output directory: build/web
5. Environment variables (선택)
6. Deploy
```

### A.3 Web Export 빠른 가이드

```
1. Godot 에디터에서 Project → Export
2. Add → Web 선택
3. Export Path: build/web/index.html
4. Export Templates 다운로드 (처음만)
5. Export Project 클릭
6. build/web 폴더에 _headers 파일 추가
```

### A.4 자주 쓰는 명령어

```bash
# 로컬 빌드
godot --headless --export-release "Web" build/web/index.html

# 로컬 테스트 (Python으로 간단 서버)
cd build/web
python3 -m http.server 8000
# http://localhost:8000 접속

# Git 워크플로우
git add .
git commit -m "기능 추가: XXX"
git push
# → Cloudflare Pages 자동 배포
```

---

## 🎯 마무리

이 기획서는 **Claude Code에 넘겨서 실제 개발을 시작할 수 있는 수준**으로 작성되었습니다.

### 다음 액션

1. **사용자**: 환경 셋업 (Godot 설치, GitHub 저장소, Cloudflare Pages)
2. **Claude Code**: 이 기획서 + Phase 0 작업 지시 → 코딩 시작
3. **사용자**: 단계별 동작 확인 + 피드백
4. **반복**: Phase 1 → 2 → 3 진행

### 중요 원칙

- ⭐ **MVP 먼저, 확장은 나중에**
- ⭐ **각 Phase 완료 후 다음 단계**
- ⭐ **베타 테스트 적극 활용**
- ⭐ **출시 자체가 목표가 아닌 "재미있는 게임" 목표**

화이팅! 🚀

---

**기획자 노트**:
이 문서는 살아있는 문서입니다. 개발 진행 중 발견되는 새로운 요구사항이나 변경사항이 있으면 이 문서를 업데이트하면서 진행하세요.

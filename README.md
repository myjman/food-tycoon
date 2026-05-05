# 한국식 음식 장사 타이쿤 (Korean Food Tycoon)

한국 자영업의 현실을 담은 픽셀 아트 음식 장사 시뮬레이션 게임. Godot 4 + GDScript.

## 현재 상태

- **버전**: MVP v0.1 (개발 중)
- **Phase 0**: 환경 셋업 ✅
- **Phase 1**: 핵심 시스템 ✅ (GameState / TimeSystem / Restaurant / Customer / Staff / 1일 사이클)
- **Phase 2**: 콘텐츠 확장 ✅ (3개 지역 / 전략카드 5종 / 마케팅 / 평판 / 단골)
- **Phase 3**: 폴리싱 (픽셀 아트 / 사운드 / 밸런싱) — 미시작

## 폴더 구조

```
food/
├── project.godot              # Godot 프로젝트 설정
├── icon.svg                   # 앱 아이콘
├── scenes/                    # .tscn 씬 파일
│   ├── Main.tscn              # 메인 게임 씬
│   ├── MenuManager.tscn       # 메뉴 관리 UI
│   ├── StaffManager.tscn      # 알바 관리 UI
│   ├── StrategyPanel.tscn     # 전략 카드 UI
│   ├── DayEndReport.tscn      # 일일 정산 UI
│   └── RegionTransfer.tscn    # 지역 이전 UI
├── scripts/
│   ├── data/                  # 정적 데이터 (전역 상수)
│   │   ├── Menus.gd           # 메뉴 10종
│   │   ├── Regions.gd         # 지역 3종
│   │   └── Strategies.gd      # 전략 카드 5종
│   ├── entities/              # 게임 오브젝트
│   │   ├── Customer.gd        # 손님 (4종 + 상태머신)
│   │   └── Staff.gd           # 알바 (3등급)
│   ├── systems/               # 싱글톤(autoload)
│   │   ├── GameState.gd       # 전역 상태 (자금/평판/통계)
│   │   ├── TimeSystem.gd      # 시간 (1일 = 5분)
│   │   ├── Restaurant.gd      # 가게 운영 로직
│   │   ├── CustomerSpawner.gd # 손님 생성 (메인 씬에 부착)
│   │   └── SaveSystem.gd      # 저장/로드 (user://)
│   └── ui/                    # UI 스크립트
└── build/web/                 # 웹 빌드 출력
    └── _headers               # Cloudflare Pages COEP/COOP
```

## 실행 방법

### 로컬 (Godot 에디터)
1. [Godot 4.x](https://godotengine.org/download) Standard 설치
2. Godot 실행 → `Import` → `food/project.godot` 선택
3. F5 (게임 실행)

### 웹 빌드 (Cloudflare Pages)
1. Godot 에디터 → `Project` → `Export`
2. `Add...` → `Web` 선택 → Export Templates 다운로드 (처음 1회)
3. Export Path: `build/web/index.html`
4. `Export Project` 실행
5. `_headers` 파일이 `build/web/`에 그대로 유지되는지 확인 (COEP/COOP)
6. GitHub push → Cloudflare Pages 자동 배포

## 게임플레이

- **시작 자금**: 500만원
- **시작 지역**: 노원/상계 (월세 50만원, 한적한 주택가)
- **목표**: 신촌 → 강남으로 진출하면서 음식 제국 건설
- **루프**: 9시 오픈 → 손님 받기 → 22시 마감 → 정산 → 다음 날
- **1일 = 5분 실시간**

## 메뉴 (10종)
김밥 / 떡볶이 / 라면 / 김치찌개 / 된장찌개 / 비빔밥 / 수제버거 / 파스타 / 아메리카노 / 케이크

## 지역 (3종)
- 노원/상계: 변두리, 월세 ↓, 단골 안정형
- 신촌/이대: 대학가, 가성비 핵심, 시험기간 매출 -40%
- 강남역: 사무실/번화가, 객단가 ↑, 월세 1500만원, 평판 70+ 잠금

## 알바 (3등급)
- 신입 (시급 9,860원, 분식만)
- 경험 (시급 12,000원, 분식+한식+양식)
- 셰프 (월급 250만원, 모든 메뉴)

## 전략 카드 (5종)
점심 할인 / 학생 할인 / 인스타 마케팅 / 블로그 체험단 / 단골 쿠폰

## 기획서

상세 기획은 [`korean-food-tycoon-GDD.md`](./korean-food-tycoon-GDD.md) 참조.

## 라이선스

미정 (개발 중)

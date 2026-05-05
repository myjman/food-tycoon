extends Node
# 저장/로드 시스템 (autoload)

const SAVE_PATH: String = "user://save_main.tres"

func save_game() -> bool:
	var data = {
		"money": GameState.money,
		"current_day": GameState.current_day,
		"current_region": GameState.current_region,
		"reputation": GameState.reputation,
		"menu_unlocked": GameState.menu_unlocked,
		"menu_active": GameState.menu_active,
		"menu_prices": GameState.menu_prices,
		"staff_list": _serialize_staff(GameState.staff_list),
		"table_count": GameState.table_count,
		"active_strategies": GameState.active_strategies,
		"marketing_flags": GameState.marketing_flags,
		"regulars_count": GameState.regulars_count,
		"review_scores": GameState.review_scores,
		"stats": GameState.stats,
		"version": 1
	}
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_error("저장 실패: 파일 열 수 없음")
		return false
	f.store_string(JSON.stringify(data))
	f.close()
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return false
	var raw = f.get_as_text()
	f.close()
	var parse = JSON.parse_string(raw)
	if parse == null:
		push_error("저장 파일 파싱 실패")
		return false
	var data: Dictionary = parse
	GameState.money = int(data.get("money", 5000000))
	GameState.current_day = int(data.get("current_day", 1))
	GameState.current_region = String(data.get("current_region", "nowon"))
	GameState.reputation = float(data.get("reputation", 50.0))
	GameState.menu_unlocked.assign(data.get("menu_unlocked", []))
	GameState.menu_active.assign(data.get("menu_active", []))
	GameState.menu_prices = data.get("menu_prices", {})
	GameState.staff_list = _deserialize_staff(data.get("staff_list", []))
	GameState.table_count = int(data.get("table_count", 6))
	GameState.active_strategies = data.get("active_strategies", {})
	GameState.marketing_flags = data.get("marketing_flags", {})
	GameState.regulars_count = int(data.get("regulars_count", 0))
	GameState.review_scores.assign(data.get("review_scores", []))
	GameState.stats = data.get("stats", {})
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func _serialize_staff(list: Array) -> Array:
	var out = []
	for s in list:
		out.append({
			"name": s.name,
			"level": s.level
		})
	return out

func _deserialize_staff(arr) -> Array:
	var out = []
	for d in arr:
		var s = Staff.new(int(d.get("level", 0)), String(d.get("name", "알바")))
		out.append(s)
	return out

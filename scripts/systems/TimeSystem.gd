extends Node
# 시간 시스템 싱글톤 (autoload)
# 1일 = 5분 실시간 (9시 ~ 22시 = 13시간)
# 따라서 1게임시간 = 약 23.07초

signal hour_passed(new_hour: int)
signal day_opened(day: int)
signal day_closed(day: int)
signal time_paused(paused: bool)

const HOURS_PER_DAY: int = 14  # 9~22 (마감 시 22시 도달)
const OPEN_HOUR: int = 9
const CLOSE_HOUR: int = 22
const REAL_SECONDS_PER_DAY: float = 300.0  # 5분
const REAL_SECONDS_PER_HOUR: float = REAL_SECONDS_PER_DAY / float(HOURS_PER_DAY)

var current_hour: int = OPEN_HOUR
var current_minute: int = 0
var is_running: bool = false
var is_paused: bool = false

var _accumulated: float = 0.0

func _ready() -> void:
	set_process(true)

func start_day() -> void:
	current_hour = OPEN_HOUR
	current_minute = 0
	is_running = true
	is_paused = false
	_accumulated = 0.0
	day_opened.emit(GameState.current_day)

func pause(p: bool) -> void:
	is_paused = p
	time_paused.emit(p)

func _process(delta: float) -> void:
	if not is_running or is_paused:
		return
	_accumulated += delta
	var minutes_per_second = 60.0 / REAL_SECONDS_PER_HOUR
	while _accumulated >= 1.0 / minutes_per_second:
		_accumulated -= 1.0 / minutes_per_second
		_advance_one_minute()

func _advance_one_minute() -> void:
	current_minute += 1
	if current_minute >= 60:
		current_minute = 0
		current_hour += 1
		hour_passed.emit(current_hour)
		if current_hour >= CLOSE_HOUR:
			_close_day()

func _close_day() -> void:
	is_running = false
	day_closed.emit(GameState.current_day)

# 외부에서 시간 표시용
func get_time_string() -> String:
	return "%02d:%02d" % [current_hour, current_minute]

# 현재 진행률 0.0~1.0
func get_day_progress() -> float:
	var total_minutes = HOURS_PER_DAY * 60
	var elapsed = (current_hour - OPEN_HOUR) * 60 + current_minute
	return clamp(float(elapsed) / float(total_minutes), 0.0, 1.0)

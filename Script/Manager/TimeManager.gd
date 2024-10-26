# 时间管理器-自动加载脚本

extends Node

signal time_changed(year, month, day, hour, minute)
signal day_changed(year, month, day)
signal month_changed(year, month)
signal year_changed(year)

var current_year: int = 999
var current_month: int = 1
var current_day: int = 1
var current_hour: int = 0
var current_minute: int = 0

var time_scale: float = 1.0  # 时间流速，1.0 表示正常速度
var is_paused: bool = false

const MINUTES_PER_HOUR: int = 60
const HOURS_PER_DAY: int = 24
const DAYS_PER_MONTH: int = 30
const MONTHS_PER_YEAR: int = 12

# 一分钟的长度（以秒为单位，这里设置为 1 秒 = 1 分钟）
const MINUTE_LENGTH: float = 1.0

func _process(delta: float) -> void:
	if not is_paused:
		advance_time(delta)

func advance_time(delta: float) -> void:
	var minutes_passed = int((delta * time_scale) / MINUTE_LENGTH)
	
	for i in range(minutes_passed):
		current_minute += 1
		if current_minute >= MINUTES_PER_HOUR:
			current_minute = 0
			current_hour += 1
			if current_hour >= HOURS_PER_DAY:
				current_hour = 0
				current_day += 1
				emit_signal("day_changed", current_year, current_month, current_day)
				if current_day > DAYS_PER_MONTH:
					current_day = 1
					current_month += 1
					emit_signal("month_changed", current_year, current_month)
					if current_month > MONTHS_PER_YEAR:
						current_month = 1
						current_year += 1
						emit_signal("year_changed", current_year)
	
	emit_signal("time_changed", current_year, current_month, current_day, current_hour, current_minute)

func get_formatted_time() -> String:
	return "%04d-%02d-%02d %02d:%02d" % [current_year, current_month, current_day, current_hour, current_minute]

func set_time(year: int, month: int, day: int, hour: int, minute: int) -> void:
	current_year = year
	current_month = clamp(month, 1, MONTHS_PER_YEAR)
	current_day = clamp(day, 1, DAYS_PER_MONTH)
	current_hour = clamp(hour, 0, HOURS_PER_DAY - 1)
	current_minute = clamp(minute, 0, MINUTES_PER_HOUR - 1)
	emit_signal("time_changed", current_year, current_month, current_day, current_hour, current_minute)

func pause() -> void:
	is_paused = true

func resume() -> void:
	is_paused = false

func set_time_scale(scale: float) -> void:
	time_scale = scale

func is_night() -> bool:
	return current_hour >= 20 or current_hour < 6

func get_total_days() -> int:
	return (current_year - 1) * MONTHS_PER_YEAR * DAYS_PER_MONTH + (current_month - 1) * DAYS_PER_MONTH + current_day

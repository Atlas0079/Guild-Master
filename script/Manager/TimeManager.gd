# 时间管理器-自动加载脚本

extends Node

signal time_changed(hour, minute)
signal day_changed(day)

var current_time: float = 0.0  # 以小时为单位的当前时间
var current_day: int = 1
var time_scale: float = 1.0  # 时间流速，1.0 表示正常速度
var is_paused: bool = false

# 一天的长度（以秒为单位，这里设置为 24 分钟 = 1440 秒）
const DAY_LENGTH: float = 1440.0

func _process(delta: float) -> void:
    if not is_paused:
        advance_time(delta)

func advance_time(delta: float) -> void:
    current_time += (delta * time_scale) / (DAY_LENGTH / 24.0)
    
    if current_time >= 24.0:
        current_time -= 24.0
        current_day += 1
        emit_signal("day_changed", current_day)
    
    emit_signal("time_changed", get_hour(), get_minute())

func get_hour() -> int:
    return int(current_time)

func get_minute() -> int:
    return int((current_time - floor(current_time)) * 60)

func get_formatted_time() -> String:
    return "%02d:%02d" % [get_hour(), get_minute()]

func set_time(hour: int, minute: int) -> void:
    current_time = float(hour) + float(minute) / 60.0
    emit_signal("time_changed", hour, minute)

func pause() -> void:
    is_paused = true

func resume() -> void:
    is_paused = false

func set_time_scale(scale: float) -> void:
    time_scale = scale

func is_night() -> bool:
    return get_hour() >= 20 or get_hour() < 6
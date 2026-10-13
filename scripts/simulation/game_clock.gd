class_name GameClock
extends RefCounted

## Pausable real-time clock. Speed 0 is pause; 1× and 2× scale sim dt.

const SPEED_PAUSED := 0
const SPEED_NORMAL := 1
const SPEED_FAST := 2

var paused: bool = false
var multiplier: int = SPEED_NORMAL
var sim_time: float = 0.0


func get_speed() -> int:
	if paused or multiplier <= 0:
		return SPEED_PAUSED
	return multiplier


func set_speed(speed: int) -> void:
	if speed <= SPEED_PAUSED:
		paused = true
		return
	paused = false
	if speed >= SPEED_FAST:
		multiplier = SPEED_FAST
	else:
		multiplier = SPEED_NORMAL


func toggle_paused() -> void:
	paused = not paused


func step_delta(wall_delta: float) -> float:
	if paused or multiplier <= 0:
		return 0.0
	var sim_delta := wall_delta * float(multiplier)
	sim_time += sim_delta
	return sim_delta

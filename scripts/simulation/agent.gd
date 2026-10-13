class_name Agent
extends RefCounted

## One named person in the home valley. Needs are 0–1 (higher is better).

var id: int = 0
var display_name: String = ""
var hunger: float = 1.0
var rest: float = 1.0
var shelter: float = 0.28
var idle: bool = false
var left: bool = false
var leave_pressure: float = 0.0
var world_pos: Vector2 = Vector2.ZERO


func is_present() -> bool:
	return not left

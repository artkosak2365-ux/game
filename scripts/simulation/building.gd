class_name Building
extends RefCounted

## Timed construction job. Progress is in simulated seconds.

var kind: String = "dwelling"
var duration: float = 6.0
var progress: float = 0.0
var complete: bool = false
var world_pos: Vector2 = Vector2.ZERO


func advance(amount: float) -> void:
	if complete:
		return
	if amount <= 0.0:
		return
	progress += amount
	if progress >= duration:
		progress = duration
		complete = true

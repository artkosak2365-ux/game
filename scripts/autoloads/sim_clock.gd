extends Node

## Autoload wrapper so pause hits the sim clock, not SceneTree.paused.

const GameClock := preload("res://scripts/simulation/game_clock.gd")

var clock: GameClock


func _init() -> void:
	clock = GameClock.new()

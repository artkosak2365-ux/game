extends SceneTree

const GameClock := preload("res://scripts/simulation/game_clock.gd")
const ValleySim := preload("res://scripts/simulation/valley_sim.gd")

var _failures: int = 0


func _initialize() -> void:
	_test_clock_pause_and_resume()
	_test_clock_double_speed()
	_test_speed_zero_is_pause()
	_test_needs_decay_and_pause()
	_test_construction_vs_pause()
	_test_levy_coupling()
	_test_walk_out_under_cruelty()
	_test_police_granary_not_utopia()
	_test_hold_prints_once_without_quit()
	_test_hud_has_no_opinion_meter()
	if _failures > 0:
		print("SETTLEMENT_SLICE_FAIL %d" % _failures)
		quit(1)
		return
	print("SETTLEMENT_SLICE_OK")
	quit(0)


func _assert(cond: bool, msg: String) -> void:
	if cond:
		return
	_failures += 1
	push_error("FAIL: %s" % msg)
	print("FAIL: %s" % msg)


func _test_clock_pause_and_resume() -> void:
	var clock := GameClock.new()
	clock.set_speed(1)
	var first := clock.step_delta(1.0)
	_assert(is_equal_approx(first, 1.0), "1× advances one sim second")
	_assert(is_equal_approx(clock.sim_time, 1.0), "sim time is 1 after 1s")
	clock.paused = true
	var frozen := clock.sim_time
	var paused_dt := clock.step_delta(5.0)
	_assert(is_equal_approx(paused_dt, 0.0), "pause returns zero dt")
	_assert(is_equal_approx(clock.sim_time, frozen), "pause does not advance")
	clock.paused = false
	var resumed := clock.step_delta(1.0)
	_assert(is_equal_approx(resumed, 1.0), "resume still runs at 1×")
	_assert(is_equal_approx(clock.sim_time, frozen + 1.0), "resume keeps time")


func _test_clock_double_speed() -> void:
	var clock := GameClock.new()
	clock.set_speed(2)
	var dt := clock.step_delta(1.0)
	_assert(is_equal_approx(dt, 2.0), "2× doubles wall time")
	_assert(is_equal_approx(clock.sim_time, 2.0), "2× accumulated 2s")


func _test_speed_zero_is_pause() -> void:
	var clock := GameClock.new()
	clock.set_speed(1)
	clock.step_delta(0.5)
	clock.set_speed(0)
	var frozen := clock.sim_time
	_assert(clock.get_speed() == 0, "speed 0 reports paused")
	clock.step_delta(3.0)
	_assert(is_equal_approx(clock.sim_time, frozen), "speed 0 freezes time")


func _test_needs_decay_and_pause() -> void:
	var sim := ValleySim.new()
	var clock := GameClock.new()
	var start_hunger: float = sim.agents[0].hunger
	clock.set_speed(0)
	sim.step(clock.step_delta(4.0))
	_assert(
		is_equal_approx(sim.agents[0].hunger, start_hunger),
		"paused clock freezes hunger"
	)
	clock.set_speed(1)
	sim.step(clock.step_delta(3.0))
	_assert(sim.agents[0].hunger < start_hunger, "hunger decays while running")


func _test_construction_vs_pause() -> void:
	var sim := ValleySim.new()
	sim.dwelling_duration = 4.0
	var building = sim.start_dwelling()
	var clock := GameClock.new()
	clock.set_speed(1)
	sim.step(clock.step_delta(1.0))
	_assert(not building.complete, "house is unfinished after 1s")
	var progress: float = building.progress
	clock.set_speed(0)
	sim.step(clock.step_delta(20.0))
	_assert(not building.complete, "paused build does not finish")
	_assert(is_equal_approx(building.progress, progress), "pause freezes build")
	clock.set_speed(1)
	sim.step(clock.step_delta(5.0))
	_assert(building.complete, "house completes after enough sim time")
	_assert(sim.completed_dwellings() >= 1, "completed dwelling is counted")


func _test_levy_coupling() -> void:
	var taxed := ValleySim.new()
	taxed.levy = 1.0
	var free := ValleySim.new()
	free.levy = 0.0
	taxed.step(5.0)
	free.step(5.0)
	_assert(taxed.store_grain > 0.0, "high levy fills the store")
	_assert(is_zero_approx(free.store_grain), "zero levy extracts nothing")
	var taxed_need: float = taxed.agents[0].hunger + taxed.agents[0].rest
	var free_need: float = free.agents[0].hunger + free.agents[0].rest
	_assert(taxed_need < free_need, "high levy hurts hunger or rest")


func _test_walk_out_under_cruelty() -> void:
	var sim := ValleySim.new()
	sim.levy = 1.0
	sim.fence_closed = false
	sim.step(30.0)
	var any_left := false
	for agent in sim.agents:
		if agent.left:
			any_left = true
	_assert(any_left, "someone leaves under a cruel levy")
	var recorded := false
	for line in sim.chronicle:
		if "walked east" in line:
			recorded = true
	_assert(recorded, "chronicle records a walk-out")


func _test_police_granary_not_utopia() -> void:
	var police := ValleySim.new()
	police.levy = 1.0
	police.fence_closed = true
	police.step(16.0)
	var mild := ValleySim.new()
	mild.levy = 0.1
	mild.fence_closed = false
	mild.utopia.durability_window = 1.0
	mild.start_dwelling()
	mild.step(mild.dwelling_duration + 1.0)
	for agent in mild.agents:
		agent.hunger = 0.95
		agent.rest = 0.95
	mild.step(2.0)
	_assert(police.store_grain > 1.0, "police granary has stores")
	_assert(
		police.utopia.felt < mild.utopia.felt,
		"police granary scores lower than a mild open valley"
	)
	_assert(police.utopia.felt >= 0.0, "felt is non-negative")
	_assert(police.utopia.felt <= 1.0, "felt is at most 1")


func _test_hold_prints_once_without_quit() -> void:
	var sim := ValleySim.new()
	sim.levy = 0.0
	sim.fence_closed = false
	sim.utopia.hold_required_seconds = 1.0
	sim.utopia.durability_window = 0.25
	sim.start_dwelling()
	sim.step(sim.dwelling_duration)
	for agent in sim.agents:
		agent.hunger = 1.0
		agent.rest = 1.0
		agent.shelter = 1.0
	sim.step(2.0)
	_assert(sim.utopia.utopia_held, "secret hold sets utopia_held")
	_assert(sim.utopia.announce_count == 1, "UTOPIA_HELD prints once")
	var felt_at_hold: float = sim.utopia.felt
	sim.step(1.5)
	_assert(sim.utopia.announce_count == 1, "a later tick does not reprint")
	_assert(sim.sim_elapsed > sim.dwelling_duration + 2.0, "time continues")
	_assert(felt_at_hold >= 0.0, "session still exposes felt after hold")


func _test_hud_has_no_opinion_meter() -> void:
	var packed := load("res://scenes/screens/main.tscn")
	_assert(packed != null, "valley main scene loads")
	if packed == null:
		return
	var scene: Node = packed.instantiate()
	root.add_child(scene)
	_assert(not _has_forbidden_meter(scene), "HUD has no opinion/utopia bar")
	scene.queue_free()


func _has_forbidden_meter(node: Node) -> bool:
	if node is ProgressBar or node is TextureProgressBar:
		return true
	var named := String(node.name).to_lower()
	var meter_name := (
		"opinion" in named or "harmony" in named or "utopia" in named
	)
	if meter_name and (node is Range):
		return true
	if node is Label:
		var text := (node as Label).text.to_lower()
		if "opinion" in text or "harmony" in text:
			return true
		if "utopia" in text and ("%" in text or "bar" in text):
			return true
	for child in node.get_children():
		if _has_forbidden_meter(child):
			return true
	return false

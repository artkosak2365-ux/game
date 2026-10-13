class_name UtopiaVector
extends RefCounted

## Hidden felt-utopia. Never shown as a HUD meter or victory banner.
## felt = min(needs, freedom, justice) * durability * voluntary_union

const FELT_THRESHOLD := 0.92
const HUMANE_HUNGER := 0.55
const HUMANE_REST := 0.55
const HUMANE_SHELTER := 0.45
const GOOD_TRIO_FLOOR := 0.8

var hold_required_seconds: float = 120.0
var durability_window: float = 8.0
var needs: float = 0.0
var freedom: float = 0.0
var justice: float = 0.0
var durability: float = 0.0
var voluntary_union: float = 0.0
var felt: float = 0.0
var utopia_held: bool = false
var announce_count: int = 0
var good_time: float = 0.0
var hold_accum: float = 0.0


func evaluate(sim: Object, dt: float = 0.0) -> float:
	_compute_axes(sim)
	var trio := minf(minf(needs, freedom), justice)
	_tick_durability(trio, dt)
	felt = clampf(trio * durability * voluntary_union, 0.0, 1.0)
	_tick_hold(dt)
	return felt


func _compute_axes(sim: Object) -> void:
	var sim_agents: Array = sim.agents
	var levy: float = float(sim.levy)
	var fenced: bool = bool(sim.fence_closed)
	var living: Array = []
	for agent in sim_agents:
		if not agent.left:
			living.append(agent)
	_compute_needs(living)
	_compute_freedom(levy, fenced)
	_compute_justice(living, levy)
	_compute_union(sim_agents, fenced)


func _compute_needs(living: Array) -> void:
	if living.is_empty():
		needs = 0.0
		return
	var ok := 0
	for agent in living:
		var humane := (
			agent.hunger >= HUMANE_HUNGER
			and agent.rest >= HUMANE_REST
			and agent.shelter >= HUMANE_SHELTER
		)
		if humane:
			ok += 1
	needs = float(ok) / float(living.size())


func _compute_freedom(levy: float, fenced: bool) -> void:
	var coerced := levy * 0.5
	if fenced:
		freedom = clampf(0.22 * (1.0 - coerced), 0.0, 1.0)
		return
	freedom = clampf(1.0 - coerced, 0.0, 1.0)


func _compute_justice(living: Array, levy: float) -> void:
	if living.is_empty():
		justice = 0.0
		return
	var hunger_sum := 0.0
	for agent in living:
		hunger_sum += agent.hunger
	var avg_hunger := hunger_sum / float(living.size())
	justice = clampf(1.0 - levy * (1.0 - avg_hunger), 0.0, 1.0)


func _compute_union(sim_agents: Array, fenced: bool) -> void:
	if sim_agents.is_empty():
		voluntary_union = 0.0
		return
	var stayed := 0
	for agent in sim_agents:
		if not agent.left:
			stayed += 1
	var retention := float(stayed) / float(sim_agents.size())
	if fenced:
		voluntary_union = retention * 0.25
		return
	voluntary_union = retention


func _tick_durability(trio: float, dt: float) -> void:
	if durability_window <= 0.0:
		durability = 1.0
		return
	if trio >= GOOD_TRIO_FLOOR:
		good_time = minf(good_time + dt, durability_window)
	else:
		good_time = maxf(good_time - dt * 2.0, 0.0)
	durability = clampf(good_time / durability_window, 0.0, 1.0)


func _tick_hold(dt: float) -> void:
	if felt >= FELT_THRESHOLD:
		hold_accum += dt
	else:
		hold_accum = 0.0
	if utopia_held:
		return
	if hold_accum < hold_required_seconds:
		return
	utopia_held = true
	if announce_count != 0:
		return
	announce_count += 1
	print("UTOPIA_HELD")

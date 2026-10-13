class_name ValleySim
extends RefCounted

## Home-valley settlement: people, one levy, timed dwellings, a chronicle.

const HUNGER_DECAY := 0.025
const REST_DECAY := 0.02
const LEVY_HUNGER := 0.07
const LEVY_REST := 0.08
const GRAIN_PER_WORKER := 0.45
const LEAVE_HUNGER := 0.18
const CRUEL_LEVY := 0.7
const STALL_LEVY := 0.9
const LEAVE_SECONDS := 1.0

var agents: Array = []
var buildings: Array = []
var chronicle: Array[String] = []
var levy: float = 0.0
var fence_closed: bool = false
var store_grain: float = 0.0
var dwelling_duration: float = 6.0
var utopia: UtopiaVector
var sim_elapsed: float = 0.0


func _init() -> void:
	utopia = UtopiaVector.new()
	_spawn_people()


func start_dwelling() -> Building:
	var building := Building.new()
	building.kind = "dwelling"
	building.duration = dwelling_duration
	var slot := float(buildings.size())
	building.world_pos = Vector2(slot * 72.0 - 48.0, -96.0)
	buildings.append(building)
	chronicle.append("A dwelling is raised in the valley.")
	return building


func step(dt: float) -> void:
	if dt <= 0.0:
		return
	sim_elapsed += dt
	_advance_buildings(dt)
	_extract_levy(dt)
	_tick_needs(dt)
	_tick_behavior(dt)
	utopia.evaluate(self, dt)


func living_count() -> int:
	var count := 0
	for agent in agents:
		if not agent.left:
			count += 1
	return count


func completed_dwellings() -> int:
	var count := 0
	for building in buildings:
		if building.complete and building.kind == "dwelling":
			count += 1
	return count


func inspect_lines(agent: Agent) -> PackedStringArray:
	var lines := PackedStringArray()
	lines.append(agent.display_name)
	lines.append("hunger %.2f" % agent.hunger)
	lines.append("rest %.2f" % agent.rest)
	lines.append("shelter %.2f" % agent.shelter)
	if agent.left:
		lines.append("walked east")
	elif agent.idle:
		lines.append("idle")
	else:
		lines.append("working")
	if fence_closed and not agent.left:
		lines.append("the gate is closed around them")
	return lines


func _spawn_people() -> void:
	_add_person(0, "Mira", Vector2(-86.0, 18.0))
	_add_person(1, "Bren", Vector2(44.0, -36.0))
	_add_person(2, "Osha", Vector2(-28.0, 74.0))
	_add_person(3, "Kal", Vector2(96.0, 42.0))


func _add_person(id: int, display_name: String, at: Vector2) -> void:
	var agent := Agent.new()
	agent.id = id
	agent.display_name = display_name
	agent.world_pos = at
	agents.append(agent)


func _advance_buildings(dt: float) -> void:
	var rate := 1.0 - levy * 0.55
	if levy >= STALL_LEVY:
		rate = 0.0
	var amount := dt * maxf(rate, 0.0)
	for building in buildings:
		var was_done: bool = building.complete
		building.advance(amount)
		if building.complete and not was_done:
			chronicle.append("The dwelling stands.")


func _extract_levy(dt: float) -> void:
	if levy <= 0.0:
		return
	var workers := 0
	for agent in agents:
		if agent.left:
			continue
		if agent.idle:
			continue
		workers += 1
	store_grain += levy * float(workers) * GRAIN_PER_WORKER * dt


func _tick_needs(dt: float) -> void:
	var homes := completed_dwellings()
	var shelter_target := clampf(0.22 + 0.38 * float(homes), 0.0, 1.0)
	var shelter_rate := 0.16 if homes > 0 else 0.03
	var hunger_drain := HUNGER_DECAY + levy * LEVY_HUNGER
	var rest_drain := REST_DECAY + levy * LEVY_REST
	for agent in agents:
		if agent.left:
			continue
		agent.hunger = clampf(agent.hunger - hunger_drain * dt, 0.0, 1.0)
		agent.rest = clampf(agent.rest - rest_drain * dt, 0.0, 1.0)
		agent.shelter = move_toward(
			agent.shelter, shelter_target, shelter_rate * dt
		)


func _tick_behavior(dt: float) -> void:
	for agent in agents:
		if agent.left:
			continue
		agent.idle = agent.rest < 0.3 or agent.hunger < 0.28
		var starving: bool = agent.hunger <= LEAVE_HUNGER
		var cruel: bool = levy >= CRUEL_LEVY and (
			agent.hunger < 0.4 or agent.rest < 0.35
		)
		if fence_closed and (starving or cruel):
			agent.idle = true
			agent.leave_pressure = 0.0
			continue
		if starving or cruel:
			agent.leave_pressure += dt
		else:
			agent.leave_pressure = maxf(agent.leave_pressure - dt, 0.0)
		if agent.leave_pressure < LEAVE_SECONDS:
			continue
		agent.left = true
		agent.idle = false
		chronicle.append("%s walked east at dusk." % agent.display_name)

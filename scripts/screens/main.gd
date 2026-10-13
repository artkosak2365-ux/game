extends Node

const ValleySim := preload("res://scripts/simulation/valley_sim.gd")
const Agent := preload("res://scripts/simulation/agent.gd")
const Building := preload("res://scripts/simulation/building.gd")

const PITCH_SCALE := 0.65
const PERSON_FILL := Color(0.76, 0.6, 0.32, 1)
const PERSON_IDLE := Color(0.45, 0.42, 0.38, 1)
const PERSON_GONE := Color(0.28, 0.26, 0.24, 0.35)
const HOUSE_FILL := Color(0.38, 0.24, 0.16, 1)
const HOUSE_SITE := Color(0.22, 0.18, 0.14, 0.7)

var _sim: ValleySim
var _pitched: bool = false
var _inspected_id: int = 0
var _person_nodes: Dictionary = {}
var _building_nodes: Array = []
var _clock_label: Label
var _store_label: Label
var _inspect_label: Label
var _chronicle_list: ItemList
var _levy_slider: HSlider
var _levy_value: Label
var _fence_box: CheckBox
var _world_root: Node2D
var _people_root: Node2D
var _buildings_root: Node2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_sim = ValleySim.new()
	_world_root = $WorldRoot
	_people_root = $WorldRoot/PeopleRoot
	_buildings_root = $WorldRoot/BuildingsRoot
	_build_hud()
	_spawn_person_views()
	_refresh_hud()
	print("DYSTOPIA_VALLEY_READY")


func _process(delta: float) -> void:
	var dt := SimClock.clock.step_delta(delta)
	if dt > 0.0:
		_sim.step(dt)
		_sync_world()
	_refresh_hud()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return
	if key.keycode != KEY_SPACE:
		return
	SimClock.clock.toggle_paused()
	get_viewport().set_input_as_handled()


func _build_hud() -> void:
	var hud := $HUD as CanvasLayer
	hud.add_child(_make_top_bar())
	hud.add_child(_make_side_panel())
	hud.add_child(_make_inspect_panel())
	hud.add_child(_make_chronicle_panel())


func _make_top_bar() -> Panel:
	var bar := Panel.new()
	bar.position = Vector2(16, 16)
	bar.size = Vector2(1888, 64)
	var row := HBoxContainer.new()
	row.position = Vector2(12, 12)
	row.size = Vector2(1864, 40)
	row.add_theme_constant_override("separation", 12)
	row.add_child(_make_button("Pause", _on_pause_pressed))
	row.add_child(_make_button("1×", _on_speed_one_pressed))
	row.add_child(_make_button("2×", _on_speed_two_pressed))
	row.add_child(_make_button("Pitch camera", _on_pitch_pressed))
	_clock_label = Label.new()
	_clock_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_clock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_clock_label)
	bar.add_child(row)
	return bar


func _make_side_panel() -> Panel:
	var panel := Panel.new()
	panel.position = Vector2(16, 96)
	panel.size = Vector2(320, 280)
	var col := VBoxContainer.new()
	col.position = Vector2(12, 12)
	col.size = Vector2(296, 256)
	col.add_theme_constant_override("separation", 8)
	var title := Label.new()
	title.text = "Ashvale pocket"
	col.add_child(title)
	_store_label = Label.new()
	col.add_child(_store_label)
	var levy_title := Label.new()
	levy_title.text = "Levy (grain / labor)"
	col.add_child(levy_title)
	_levy_slider = HSlider.new()
	_levy_slider.min_value = 0.0
	_levy_slider.max_value = 1.0
	_levy_slider.step = 0.05
	_levy_slider.value = 0.0
	_levy_slider.value_changed.connect(_on_levy_changed)
	col.add_child(_levy_slider)
	_levy_value = Label.new()
	_levy_value.text = "0.00"
	col.add_child(_levy_value)
	_fence_box = CheckBox.new()
	_fence_box.text = "Close the gate"
	_fence_box.toggled.connect(_on_fence_toggled)
	col.add_child(_fence_box)
	col.add_child(_make_button("Build dwelling", _on_build_pressed))
	panel.add_child(col)
	return panel


func _make_inspect_panel() -> Panel:
	var panel := Panel.new()
	panel.position = Vector2(1584, 96)
	panel.size = Vector2(320, 280)
	var col := VBoxContainer.new()
	col.position = Vector2(12, 12)
	col.size = Vector2(296, 256)
	var title := Label.new()
	title.text = "Person"
	col.add_child(title)
	_inspect_label = Label.new()
	_inspect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_inspect_label)
	panel.add_child(col)
	return panel


func _make_chronicle_panel() -> Panel:
	var panel := Panel.new()
	panel.position = Vector2(16, 900)
	panel.size = Vector2(1888, 164)
	var col := VBoxContainer.new()
	col.position = Vector2(12, 8)
	col.size = Vector2(1864, 148)
	var title := Label.new()
	title.text = "Chronicle"
	col.add_child(title)
	_chronicle_list = ItemList.new()
	_chronicle_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_chronicle_list.custom_minimum_size = Vector2(0, 110)
	col.add_child(_chronicle_list)
	panel.add_child(col)
	return panel


func _make_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.pressed.connect(callback)
	return button


func _spawn_person_views() -> void:
	for agent in _sim.agents:
		var area := Area2D.new()
		area.position = agent.world_pos
		area.input_pickable = true
		area.set_meta("agent_id", agent.id)
		var body := Polygon2D.new()
		body.name = "Body"
		body.polygon = PackedVector2Array(
			[Vector2(-9, -9), Vector2(9, -9), Vector2(9, 9), Vector2(-9, 9)]
		)
		body.color = PERSON_FILL
		area.add_child(body)
		var hit := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(22, 22)
		hit.shape = rect
		area.add_child(hit)
		area.input_event.connect(_on_person_input.bind(agent.id))
		_people_root.add_child(area)
		_person_nodes[agent.id] = area


func _sync_world() -> void:
	for agent in _sim.agents:
		if not _person_nodes.has(agent.id):
			continue
		var area: Area2D = _person_nodes[agent.id]
		var body := area.get_node("Body") as Polygon2D
		if agent.left:
			body.color = PERSON_GONE
			area.position = agent.world_pos + Vector2(140.0, -20.0)
		elif agent.idle:
			body.color = PERSON_IDLE
			area.position = agent.world_pos
		else:
			body.color = PERSON_FILL
			area.position = agent.world_pos
	for building in _sim.buildings:
		_ensure_building_view(building)


func _ensure_building_view(building: Building) -> void:
	var index := _sim.buildings.find(building)
	if index < 0:
		return
	while _building_nodes.size() <= index:
		var poly := Polygon2D.new()
		_buildings_root.add_child(poly)
		_building_nodes.append(poly)
	var node: Polygon2D = _building_nodes[index]
	var width := 28.0 + 20.0 * (building.progress / maxf(building.duration, 0.01))
	var half_w := width * 0.5
	node.position = building.world_pos
	node.polygon = PackedVector2Array(
		[
			Vector2(-half_w, -16.0),
			Vector2(half_w, -16.0),
			Vector2(half_w, 16.0),
			Vector2(-half_w, 16.0),
		]
	)
	node.color = HOUSE_FILL if building.complete else HOUSE_SITE


func _refresh_hud() -> void:
	var speed := SimClock.clock.get_speed()
	var speed_text := "paused"
	if speed == 1:
		speed_text = "1×"
	elif speed == 2:
		speed_text = "2×"
	_clock_label.text = "Sim %.1fs   %s" % [SimClock.clock.sim_time, speed_text]
	_store_label.text = "Store: %.1f grain" % _sim.store_grain
	_levy_value.text = "%.2f" % _sim.levy
	_refresh_inspect()
	_refresh_chronicle()


func _refresh_inspect() -> void:
	var agent := _agent_by_id(_inspected_id)
	if agent == null:
		_inspect_label.text = "Click a person."
		return
	var lines := _sim.inspect_lines(agent)
	_inspect_label.text = "\n".join(lines)


func _refresh_chronicle() -> void:
	while _chronicle_list.item_count < _sim.chronicle.size():
		var line: String = _sim.chronicle[_chronicle_list.item_count]
		_chronicle_list.add_item(line)


func _agent_by_id(id: int) -> Agent:
	for agent in _sim.agents:
		if agent.id == id:
			return agent
	return null


func _on_pause_pressed() -> void:
	SimClock.clock.toggle_paused()


func _on_speed_one_pressed() -> void:
	SimClock.clock.set_speed(1)


func _on_speed_two_pressed() -> void:
	SimClock.clock.set_speed(2)


func _on_pitch_pressed() -> void:
	_pitched = not _pitched
	_world_root.scale.y = PITCH_SCALE if _pitched else 1.0


func _on_build_pressed() -> void:
	_sim.start_dwelling()
	_sync_world()
	_refresh_hud()


func _on_levy_changed(value: float) -> void:
	_sim.levy = value


func _on_fence_toggled(pressed: bool) -> void:
	_sim.fence_closed = pressed


func _on_person_input(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int,
	agent_id: int
) -> void:
	if not event is InputEventMouseButton:
		return
	var mouse := event as InputEventMouseButton
	if not mouse.pressed or mouse.button_index != MOUSE_BUTTON_LEFT:
		return
	_inspected_id = agent_id
	_refresh_inspect()

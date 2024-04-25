extends Node3D
class_name Lane


class TowerQueue:
	extends RefCounted
	signal tower_destroyed
	signal tower_placed

	var lane: Lane
	var current_tower: Tower:
		get:
			return towers[0]
		set(v):
			if current_tower and current_tower.tower_destroyed.is_connected(_on_tower_destroyed):
				current_tower.tower_destroyed.disconnect(_on_tower_destroyed)
				towers[0] = v
			else: 
				towers.append(v)
			current_tower.tower_destroyed.connect(_on_tower_destroyed)
			if in_switchmode: 
				current_tower.start_pulse()
			else: 
				current_tower.stop_pulse()

	var towers: Array[Tower] = []
	var in_switchmode: bool = false

	func _init(lane_to_use: Lane) -> void:
		lane = lane_to_use
		var tower := Tower.instantiate(BaseUnit.pick_element())
		towers.append(tower)
		_place_current_tower()

	func clear() -> void:
		for tower: Tower in towers:
			if is_instance_valid(tower) and not tower.is_queued_for_deletion():
				tower.queue_free()
	
	func start_switchmode() -> void:
		in_switchmode = true
		current_tower.start_pulse()

	func stop_switchmode() -> void:
		in_switchmode = false
		current_tower.stop_pulse()

	func _add_next_tower() -> void:
		var next_tower: Tower = Tower.instantiate(BaseUnit.pick_element(current_tower.element))
		next_tower.set_lane(lane)
		towers.append(next_tower)

	func _on_tower_destroyed() -> void:
		towers.pop_front()
		_place_current_tower()
		tower_destroyed.emit()

	func _place_current_tower() -> void:
		lane.add_child(current_tower)
		current_tower.place(lane)
		current_tower.tower_destroyed.connect(_on_tower_destroyed)
		_add_next_tower()
		await current_tower.place_finished
		if in_switchmode:
			current_tower.start_pulse()
		else:
			current_tower.stop_pulse()
		tower_placed.emit()


const forward := Vector3.FORWARD
@export var progress: float = 0.0
@export var lange_length: float = 4.0

var joypad: Node3D
var keyboard: Node3D

var tower_queue: TowerQueue


func _ready():
	joypad = get_node_or_null("JoypadControl")
	keyboard = get_node_or_null("KeyboardControl")
	GameState.input_mode.changed.connect(__update_inputs)


func start_action() -> void:
	tower_queue = TowerQueue.new(self)


func _exit_tree() -> void:
	if tower_queue:
		tower_queue.clear()


func __update_inputs():
	print(joypad)
	if joypad:
		joypad.visible = GameState.input_mode.value == 0
	if keyboard:
		keyboard.visible = GameState.input_mode.value == 1


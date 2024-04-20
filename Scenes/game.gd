extends Node3D



class TowerQueue:
	var lane: Lane
	var first: Tower:
		get:
			return towers[0]
	var towers: Array[Tower] = []
	func push(t: Tower):
		towers.push_back(t)
	func pop() -> Tower:
		return towers.pop_front()


class SwitchTowerDef:
	var lane1: Lane
	var lane2: Lane
	
	func _init(lanes: Array[Lane]):
		lane1 = lanes.pick_random()
		
		# Rejection sampling
		lane2 = lanes.pick_random()
		while lane1 == lane2:
			lane2 = lanes.pick_random()


const UNITS := [
	preload("res://Scenes/units/player_unit/fire_unit.tscn"),
	preload("res://Scenes/units/player_unit/water_unit.tscn"),
	preload("res://Scenes/units/player_unit/plant_unit.tscn"),
]


const SwitchWarning := preload("res://Scenes/switch_warning.tscn")

@export var menu: Control


@onready var lanes: Array[Lane] = [
	$Lanes/Lane1,
	$Lanes/Lane2,
	$Lanes/Lane3,
]

@onready var tower_queues: Array[TowerQueue] = []
@onready var tower_holder := $Towers

var switches: Array[SwitchTowerDef] = []

var switch_warning_1: Node3D
var switch_warning_2: Node3D

func _ready():
	$Camera3D.make_current()
	var tween: Tween = create_tween()
	set_process_input(false)
	menu.hide()

	tween.tween_property($Camera3D, "position:z", $Camera3D.position.z, 2.0).from($Camera3D.position.z + 10).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel()
	tween.tween_property($Camera3D, "rotation_degrees:x", $Camera3D.rotation_degrees.x, 2.0).from($Camera3D.rotation_degrees.x + 40).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(game_start)


func game_start() ->void:
	set_process_input(true)
	menu.show()

	GameState.mana.changed.connect(__on_mana_changed)
	randomize()
	GameState.player_health.changed.connect(__check_win_loose)
	GameState.enemy_health.changed.connect(__check_win_loose)
	
	GameState.unit_stash.value.append(UNITS.pick_random())
	GameState.unit_stash.value.append(UNITS.pick_random())
	GameState.unit_stash.value.append(UNITS.pick_random())
	GameState.unit_stash.changed.emit()
	
	switch_warning_1 = SwitchWarning.instantiate()
	switch_warning_2 = SwitchWarning.instantiate()
	add_child(switch_warning_1)
	add_child(switch_warning_2)
	
	GameState.tower_switch_timer = get_tree().create_timer(GameState.rules.tower_switch_time)
	GameState.tower_switch_timer.timeout.connect(__on_tower_switch, CONNECT_ONE_SHOT)
	GameState.unit_reached_tower.connect(__on_fight)
	
	switches.append(SwitchTowerDef.new(lanes))
	
	__animate_warning_appear()
	
	for lane in lanes:
		var queue = TowerQueue.new()
		queue.lane = lane
		
		var tower := Tower.instantiate(BaseUnit.pick_element())
		tower_holder.add_child(tower)
		tower.place(lane)
		queue.push(tower)
		
		tower = Tower.instantiate(BaseUnit.pick_element())
		tower.set_lane(lane)
		queue.push(tower)
		
		tower_queues.append(queue)
		
	var unit: Unit = preload("res://Scenes/units/player_unit/fire_unit.tscn").instantiate()
	unit.set_lane(lanes[1])
	unit.summon()
	unit = preload("res://Scenes/units/player_unit/fire_unit.tscn").instantiate()
	unit.set_lane(lanes[2])
	unit.summon()
	unit = preload("res://Scenes/units/player_unit/fire_unit.tscn").instantiate()
	unit.set_lane(lanes[0])
	unit.summon()

func _input(event):
	if event.is_action_pressed("summon_lane_0"):
		__summon_on_lane(0)
	elif event.is_action_pressed("summon_lane_1"):
		__summon_on_lane(1)
	elif event.is_action_pressed("summon_lane_2"):
		__summon_on_lane(2)
	elif event.is_action_pressed("select_0"):
		__select(0)
	elif event.is_action_pressed("select_1"):
		__select(1)
	elif event.is_action_pressed("select_2"):
		__select(2)
	elif event.is_action_released("summon_lane_0"):
		__cancle_summon(0)
	elif event.is_action_released("summon_lane_1"):
		__cancle_summon(1)
	elif event.is_action_released("summon_lane_2"):
		__cancle_summon(2)
		


func __check_win_loose():
	if GameState.enemy_health.value <= 0:
		get_tree().change_scene_to_packed(preload("res://Scenes/win.tscn"))
	elif GameState.player_health.value <= 0:
		get_tree().change_scene_to_packed(preload("res://Scenes/loose.tscn"))


func __select(id: int):
	if id >= len(GameState.unit_stash.value):
		return
	GameState.selected_unit.value = id


var summoning_unit: Unit
var summoning_id: int


func __summon_on_lane(id: int):
	if GameState.selected_unit.value >= len(GameState.unit_stash.value):
		return
	if summoning_unit:
		return
	
	var unit: Unit = GameState.unit_stash.value[GameState.selected_unit.value].instantiate()
	summoning_unit = unit
	summoning_id = id
	
	var lane = lanes[id]
	unit.set_lane(lane)
	unit.summon()
	unit.finished_animation.connect(__on_finished_summoning)
func __on_finished_summoning() -> void:
	GameState.unit_stash.value.remove_at(GameState.selected_unit.value)
	GameState.unit_stash.changed.emit()
	__check_add_unit()
	summoning_unit = null


func __cancle_summon(id: int):
	if not summoning_unit or id != summoning_id:
		return
	summoning_unit.cancle_summoning()
	summoning_unit = null


func __animate_warning_appear():
	if switch_warning_1:
		switch_warning_1.global_position = switches[0].lane1.global_position + Vector3.UP * 2
		switch_warning_1.scale = Vector3.ZERO
		switch_warning_1.show()
	if switch_warning_2:
		switch_warning_2.global_position = switches[0].lane2.global_position + Vector3.UP * 2
		switch_warning_2.scale = Vector3.ZERO
		switch_warning_2.show()
		
	var tween = get_tree().create_tween()
	
	if switch_warning_1:
		tween.tween_property(switch_warning_1, "scale", Vector3.ONE, 0.1)
	if switch_warning_2:
		tween.parallel().tween_property(switch_warning_2, "scale", Vector3.ONE, 0.1).set_delay(0.05)
	await tween.finished

func __animate_warning_disappear():
	var tween = get_tree().create_tween()
	if switch_warning_1:
		tween.tween_property(switch_warning_1, "scale", Vector3.ZERO, 0.1)
	if switch_warning_2:
		tween.parallel().tween_property(switch_warning_2, "scale", Vector3.ZERO, 0.1).set_delay(0.05)
	await tween.finished

func __on_mana_changed():
	__check_add_unit()

func __check_add_unit():
	if GameState.mana.value >= GameState.rules.player_max_mana and len(GameState.unit_stash.value) < GameState.rules.player_unit_stash_size:
		GameState.unit_stash.value.append(UNITS.pick_random())
		GameState.unit_stash.changed.emit()
		GameState.mana.value = 0


func __on_fight(unit: Unit):
	var tower_queue = tower_queues[0]
	var current_lane: Lane = unit.current_lane
	var i = 1
	while i < len(tower_queues) and tower_queue.lane != current_lane:
		tower_queue = tower_queues[i]
		i += 1
	

	var current_tower: Tower = tower_queue.pop()
	
	var win := __rock_paper_siccsor(unit.element,	current_tower.element)
	
	if win:
		GameState.enemy_health.value -= 1
	else:
		GameState.player_health.value -= 1
	
	current_tower.fight(not win)
	unit.fight(win)
	# await current_tower.tower_destroyed
	
	var new_tower: Tower = tower_queue.first
	# Shift the tower queue state
	tower_holder.add_child(new_tower)
	new_tower.place(current_lane)
	tower_queue.push(Tower.instantiate(BaseUnit.pick_element()))


func __on_tower_switch():
	var tq1: TowerQueue
	var tq2: TowerQueue
	
	__animate_warning_disappear()
	
	var switch = switches.pop_front()
	
	for tower_queue in tower_queues:
		if tower_queue.lane == switch.lane1:
			tq1 = tower_queue
		elif tower_queue.lane == switch.lane2:
			tq2 = tower_queue
	
	var i = tq1.towers[0]
	tq1.towers[0] = tq2.towers[0]
	tq2.towers[0] = i
	
	tq1.towers[0].switch_lane(tq1.lane)
	tq2.towers[0].switch_lane(tq2.lane)
	
	switches.append(SwitchTowerDef.new(lanes))
	
	GameState.tower_switch_timer = get_tree().create_timer(GameState.rules.tower_switch_time)
	GameState.tower_switch_timer.timeout.connect(__on_tower_switch, CONNECT_ONE_SHOT)
	
	await get_tree().create_timer(0.5).timeout
	__animate_warning_appear()


func __rock_paper_siccsor(player: BaseUnit.Elements, enemy: BaseUnit.Elements) -> bool:
	if player == enemy:
		return GameState.rules.tie_player_advantage
	match player:
		BaseUnit.Elements.FIRE:
			return enemy == BaseUnit.Elements.PLANT
		BaseUnit.Elements.PLANT:
			return enemy == BaseUnit.Elements.WATER
		BaseUnit.Elements.WATER:
			return enemy == BaseUnit.Elements.FIRE
	# Unreachable
	return true

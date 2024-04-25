class_name Game
extends Node3D


signal game_won
signal game_lost



class SwitchTowerDef:
	var lane1: Lane
	var lane2: Lane
	
	func _init(lanes: Array[Lane]):
		lane1 = lanes.pick_random()
		
		# Rejection sampling
		lane2 = lanes.pick_random()
		while lane1 == lane2:
			lane2 = lanes.pick_random()
		lane1.tower_queue.start_switchmode()
		lane2.tower_queue.start_switchmode()
	
	func clear() -> void:
		lane1.tower_queue.stop_switchmode()
		lane2.tower_queue.stop_switchmode()

const SwitchWarning := preload("res://Scenes/switch_warning.tscn")

@export var menu: Control
@export var camera: Camera3D
@export var camera_position_title: Marker3D
@export var camera_position_game: Marker3D
@export var lanes_node: Node3D
@export var sound_manager: SoundManager
@export var tower_switch_timer: Timer 
@export var summon_streak_timer: Timer

@onready var lanes: Array[Lane] = [
	lanes_node.find_child("Lane1"),
	lanes_node.find_child("Lane2"),
	lanes_node.find_child("Lane3"),
]


var current_switch: SwitchTowerDef

var summon_streak: int = 0
var can_check_summon_streak = false

func _ready():
	GameState.tower_switch_timer = tower_switch_timer
	camera.make_current()
	camera.global_position = camera_position_title.global_position
	camera.global_rotation = camera_position_title.global_rotation
	set_process_input(false)
	menu.hide()

func start_game() -> void:
	sound_manager.start_game()

	var tween: Tween = create_tween()
	tween.tween_property(camera, "global_position", camera_position_game.global_position, 2.0).from(camera_position_title.global_position).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel()
	tween.tween_property(camera, "global_rotation", camera_position_game.global_rotation, 2.0).from(camera_position_title.global_rotation).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(_start_action)


func _start_action() ->void:
	set_process_input(true)
	menu.show()

	
	GameState.mana.changed.connect(__on_mana_changed)
	randomize()
	GameState.player_health.changed.connect(__check_win_loose)
	GameState.enemy_health.changed.connect(__check_win_loose)
	
	var current_element: BaseUnit.Elements = BaseUnit.pick_element()
	GameState.unit_stash.value.append(Unit.get_scene_by_element(current_element))
	current_element = BaseUnit.pick_element(current_element)
	GameState.unit_stash.value.append(Unit.get_scene_by_element(current_element))
	current_element = BaseUnit.pick_element(current_element)
	GameState.unit_stash.value.append(Unit.get_scene_by_element(current_element))
	GameState.unit_stash.changed.emit()
	
	get_tree().create_timer(15).timeout.connect(func() -> void: can_check_summon_streak = true)
	summon_streak_timer.timeout.connect(
		func() -> void: 
			summon_streak = 0
			__check_summon_streak()
			print("reset streak")
			)

	tower_switch_timer.start(GameState.rules.tower_switch_time)
	tower_switch_timer.timeout.connect(__on_tower_switch)
	GameState.unit_reached_tower.connect(__on_fight)
	for lane in lanes:
		lane.start_action()	
	
	current_switch = SwitchTowerDef.new(lanes)
	
	lanes_node.show()

	
	


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		GameState.restart()
		get_tree().reload_current_scene()
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
	if event.is_action_released("summon_lane_0"):
		__cancle_summon(0)
	if event.is_action_released("summon_lane_1"):
		__cancle_summon(1)
	if event.is_action_released("summon_lane_2"):
		__cancle_summon(2)


func __check_win_loose():
	if not menu.is_visible_in_tree():
		return
	__check_endfight_state()
	if GameState.enemy_health.value <= 0:
		__game_won()
	elif GameState.player_health.value <= 0:
		__game_lost()


func __select(id: int):
	print("select ", id)
	if id >= len(GameState.unit_stash.value):
		return
	GameState.selected_unit.value = id


var summoning_unit: Unit
var summoning_id: int


func __summon_on_lane(id: int):
	print("summon ", id)	
	if GameState.selected_unit.value >= len(GameState.unit_stash.value):
		return
	if summoning_unit:
		return
	
	var unit: Unit = GameState.unit_stash.value[GameState.selected_unit.value].instantiate()
	summoning_unit = unit
	summoning_id = id
	
	var lane = lanes[id]
	unit.set_lane(lane)
	unit.summon(game_won, game_lost)
	unit.summon_finished.connect(__on_finished_summoning)

func __on_finished_summoning() -> void:
	GameState.unit_stash.value.remove_at(GameState.selected_unit.value)
	GameState.unit_stash.changed.emit()
	__check_add_unit()
	summoning_unit = null
	if can_check_summon_streak:
		summon_streak += 1
		summon_streak_timer.start(GameState.rules.summon_streak_time)
		__check_summon_streak()


func __cancle_summon(id: int):
	if not summoning_unit or id != summoning_id:
		return
	summoning_unit.cancle_summoning()
	summoning_unit = null



func __on_mana_changed():
	__check_add_unit()

func __check_add_unit():
	if GameState.mana.value >= GameState.rules.player_max_mana and len(GameState.unit_stash.value) < GameState.rules.player_unit_stash_size:
		var current_element: BaseUnit.Elements = BaseUnit.pick_element()
		if len(GameState.unit_stash.value) > 0:
			current_element = BaseUnit.pick_element(Unit.get_element_by_scene(GameState.unit_stash.value.back()))
		GameState.unit_stash.value.append(Unit.get_scene_by_element(current_element))
		GameState.unit_stash.changed.emit()
		GameState.mana.value = 0


func __on_fight(unit: Unit):
	var current_lane: Lane = unit.current_lane

	var current_tower: Tower = current_lane.tower_queue.current_tower
	if current_tower.is_switching:
		await current_tower.switch_finished

	tower_switch_timer.paused = true

	var win := __rock_paper_siccsor(unit.element,	current_tower.element)
	print("Win: ", win)

	current_tower.fight(not win)
	unit.fight(win)
	await current_lane.tower_queue.tower_destroyed

	if win:
		GameState.unit_damage.emit(camera.unproject_position(unit.global_position))
	else:
		GameState.door_damage.emit(camera.unproject_position(current_tower.global_position))
	
	await current_lane.tower_queue.tower_placed
	tower_switch_timer.paused = false
	

func __place_new_tower() -> void:
	pass


func __on_tower_switch():
	Input.start_joy_vibration(0, 0.1, 0.05, 0.3)
	
	var tq1: Lane.TowerQueue = current_switch.lane1.tower_queue
	var tq2: Lane.TowerQueue = current_switch.lane2.tower_queue
	
	var i = tq1.current_tower
	tq1.current_tower = tq2.current_tower
	tq2.current_tower = i
	
	tower_switch_timer.paused = true

	tq1.current_tower.switch_lane(tq1.lane)
	tq2.current_tower.switch_lane(tq2.lane)

	current_switch.clear()	
	current_switch = SwitchTowerDef.new(lanes)
	await tq2.current_tower.switch_finished
	tower_switch_timer.paused = false	


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


func __game_won() -> void:
	sound_manager.play_won()
	menu.hide()
	set_process_input(false)
	__cancle_summon(0)
	__cancle_summon(1)
	__cancle_summon(2)
	tower_switch_timer.paused = true
	for lane: Lane in lanes:
		lane.queue_free()
	game_won.emit()


func __game_lost() -> void:
	sound_manager.play_lost()
	menu.hide()
	set_process_input(false)
	__cancle_summon(0)
	__cancle_summon(1)
	__cancle_summon(2)
	tower_switch_timer.paused = true
	for lane: Lane in lanes:
		lane.queue_free()
	game_lost.emit()


func __check_endfight_state() -> void:
	if GameState.enemy_health.value <= 4:
		summon_streak_timer.paused = true
		can_check_summon_streak = false
		sound_manager.play_endfight()
	elif GameState.player_health.value <= 3:
		summon_streak_timer.paused = true
		can_check_summon_streak = false
		sound_manager.play_endfight()


func __check_summon_streak() -> void:
	if not can_check_summon_streak:
		return
	if summon_streak == GameState.rules.summon_streak_busy:
		sound_manager.play_busy()
		print("streak_busy")
	elif summon_streak == 0:
		sound_manager.play_normal()
		print("streak_ended")

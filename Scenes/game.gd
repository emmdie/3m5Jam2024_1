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


const SwitchWarning := preload("res://Scenes/switch_warning.tscn")

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

func _ready():
	randomize()
	
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


func __on_fight(unit: Unit):
	var tower_queue = tower_queues[0]
	var i = 1
	while i < len(tower_queues) and tower_queue.lane != unit.current_lane:
		tower_queue = tower_queues[i]
		i += 1
	
	var win := __rock_paper_siccsor(unit.element, tower_queue.towers[0].element)
	
	if win:
		GameState.enemy_health.value -= 1
	else:
		GameState.player_health.value -= 1
	
	tower_queue.first.finished_animation.connect(__on_animate_tower_shift.bind(tower_queue), CONNECT_ONE_SHOT)
	tower_queue.first.fight(not win)
	unit.fight(win)
	
	# Shift the tower queue state
	tower_holder.add_child(tower_queue.towers[1])
	tower_queue.pop()
	tower_queue.push(Tower.instantiate(BaseUnit.pick_element()))


func __on_animate_tower_shift(tower_queue: TowerQueue):
	#tower_queue.first.build()
	pass


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

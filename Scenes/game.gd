extends Node3D


class TowerQueue:
	var lane: Lane
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

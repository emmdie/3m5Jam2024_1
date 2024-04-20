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


@onready var lanes: Array[Lane] = [
	$Lanes/Lane1,
	$Lanes/Lane2,
	$Lanes/Lane3,
]

@onready var tower_queues: Array[TowerQueue] = []
@onready var tower_holder := $Towers

var switches: Array[SwitchTowerDef] = []

func _ready():
	randomize()
	
	GameState.tower_switch_timer = get_tree().create_timer(GameState.rules.tower_switch_time)
	GameState.tower_switch_timer.timeout.connect(__on_tower_switch, CONNECT_ONE_SHOT)
	
	switches.append(SwitchTowerDef.new(lanes))
	
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

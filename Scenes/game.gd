extends Node3D


class TowerQueue:
	var towers: Array[Tower] = []
	func push(t: Tower):
		towers.push_back(t)
	func pop() -> Tower:
		return towers.pop_front()


@onready var lanes: Array[Lane] = [
	$Lanes/Lane1,
	$Lanes/Lane2,
	$Lanes/Lane3,
]

@onready var tower_queues: Array[TowerQueue] = []
@onready var tower_holder := $Towers

func _ready():
	randomize()
	
	for lane in lanes:
		var queue = TowerQueue.new()
		
		var tower := Tower.instantiate(BaseUnit.pick_element())
		tower_holder.add_child(tower)
		tower.place(lane)
		queue.push(tower)
		
		tower = Tower.instantiate(BaseUnit.pick_element())
		tower.set_lane(lane)
		queue.push(tower)
		
		tower_queues.append(queue)

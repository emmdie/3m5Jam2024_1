extends Node3D


class TowerQueue:
	var towers: Array[Tower] = []


@onready var lanes: Array[Lane] = [
	$Lanes/Lane1,
	$Lanes/Lane2,
	$Lanes/Lane3,
]

@onready var tower_queues: Array[TowerQueue] = []

func _ready():
	for lane in lanes:
		tower_queues.append(TowerQueue.new())

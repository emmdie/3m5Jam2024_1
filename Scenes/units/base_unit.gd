class_name BaseUnit
extends Node3D

enum Elements {FIRE, WATER, PLANT}

@export var element: Elements

var current_lane: Lane


func set_lane(lane: Lane) -> void:
	current_lane = lane
	current_lane.add_child()

class_name BaseUnit
extends Node3D

signal finished_animation()

enum Elements {
	FIRE, 
	WATER,
	PLANT,
}
const ELEMENTS = [
	Elements.FIRE,
	Elements.WATER,
	Elements.PLANT,
]

static func pick_element() -> Elements:
	return ELEMENTS.pick_random()

@export var element: Elements

var current_lane: Lane

func set_lane(lane: Lane) -> void:
	current_lane = lane
	current_lane.add_child(self)


func fight(_has_won_fight: bool) -> void:
	pass

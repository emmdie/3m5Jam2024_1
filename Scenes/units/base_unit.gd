class_name BaseUnit
extends Node3D

signal finished_animation

enum Elements { FIRE, WATER, PLANT, NONE }
const ELEMENTS = [
	Elements.FIRE,
	Elements.WATER,
	Elements.PLANT,
]


static func pick_element(current_element: Elements = Elements.NONE) -> Elements:
	var elements_to_pick: Array = ELEMENTS.duplicate(true)
	if current_element != Elements.NONE:
		elements_to_pick.erase(current_element)
	return elements_to_pick.pick_random()


@export var element: Elements

var current_lane: Lane


func set_lane(lane: Lane) -> void:
	current_lane = lane


func fight(_has_won_fight: bool) -> void:
	pass


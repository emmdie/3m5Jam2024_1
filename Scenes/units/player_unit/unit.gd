class_name Unit
extends BaseUnit

signal summon_finished
signal fight_finished
signal died
signal disapeared


static func get_scene_by_element(type: Elements) -> PackedScene:
	match type:
		Elements.FIRE:
			return preload("res://Scenes/units/player_unit/fire_unit.tscn")
		Elements.WATER:
			return preload("res://Scenes/units/player_unit/water_unit.tscn")
		Elements.PLANT:
			return preload("res://Scenes/units/player_unit/plant_unit.tscn")
	return preload("res://Scenes/units/player_unit/fire_unit.tscn")


static func get_element_by_scene(scene: PackedScene) -> Elements:
	match scene.resource_path:
		"res://Scenes/units/player_unit/fire_unit.tscn":
			return Elements.FIRE
		"res://Scenes/units/player_unit/plant_unit.tscn":
			return Elements.PLANT
		"res://Scenes/units/player_unit/water_unit.tscn":
			return Elements.WATER
	return Elements.NONE


@export var behavior: Behavior
@export var preview_cam: Camera3D
@export var preview_spot_light: SpotLight3D
@export var preview_kick_light: SpotLight3D
@export var animation: AnimationPlayer

var has_won: bool = false


func summon(level_won_signal: Signal, level_lost_signal: Signal) -> void:
	if preview_cam:
		preview_cam.clear_current()
	if preview_spot_light:
		preview_spot_light.hide()
	if preview_kick_light:
		preview_kick_light.hide()
	current_lane.add_child(self)
	behavior.change_state(UnitStateSummon.new())
	level_won_signal.connect(func() -> void: behavior.change_state(UnitStateWon.new()))
	level_lost_signal.connect(func() -> void: behavior.change_state(UnitStateLoss.new()))


func cancle_summoning() -> void:
	queue_free()


func fight(has_won_fight: bool) -> void:
	has_won = has_won_fight
	behavior.change_state(UnitStateFight.new())


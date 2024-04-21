class_name Tower
extends BaseUnit

signal tower_destroyed


var material: StandardMaterial3D
var max_mult: float
var tween: Tween

func _ready():
	material = (get_child(0).get_child(0).get_child(0).mesh as Mesh).surface_get_material(0).duplicate()
	(get_child(0).get_child(0).get_child(0).mesh as Mesh).surface_set_material(0, material)
	#(get_child(0).get_child(0).get_child(0).mesh as Mesh).surface_set_material()
	print(material)
	max_mult = material.emission_energy_multiplier

func start_pulse():
	if tween:
		tween.stop()
	if is_inside_tree():
		tween = get_tree().create_tween().set_loops()
		tween.tween_property(material, "emission_energy_multiplier", max_mult / 2, 0.2)
		tween.tween_property(material, "emission_energy_multiplier", max_mult * 1, 0.2)

func stop_pulse():
	if tween:
		tween.stop()
	tween = get_tree().create_tween()
	tween.tween_property(material, "emission_energy_multiplier", max_mult, 0.2)

func set_lane(lane: Lane) -> void:
	current_lane = lane

static func instantiate(type: Elements) -> Tower:
	match type:
		Elements.FIRE:
			return preload("res://Scenes/units/tower/fire.tscn").instantiate()
		Elements.WATER:
			return preload("res://Scenes/units/tower/water.tscn").instantiate()
		Elements.PLANT:
			return preload("res://Scenes/units/tower/plant.tscn").instantiate()
	return preload("res://Scenes/units/tower/fire.tscn").instantiate()

func place(lane: Lane) -> void:
	set_lane(lane)
	global_position = lane.global_position
	

func switch_lane(lane: Lane) -> void:
	set_lane(lane)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", lane.global_position, 0.2)


func fight(_has_won_fight: bool) -> void:
	tower_destroyed.emit()
	queue_free()

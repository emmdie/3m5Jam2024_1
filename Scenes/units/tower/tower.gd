class_name Tower
extends BaseUnit

signal tower_destroyed
signal switch_finished

@export var animation: AnimationPlayer

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
	animation.play("build")
	

func switch_lane(lane: Lane) -> void:
	set_lane(lane)
	animation.play_backwards("build")
	await animation.animation_finished
	global_position = current_lane.global_position
	animation.play("build")
	await animation.animation_finished
	switch_finished.emit()

func fight(_has_won_fight: bool) -> void:
	animation.play("fight")
	await animation.animation_finished
	if not _has_won_fight:
		animation.play("die")
	else:
		animation.play_backwards("build")
	await animation.animation_finished
	tower_destroyed.emit()
	queue_free()

class_name Tower
extends BaseUnit

signal tower_destroyed


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

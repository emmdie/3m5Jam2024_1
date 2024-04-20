class_name Tower
extends BaseUnit

static func instantiate(type: Elements):
	match type:
		Elements.FIRE:
			return preload("res://Scenes/units/tower/fire.tscn").instantiate()
		Elements.WATER:
			return preload("res://Scenes/units/tower/water.tscn").instantiate()
		Elements.PLANT:
			return preload("res://Scenes/units/tower/plant.tscn").instantiate()

func switch_lane(lane: Lane) -> void:
	set_lane(lane)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", lane.global_position, 1)

class_name Unit
extends BaseUnit

@export var behavior: Behavior
@export var preview_cam: Camera3D
@export var preview_spot_light: SpotLight3D
@export var preview_kick_light: SpotLight3D

var has_won: bool = false


func summon() -> void:
	if preview_cam:
		preview_cam.clear_current()
	if preview_spot_light:
		preview_spot_light.hide()
	if preview_kick_light:
		preview_kick_light.hide()
	current_lane.add_child(self)
	behavior.change_state(UnitStateSummon.new())


func cancle_summoning() -> void:
	queue_free()


func fight(has_won_fight: bool) -> void:
	has_won = has_won_fight
	behavior.change_state(UnitStateFight.new())


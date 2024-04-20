class_name Unit
extends BaseUnit

@export var behavior: Behavior
@export var preview_cam: Camera2D
@export var preview_spot_light: SpotLight3D
@export var preview_kick_light: SpotLight3D

var has_won: bool = false

func set_lane(lane: Lane) -> void:
	super(lane)

func summon() -> void:
	preview_cam.clear_current()
	preview_spot_light.hide()
	preview_kick_light.hide()
	behavior.change_state(UnitStateSummon.new())


func fight(has_won_fight: bool) -> void:
	has_won = has_won_fight
	behavior.change_state(UnitStateFight.new())


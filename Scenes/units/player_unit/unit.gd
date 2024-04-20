class_name Unit
extends BaseUnit

@export var behavior: Behavior
@export var preview_cam: Camera2D
@export var preview_spot_light: SpotLight3D
@export var preview_kick_light: SpotLight3D



func set_lane(lane: Lane) -> void:
	super(lane)

func summon() -> void:
	preview_cam.clear_current()
	preview_spot_light.hide()
	preview_kick_light.hide()
	behavior.change_state(UnitStateSummon.new())


func fight() -> void:
	behavior.change_state(UnitStateFight.new())


func won() -> void:
	behavior.change_state(UnitStateWon.new())

func loss() -> void:
	behavior.change_state(UnitStateLoss.new())

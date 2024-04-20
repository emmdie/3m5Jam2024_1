class_name Unit
extends BaseUnit

@export var behavior: Behavior
@export var preview_cam: Camera2D
@export var preview_spot_light: SpotLight3D
@export var preview_kick_light: SpotLight3D


var progress: float = 0.0


func set_lane(lane: Lane) -> void:
	super(lane)

func summon() -> void:
	preview_cam.clear_current()
	preview_spot_light.hide()
	preview_kick_light.hide()


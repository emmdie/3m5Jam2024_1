@tool
extends Node3D
class_name Lane

const forward := Vector3.FORWARD
@export var progress: float = 0.0
@export var lange_length: float = 4.0:
	set(val):
		$CSGBox3D.size.z = lange_length
		$CSGBox3D.position.z = lange_length / 2.0
		lange_length = val

func _ready():
	lange_length = lange_length

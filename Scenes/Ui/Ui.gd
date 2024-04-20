extends Control

@onready var preview1 = $MarginContainer/UnitPreviewPanel/MarginContainer/HBoxContainer/UnitPreview1
@onready var preview2 = $MarginContainer/UnitPreviewPanel/MarginContainer/HBoxContainer/UnitPreview2
@onready var preview3 = $MarginContainer/UnitPreviewPanel/MarginContainer/HBoxContainer/UnitPreview3
@onready var previews = [preview1, preview2, preview3]

@export var fire_scene: PackedScene
func update_preview():
	for preview in previews:
		pass

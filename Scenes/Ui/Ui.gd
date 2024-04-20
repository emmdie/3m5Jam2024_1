extends Control

@onready var preview1 = $MarginContainer/UnitPreviewPanel/MarginContainer/HBoxContainer/UnitPreview1
@onready var preview2 = $MarginContainer/UnitPreviewPanel/MarginContainer/HBoxContainer/UnitPreview2
@onready var preview3 = $MarginContainer/UnitPreviewPanel/MarginContainer/HBoxContainer/UnitPreview3
@onready var previews = [preview1, preview2, preview3]

@export var fire_scene: PackedScene

func _ready() -> void:
	GameState.unit_stash.changed.connect(update_preview)
	
func update_preview():
	var stash_size = GameState.unit_stash.value.size()
	for i in previews.size():
		print("unit preview Nr. "+str(i))
		if i >=stash_size:
			previews[i].clear()
		else:
			var unit = GameState.unit_stash.value[i].instantiate()
			previews[i].set_unit(unit)
		

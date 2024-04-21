extends Control

@onready var preview1 = $Previews/UnitPreview1
@onready var preview2 = $Previews/UnitPreview2
@onready var preview3 = $Previews/UnitPreview3
@onready var mana_icon = $MarginContainer/Manabar/HBoxContainer/Spacer/TextureRect
@onready var previews = [preview1, preview2, preview3]
@export var left_icons: Array[Texture]
@export var up_icons: Array[Texture]
@export var right_icons: Array[Texture]

func _ready() -> void:
	GameState.unit_stash.changed.connect(update_preview)
	set_input_icons()
	GameState.selected_unit.changed.connect(highlight)
	highlight()

func _process(delta: float) -> void:
	mana_icon.rotation_degrees += delta *10
	
func update_preview():
	var stash_size = GameState.unit_stash.value.size()
	for i in previews.size():
		print("unit preview Nr. "+str(i))
		if i >=stash_size:
			previews[i].clear()
		else:
			var unit = GameState.unit_stash.value[i].instantiate()
			previews[i].set_unit(unit)
		
func set_input_icons():
	preview1.set_icons(left_icons)
	preview2.set_icons(up_icons)
	preview3.set_icons(right_icons)


func highlight():
	var i = 0
	for preview in previews:
		preview.highlight(i == GameState.selected_unit.value)
		i += 1 

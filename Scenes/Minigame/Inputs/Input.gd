extends TextureRect

@export var right_arrow: Texture
@export var up_arrow: Texture

var input_value

func set_input_value(new_value):
	input_value = new_value
	_set_orientation(new_value)

func _set_orientation(direction):
	if direction == "r":
		texture = right_arrow
		flip_h = false
		flip_v = false
	if direction == "l":
		texture = right_arrow
		flip_h = true
		flip_v = false
	if direction == "u":
		texture = up_arrow
		flip_h = false
		flip_v = false
	if direction == "d":
		texture = up_arrow
		flip_h = false
		flip_v = true

extends PanelContainer

@onready var texture_bar = $CenterContainer/ProgressBar

func _process(delta):
	pass

func update_time():
	texture_bar.value = 0.5

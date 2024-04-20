extends PanelContainer

@onready var bar = $HBoxContainer/ProgressBar

func update() -> void:
	bar.value = 10
	

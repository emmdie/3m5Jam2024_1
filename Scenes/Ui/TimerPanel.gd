extends PanelContainer

@onready var texture_bar = $CenterContainer/ProgressBar
<<<<<<< HEAD
@onready var time_label = $CenterContainer/Label

func _ready() -> void:
	texture_bar.max_value = GameState.rules.tower_switch_time
	
func _process(delta):
	update_time()

func update_time():
	texture_bar.value = GameState.time_to_tower_change
	time_label.text = str(GameState.time_to_tower_change)
	
=======

func _process(delta):
	pass

func update_time():
	texture_bar.value = 0.5
>>>>>>> b2aaf53 (create hud and Ui scene)

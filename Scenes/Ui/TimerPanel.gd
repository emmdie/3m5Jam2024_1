extends PanelContainer

@onready var texture_bar = $CenterContainer/ProgressBar

func _ready() -> void:
	texture_bar.max_value = GameState.rules.tower_switch_time
	
func _process(_delta):
	update_time()

func update_time():
	texture_bar.value = GameState.time_to_tower_change

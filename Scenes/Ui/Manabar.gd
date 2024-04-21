extends PanelContainer

@onready var bar = $HBoxContainer/CenterContainer/ProgressBar
@onready var label = $HBoxContainer/CenterContainer/Label

func _ready() -> void:
	GameState.mana.changed.connect(update)
	update()
	bar.max_value = GameState.rules.player_max_mana
	
func update():
	bar.value = GameState.mana.value
	label.text = str(GameState.mana.value) + " Mana"

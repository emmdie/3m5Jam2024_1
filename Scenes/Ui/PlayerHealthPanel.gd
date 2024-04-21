extends PanelContainer
@onready var container = $GridContainer
@onready var heart_scene= preload("res://Scenes/Ui/enemy_heart.tscn")


func _ready():
	GameState.player_health.changed.connect(update)
	update()
	
func update() -> void:
	var current_hearts = container.get_children()
	if current_hearts.size() < GameState.player_health.value:
		for i in GameState.player_health.value:
			var heart = heart_scene.instantiate()
			container.add_child(heart)
			heart.make_player()
	else:
		for i in current_hearts.size() - GameState.player_health.value:
			container.get_child(i).queue_free()
			
		

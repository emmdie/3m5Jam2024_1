extends PanelContainer

@onready var container = $GridContainer
@export var heart_scene: PackedScene


func _ready():
	GameState.enemy_health.changed.connect(update)
	update()
	
func update() -> void:
	var current_hearts = container.get_children()
	if current_hearts.size() < GameState.enemy_health.value:
		for i in GameState.enemy_health.value:
			var heart = heart_scene.instantiate()
			container.add_child(heart)
	else:
		for i in current_hearts.size() - GameState.enemy_health.value:
			container.get_child(i).queue_free()
			
		

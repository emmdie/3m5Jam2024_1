extends PanelContainer

@onready var container = $GridContainer
@export var heart_scene: PackedScene


func _ready():
	GameState.destroy_enemy.connect(__animate_loose_health)
	
	for i in GameState.rules.enemy_max_health:
		container.add_child(heart_scene.instantiate())
	
	#update()
	
func update() -> void:
	var current_hearts = container.get_children()
	if current_hearts.size() < GameState.enemy_health.value:
		for i in GameState.enemy_health.value:
			var heart = heart_scene.instantiate()
			container.add_child(heart)
	else:
		for i in current_hearts.size() - GameState.enemy_health.value:
			container.get_child(i).queue_free()

func __animate_loose_health(from: Vector2):
	var target: CanvasItem = container.get_child(GameState.enemy_health.value)
	var pos = target.global_position + Vector2(24, 24)
	var stream = ParticleOverlay.create_particle_stream(from, pos)
	stream.hit.connect(func(_c):
		var tween = get_tree().create_tween()
		tween.tween_property(target, "modulate:s", 255, 0.01).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(target, "modulate:s", 0, 0.01).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		)
	stream.finished.connect(func():
		target.modulate.a = 0.0
	)

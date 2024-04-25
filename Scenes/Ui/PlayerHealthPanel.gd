extends PanelContainer
@onready var container = $GridContainer
@onready var heart_scene= preload("res://Scenes/Ui/enemy_heart.tscn")

var internal_health: int

func _ready():
	GameState.door_damage.connect(__animate_loose_health)
	internal_health = GameState.rules.player_max_health
	for i in GameState.rules.player_max_health:
		var heart = heart_scene.instantiate()
		container.add_child(heart)
		heart.make_player()

func __animate_loose_health(from: Vector2) -> void:
	if internal_health <= 0:
		return
	var target: CanvasItem = container.get_child(GameState.rules.player_max_health - internal_health)
	internal_health -= 1
	var pos = target.global_position + Vector2(24, 24)
	var stream = ParticleOverlay.create_particle_stream(from, pos)
	stream.hit.connect(func(_c):
		Input.start_joy_vibration(0, 0.1, 0, 0.05)
		var tween = get_tree().create_tween()
		tween.tween_property(target, "modulate:s", 255, 0.01).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(target, "modulate:s", 0, 0.01).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		)
	stream.finished.connect(func():
		Input.start_joy_vibration(0, 0.1, 0.3, 0.2)
		#target.modulate.a = 0.0
		target.explode()
		GameState.player_health.value -= 1
	)

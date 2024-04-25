class_name Tower
extends BaseUnit

signal tower_destroyed
signal switch_finished
signal place_finished

@export var animation: AnimationPlayer
@export var death_timer: Timer
@export var death_timer_label: Label3D

var sprite: Sprite3D
var max_pixel_size: float
var tween: Tween
var is_switching: bool = false


func _ready():
	sprite = $Sprite3D
	max_pixel_size = sprite.pixel_size
	set_process(false)
	death_timer_label.text = ""


func _process(_delta: float) -> void:
	death_timer_label.text = "%d" % death_timer.time_left


func start_pulse():
	if tween:
		tween.kill()
	if is_inside_tree():
		tween = get_tree().create_tween().set_loops().bind_node($Sprite3D)
		tween.tween_property($Sprite3D, "pixel_size", max_pixel_size * 0.8, 0.2)
		tween.tween_property($Sprite3D, "pixel_size", max_pixel_size, 0.2)
	return


func stop_pulse():
	if tween:
		tween.kill()
	tween = get_tree().create_tween().bind_node($Sprite3D)
	tween.tween_property(sprite, "pixel_size", max_pixel_size, 0.2)


func set_lane(lane: Lane) -> void:
	current_lane = lane


static func instantiate(type: Elements) -> Tower:
	match type:
		Elements.FIRE:
			return preload("res://Scenes/units/tower/fire.tscn").instantiate()
		Elements.WATER:
			return preload("res://Scenes/units/tower/water.tscn").instantiate()
		Elements.PLANT:
			return preload("res://Scenes/units/tower/plant.tscn").instantiate()
	return preload("res://Scenes/units/tower/fire.tscn").instantiate()


func place(lane: Lane) -> void:
	set_lane(lane)
	global_position = lane.global_position
	animation.play("build")
	await animation.animation_finished
	death_timer.start(GameState.rules.tower_death_timeout)
	death_timer.timeout.connect(_on_death_timer_timeout)
	place_finished.emit()
	set_process(true)


func switch_lane(lane: Lane) -> void:
	death_timer.paused = true
	is_switching = true
	set_lane(lane)
	animation.play_backwards("build")
	await animation.animation_finished
	global_position = current_lane.global_position
	animation.play("build")
	await animation.animation_finished
	is_switching = false
	death_timer.paused = false
	switch_finished.emit()


func fight(_has_won_fight: bool) -> void:
	death_timer.paused = true
	animation.play("fight")
	await animation.animation_finished
	if not _has_won_fight:
		animation.play("die")
	else:
		animation.play_backwards("build")
	await animation.animation_finished
	tower_destroyed.emit()
	queue_free()


func _on_death_timer_timeout() -> void:
	animation.play_backwards("build")
	GameState.door_damage.emit(get_viewport().get_camera_3d().unproject_position(global_position))
	await animation.animation_finished
	tower_destroyed.emit()
	queue_free()


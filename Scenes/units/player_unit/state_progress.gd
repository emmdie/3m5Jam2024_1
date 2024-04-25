class_name UnitStateWalking
extends State

var progress_tween: Tween


func start() -> void:
	start_move()


func start_move() -> void:
	var unit: Unit = behavior.unit
	unit.animation.play("walking")
	progress_tween = behavior.create_tween()

	progress_tween.tween_property(unit, "position:z", 3, GameState.rules.unit_lane_completion_time)
	progress_tween.tween_callback(func() -> void: GameState.unit_reached_tower.emit(unit))


func end(new_state: State) -> void:
	if progress_tween and progress_tween.is_valid():
		progress_tween.kill()
	super(new_state)


class_name UnitStateSummon
extends State


func start() -> void:
	var unit: Unit = behavior.unit
	unit.position.z = unit.current_lane.lange_length
	start_move()


func start_move() -> void:
	var unit: Unit = behavior.unit
	var tween: Tween = behavior.create_tween()

	tween.tween_property(unit, "position:z", 1, GameState.rules.unit_lane_completion_time)
	tween.play()
	await tween.finished
	GameState.unit_reached_tower.emit(unit)



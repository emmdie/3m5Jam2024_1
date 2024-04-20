class_name UnitStateSummon
extends State


func start() -> void:
	var unit: Unit = behavior.unit
	unit.current_lane.add_child(unit)
	start_move()
	unit.position.z = unit.current_lane.lange_length


func start_move() -> void:
	var unit: Unit = behavior.unit
	var tween: Tween = behavior.create_tween()

	tween.tween_property(unit, "position.z", 0, GameState.rules.unit_lane_completion_time)
	tween.play()
	await tween.finished
	GameState.unit_reached_tower(unit)



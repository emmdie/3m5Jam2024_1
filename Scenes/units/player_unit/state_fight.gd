class_name UnitStateFight
extends State

func start() -> void:
	var unit: Unit = behavior.unit
	if unit.has_won:
		behavior.change_state(UnitStateWon.new())
	else:
		behavior.change_state(UnitStateLoss.new())

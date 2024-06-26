class_name UnitStateSummon
extends State


func start() -> void:
	var unit: Unit = behavior.unit
	unit.position.z = unit.current_lane.lange_length
	unit.animation.play("summon")
	await unit.animation.animation_finished
	behavior.change_state(UnitStateWalking.new())
	unit.summon_finished.emit()


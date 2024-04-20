extends CanvasLayer


class ParticleStream extends MultiMeshInstance2D:
	signal hit(c)
	signal finished()
	
	var to: Vector2
	var from: Vector2
	var c: int = 0
	var curves: Array[Curve2D] = []
	var time: float = 0.0
	func _init(p_from: Vector2, p_to: Vector2):
		to = p_to
		from = p_from
		multimesh = MultiMesh.new()
		var sphere := SphereMesh.new()
		sphere.radius = 10
		sphere.height = 20
		multimesh.mesh = sphere
		multimesh.use_colors = true
		multimesh.use_custom_data = true
		multimesh.instance_count = 10
		
		for i in multimesh.instance_count:
			multimesh.set_instance_color(i, Color.WHITE)
			var curve = Curve2D.new()
			curve.add_point(from, Vector2.ZERO, Vector2.from_angle(randf_range(0, 2 * PI)) * randf_range(100, 300))
			curve.add_point(to, (from - to) * 0.8, Vector2.ZERO)
			curves.append(curve)
			multimesh.set_instance_custom_data(i, Color(randf_range(1.0, 1.5), 0.0, 0.0))
			multimesh.set_instance_transform_2d(i, Transform2D(0, from))
	
	func _process(delta):
		time += delta
		const damping = 2
		const attraction = 600
		for i in multimesh.instance_count:
			var data = multimesh.get_instance_custom_data(i)
			var duration = data.r
			var progress = clamp(time / duration, 0.0, 1.0)
			if progress >= 1 and data.g < 0.5:
				data.g = 1.0
				multimesh.set_instance_color(i, Color(0.0, 0.0, 0.0, 0.0))
				c += 1
				hit.emit(c)
				multimesh.set_instance_custom_data(i, data)
			progress = ease(progress, 1.7)
			var pos = curves[i].sample(0, progress)
			multimesh.set_instance_transform_2d(i, Transform2D(0, pos))
		
		if c >= multimesh.instance_count:
			finished.emit()
			queue_free()


func create_particle_stream(from: Vector2, to: Vector2) -> ParticleStream:
	var stream = ParticleStream.new(from, to)
	add_child(stream)
	return stream

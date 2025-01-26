extends MeshInstance3D

func set_perspective(perspective: bool) -> void:
	var material : = get_active_material(0);
	
	if material:
		# When changing between ortho/perspective, the far value changes
		# We must adjust our edge threshold to reflect this, or the shader will not work well
		material.set_shader_parameter("edge_scale", 0.5 if perspective else 0.00001);

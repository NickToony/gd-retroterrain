extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func set_perspective(perspective: bool) -> void:
	var material : = get_active_material(0);
	
	if material:
		material.set_shader_parameter("edge_scale", 0.5 if perspective else 0.00001);

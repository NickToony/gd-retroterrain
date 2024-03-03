using Godot;
using System;

public partial class WaterPlane : MeshInstance3D
{
	public void SetPerspective(bool perspective)
	{
		var material = (ShaderMaterial) GetSurfaceOverrideMaterial(0);
		material.SetShaderParameter("edge_scale", perspective ? 0.1f : 0.00001f);
	}
}

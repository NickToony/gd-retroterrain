using Godot;
using System;

public partial class RTSCamera : Camera3D
{
	
	[Export] public int Speed = 100;
	[Export] public int ZoomSpeed = 100;
	
	public override void _Process(double delta)
	{
		if (!Visible) return;
		
		var direction = Vector3.Zero;
		if (Input.IsActionPressed("camera_forward"))
		{
			direction += Vector3.Forward;
		}
		if (Input.IsActionPressed("camera_backward"))
		{
			direction += Vector3.Back;
		}
		if (Input.IsActionPressed("camera_left"))
		{
			direction += Vector3.Left;
		}
		if (Input.IsActionPressed("camera_right"))
		{
			direction += Vector3.Right;
		}

		if (direction != Vector3.Zero)
		{
			Translate(direction.Rotated(new Vector3(1, 0, 0), -Rotation.X) * Speed * (float) delta);
		}

		if (Input.IsActionPressed("camera_zoom_in"))
		{
			Size += ZoomSpeed * (float) delta;
		}
		if (Input.IsActionPressed("camera_zoom_out"))
		{
			Size -= ZoomSpeed * (float) delta;
		}

		Size = Math.Clamp(Size, 10, 100);
	}
	
	public void Enable()
	{
		Visible = true;
		Current = true;
	}
	
	public void Disable()
	{
		Visible = false;
		Current = false;
	}
}

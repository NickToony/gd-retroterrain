using Godot;
using System;

public partial class FPSCamera : Node3D
{
	[Export]
	public float MouseSensitivity = 0.002f;

	[Export] public int Speed = 10;
	
	private Camera3D _camera;

	public override void _Ready()
	{
		_camera = GetNode<Camera3D>("Camera3D");
	}

	public override void _Process(double delta)
	{
		if (!Visible) return;
		
		if (Input.IsActionJustPressed("ui_cancel"))
		{
			Input.MouseMode = Input.MouseMode == Input.MouseModeEnum.Captured
				? Input.MouseModeEnum.Visible
				: Input.MouseModeEnum.Captured;
		}

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
			Translate(direction.Rotated(new Vector3(1, 0, 0), _camera.Rotation.X) * Speed * (float) delta);
		}
	}

	public override void _Input(InputEvent @event)
	{
		if (@event is InputEventMouseMotion specificEvent && (Input.MouseMode == Input.MouseModeEnum.Captured))
		{
			RotateY(-specificEvent.Relative.X * MouseSensitivity);
			_camera.RotateX(-specificEvent.Relative.Y * MouseSensitivity);
			_camera.Rotation = new Vector3(
				Mathf.Clamp(_camera.Rotation.X, -Mathf.DegToRad(70), Mathf.DegToRad(70)),
				_camera.Rotation.Y,
				_camera.Rotation.Z
			);
		}
	}
	
	public void Enable()
    {
        Input.MouseMode = Input.MouseModeEnum.Captured;
        _camera.Current = true;
        Visible = true;
    }

	public void Disable()
	{
		Input.MouseMode = Input.MouseModeEnum.Visible;
		_camera.Current = false;
		Visible = false;
	}
}

using Godot;
using System;

public partial class Main : Node3D
{
    private bool _ortho = true;

    private FPSCamera _fpsCamera;
    private RTSCamera _rtsCamera;
    private WaterPlane _waterPlane;
    
    public override void _Ready()
    {
        _fpsCamera = GetNode<FPSCamera>("FPSCamera");
        _rtsCamera = GetNode<RTSCamera>("RTSCamera");
        _waterPlane = GetNode<WaterPlane>("WaterPlane");
        _fpsCamera.Disable();
        _rtsCamera.Enable();
    }

    public override void _Process(double delta)
    {
        if (Input.IsActionJustPressed("ui_accept"))
        {
            _ortho = !_ortho;
            if (_ortho)
            {
                _fpsCamera.Disable();
                _rtsCamera.Enable();
            }
            else
            {
                _fpsCamera.Enable();
                _rtsCamera.Disable();
            }
            _waterPlane.SetPerspective(!_ortho);
        }
    }
}

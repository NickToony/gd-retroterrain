extends Node3D

@export var rts_mode := true

@onready var camera_rts := $RTSCamera
@onready var camera_fps := $FPSCamera
@onready var water_plane := $WaterPlane

func _ready() -> void:
	update_cameras()

func update_cameras():
	if rts_mode:
		camera_rts.enable()
		camera_fps.disable()
	else:
		camera_rts.disable()
		camera_fps.enable()
	
	# Because the water shader depends on the camera far value, we must adjust our edge threshold
	water_plane.set_perspective(!rts_mode)

func _process(_delta: float) -> void:
	# Toggle between camera modes
	if Input.is_action_just_pressed("ui_accept"):
		rts_mode = !rts_mode
		update_cameras()

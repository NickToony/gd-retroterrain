extends Node3D

@export var sensitivity : float = 0.002
@export var speed : int = 10

@onready var camera: Camera3D = $Camera3D

func _process(delta: float) -> void:
	if !visible:
		return
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode =Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
	
	var direction = Vector3.ZERO
	if Input.is_action_pressed("camera_forward"):
		direction += Vector3.FORWARD
	if Input.is_action_pressed("camera_backward"):
		direction += Vector3.BACK
	if Input.is_action_pressed("camera_left"):
		direction += Vector3.LEFT
	if Input.is_action_pressed("camera_right"):
		direction += Vector3.RIGHT

	if direction != Vector3.ZERO:
		translate(direction.rotated(Vector3(1, 0, 0), camera.rotation.x) * speed * delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var specific_event : InputEventMouseMotion = event
		rotate_y(-specific_event.relative.x * sensitivity)
		camera.rotate_x(-specific_event.relative.y * sensitivity)
		camera.rotation = Vector3(
			clamp(camera.rotation.x, -deg_to_rad(70), deg_to_rad(70)),
			camera.rotation.y,
			camera.rotation.z
		)

func enable() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	visible = true

func disable() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	camera.current = false
	visible = false

extends Node3D

@export var sensitivity : float = 0.002
@export var speed : int = 10

@onready var camera: Camera3D = $Camera3D

func _process(delta: float) -> void:
	# Camera should ignore all input if not ative
	if !visible:
		return
	
	# Toggle the capture mode to help debugging
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode =Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
	
	# Determine the camera movement (4 directions)
	var direction = Vector3.ZERO
	if Input.is_action_pressed("camera_forward"):
		direction += Vector3.FORWARD
	if Input.is_action_pressed("camera_backward"):
		direction += Vector3.BACK
	if Input.is_action_pressed("camera_left"):
		direction += Vector3.LEFT
	if Input.is_action_pressed("camera_right"):
		direction += Vector3.RIGHT

	# If some movement
	if direction != Vector3.ZERO:
		# Translate the camera in the direction of the movement, reletative to the current direction
		translate(direction.rotated(Vector3(1, 0, 0), camera.rotation.x) * speed * delta)

func _input(event: InputEvent) -> void:
	# We capture the mouse movement
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Typecast the event, making it easier to work with
		var specific_event : InputEventMouseMotion = event
		
		# Rotate the camera based on mouse movement
		# You probably want to replace this implementation with something better if you're going fps route
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

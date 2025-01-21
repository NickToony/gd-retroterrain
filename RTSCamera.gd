extends Camera3D

@export var speed := 100
@export var zoom_speed := 100

func _process(delta: float) -> void:
    if !visible:
        return
    
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
        translate(direction.rotated(Vector3(1,0,0), -rotation.x) * speed * delta)
    
    if Input.is_action_pressed("camera_zoom_in"):
        size += zoom_speed * delta
    if Input.is_action_pressed("camera_zoom_out"):
        size -= zoom_speed * delta
    size = clamp(size, 10, 150)

func enable() -> void:
    visible = true
    current = true

func disable() -> void:
    visible = false
    current = false
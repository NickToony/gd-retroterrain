extends MeshInstance3D

@export var size : Vector2i = Vector2i(10, 10)

@export var noise : Noise

@export var should_update : bool = true

@export var smooth : bool = true

@export var grid : bool = true

@export var edge_height : float = -2.5

var coords : Array[Vector3] = []

func _ready() -> void:
    should_update = true

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("toggle_smooth"):
        smooth = !smooth
        should_update = true

    if Input.is_action_just_pressed("toggle_grid"):
        grid = !grid
        should_update = true
    
    if Input.is_action_just_pressed("toggle_regen"):
        noise.seed = randi()
        should_update = true

    if should_update:
        generate_coords()
        should_update = false

func generate_coords() -> void:
    coords.resize((size.x + 1) * (size.y + 1))
    for x in range(size.x + 1):
        for z in range(size.y + 1):
            # Sample a smoothed noise value
            var y = noise.get_noise_2d(x, z) * 15;
            y = floor(y) / 2.0

            if x == 0 or x == size.x-1 or z == 0 or z == size.y-1:
                y = edge_height

            coords[x * size.y + z] = Vector3(x, y, z)

    generate_mesh()

func vertex_color(height: float) -> Color:
    if height > 2:
        return Color.RED
    if height > -2:
        return Color.BLACK
    
    return Color.GREEN;

func generate_mesh() -> void:
    var surface_tool := SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

    for x in range(size.x - 1):
        for z in range(size.y - 1):
            var coord_id := x * size.y + z

            var top_left_vertex := coords[coord_id]
            var top_left_uv := Vector2(0, 0)
            var top_right_vertex := coords[coord_id + 1]
            var top_right_uv := Vector2(1, 0)
            var bottom_left_vertex := coords[coord_id + size.x]
            var bottom_left_uv := Vector2(0, 1)
            var bottom_right_vertex := coords[coord_id + size.x + 1]
            var bottom_right_uv := Vector2(1, 1)

            var vertices: Array[Vector3]
            var uvs: Array[Vector2]
            if triangulation_check(top_left_vertex, bottom_right_vertex):
                vertices = [
                    bottom_left_vertex,
                    bottom_right_vertex,
                    top_left_vertex,
                    bottom_right_vertex,
                    top_right_vertex,
                    top_left_vertex,
                ]
                uvs = [
                    bottom_left_uv,
                    bottom_right_uv,
                    top_left_uv,
                    bottom_right_uv,
                    top_right_uv,
                    top_left_uv,
                ]
            else:
                vertices = [
                    bottom_left_vertex,
                    top_right_vertex,
                    top_left_vertex,
                    bottom_left_vertex,
                    bottom_right_vertex,
                    top_right_vertex,
                ]
                uvs = [
                    bottom_left_uv,
                    top_right_uv,
                    top_left_uv,
                    bottom_left_uv,
                    bottom_right_uv,
                    top_right_uv,
                ]
            
            for i in range(vertices.size()):
                surface_tool.set_uv(uvs[i])
                surface_tool.set_color(vertex_color(vertices[i].y))
                if (!smooth):
                    surface_tool.set_smooth_group(-1)
                surface_tool.add_vertex(vertices[i])
        
    surface_tool.generate_normals()

    var array_mesh := ArrayMesh.new()
    surface_tool.commit(array_mesh)
    mesh = array_mesh

    var shader := ShaderMaterial.new()
    shader.shader = load("res://shaders/terrain.gdshader");
    shader.set_shader_parameter("grassTexture", load("res://assets/grass.jpg"));
    shader.set_shader_parameter("rockTexture", load("res://assets/rock.jpg"));
    shader.set_shader_parameter("sandTexture", load("res://assets/sand.jpg"));
    shader.set_shader_parameter("lineThickness", 0.02);
    shader.set_shader_parameter("lineVisibility", 0.5 if grid else 0.0);
    mesh.surface_set_material(0, shader);

func triangulation_check(coord0: Vector3, coord1: Vector3) -> bool:
    return coord0.y == coord1.y

extends MeshInstance3D

# This is the important file of the demo!
# It generates a terrain mesh using 2D noise, then assigns a shader to it.

# The size of the map, in tiles
@export var size : Vector2i = Vector2i(10, 10)

# The noise to use for the terrain generation
@export var noise : Noise

# Flag to regenerate the terrain mesh.
@export var should_update : bool = true

# Flag to toggle smoothness of the terrain mesh. This just enables smooth normals.
@export var smooth : bool = true

# Flag to toggle the grid visibility
@export var grid : bool = true

# The height to force the edge of the map to be. Creates cliffs around the map.
@export var edge_height : float = -2.5

var coords : Array[Vector3] = []

func _ready() -> void:
    # The map may not exist yet, so always generate
    should_update = true

func _process(_delta: float) -> void:
    # Toggle smoothing, requies a regen of the normal maps
    if Input.is_action_just_pressed("toggle_smooth"):
        smooth = !smooth
        should_update = true

    # Toggle grid visibility by adjusting shader parameter. Does't really require a regen.
    if Input.is_action_just_pressed("toggle_grid"):
        grid = !grid
        should_update = true
    
    # Regenerate the terrain mesh with a new seed
    if Input.is_action_just_pressed("toggle_regen"):
        noise.seed = randi()
        should_update = true

    if should_update:
        # Generate the map mesh, normals, and assign the shader
        generate_coords()
        should_update = false

func generate_coords() -> void:
    # Ensure our array is big enough, should improve performance
    coords.resize((size.x + 1) * (size.y + 1))

    # For every tile in the map
    for x in range(size.x + 1):
        for z in range(size.y + 1):
            # Sample a noise value
            var y = noise.get_noise_2d(x, z) * 15;
            y = floor(y) / 2.0

            # If we're on the edge, force the height to be the edge height
            if x == 0 or x == size.x-1 or z == 0 or z == size.y-1:
                y = edge_height

            # Store the height in the array
            coords[x * size.y + z] = Vector3(x, y, z)

    generate_mesh()

func vertex_color(height: float) -> Color:
    # The terrain shader is very basic - it changes texture based on the colour of the vertex
    if height > 2:
        return Color.RED
    if height > -2:
        return Color.BLACK
    
    return Color.GREEN;

func generate_mesh() -> void:
    # SurfaceTool makes generating the mesh very simple
    var surface_tool := SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

    # For every tile in the map
    for x in range(size.x - 1):
        for z in range(size.y - 1):
            # Calculate the offset of the specific tile
            var coord_id := x * size.y + z

            # Get the vertices and UVs for each corner of the tile
            var top_left_vertex := coords[coord_id]
            var top_left_uv := Vector2(0, 0)
            var top_right_vertex := coords[coord_id + 1]
            var top_right_uv := Vector2(1, 0)
            var bottom_left_vertex := coords[coord_id + size.x]
            var bottom_left_uv := Vector2(0, 1)
            var bottom_right_vertex := coords[coord_id + size.x + 1]
            var bottom_right_uv := Vector2(1, 1)

            # We want to construct an array of vertices/uvs in the correct order
            var vertices: Array[Vector3]
            var uvs: Array[Vector2]

            # We check the height of opposite corners to determine which direction a tile slopes in
            # In some situations, we may want to rotate which triangles are connected to ensure the slope renders correctly
            if triangulation_check(top_left_vertex, bottom_right_vertex):
                # bottom left -> bottom right -> top left -> bottom right -> top right -> top left
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
                # bottom left -> top right -> top left -> bottom left -> bottom right -> top right
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
            
            # Now we have the vertices/uvs in the right order, so we can pass them into he surface tool
            for i in range(vertices.size()):
                # Set the uv/color/properties BEFORE adding the vertex
                surface_tool.set_uv(uvs[i])
                surface_tool.set_color(vertex_color(vertices[i].y))

                if (!smooth):
                    # If smoothing is not enabled, set the smooth group to -1 (never group)
                    # For CSharp I believe the equivelant is to use int.MaxValue
                    surface_tool.set_smooth_group(-1)

                # Add a new vertex, which has all the properties as defined above
                surface_tool.add_vertex(vertices[i])
    
    # Mesh is almost done, be sure to generate normals so lighting works correctly
    surface_tool.generate_normals()

    # Generate the final mesh, and assign it to our mesh instance
    var array_mesh := ArrayMesh.new()
    surface_tool.commit(array_mesh)
    mesh = array_mesh

    # Finally we can assign our shader
    var shader := ShaderMaterial.new()
    shader.shader = load("res://shaders/terrain.gdshader");
    # Vertex colour is used to determine the texture
    shader.set_shader_parameter("grassTexture", load("res://assets/grass.jpg"));
    shader.set_shader_parameter("rockTexture", load("res://assets/rock.jpg"));
    shader.set_shader_parameter("sandTexture", load("res://assets/sand.jpg"));
    # Grid settings
    shader.set_shader_parameter("lineThickness", 0.02);
    shader.set_shader_parameter("lineVisibility", 0.5 if grid else 0.0);
    mesh.surface_set_material(0, shader);

func triangulation_check(coord0: Vector3, coord1: Vector3) -> bool:
    # Check if the two coordinates are on the same height
    return coord0.y == coord1.y

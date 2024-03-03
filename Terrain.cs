using Godot;
using System;

struct Corner
{
    public Vector3 Vertex;
    public Vector2 UV;
}

[Tool]
partial class Terrain : MeshInstance3D
{
    [Export] public Vector2I Size = new(10, 10);

    [Export] public Noise Noise;

    [Export] public bool ShouldUpdate = true;

    [Export] public bool Smooth = false;

    private Vector3[] _coords;

    public override void _Ready()
    {
        ShouldUpdate = true;
    }

    public override void _Process(double delta)
    {
        if (ShouldUpdate)
        {
            CreateCoords();
            ShouldUpdate = false;
        }
    }

    private void CreateCoords()
    {
        _coords = new Vector3[(Size.X + 1) * (Size.Y + 1)];

        for (var x = 0; x <= Size.X; x++)
        {
            for (var z = 0; z <= Size.Y; z++)
            {
                // Sample a smooth noise to get a smooth set of points
                float y = Noise.GetNoise2D(x, z) * 15;
                y = Mathf.Floor(y) / 2f;
                _coords[x * Size.Y + z] = new Vector3(x, y, z);
            }
        }

        // UpdateDebug();
        CreateMesh();
    }

    private void UpdateDebug()
    {
        // Remove all the previous spheres
        foreach (var child in GetChildren())
        {
            if (child is MeshInstance3D meshInstance)
            {
                RemoveChild(meshInstance);
            }
        }

        // For each coordinate, create a sphere to help us visually see the points on the terrain
        foreach (var coord in _coords)
        {
            var meshInstance = new MeshInstance3D();
            var mesh = new SphereMesh();
            mesh.Radius = 0.1f;
            mesh.Height = 0.1f;
            meshInstance.Mesh = mesh;
            meshInstance.Position = coord;
            AddChild(meshInstance);
        }
    }

    private Color VertexColor(float height)
    {
        if (height > 2)
        {
            return Colors.Red;
        }
        
        if (height > -2)
        {
            return Colors.Black;
        }

        return Colors.Green;
    }

    private void CreateMesh()
    {
        var surfaceTool = new SurfaceTool();
        surfaceTool.Begin(Mesh.PrimitiveType.Triangles);

        for (var x = 0; x < Size.X - 1; x += 1)
        {
            for (var z = 0; z < Size.Y - 1; z += 1)
            {
                var coordIdx = (x * Size.Y + z);

                var topLeftWrap = new Corner() { Vertex = _coords[coordIdx], UV = new Vector2(0, 0) };
                var topRightWrap = new Corner() { Vertex = _coords[coordIdx + 1], UV = new Vector2(1, 0) };
                var bottomLeftWrap = new Corner() { Vertex = _coords[coordIdx + Size.X], UV = new Vector2(0, 1) };
                var bottomRightWrap = new Corner() { Vertex = _coords[coordIdx + 1 + Size.X], UV = new Vector2(1, 1) };

                Corner[] corners;
                if (TriangulationCheck(topLeftWrap.Vertex, bottomRightWrap.Vertex))
                {
                    corners = new []
                    {
                        bottomLeftWrap,
                        bottomRightWrap,
                        topLeftWrap,
                        bottomRightWrap,
                        topRightWrap,
                        topLeftWrap
                    };
                }
                else
                {
                    corners = new []
                    {
                        bottomLeftWrap,
                        topRightWrap,
                        topLeftWrap,
                        bottomLeftWrap,
                        bottomRightWrap,
                        topRightWrap,
                    };
                }

                foreach (var corner in corners)
                {
                    surfaceTool.SetUV(corner.UV);
                    surfaceTool.SetColor(VertexColor(corner.Vertex.Y));
                    if (!Smooth)
                    {
                        surfaceTool.SetSmoothGroup(uint.MaxValue);
                    }
                    surfaceTool.AddVertex(corner.Vertex);
                }
            }
        }

        // The reason we use surface tool - it can calculate normals for us
        surfaceTool.GenerateNormals();
        
        // Finally we generate the mesh
        var arrMesh = new ArrayMesh();
        surfaceTool.Commit(arrMesh);
        Mesh = arrMesh;

        // Setup the terrain shader
        // This should probably be a saved resource rather than configured via code
        var shader = new ShaderMaterial();
        shader.Shader = GD.Load<Shader>("res://Terrain.gdshader");
        shader.SetShaderParameter("grassTexture", GD.Load<Texture>("res://grass.jpg"));
        shader.SetShaderParameter("rockTexture", GD.Load<Texture>("res://rock.jpg"));
        shader.SetShaderParameter("sandTexture", GD.Load<Texture>("res://sand.jpg"));
        shader.SetShaderParameter("lineThickness", 0.02f);
        shader.SetShaderParameter("lineVisibility", 0.5f);
        arrMesh.SurfaceSetMaterial(0, shader);
    }

    private bool TriangulationCheck(Vector3 coord0, Vector3 coord1)
    {
        return coord0.Y == coord1.Y;
    }
}
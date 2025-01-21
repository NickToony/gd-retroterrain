# Godot RetroTerrain

An example of how to build terrain similar to old strategy or management games, like _Rollercoaster Tycoon_. It also includes a water shader and basic terrain generation. Rewritten for **Godot 4.3** and **GDScript**!

This implementation is based on the fantastic tutorial by Eric Schubert. Please watch the video for a full guide on how this works (linked below).

<img src="/screenshots/ortho_close.png?raw=true" width="100%" />
<p float="left" align="middle">
  <img src="/screenshots/fps_grid.png?raw=true" width="45%" />
  <img src="/screenshots/ortho_no_grid.png?raw=true" width="45%" />
</p>
<p float="left" align="middle">
   <img src="/screenshots/overview.png?raw=true" width="45%" />
   <img src="/screenshots/smooth_fps_grid.png?raw=true" width="45%" />
</p>


## Features
- Generation of terrain mesh and normals
- Simple terrain shader based on height of vertexes
- FPS and RTS camera implementations
- Basic map generation using FastNoise
- Optional smoothing of normal maps, so the shading looks less blocky
- Optional grid lines for more retro look

## What's missing?
This example should be a great starting point, but if you wanted to take this further:
- Chunk-based map rendering
  - Tying to render huge maps (e.g. 1000x1000) ends up crashing Godot. Try breaking the map into several smaller meshes as needed.
- Collisions
  - Using a similar technique to the mesh generation, you should be able to easily generate a collision shape.

## Credits

- **Eric Schubert** for the original tutorial in Unity
  - https://www.youtube.com/watch?v=55fGgHhF2DM
- **StayAtHomeDev** for the water shader tutorial in Godot
  - https://www.youtube.com/watch?v=7L6ZUYj1hs8
- Myself (**NickToony / Nick Hope**) for bringing this all together in Godot 4.3

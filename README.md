# Godot RetroTerrain

This is an example of how to build terrain similar to old strategy or management games, like Rollercoaster Tycoon. It also includes a water shader and basic terrain generation. While the code is in C# for Godot 4, there's no reason this couldn't work for GDScript and/or Godot 3.5.

This implementation is based on the fantastic tutorial by Eric Schubert. Please watch the video for a full guide on how this works (linked below).

<img src="/screenshots/orthogonal_retro.png?raw=true" width="100%" />
<p float="left" align="middle">
  <img src="/screenshots/perspective_retro.png?raw=true" width="33%" />
  <img src="/screenshots/orthogonal.png?raw=true" width="33%" />
  <img src="/screenshots/perspective.png?raw=true" width="33%" />
</p>

## Features
- Generation of terrain mesh and normals
- Smooth texturing based on height of vertexes
- Perspective and Orthographic camera implementations
- Basic map generation using FastNoise
- Optional smoothing of normal maps, so the shading looks less blocky

## Credits

- Eric Schubert for the original tutorial in Unity
  - https://www.youtube.com/watch?v=55fGgHhF2DM
- StayAtHomeDev for the water shader tutorial in Godot
  - https://www.youtube.com/watch?v=7L6ZUYj1hs8
- Myself (NickToony / Nick Hope) for bringing this all together in Godot 4

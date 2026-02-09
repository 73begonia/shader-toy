# Cubemap Buffer Test Demo

This demo showcases the new **Cubemap Buffer** feature in shader-toy.

## Files

1. **main.glsl** - Main shader that samples from a cubemap buffer
   - References `cubemap_a.glsl` as a cubemap buffer using `#iChannel0::Type "CubeMap"`
   - Demonstrates how to sample from a procedurally generated cubemap

2. **cubemap_a.glsl** - Cubemap buffer shader
   - Generates a procedural cubemap with different colors per face
   - Uses the `iCubeFace` uniform (0-5) to render different content for each face
   - Animates over time using `iTime`

3. **cubemap_feedback.glsl** - Self-referencing cubemap buffer
   - Demonstrates feedback effects by reading from itself (`"self"`)
   - Creates evolving patterns across cubemap faces
   - Shows ping-pong rendering for cubemap buffers

## Usage

Open any of these shaders in VS Code with the shader-toy extension installed:

```bash
# View the main shader with cubemap buffer
code main.glsl

# View the self-referencing cubemap
code cubemap_feedback.glsl
```

## How It Works

### Cubemap Buffer Declaration

To declare a cubemap buffer, reference a `.glsl` file and specify the type:

```glsl
#iChannel0 "file://cubemap_a.glsl"
#iChannel0::Type "CubeMap"
```

### iCubeFace Uniform

Cubemap buffer shaders receive an `iCubeFace` uniform (int, 0-5) indicating which face is being rendered:
- 0 = +X (right)
- 1 = -X (left)
- 2 = +Y (top)
- 3 = -Y (bottom)
- 4 = +Z (front)
- 5 = -Z (back)

### Sampling Cubemap Buffers

Cubemap buffers are sampled using `samplerCube` and a direction vector:

```glsl
vec3 dir = normalize(vec3(x, y, z));
vec4 color = texture(iChannel0, dir);
```

### Self-Referencing

Cubemap buffers support reading from their previous frame:

```glsl
#iChannel0 "self"
#iChannel0::Type "CubeMap"
```

This enables feedback effects using double-buffered cubemap render targets.

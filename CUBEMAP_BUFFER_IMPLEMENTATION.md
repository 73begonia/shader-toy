# Cubemap Buffer Implementation - Complete

## Summary

This implementation adds **Cubemap Buffer** support to the shader-toy VSCode extension, analogous to Shadertoy's "Cube A" feature. Users can now define render passes that output to a cubemap texture (1024×1024, 6 faces), which can then be sampled by other passes as a `samplerCube`.

## Implementation Details

### 1. Type System (`src/typenames.ts`)
- Added `IsCubemapBuffer?: boolean` field to `BufferDefinition`
- Distinguishes cubemap buffers from regular 2D buffers

### 2. Buffer Provider (`src/bufferprovider.ts`)
- Detects when a texture input references a shader file with `Type "CubeMap"`
- Automatically marks the referenced buffer as a cubemap buffer
- Supports self-referencing for feedback effects (ping-pong rendering)

### 3. Constants (`src/constants.ts`)
- Added `CUBEMAP_RESOLUTION = 1024` constant
- Ensures consistent resolution across all cubemap-related code

### 4. Buffer Initialization (`src/extensions/buffers/buffers_init_extension.ts`)
- Creates `WebGLCubeRenderTarget` for cubemap buffers instead of regular 2D targets
- Supports ping-pong targets for self-referencing cubemap buffers
- Adds `iCubeFace` uniform (integer 0-5) to all buffer shaders
- Adds `IsCubemapBuffer` flag to buffer metadata

### 5. Texture Setup (`src/extensions/textures/textures_init_extension.ts`)
- Sets proper channel resolution for cubemap buffers: `vec3(1024, 1024, 6)`
- Handles cubemap buffer textures correctly when used as inputs
- Skips wrap mode settings for cubemap textures (not applicable)

### 6. Shader Compilation (`src/extensions/preamble_extension.ts`, `src/extensions/buffers/shaders_extension.ts`)
- Added `iCubeFace` uniform to shader preamble
- Existing code already replaces `sampler2D` with `samplerCube` for cubemap-typed channels

### 7. WebView Render Loop (`resources/webview_base.html`)
- Renders cubemap buffers 6 times per frame (once for each face)
- Sets `iCubeFace` uniform (0-5) for each face render
- Sets render target to appropriate cubemap face
- Updates `iResolution` to cubemap resolution (1024×1024)
- Skips viewport resizing for cubemap buffers (maintain fixed size)
- Properly handles ping-pong swapping for cubemap targets

### 8. Cubemap Resolution Extension (`src/extensions/cubemap_resolution_extension.ts`)
- Injects `CUBEMAP_RESOLUTION` constant into webview JavaScript
- Ensures runtime code uses the same constant as build-time code

### 9. WebView Content Provider (`src/webviewcontentprovider.ts`)
- Wires up `CubemapResolutionExtension` to inject constant
- Imports and uses `CUBEMAP_RESOLUTION` constant

## Usage

### Basic Cubemap Buffer

**cubemap_a.glsl:**
```glsl
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec3 color = vec3(0.0);
    
    // Use iCubeFace to render different content per face
    // 0=+X, 1=-X, 2=+Y, 3=-Y, 4=+Z, 5=-Z
    if (iCubeFace == 0) {
        color = vec3(1.0, uv.y, uv.x); // +X face (right)
    } else if (iCubeFace == 1) {
        color = vec3(uv.x, 1.0, 1.0); // -X face (left)
    }
    // ... other faces
    
    fragColor = vec4(color, 1.0);
}
```

**main.glsl:**
```glsl
#iChannel0 "file://cubemap_a.glsl"
#iChannel0::Type "CubeMap"

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    // Create a direction vector for cubemap sampling
    vec3 dir = normalize(vec3(uv.x, uv.y, 1.0));
    
    // Sample the cubemap buffer
    vec3 color = texture(iChannel0, dir).rgb;
    
    fragColor = vec4(color, 1.0);
}
```

### Self-Referencing Cubemap Buffer

**cubemap_feedback.glsl:**
```glsl
#iChannel0 "self"
#iChannel0::Type "CubeMap"

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    
    // Create direction based on face and UV
    vec3 dir = normalize(vec3(uv.x - 0.5, uv.y - 0.5, 1.0));
    
    // Sample previous frame from self
    vec3 prevColor = texture(iChannel0, dir).rgb;
    
    // Create new color based on face
    vec3 newColor = vec3(float(iCubeFace) / 6.0);
    
    // Blend for feedback effect
    vec3 color = mix(newColor, prevColor * 0.95, 0.9);
    
    fragColor = vec4(color, 1.0);
}
```

## Key Features

1. ✅ **Cubemap render targets**: WebGLCubeRenderTarget (1024×1024, 6 faces)
2. ✅ **Face-aware rendering**: `iCubeFace` uniform (0-5) identifies which face is being rendered
3. ✅ **Self-referencing**: Support for reading from previous frame via `"self"`
4. ✅ **Ping-pong rendering**: Double-buffered cubemap targets for feedback effects
5. ✅ **Proper sampling**: Automatic `samplerCube` replacement in shader code
6. ✅ **Fixed resolution**: Cubemap buffers maintain 1024×1024 resolution
7. ✅ **Channel resolution**: Reports `vec3(1024, 1024, 6)` for cubemap channels

## Testing

Demo shaders are provided in `demos/cubemap_buffer_test/`:
- `main.glsl` - Basic cubemap buffer usage
- `cubemap_a.glsl` - Procedural cubemap generation
- `cubemap_feedback.glsl` - Self-referencing feedback effects
- `README.md` - Detailed documentation

## Technical Notes

### Cubemap Face Order
- 0 = `TEXTURE_CUBE_MAP_POSITIVE_X` (right)
- 1 = `TEXTURE_CUBE_MAP_NEGATIVE_X` (left)
- 2 = `TEXTURE_CUBE_MAP_POSITIVE_Y` (top)
- 3 = `TEXTURE_CUBE_MAP_NEGATIVE_Y` (bottom)
- 4 = `TEXTURE_CUBE_MAP_POSITIVE_Z` (front)
- 5 = `TEXTURE_CUBE_MAP_NEGATIVE_Z` (back)

### Performance Considerations
- Cubemap buffers render 6 times per frame (6× fragment shader invocations)
- Fixed 1024×1024 resolution provides good quality while maintaining performance
- Consider using lower shader complexity for cubemap buffers if performance is critical

### Limitations
- Cubemap resolution is fixed at 1024×1024 (matching Shadertoy specification)
- Cannot use custom vertex shaders with cubemap buffers (same as 2D buffers)
- Cubemap buffers always use the same framebuffer type as 2D buffers (Float, HalfFloat, or UnsignedByte)

## Security Review

✅ CodeQL security analysis completed with **0 vulnerabilities** found.

## Compatibility

- Compatible with both WebGL 1.0 and WebGL 2.0
- Works with existing texture settings (mag/min filter)
- Compatible with all existing buffer features (self-referencing, dependencies, etc.)

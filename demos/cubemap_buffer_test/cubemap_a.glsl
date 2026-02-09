// Cubemap Buffer A - generates a simple procedural cubemap
// Each face renders a different color based on the face index

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Normalize coordinates to [0,1]
    vec2 uv = fragCoord / iResolution.xy;
    
    // Create different patterns for each cubemap face
    // iCubeFace: 0=+X, 1=-X, 2=+Y, 3=-Y, 4=+Z, 5=-Z
    vec3 color = vec3(0.0);
    
    if (iCubeFace == 0) {
        // +X face - Red gradient
        color = vec3(1.0, uv.y, uv.x);
    } else if (iCubeFace == 1) {
        // -X face - Cyan gradient
        color = vec3(uv.x, 1.0, 1.0);
    } else if (iCubeFace == 2) {
        // +Y face - Green gradient
        color = vec3(uv.x, 1.0, uv.y);
    } else if (iCubeFace == 3) {
        // -Y face - Magenta gradient
        color = vec3(1.0, uv.y, 1.0);
    } else if (iCubeFace == 4) {
        // +Z face - Blue gradient
        color = vec3(uv.x, uv.y, 1.0);
    } else if (iCubeFace == 5) {
        // -Z face - Yellow gradient
        color = vec3(1.0, 1.0, uv.x * uv.y);
    }
    
    // Add some animation
    color *= 0.5 + 0.5 * sin(iTime * 0.5 + float(iCubeFace));
    
    fragColor = vec4(color, 1.0);
}

// Self-referencing cubemap buffer test
// This cubemap buffer reads from itself to create feedback effects

#iChannel0 "self"
#iChannel0::Type "CubeMap"

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    
    // Create a direction based on the current face and UV
    vec3 dir = vec3(0.0);
    float faceIndex = float(iCubeFace);
    
    // Simple rotation based on face
    float angle = iTime * 0.1 + faceIndex * 0.5;
    dir = normalize(vec3(
        cos(angle) * (uv.x - 0.5),
        sin(angle) * (uv.y - 0.5),
        1.0
    ));
    
    // Sample previous frame from self
    vec3 prevColor = texture(iChannel0, dir).rgb;
    
    // Create new color based on face
    vec3 newColor = vec3(
        fract(sin(faceIndex * 12.9898) * 43758.5453),
        fract(sin(faceIndex * 78.233) * 43758.5453),
        fract(sin(faceIndex * 39.346) * 43758.5453)
    );
    
    // Blend with previous frame for feedback effect
    vec3 color = mix(newColor * 0.1, prevColor * 0.95, 0.9);
    
    // Add some energy on mouse click
    if (iMouse.z > 0.0) {
        color += 0.1;
    }
    
    fragColor = vec4(color, 1.0);
}

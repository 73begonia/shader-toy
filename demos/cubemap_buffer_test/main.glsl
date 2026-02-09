// Main Image - samples from the cubemap buffer
// This shader references cubemap_a.glsl as a cubemap buffer

#iChannel0 "file://cubemap_a.glsl"
#iChannel0::Type "CubeMap"

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Normalize coordinates to [-1, 1]
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    // Create a rotating view direction
    float angle = iTime * 0.3;
    vec3 dir = normalize(vec3(
        uv.x * cos(angle) - sin(angle),
        uv.y,
        uv.x * sin(angle) + cos(angle)
    ));
    
    // Sample the cubemap buffer
    vec3 color = texture(iChannel0, dir).rgb;
    
    // Add a vignette effect
    float vignette = 1.0 - length(uv) * 0.5;
    color *= vignette;
    
    fragColor = vec4(color, 1.0);
}

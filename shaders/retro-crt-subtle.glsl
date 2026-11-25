// Kiseki Terminal (macOS) — Subtle CRT Phosphor Bloom & Scanline Shader for Ghostty
// Ported from nerv-base/kiseki-terminal (HLSL) to Ghostty Shadertoy GLSL.
// Preserves razor-sharp typography while adding authentic retro CRT atmosphere.

vec4 sampleBloom(vec2 uv, vec2 texel) {
    vec4 sum = vec4(0.0);
    sum += texture(iChannel0, uv + vec2(-texel.x,  0.0))     * 0.20;
    sum += texture(iChannel0, uv + vec2( texel.x,  0.0))     * 0.20;
    sum += texture(iChannel0, uv + vec2( 0.0,     -texel.y)) * 0.20;
    sum += texture(iChannel0, uv + vec2( 0.0,      texel.y)) * 0.20;
    sum += texture(iChannel0, uv + vec2(-texel.x, -texel.y)) * 0.05;
    sum += texture(iChannel0, uv + vec2( texel.x, -texel.y)) * 0.05;
    sum += texture(iChannel0, uv + vec2(-texel.x,  texel.y)) * 0.05;
    sum += texture(iChannel0, uv + vec2( texel.x,  texel.y)) * 0.05;
    return sum;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 texel = 1.0 / iResolution.xy;
    vec4 color = texture(iChannel0, uv);

    // 1. Gentle phosphor bloom only on bright foreground glyphs
    vec4 blur = sampleBloom(uv, texel * 1.25);
    float luma = dot(blur.rgb, vec3(0.299, 0.587, 0.114));
    float glowMask = smoothstep(0.32, 0.85, luma);
    color.rgb += blur.rgb * glowMask * 0.14;

    // 2. Whisper-soft 2px CRT scanlines (6% modulation — preserves legibility)
    float scan = sin(fragCoord.y * 3.14159265) * 0.5 + 0.5;
    color.rgb *= mix(0.94, 1.0, scan);

    // 3. Very subtle edge vignette for cozy CRT depth
    vec2 centered = uv * 2.0 - 1.0;
    float vig = clamp(1.0 - dot(centered, centered) * 0.06, 0.0, 1.0);
    color.rgb *= vig;

    fragColor = color;
}

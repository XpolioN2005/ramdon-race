shader_type spatial;
//render_mode unshaded;

// Base mesh color
uniform vec3 mesh_color : source_color = vec3(0.0, 1.0, 0.0);

// Outline
uniform vec3 outline_color : source_color = vec3(1.0, 1.0, 0.0);
uniform float outline_size : hint_range(0.0, 1.0) = 0.15;
uniform float outline_strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    float ndotv = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);

    // Fresnel
    float edge = 1.0 - ndotv;

    // HARD cutoff (no smoothstep)
    edge = step(1.0 - outline_size, edge);

    vec3 final_color = mix(mesh_color, outline_color, edge * outline_strength);

    ALBEDO = final_color;
    ALPHA = 1.0;
}

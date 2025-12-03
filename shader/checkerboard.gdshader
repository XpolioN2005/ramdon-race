shader_type spatial;

uniform vec3 color_a = vec3(0.1);
uniform vec3 color_b = vec3(0.9);
uniform float cell_size = 1.2;

varying vec3 world_pos;

void vertex()
{
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment()
{
    vec2 p = floor(world_pos.xz / cell_size);
    float checker = mod(p.x + p.y, 2.0);
    ALBEDO = mix(color_a, color_b, checker);
}

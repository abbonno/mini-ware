shader_type canvas_item;

uniform vec4 color : source_color = vec4(0.0, 1.0, 0.0, 1.0); // Verde por defecto
uniform float border_thickness : hint_range(0.0, 1.0) = 0.1;
uniform float edge_softness : hint_range(0.0, 0.2) = 0.05;

void fragment() {
    vec2 uv = UV;

    float dist_x = min(uv.x, 1.0 - uv.x);
    float dist_y = min(uv.y, 1.0 - uv.y);
    float edge = min(dist_x, dist_y);

    float border = smoothstep(border_thickness, border_thickness - edge_softness, edge);

    COLOR = color;
    COLOR.a *= border; // Solo en los bordes
}

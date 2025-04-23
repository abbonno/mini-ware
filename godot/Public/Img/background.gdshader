shader_type canvas_item;

void fragment() {
    vec2 uv = UV;
    float t = sin(TIME * 0.5) * 0.5 + 0.5; // Animación de color
    vec3 color1 = vec3(0.1, 0.4, 0.8);  // Azul
    vec3 color2 = vec3(0.8, 0.4, 0.1);  // Naranja
    vec3 color = mix(color1, color2, t); // Mezcla animada
    COLOR = vec4(color, 1.0);
}

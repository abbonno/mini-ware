shader_type canvas_item; // Aún por probar

uniform float duration = 10.0; // Duración total del "reloj" en segundos
uniform vec4 fill_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform vec4 bg_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);

void fragment() {
    float progress = clamp(TIME / duration, 0.0, 1.0); // 0 → 1 durante el tiempo de duración
    float fill = 1.0 - UV.y;

    if (fill < progress) {
        COLOR = fill_color;
    } else {
        COLOR = bg_color;
    }
}

shader_type canvas_item;

uniform vec4 bar_color : source_color = vec4(0.0, 1.0, 0.0, 1.0); // Verde
uniform vec4 background_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Negro
uniform float duration : hint_range(0.1, 10.0) = 2.0; // Duración en segundos

void fragment() {
    // Normaliza el tiempo entre 0 y 1 cada "duration" segundos
    float progress = fract(TIME / duration);

    // Usa coordenadas UV horizontales (0 a 1)
    if (UV.x < progress) {
        COLOR = bar_color;
    } else {
        COLOR = background_color;
    }
}

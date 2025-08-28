shader_type canvas_item;

// Colores base
uniform vec4 background_color : source_color = vec4(0.05, 0.05, 0.1, 1.0);
uniform vec4 pixel_color : source_color = vec4(0.8, 0.5, 0.6, 1.0);

// Tamaño del “pixel” (más grande = más retro)
uniform float pixel_size = 8.0;

// Velocidad de animación
uniform float speed = 0.8;

void fragment() {
    // Coordenadas pixeladas (redondeamos UV a bloques grandes)
    vec2 pixel_uv = floor(UV * pixel_size) / pixel_size;

    // Pseudoaleatorio por celda
    float rnd = fract(sin(dot(pixel_uv, vec2(12.9898, 78.233))) * 43758.5453);

    // Oscilación con fase distinta por cada pixel
    float t = TIME * speed + rnd * 6.28318; // cada celda tiene offset
    float intensity = (sin(t) * 0.5 + 0.5); // valor entre 0 y 1

    // Mezclamos colores según intensidad
    vec4 neon_pixel = pixel_color * intensity;
    COLOR = mix(background_color, neon_pixel, intensity);
}

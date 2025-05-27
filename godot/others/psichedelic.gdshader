shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float time;
uniform float wave_intensity : hint_range(0.0, 0.05) = 0.005;
uniform float wave_frequency : hint_range(1.0, 30.0) = 8.0;
uniform float color_shift_intensity : hint_range(0.0, 2.0) = 0.3;
uniform float color_cycle_speed : hint_range(0.1, 5.0) = 1.0;
uniform float chromatic_aberration : hint_range(0.0, 0.02) = 0.002;

void fragment() {
    vec2 uv = UV;

    // Distorsión de ondas más sutil
    float wave_x = sin(uv.y * wave_frequency * 2.0 + time * 2.0) * wave_intensity;
    float wave_y = cos(uv.x * wave_frequency * 1.5 + time * 1.5) * wave_intensity;

    // Añadir un poco de movimiento circular
    float circular_wave = sin(length(uv - 0.5) * wave_frequency * 3.0 + time) * wave_intensity * 0.5;

    vec2 distorted_uv = uv + vec2(wave_x + circular_wave, wave_y + circular_wave);

    // Aberración cromática sutil
    vec4 col;
    col.r = texture(SCREEN_TEXTURE, distorted_uv + vec2(chromatic_aberration, 0.0)).r;
    col.g = texture(SCREEN_TEXTURE, distorted_uv).g;
    col.b = texture(SCREEN_TEXTURE, distorted_uv - vec2(chromatic_aberration, 0.0)).b;
    col.a = texture(SCREEN_TEXTURE, distorted_uv).a;

    // Modulación de color más suave
    float hue_shift = sin(time * color_cycle_speed) * color_shift_intensity;
    float sat_shift = cos(time * color_cycle_speed * 0.7) * color_shift_intensity * 0.5;

    // Aplicar shifts de color de forma más controlada
    col.r = col.r * (1.0 + hue_shift * sin(time * 0.8));
    col.g = col.g * (1.0 + hue_shift * cos(time * 1.2));
    col.b = col.b * (1.0 + hue_shift * sin(time * 0.5 + 1.57)); // +π/2 para desfase

    // Añadir un poco de saturación dinámica
    float avg = (col.r + col.g + col.b) / 3.0;
    col.rgb = mix(vec3(avg), col.rgb, 1.0 + sat_shift);

    COLOR = col;
}
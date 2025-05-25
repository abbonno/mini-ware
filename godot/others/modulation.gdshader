shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform float time;
uniform float intensity = 0.1;

void fragment() {
    vec2 uv = UV;

    // Distorsión en forma de onda
    uv.y += sin(uv.x * 20.0 + time) * intensity;
    uv.x += cos(uv.y * 15.0 + time) * intensity;


    // Colores psicodélicos
    vec4 col = texture(SCREEN_TEXTURE, uv);
    col.rg = col.rg * vec2(sin(time), cos(time));
    col.b = col.b * abs(sin(time * 0.5));

    COLOR = col;
}
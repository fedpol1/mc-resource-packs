#version 150

#define EXTENSION 42.0
#define HOTBAR_SIZE vec2(182.0, 44.0)

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform vec4 FogColor;
uniform int FogShape;

in vec2 texCoord0;
in float fcheck_hotbar;
in float fcheck_top_vertex;
in float fcheck_right_vertex;
in float[6] timer_digits;
in float[5] fog_digits;
in float yaw_direction;
in float pitch_direction;

out vec4 fragColor;

bool check_bounds(vec2 uv, vec2 start, vec2 size)
{
	return uv.x >= start.x && uv.x < start.x + size.x && uv.y >= start.y && uv.y < start.y + size.y;
}

void main() {

	vec2 size = textureSize(Sampler0, 0);
	vec2 step = vec2(7.0, 0.0)/size;
	vec2 hotbar_coord = vec2(fcheck_right_vertex * (HOTBAR_SIZE.x + EXTENSION), (1.0 - fcheck_top_vertex) * HOTBAR_SIZE.y * 0.5);
	float check_field = float(fcheck_right_vertex * (HOTBAR_SIZE.x + EXTENSION) > HOTBAR_SIZE.x) * fcheck_hotbar;
	float check_decimal = float(check_bounds(hotbar_coord, vec2(208.0, 20.0), vec2(1.0, 1.0))) * fcheck_hotbar;
	vec2 texCoord0_altered = texCoord0 + (
			   + (vec2(-173.0, 37.0)/size + step * timer_digits[0]) * float(check_bounds(hotbar_coord, vec2(188.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(-179.0, 37.0)/size + step * timer_digits[1]) * float(check_bounds(hotbar_coord, vec2(194.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(-185.0, 37.0)/size + step * timer_digits[2]) * float(check_bounds(hotbar_coord, vec2(200.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(-191.0, 37.0)/size + step * timer_digits[3]) * float(check_bounds(hotbar_coord, vec2(206.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(-197.0, 37.0)/size + step * timer_digits[4]) * float(check_bounds(hotbar_coord, vec2(212.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(-203.0, 37.0)/size + step * timer_digits[5]) * float(check_bounds(hotbar_coord, vec2(218.0, 1.0), vec2(5.0, 6.0)))
			   
			   + (vec2(-203.0, 23.0)/size + step * float(FogShape)) * float(check_bounds(hotbar_coord, vec2(217.0, 8.0), vec2(6.0, 6.0)))
			   
			   + (vec2(-169.0, 23.0)/size + step * fog_digits[0]) * float(check_bounds(hotbar_coord, vec2(184.0, 15.0), vec2(5.0, 6.0)))
			   + (vec2(-175.0, 23.0)/size + step * fog_digits[1]) * float(check_bounds(hotbar_coord, vec2(190.0, 15.0), vec2(5.0, 6.0)))
			   + (vec2(-181.0, 23.0)/size + step * fog_digits[2]) * float(check_bounds(hotbar_coord, vec2(196.0, 15.0), vec2(5.0, 6.0)))
			   + (vec2(-187.0, 23.0)/size + step * fog_digits[3]) * float(check_bounds(hotbar_coord, vec2(202.0, 15.0), vec2(5.0, 6.0)))
			   + (vec2(-195.0, 23.0)/size + step * fog_digits[4]) * float(check_bounds(hotbar_coord, vec2(210.0, 15.0), vec2(5.0, 6.0)))
			   ) * check_field;
			   
	float fog_bounds = float(check_bounds(hotbar_coord, vec2(217.0, 15.0), vec2(6.0, 6.0))) * fcheck_hotbar;
	vec4 fog_component_bounds = vec4(
		float(check_bounds(hotbar_coord, vec2(190.0, 8.0), vec2(5.0, 6.0))),
		float(check_bounds(hotbar_coord, vec2(196.0, 8.0), vec2(5.0, 6.0))),
		float(check_bounds(hotbar_coord, vec2(202.0, 8.0), vec2(5.0, 6.0))),
		float(check_bounds(hotbar_coord, vec2(210.0, 8.0), vec2(5.0, 6.0)))
	) * fcheck_hotbar;
	
	float fog_bounded = min(1.0, fog_bounds + fog_component_bounds.r + fog_component_bounds.g + fog_component_bounds.b + fog_component_bounds.a);

    vec4 color = texture(Sampler0, texCoord0_altered) * (1.0 - check_field * float(texCoord0 == texCoord0_altered));
	color += vec4(vec3(0.25), 0.5) * check_field;
	color += vec4(1.0) * check_decimal;
	color = color * (1.0 - fog_bounded)
		+ vec4(FogColor.rgb, 1.0) * fog_bounds
		+ vec4(FogColor.r, 0.0, 0.0, 1.0) * fog_component_bounds.r
		+ vec4(0.0, FogColor.g, 0.0, 1.0) * fog_component_bounds.g
		+ vec4(0.0, 0.0, FogColor.b, 1.0) * fog_component_bounds.b
		+ vec4(FogColor.aaa, 1.0) * fog_component_bounds.a;

    if (color.a == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;
}

#version 150

#define EXTENSION 47.0
#define HOTBAR_SIZE vec2(182.0, 44.0)

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform vec4 FogColor;

in vec2 texCoord0;
in float fcheck_hotbar;
in float fcheck_top_vertex;
in float fcheck_right_vertex;
in float[6] yaw_digits;
in float[5] pitch_digits;
in float[6] fog_digits;
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
	float check_decimal = float(check_bounds(hotbar_coord, vec2(207.0, 6.0), vec2(1.0, 1.0))
	                         || check_bounds(hotbar_coord, vec2(207.0, 13.0), vec2(1.0, 1.0))
	                         || check_bounds(hotbar_coord, vec2(207.0, 20.0), vec2(1.0, 1.0))) * fcheck_hotbar;
	vec2 texCoord0_altered = texCoord0 + (
			   + (vec2(-168.0, 37.0)/size + step * yaw_digits[0]) * float(check_bounds(hotbar_coord, vec2(183.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(-174.0, 37.0)/size + step * yaw_digits[1]) * float(check_bounds(hotbar_coord, vec2(189.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(-180.0, 37.0)/size + step * yaw_digits[2]) * float(check_bounds(hotbar_coord, vec2(195.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(-186.0, 37.0)/size + step * yaw_digits[3]) * float(check_bounds(hotbar_coord, vec2(201.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(-194.0, 37.0)/size + step * yaw_digits[4]) * float(check_bounds(hotbar_coord, vec2(209.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(-200.0, 37.0)/size + step * yaw_digits[5]) * float(check_bounds(hotbar_coord, vec2(215.0, 1.0), vec2(5.0, 6.0)))
			   
			   + (vec2(-174.0, 30.0)/size + step * pitch_digits[0]) * float(check_bounds(hotbar_coord, vec2(189.0, 8.0), vec2(5.0, 6.0)))
			   + (vec2(-180.0, 30.0)/size + step * pitch_digits[1]) * float(check_bounds(hotbar_coord, vec2(195.0, 8.0), vec2(5.0, 6.0)))
			   + (vec2(-186.0, 30.0)/size + step * pitch_digits[2]) * float(check_bounds(hotbar_coord, vec2(201.0, 8.0), vec2(5.0, 6.0)))
			   + (vec2(-194.0, 30.0)/size + step * pitch_digits[3]) * float(check_bounds(hotbar_coord, vec2(209.0, 8.0), vec2(5.0, 6.0)))
			   + (vec2(-200.0, 30.0)/size + step * pitch_digits[4]) * float(check_bounds(hotbar_coord, vec2(215.0, 8.0), vec2(5.0, 6.0)))
			   
			   + (vec2(-168.0, 23.0)/size + step * fog_digits[0]) * float(check_bounds(hotbar_coord, vec2(183.0, 15.0), vec2(5.0, 6.0)))
			   + (vec2(-174.0, 23.0)/size + step * fog_digits[1]) * float(check_bounds(hotbar_coord, vec2(189.0, 15.0), vec2(5.0, 6.0)))
			   + (vec2(-180.0, 23.0)/size + step * fog_digits[2]) * float(check_bounds(hotbar_coord, vec2(195.0, 15.0), vec2(5.0, 6.0)))
			   + (vec2(-186.0, 23.0)/size + step * fog_digits[3]) * float(check_bounds(hotbar_coord, vec2(201.0, 15.0), vec2(5.0, 6.0)))
			   + (vec2(-194.0, 23.0)/size + step * fog_digits[4]) * float(check_bounds(hotbar_coord, vec2(209.0, 15.0), vec2(5.0, 6.0)))
			   + (vec2(-200.0, 23.0)/size + step * fog_digits[5]) * float(check_bounds(hotbar_coord, vec2(215.0, 15.0), vec2(5.0, 6.0)))
			   
			   + (vec2(-208.0, 30.0)/size + step * yaw_direction) * float(check_bounds(hotbar_coord, vec2(222.0, 1.0), vec2(6.0, 6.0)))
			   + (vec2(-187.0, 16.0)/size + step * pitch_direction) * float(check_bounds(hotbar_coord, vec2(222.0, 8.0), vec2(6.0, 6.0)))
			   ) * check_field;
			   
	float fog_bounds = float(check_bounds(hotbar_coord, vec2(222.0, 15.0), vec2(6.0, 6.0))) * fcheck_hotbar;
			   
    vec4 color = texture(Sampler0, texCoord0_altered) * (1.0 - check_field * float(texCoord0 == texCoord0_altered));
	color += vec4(vec3(0.25), 0.5) * check_field;
	color += vec4(1.0) * check_decimal;
	color = color * (1.0 - fog_bounds) + vec4(FogColor.rgb, 1.0) * fog_bounds;

    if (color.a == 0.0) {
        discard;
    }
    //fragColor = vec4(hotbar_topright_position/size * 4.0, 0.0, 1.0) * ColorModulator;
    fragColor = color * ColorModulator;
}

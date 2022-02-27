#version 150

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;

in vec2 texCoord0;
in float fcheck_hotbar;
in float[6] yaw_digits;
in float[5] pitch_digits;
in float[6] fog_digits;

out vec4 fragColor;

bool check_bounds(vec2 uv, vec2 start, vec2 size)
{
	return uv.x >= start.x && uv.x < start.x + size.x && uv.y >= start.y && uv.y < start.y + size.y;
}

void main() {

	vec2 size = textureSize(Sampler0, 0);
	// 250 172
	vec2 step = vec2(0.0, 7.0)/size;
	float check_field = float(check_bounds(texCoord0 * size, vec2(182.0, 0.0), vec2(39.0, 22.0))) * fcheck_hotbar;
	float check_decimal = float(check_bounds(texCoord0 * size, vec2(207.0, 6.0), vec2(1.0, 1.0))
	                         || check_bounds(texCoord0 * size, vec2(207.0, 13.0), vec2(1.0, 1.0))
	                         || check_bounds(texCoord0 * size, vec2(207.0, 20.0), vec2(1.0, 1.0))) * fcheck_hotbar;
	vec2 texCoord0_altered = texCoord0 + (
			   + (vec2(68.0, 186.0)/size + step * yaw_digits[0]) * float(check_bounds(texCoord0 * size, vec2(183.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(62.0, 186.0)/size + step * yaw_digits[1]) * float(check_bounds(texCoord0 * size, vec2(189.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(56.0, 186.0)/size + step * yaw_digits[2]) * float(check_bounds(texCoord0 * size, vec2(195.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(50.0, 186.0)/size + step * yaw_digits[3]) * float(check_bounds(texCoord0 * size, vec2(201.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(42.0, 186.0)/size + step * yaw_digits[4]) * float(check_bounds(texCoord0 * size, vec2(209.0, 1.0), vec2(5.0, 6.0)))
			   + (vec2(36.0, 186.0)/size + step * yaw_digits[5]) * float(check_bounds(texCoord0 * size, vec2(215.0, 1.0), vec2(5.0, 6.0)))
			   
			   + (vec2(62.0, 179.0)/size + step * pitch_digits[0]) * float(check_bounds(texCoord0 * size, vec2(189.0, 8.0), vec2(5.0, 6.0)))
			   + (vec2(56.0, 179.0)/size + step * pitch_digits[1]) * float(check_bounds(texCoord0 * size, vec2(195.0, 8.0), vec2(5.0, 6.0)))
			   + (vec2(50.0, 179.0)/size + step * pitch_digits[2]) * float(check_bounds(texCoord0 * size, vec2(201.0, 8.0), vec2(5.0, 6.0)))
			   + (vec2(42.0, 179.0)/size + step * pitch_digits[3]) * float(check_bounds(texCoord0 * size, vec2(209.0, 8.0), vec2(5.0, 6.0)))
			   + (vec2(36.0, 179.0)/size + step * pitch_digits[4]) * float(check_bounds(texCoord0 * size, vec2(215.0, 8.0), vec2(5.0, 6.0)))
			   
			   + (vec2(68.0, 172.0)/size + step * fog_digits[0]) * float(check_bounds(texCoord0 * size, vec2(183.0, 15.0), vec2(5.0, 6.0)))
			   + (vec2(62.0, 172.0)/size + step * fog_digits[1]) * float(check_bounds(texCoord0 * size, vec2(189.0, 15.0), vec2(5.0, 6.0)))
			   + (vec2(56.0, 172.0)/size + step * fog_digits[2]) * float(check_bounds(texCoord0 * size, vec2(195.0, 15.0), vec2(5.0, 6.0)))
			   + (vec2(50.0, 172.0)/size + step * fog_digits[3]) * float(check_bounds(texCoord0 * size, vec2(201.0, 15.0), vec2(5.0, 6.0)))
			   + (vec2(42.0, 172.0)/size + step * fog_digits[4]) * float(check_bounds(texCoord0 * size, vec2(209.0, 15.0), vec2(5.0, 6.0)))
			   + (vec2(36.0, 172.0)/size + step * fog_digits[5]) * float(check_bounds(texCoord0 * size, vec2(215.0, 15.0), vec2(5.0, 6.0)))
			   ) * check_field;
    vec4 color = texture(Sampler0, texCoord0_altered) * (1.0 - check_field * float(texCoord0 == texCoord0_altered));
	color += vec4(vec3(0.25), 0.5) * check_field;
	color += vec4(1.0) * check_decimal;

    if (color.a == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;
}

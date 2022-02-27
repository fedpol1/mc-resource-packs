#version 150

#define SENSITIVITY 0.0625

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;

in vec2 texCoord0;
in float v_check_tab;

out vec4 fragColor;

void main() {
	float check_tab = float(textureSize(Sampler0, 0) == vec2(64.0, 64.0)) * v_check_tab;
	float check_hat = float(texCoord0.x >= 0.625 && texCoord0.y >= 0.125 && texCoord0.x <= 0.75 && texCoord0.y <= 0.25);

    vec4 pre_color = texture(Sampler0, texCoord0);
	vec4 face_color = texture(Sampler0, clamp(texCoord0 - vec2(0.5, 0.0), 0.0, 1.0));
	
	vec3 d = pre_color.rgb - face_color.rgb;
	float diff = dot(d, d) * pre_color.a;

    vec4 indicator_color = vec4(
		check_tab * check_hat, 
		check_tab * ((1.0 - check_hat) * 0.75 + float(diff < SENSITIVITY) * check_hat * 0.5), 
		0.0, 
		check_tab);
		
    vec4 color = pre_color * vec4(vec3(1.0 - check_tab), 1.0) + indicator_color;
    if (color.a == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;
}

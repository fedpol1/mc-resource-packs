#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 vertexColorNoTint;
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
	float check_tint = float(abs(color.a - 196.0/255.0) < 0.004); // does this part of the tinted texture need to be not tinted?
	vec4 tint = check_tint * vertexColorNoTint + (1.0 - check_tint) * vertexColor;
	color.a = check_tint * 1.0 + (1.0 - check_tint) * color.a;
	color *= tint * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}

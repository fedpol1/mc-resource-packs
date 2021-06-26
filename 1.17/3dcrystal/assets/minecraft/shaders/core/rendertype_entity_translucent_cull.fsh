#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;

out vec4 fragColor;

bool check_crystal(vec4 color) {
	vec2 d = color.ra - vec2(255.0, 63.0) / 255.0;
	return dot(d, d) < 0.004;
}

void main() {
    vec4 color = texture(Sampler0, texCoord0);
	if(check_crystal(color)) { color = texture(Sampler0, vec2(texCoord0.x + 64.0/1024.0, texCoord0.y)); }
	color *= vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}

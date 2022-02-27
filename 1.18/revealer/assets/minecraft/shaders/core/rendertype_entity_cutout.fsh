#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec4 normal;

out vec4 fragColor;

bool check(vec4 color) {
	vec2 d = color.ra - vec2(255.0, 63.0) / 255.0;
	return dot(d, d) < 0.004;
}

void main() {
    vec4 color = texture(Sampler0, texCoord0);
	color = texture(Sampler0, vec2(texCoord0.x + float(check(color)) * 16.0/1024.0, texCoord0.y));
    if (color.a < 0.1) { discard; }
    color *= vertexColor * ColorModulator;
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    color *= lightMapColor;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}

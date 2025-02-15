#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float AlphaThreshold;

in float vertexDistance;
in float sphericalDistance;
in float fov;
in vec4 vertexColor;
in vec2 texCoord0;
in vec4 normal;

out vec4 fragColor;

void main() {
	float check_highlight = float(abs(sphericalDistance - 2.0*(fov - 30.0) - 0.5) < 0.5);
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
	color.rgb = color.rgb * (1.0 - check_highlight) + vec3(1.0, 0.0, 0.0) * check_highlight;
    if (color.a < AlphaThreshold) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}

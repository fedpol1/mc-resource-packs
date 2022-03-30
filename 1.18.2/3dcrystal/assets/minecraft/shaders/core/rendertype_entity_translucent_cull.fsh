#version 150

#moj_import <fog.glsl>
#moj_import <crystal_util.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
	
	vec2 d = color.ra - vec2(255.0, 63.0) / 255.0;
	float check_crystal = float(dot(d, d) < EPSILON); // is the thing a crystal?
	
	color = texture(Sampler0, vec2(texCoord0.x + 64.0/textureSize(Sampler0, 0).x * check_crystal, texCoord0.y));
	color *= vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}

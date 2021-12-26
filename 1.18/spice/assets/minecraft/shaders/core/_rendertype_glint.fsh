#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform mat4 TextureMat;
uniform float AppliesToItems;

in float vertexDistance;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);// * ColorModulator;
    if (color.a == 0.0) { discard; }
	fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, vec4(vec3(vec3(1.0) - FogColor.rgb), FogColor.a));
}

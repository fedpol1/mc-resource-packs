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
	vec4 fog_probe = linear_fog(vec4(vec3(-1.0), 1.0), vertexDistance, FogStart, FogEnd, FogColor);
	float fog_intensity = ((fog_probe + 1.0) / (FogColor + 1.0)).r;
	fragColor = vec4(mix(color.rgb, vec3(1.0) - FogColor.rgb, fog_intensity), color.a);
}

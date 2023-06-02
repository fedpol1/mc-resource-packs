#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float GlintAlpha;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform mat4 TextureMat;
uniform float AppliesToItems;

in float vertexDistance;
in vec2 texCoord0;

out vec4 fragColor;

// used for hue rotation, in which case axis would be vec3(1.0), normalized
mat4 rotate(vec3 u, float rt) { // axis, theta
	return mat4(
		cos(rt)+u.x*u.x*(1.0-cos(rt)), 		u.x*u.y*(1.0-cos(rt))+u.z*sin(rt), 		u.x*u.z*(1.0-cos(rt))-u.y*sin(rt), 	0.0,
		u.x*u.y*(1.0-cos(rt))-u.z*sin(rt), 	cos(rt)+u.y*u.y*(1.0-cos(rt)), 			u.y*u.z*(1.0-cos(rt))+u.x*sin(rt), 	0.0,
		u.x*u.z*(1.0-cos(rt))+u.y*sin(rt), 	u.y*u.z*(1.0-cos(rt))-u.x*sin(rt), 		cos(rt)+u.z*u.z*(1.0-cos(rt)), 		0.0,
	    0.0, 								0.0, 									0.0, 								1.0);
}

void main() {
    vec4 color = texture(Sampler0, texCoord0);// * ColorModulator;
    if (color.a == 0.0) { discard; }
	
	color.rgb = (rotate(vec3(0.5773502691896258), GlintAlpha * 2.0 * 3.14159265358979) * color).rgb; // 0.577.. = 1/sqrt(3)
	
	vec4 fog_probe = linear_fog(vec4(vec3(-1.0), 1.0), vertexDistance, FogStart, FogEnd, FogColor);
	float fog_intensity = ((fog_probe + 1.0) / (FogColor + 1.0)).r;
	fragColor = vec4(mix(color.rgb, vec3(1.0) - FogColor.rgb, fog_intensity), color.a);
}

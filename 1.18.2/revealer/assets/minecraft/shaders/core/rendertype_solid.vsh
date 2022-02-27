#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ChunkOffset;
uniform int FogShape;
uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 normal;

bool check(vec4 color) {
	vec2 d = color.ra - vec2(255.0, 63.0) / 255.0;
	return dot(d, d) < 0.004;
}

bool check_special(vec4 color) {
	vec2 d = color.ga - vec2(255.0, 63.0) / 255.0;
	return dot(d, d) < 0.004;
}

void main() {
	vec4 col = texture(Sampler0, UV0);
	float c = float(check(col));
	float cs = float(check_special(col));
	
    vec3 pos = Position + ChunkOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
	gl_Position.z *= 1.0 - 0.9375 * c;

    vertexDistance = fog_distance(ModelViewMat, pos, FogShape) * (1.0 - c);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2) * (1.0 - c)
				+ minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1.0)) * c * (1.0 - cs)
				+ Color * minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1.0)) * c * cs;
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}

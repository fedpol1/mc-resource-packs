#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec4 normal;
out float check_pop;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

	bool check_inventory = ModelViewMat[3].r > 2.0 && ModelViewMat[3].g > 2.0; // is the crystal in a GUI?
	bool check_hand_world = ProjMat[1].g > 0.5;
	check_pop = float(!check_inventory && !check_hand_world);

    vertexDistance = cylindrical_distance(ModelViewMat, IViewRotMat * Position);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}

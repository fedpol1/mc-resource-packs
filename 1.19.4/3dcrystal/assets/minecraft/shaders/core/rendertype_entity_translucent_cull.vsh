#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

#define PI 3.1415926535897932

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat4 IdentityMat;
uniform mat3 IViewRotMat;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;
uniform float GameTime;
uniform float FogStart;
uniform int FogShape;

uniform vec2 TextureSize;
uniform ivec3 VertexOffsets;
uniform ivec3 FaceNormals;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec3 n;

vec3 get_offset() {
	int mod = gl_VertexID % 24;
	float x = float((VertexOffsets.x >> mod) & 1) * 2.0 - 1.0;
	float y = float((VertexOffsets.y >> mod) & 1) * 2.0 - 1.0;
	float z = float((VertexOffsets.z >> mod) & 1) * 2.0 - 1.0;
	return vec3(x, y, z);
}

vec3 get_normal() {
	int face = ((gl_VertexID % 72) / 4) % 6;
	float x = float((FaceNormals.x >> (face * 2)) & 3) - 1.0;
	float y = float((FaceNormals.y >> (face * 2)) & 3) - 1.0;
	float z = float((FaceNormals.z >> (face * 2)) & 3) - 1.0;
	return vec3(x, y, z);
}

int get_layer() { // 0 outer, 1 middle, 2 inner
	return (gl_VertexID % 72) / 24;
}

vec2 get_uv(float is_crystal) {
	int face = (gl_VertexID % 72) / 4;
	int modface = face % 6;
	vec2 offset = (TextureSize / vec2(8.0, 4.0)) / textureSize(Sampler0, 0);
	vec2 new_uv = UV0;
	new_uv.x = new_uv.x + is_crystal * float(modface < 2) * (modface + 1) * offset.x;
	new_uv.x = new_uv.x + is_crystal * float(modface >= 2) * (modface - 2) * offset.x;
	new_uv.y = new_uv.y + is_crystal * float(modface >= 2) * offset.y;
	new_uv.x = new_uv.x + is_crystal * float(face >= 12) * 4.0 * offset.x;
	return new_uv;
}

float getY() {
    float f3 = sin(GameTime * 4800.0) / 2.0 + 0.5;
    return (f3 * f3 + f3) * 0.4 - 0.4;
}

mat4 translate(vec3 t) {
	mat4 m = IdentityMat;
	m[3].xyz = t;
	return m;
}

mat4 rotate(vec3 u, float rt) { // axis, theta
	return mat4(
		cos(rt)+u.x*u.x*(1.0-cos(rt)), 		u.x*u.y*(1.0-cos(rt))+u.z*sin(rt), 		u.x*u.z*(1.0-cos(rt))-u.y*sin(rt), 	0.0,
		u.x*u.y*(1.0-cos(rt))-u.z*sin(rt), 	cos(rt)+u.y*u.y*(1.0-cos(rt)), 			u.y*u.z*(1.0-cos(rt))+u.x*sin(rt), 	0.0,
		u.x*u.z*(1.0-cos(rt))+u.y*sin(rt), 	u.y*u.z*(1.0-cos(rt))-u.x*sin(rt), 		cos(rt)+u.z*u.z*(1.0-cos(rt)), 		0.0,
	    0.0, 								0.0, 									0.0, 								1.0);
}

void main() {
	
	float check_inventory = float(ProjMat[3][2] == -2.0); // is the crystal in a GUI?
	float check_hand = float(FogStart >= 3.402823e+38 && check_inventory == 0.0); // is the crystal in the player's hand in firstperson?
	float check_inventory_hand = float(check_inventory * float(Position.z < -150.0)); // is this crystal in the player's hand in the GUI?
	
	float check_crystal = float(Normal == vec3(0.0)); // is the thing a crystal?
	float check_middle_layer = float(get_layer() == 1); // middle layer of the crystal?
	float check_inner_layer = float(get_layer() == 2); // inner layer of the crystal?
	
	
	mat4 wm = mat4(inverse(IViewRotMat)) * (1.0 - min(1.0, check_inventory + check_hand)) // use world matrix unless...
	        + IdentityMat * min(1.0, check_inventory + check_hand); // if in inventory or firstperson hand, then use identity matrix
	
	float rt = GameTime * 1000.0; // rotation value
	float model_scale = 0.125 // base scale
					  + 0.125 * min(1.0, check_inventory + check_hand) // larger if in inventory or firstperson hand
					  + 0.0625 * check_inventory // even larger if in inventory
					  + 3.6875 * check_inventory * check_inventory_hand; // slightly smaller if in inventory and held by the character model since inventory scales it too big
	float translation_scale = model_scale * 2.0 //
	                        * (-2.0 * check_inventory_hand + 1.0); // offset the model if held by the character model in the inventory

	mat4 standard_rotation = rotate(vec3(wm[1].xyz), rt) * rotate(vec3(wm[2].xyz), 30.0*PI/180.0) * rotate(vec3(wm[0].xyz), PI/4.0);
	mat4 rotation = (standard_rotation * check_inner_layer + IdentityMat * (1.0 - check_inner_layer)) // inner layer
				  * (standard_rotation * min(1.0, check_middle_layer + check_inner_layer) + IdentityMat * (1.0 - min(1.0, check_middle_layer + check_inner_layer))) // middle layer
				  * standard_rotation; // standard crystal rotation
	model_scale *= -1.0 + 2.0 * check_inventory * check_inventory_hand; // flip crystal back to normal if its not in a ui hand since for some reason they start inside-out
	model_scale *= (1.0 - 0.125 * min(1.0, check_middle_layer + check_inner_layer)) * (1.0 - 0.125 * check_inner_layer); // scale innards of crystal
	
	vec4 a = translate(Position) * translate(wm[1].xyz * getY() * (1.0 - check_inventory * (1.0 - check_inventory_hand)) * translation_scale) // dont bob in guis
		   * rotation * wm * vec4(model_scale*(get_offset()), 1.0) * check_crystal // crystal
		   + vec4(Position, 1.0) * (1.0 - check_crystal); // not crystal
	vertexColor = texelFetch(Sampler2, UV2 / 16, 0) // light level
				* (minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * (1.0 - check_crystal) + vec4(1.0) * check_crystal); // shade only if not crystal
	
    gl_Position = ProjMat * ModelViewMat * a;

    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    texCoord0 = get_uv(check_crystal);
}

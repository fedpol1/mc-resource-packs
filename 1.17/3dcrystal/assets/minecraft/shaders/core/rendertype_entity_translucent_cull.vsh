#version 150

#moj_import <light.glsl>

#define EPSILON 0.004
#define INV_SQRT_2 0.7071067811865475
#define PI 3.1415926535897932
#define LIGHT0_DIRECTION vec3(0.2, 1.0, -0.7) // Default light 0 direction everywhere except in inventory
#define LIGHT1_DIRECTION vec3(-0.2, 1.0, 0.7) // Default light 1 direction everywhere except in nether and inventory

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

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;
uniform float GameTime;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec3 pos;

bool isNether(vec3 light0, vec3 light1) {
    return abs(light0) == abs(light1);
}

mat4 getWorldMat(vec3 light0, vec3 light1, vec3 normal, bool useNormal) {
	vec3 b = light1;
	vec3 B = LIGHT1_DIRECTION;
	if(isNether(light0, light1) || useNormal) { b = normal; B = vec3(0.0,-1.0,0.0); }
    mat3 V = mat3(normalize(LIGHT0_DIRECTION), normalize(B), normalize(cross(LIGHT0_DIRECTION, B)));
    mat3 W = mat3(normalize(light0), normalize(b), normalize(cross(light0, b)));
	mat3 wm = W * inverse(V);
	return mat4(wm[0][0], wm[0][1], wm[0][2], 0.0, 
				wm[1][0], wm[1][1], wm[1][2], 0.0, 
				wm[2][0], wm[2][1], wm[2][2], 0.0, 
				0.0, 0.0, 0.0, 1.0);
}

bool check_crystal(vec4 color) {
	vec2 d = color.ra - vec2(255.0, 63.0) / 255.0;
	return dot(d, d) < EPSILON;
}

bool check_hand(vec3 light0, vec3 normal) {
	return getWorldMat(light0, vec3(0.0), normal, true)[1][1] < -EPSILON;
}

bool check_inventory(mat4 proj) {
	return proj[0][0] < 1.5/255.0 && proj[1][1] < 0.5/255.0 && proj[2][2] < 0.5/255.0;
}

bool check_inventory_hand(vec3 light0) {
	return light0.r > light0.g && light0.r > light0.b;
}

bool check_middle_layer(vec4 color) {
	float d = color.g - 63.0/255.0;
	return d*d < EPSILON;
}

bool check_inner_layer(vec4 color) {
	float d = color.g - 127.0/255.0;
	return d*d < EPSILON;
}

vec3 get_offset(vec4 color) {
	float a = floor(color.b * 7.95);
	return (vec3(mod(a, 2.0), float(a - 4.0 * float(a >= 4.0) >= 2.0), float(a >= 4.0)) - 0.5) * 2.0;
}

float getY(float GameTime) {
    float f3 = sin(GameTime * 4800.0) / 2.0 + 0.5;
    return (f3 * f3 + f3) * 0.4 - 0.4;
}

mat4 translate(vec3 t) {
	return mat4(1.0,0.0,0.0,0.0,
				0.0,1.0,0.0,0.0,
				0.0,0.0,1.0,0.0,
				t.x,t.y,t.z,1.0);
}

mat4 rotate(vec3 u, float rt) { // axis, theta
	return mat4(cos(rt)+u.x*u.x*(1.0-cos(rt)), u.x*u.y*(1.0-cos(rt))+u.z*sin(rt), u.x*u.z*(1.0-cos(rt))-u.y*sin(rt), 0.0,
		u.x*u.y*(1.0-cos(rt))-u.z*sin(rt), cos(rt)+u.y*u.y*(1.0-cos(rt)), u.y*u.z*(1.0-cos(rt))+u.x*sin(rt), 0.0,
		u.x*u.z*(1.0-cos(rt))+u.y*sin(rt), u.y*u.z*(1.0-cos(rt))-u.x*sin(rt), cos(rt)+u.z*u.z*(1.0-cos(rt)), 0.0,
	    0.0, 0.0, 0.0, 1.0);
}

void main() {

	vec4 col = texture(Sampler0, UV0);
	vec4 a = vec4(Position, 1.0);
	
	vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
	
	if(check_crystal(col)) {
		mat4 wm = getWorldMat(Light0_Direction, Light1_Direction, Normal, false);
		mat4 rotation = translate(vec3(0.0));
		float rt = GameTime * 1000.0; // rotation value
		float model_scale = 0.125;
		float translation_scale = 0.25;
		
		if(check_inventory(ProjMat) || check_hand(Light0_Direction, Normal)) { 
			model_scale = 0.25 + 0.0625*float(check_inventory(ProjMat)) + 2.25*float(check_inventory(ProjMat) && check_inventory_hand(Light0_Direction));
			translation_scale = model_scale * 2.0;
			wm = translate(vec3(0.0));
		}

		rotation = rotate(vec3(wm[1].xyz), rt) * rotate(vec3(wm[2].xyz), 35.0*PI/180.0) * rotate(vec3(wm[0].xyz), PI/4.0); 
		if(check_middle_layer(col) || check_inner_layer(col)) { 
			model_scale *= 0.875;
			rotation = rotate(vec3(wm[1].xyz), rt) * rotate(vec3(wm[2].xyz), 35.0*PI/180.0) * rotate(vec3(wm[0].xyz), PI/4.0) * rotation; 
			if(check_inner_layer(col)) { 
				model_scale *= 0.875;
				rotation = rotate(vec3(wm[1].xyz), rt) * rotate(vec3(wm[2].xyz), 35.0*PI/180.0) * rotate(vec3(wm[0].xyz), PI/4.0) * rotation;
			}
		}
		
		a = translate(Position) * translate(wm[1].xyz * getY(GameTime) * translation_scale) * rotation * wm * vec4(-model_scale*(get_offset(col)), 1.0);
		vertexColor = texelFetch(Sampler2, UV2 / 16, 0);
	}
	
    gl_Position = ProjMat * ModelViewMat * a;

    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
}

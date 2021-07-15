#version 150

#define EPSILON 0.004
#define LIGHT0_DIRECTION vec3(0.2, 1.0, -0.7) // Default light 0 direction everywhere except in inventory
#define LIGHT1_DIRECTION vec3(-0.2, 1.0, 0.7) // Default light 1 direction everywhere except in nether and inventory

bool isNether(vec3 light0, vec3 light1) {
    return abs(light0) == abs(light1);
}

mat4 getWorldMat(vec3 light0, vec3 light1, vec3 normal) {
	bool n = isNether(light0, light1);
	vec3 b = light1 * float(!n) // if not nether, then use light1
		   + normal * float(n) // otherwise use normal
		   + vec3(1.0) * float(n && abs(normal) == 0.0); // edge case if normal is 0 vector
	vec3 B = LIGHT1_DIRECTION * float(!n) // if not nether, then use light1
	       + vec3(0.0,-1.0 * float(n),0.0); // otherwise use down
    mat3 V = mat3(normalize(LIGHT0_DIRECTION), normalize(B), normalize(cross(LIGHT0_DIRECTION, B)));
    mat3 W = mat3(normalize(light0), normalize(b), normalize(cross(light0, b)));
	mat3 wm = W * inverse(V);
	return mat4(wm[0].xyz, 0.0, 
				wm[1].xyz, 0.0, 
				wm[2].xyz, 0.0, 
				0.0, 0.0, 0.0, 1.0);
}

bool check_crystal(vec4 color) {
	vec2 d = color.ra - vec2(255.0, 63.0) / 255.0;
	return dot(d, d) < EPSILON;
}

bool check_hand(vec3 normal) {
	return abs(normal) == 0.0;
}

bool check_inventory(mat4 proj) {
	return proj[0][0] < 1.5/255.0 && proj[1][1] < 0.5/255.0 && proj[2][2] < 0.5/255.0;
}

bool check_inventory_hand(vec3 light0, vec3 normal) {
	return light0.r > light0.g && light0.r > light0.b && !check_hand(normal);
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

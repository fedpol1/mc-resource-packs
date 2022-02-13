#version 150

#define EPSILON 0.004
#define LIGHT0_DIRECTION vec3(0.2, 1.0, -0.7) // Default light 0 direction everywhere except in inventory
#define LIGHT1_DIRECTION vec3(-0.2, 1.0, 0.7) // Default light 1 direction everywhere except in nether and inventory

bool parallel(vec3 v1, vec3 v2) {
    return v1 == -v2 || v1 == v2;
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
	return mat4(
		cos(rt)+u.x*u.x*(1.0-cos(rt)), 		u.x*u.y*(1.0-cos(rt))+u.z*sin(rt), 		u.x*u.z*(1.0-cos(rt))-u.y*sin(rt), 	0.0,
		u.x*u.y*(1.0-cos(rt))-u.z*sin(rt), 	cos(rt)+u.y*u.y*(1.0-cos(rt)), 			u.y*u.z*(1.0-cos(rt))+u.x*sin(rt), 	0.0,
		u.x*u.z*(1.0-cos(rt))+u.y*sin(rt), 	u.y*u.z*(1.0-cos(rt))-u.x*sin(rt), 		cos(rt)+u.z*u.z*(1.0-cos(rt)), 		0.0,
	    0.0, 								0.0, 									0.0, 								1.0);
}

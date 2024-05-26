#version 150

#define EXTENSION 47.0
#define IS_TOP_VERTEX (gl_VertexID == 0 || gl_VertexID == 3)
#define IS_RIGHT_VERTEX (gl_VertexID == 2 || gl_VertexID == 3)
#define HOTBAR_SIZE vec2(182.0, 44.0)
#define MARKER_COLOR vec4(255.0, 0.0, 0.0, 63.0)

in vec3 Position;
in vec2 UV0;

uniform sampler2D Sampler0;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;

uniform float FogEnd;
uniform vec2 ScreenSize;

out vec2 texCoord0;
out float fcheck_hotbar;
out float fcheck_top_vertex;
out float fcheck_right_vertex;
out float[6] yaw_digits;
out float[5] pitch_digits;
out float[6] fog_digits;
out float yaw_direction;
out float pitch_direction;

bool check_pixel(sampler2D sampler, vec2 coord, vec4 col)
{
	vec4 s_color = texture(Sampler0, coord);
	vec4 d = s_color - col/255.0;
	return dot(d, d) < 0.004;
}

bool check_bounds(vec2 uv, int vid, vec2 start, vec2 size)
{
	bool core = uv.x >= start.x && uv.x <= start.x + size.x && uv.y >= start.y && uv.y <= start.y + size.y;

	bool l = !(vid == 1 || vid == 0) && uv.x == start.x;
	bool r = !(vid == 2 || vid == 3) && uv.x == start.x + size.x;
	bool u = !(vid == 3 || vid == 0) && uv.y == start.y;
	bool d = !(vid == 1 || vid == 2) && uv.y == start.y + size.y;
	return core && !(l || r || u || d);
}

bool check_color(vec4 a, vec3 b, float leniency)
{
	vec3 a_mult = a.rgb * 255.0;
	
	vec3 div = max(a_mult, b) / min(a_mult, b);
	float max_div = max(div.r, div.g);
	max_div = max(max_div, div.b);
	return max_div < leniency;
}

bool check_color(vec4 a, vec3 b) { return check_color(a, b, 1.9); }

void main() {

	vec2 size = textureSize(Sampler0, 0);

	bool check_hotbar = check_pixel(Sampler0, UV0 + vec2(-1.0 * float(IS_RIGHT_VERTEX), -0.5 * HOTBAR_SIZE.y + HOTBAR_SIZE.y * float(IS_TOP_VERTEX))/size, MARKER_COLOR);

    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
	float gui_scale = round(abs(gl_Position.x * ScreenSize.x) / HOTBAR_SIZE.x);
	gl_Position.x += EXTENSION / ScreenSize.x * 2.0 * gui_scale * float(check_hotbar && IS_RIGHT_VERTEX);

	int yaw_magnitude = int(100.0 * acos(clamp(-IViewRotMat[0][0], -1.0, 1.0)) * 180.0 / 3.14159265358979);
	float pitch = asin(clamp(IViewRotMat[2][1], -1.0, 1.0)) * 180.0 / 3.14159265358979;
	int pitch_magnitude = int(100.0 * abs(pitch));
	int fog_magnitude = int(100.0 * abs(FogEnd));

	yaw_digits[0] = float(sign(IViewRotMat[0][2]) > 0.5) - 2.0; // sign of yaw; -1 for negative, -2 for positive
	yaw_digits[1] = float((yaw_magnitude % 100000) / 10000);
	yaw_digits[2] = float((yaw_magnitude % 10000) / 1000);
	yaw_digits[3] = float((yaw_magnitude % 1000) / 100);
	yaw_digits[4] = float((yaw_magnitude % 100) / 10);
	yaw_digits[5] = float((yaw_magnitude % 10));
	yaw_digits[1] -= 2.0 * float(yaw_digits[1] == 0.0 && yaw_digits[0] == -2.0) + 1.0 * float(yaw_digits[1] == 0.0 && yaw_digits[0] == -1.0); // -2 for don't draw anything
	yaw_digits[2] -= 2.0 * float(yaw_digits[2] == 0.0 && yaw_digits[1] == -2.0) + 1.0 * float(yaw_digits[2] == 0.0 && yaw_digits[1] == -1.0); // -2 for don't draw anything
	yaw_digits[0] -= 1.0 * float(yaw_digits[0] == -1.0 && yaw_digits[1] == -1.0);
	yaw_digits[1] -= 1.0 * float(yaw_digits[1] == -1.0 && yaw_digits[2] == -1.0);

	pitch_digits[0] = float(sign(pitch) < -0.5) - 2.0; // sign of pitch; -1 for negative, -2 for positive
	pitch_digits[1] = float((pitch_magnitude % 10000) / 1000);
	pitch_digits[2] = float((pitch_magnitude % 1000) / 100);
	pitch_digits[3] = float((pitch_magnitude % 100) / 10);
	pitch_digits[4] = float((pitch_magnitude % 10));
	pitch_digits[1] -= 2.0 * float(pitch_digits[1] == 0.0 && pitch_digits[0] == -2.0) + 1.0 * float(pitch_digits[1] == 0.0 && pitch_digits[0] == -1.0); // -2 for don't draw anything
	pitch_digits[0] -= 1.0 * float(pitch_digits[0] == -1.0 && pitch_digits[1] == -1.0);

	fog_digits[0] = float(sign(FogEnd) < -0.5) - 2.0; // sign of fog; -1 for negative, -2 for positive
	fog_digits[1] = float((fog_magnitude % 100000) / 10000);
	fog_digits[2] = float((fog_magnitude % 10000) / 1000);
	fog_digits[3] = float((fog_magnitude % 1000) / 100);
	fog_digits[4] = float((fog_magnitude % 100) / 10);
	fog_digits[5] = float((fog_magnitude % 10));
	fog_digits[1] -= 2.0 * float(fog_digits[1] == 0.0 && fog_digits[0] == -2.0) + 1.0 * float(fog_digits[1] == 0.0 && fog_digits[0] == -1.0); // -2 for don't draw anything
	fog_digits[2] -= 2.0 * float(fog_digits[2] == 0.0 && fog_digits[1] == -2.0) + 1.0 * float(fog_digits[2] == 0.0 && fog_digits[1] == -1.0); // -2 for don't draw anything
	fog_digits[0] -= 1.0 * float(fog_digits[0] == -1.0 && fog_digits[1] == -1.0);
	fog_digits[1] -= 1.0 * float(fog_digits[1] == -1.0 && fog_digits[2] == -1.0);

	float prelim_yaw_direction = float(int(0.01 * float(yaw_magnitude + 2250) / 45.0)) * (float(sign(IViewRotMat[0][2]) < 0.5) * 2.0 - 1.0);
	yaw_direction = prelim_yaw_direction + 8.0 * float(prelim_yaw_direction < 0.0);

	pitch_direction = sign(pitch) * (1.0 + float(pitch_magnitude >= 3000) + float(pitch_magnitude > 7500));

    texCoord0 = UV0;
    texCoord0.x += EXTENSION / size.x * float(check_hotbar && IS_RIGHT_VERTEX);
    texCoord0.y -= 0.5 * HOTBAR_SIZE.y / size.y * float(check_hotbar && !IS_TOP_VERTEX);
			  
	fcheck_hotbar = float(check_hotbar);
	fcheck_top_vertex = float(IS_TOP_VERTEX);
	fcheck_right_vertex = float(IS_RIGHT_VERTEX);
}

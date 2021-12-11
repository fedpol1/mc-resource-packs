#version 150

uniform sampler2D Sampler0;

in vec3 Position;
in vec2 UV0;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec2 texCoord0;
out float v_check_tab;

void main() {
	v_check_tab = float((UV0.y == 0.125 || UV0.y == 0.25) && (UV0.x == 0.125 || UV0.x == 0.25 || UV0.x == 0.625 || UV0.x == 0.75));
	
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    texCoord0 = UV0;
}

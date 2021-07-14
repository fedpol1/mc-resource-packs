#version 150

#moj_import <light.glsl>
#moj_import <crystal_util.glsl>

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

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;
uniform float GameTime;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;

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
		
		if(check_inventory(ProjMat) || check_hand(Normal)) { 
			model_scale = 0.25 + 0.0625*float(check_inventory(ProjMat)) + 2.25*float(check_inventory(ProjMat) && check_inventory_hand(Light0_Direction));
			translation_scale = model_scale * 2.0 * (-2.0 * float(check_inventory_hand(Light0_Direction)) + 1.0);
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

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
	
	vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
	
	mat4 wm = getWorldMat(Light0_Direction, Light1_Direction, Normal) * float(!(check_inventory(ProjMat) || check_hand(Normal))) // use world matrix unless...
	        + translate(vec3(0.0)) * float(check_inventory(ProjMat) || check_hand(Normal)); // if in inventory or firstperson hand, then use identity matrix
	
	float rt = GameTime * 1000.0; // rotation value
	float model_scale = 0.125 // base scale
					  + 0.125 * float(check_inventory(ProjMat) || check_hand(Normal)) // larger if in inventory or firstperson hand
					  + 0.0625*float(check_inventory(ProjMat)) // even larger if in inventory
					  + 2.25*float(check_inventory(ProjMat) && check_inventory_hand(Light0_Direction, Normal)); // even larger if in inventory and held by the character model
	float translation_scale = model_scale * 2.0 //
	                        * (-2.0 * float(check_inventory_hand(Light0_Direction, Normal)) + 1.0); // offset the model if held by the character model in the inventory

	mat4 standard_rotation = rotate(vec3(wm[1].xyz), rt) * rotate(vec3(wm[2].xyz), 35.0*PI/180.0) * rotate(vec3(wm[0].xyz), PI/4.0);
	mat4 rotation = (standard_rotation * float(check_inner_layer(col)) + translate(vec3(0.0)) * float(!check_inner_layer(col))) // inner layer
				  * (standard_rotation * float(check_middle_layer(col) || check_inner_layer(col)) + translate(vec3(0.0)) * float(!(check_middle_layer(col) || check_inner_layer(col)))) // middle layer
				  * standard_rotation; // standard crystal rotation
	model_scale *= (1.0 - 0.125 * float(check_middle_layer(col) || check_inner_layer(col))) * (1.0 - 0.125 * float(check_inner_layer(col)));
	
	vec4 a = translate(Position) * translate(wm[1].xyz * getY(GameTime) * translation_scale) * rotation * wm * vec4(-model_scale*(get_offset(col)), 1.0) * float(check_crystal(col)) // crystal
		   + vec4(Position, 1.0) * float(!check_crystal(col)); // not crystal
	vertexColor = texelFetch(Sampler2, UV2 / 16, 0);
	
    gl_Position = ProjMat * ModelViewMat * a;

    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
}

#version 150

vec4 linear_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor) {
	float check_lava = float(fogColor.rgb == vec3(0.6, 0.1, 0.0) && (fogStart == -8.0 || fogStart == 0.0 || fogStart == 0.25));
	float check_snow = float(fogColor.rgb == vec3(0.623, 0.734, 0.785) && (fogStart == -8.0 || fogStart == 0.0));
	float check_spectator = min(1.0, check_lava + check_snow) * float(fogStart == -8.0);
	float check_void = float(fogColor.rgb == vec3(0.0, 0.0, 0.0));
	float check_water = float(fogStart == -8.0) * (1.0 - check_lava) * (1.0 - check_snow);
	float check_overworld = float(abs(fogStart/fogEnd - 0.9) < 0.004);
	float check_nether = float(abs(min(9.6, fogStart)/fogEnd - 0.1) < 0.004) * (1.0 - check_overworld) * (1.0 - check_water); // reliable up to render distance 107
	
	float nether_farness = max(1.0, fogStart/9.6 * check_nether); // handle behaviour past render distance 12 since nether fogEnd caps at 12 * 16 * 0.5
	
	float newStart = fogStart * (1.0
							   + 23.0 * check_lava * (1.0 - check_spectator)
							   + 7.0 * check_snow * (1.0 - check_spectator)
							   + 11.0 * check_void
							   + 7.0 * check_nether / nether_farness);
	float newEnd = fogEnd * (1.0
						   + 23.0 * check_lava * (1.0 - check_spectator)
						   + 7.0 * check_snow * (1.0 - check_spectator)
						   + 3.0 * check_water
						   + 11.0 * check_void
						   + 1.0 * check_nether);

    if (vertexDistance <= newStart) {
        return inColor;
    }
    float fogValue = vertexDistance < newEnd ? smoothstep(newStart, newEnd, vertexDistance) : 1.0;
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

float linear_fog_fade(float vertexDistance, float fogStart, float fogEnd) {
    if (vertexDistance <= fogStart) {
        return 1.0;
    } else if (vertexDistance >= fogEnd) {
        return 0.0;
    }

    return smoothstep(fogEnd, fogStart, vertexDistance);
}

float fog_distance(vec3 pos, int shape) {
    if (shape == 0) {
        return length(pos);
    } else {
        float distXZ = length(pos.xz);
        float distY = abs(pos.y);
        return max(distXZ, distY);
    }
}

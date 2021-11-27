#version 150

vec4 linear_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor) {
	float multiplier = 1.0
					 + 11.0 * float((fogColor.r + fogColor.g + fogColor.b) == 0.0 && fogColor.a == 1.0)
					 + 23.0 * float(fogEnd < 4.0);
    if (vertexDistance <= fogStart * multiplier) {
        return inColor;
    }

    float fogValue = vertexDistance < fogEnd * multiplier ? smoothstep(fogStart * multiplier, fogEnd * multiplier, vertexDistance) : 1.0;
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

float linear_fog_fade(float vertexDistance, float fogStart, float fogEnd) {
	//float newFogStart = fogStart * 8.0 * float((fogColor.r + fogColor.g + fogColor.b) <= 0.01);
    if (vertexDistance <= fogStart) {
        return 1.0;
    } else if (vertexDistance >= fogEnd) {
        return 0.0;
    }

    return smoothstep(fogEnd, fogStart, vertexDistance);
}

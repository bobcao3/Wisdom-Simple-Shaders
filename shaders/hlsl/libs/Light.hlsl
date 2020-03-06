#ifndef __INCLUDE_LIGHT_HLSL
#define __INCLUDE_LIGHT_HLSL

float sunLightFromSkyLight(float skyLight) {
	return  smoothstep(0.86, 0.8758, skyLight);
}

float light_mclightmap_attenuation(in float lm) {
	float falloff = 3.0;

	lm = exp(-(1.0 - lm) * falloff);
	lm = max(0.0, lm - exp(-falloff));

	return lm;
}

float3 lighting(float blockLight, float skyLight, float sunLight, float3 builtin_skylight) {
	const float3 torch1900K = pow(float3(255.0, 147.0, 41.0) / 255.0, float3(2.2, 2.2, 2.2));
  	const float3 torch5500K = float3(1.2311, 1.0, 0.8286);
    const float3 torch_warm = float3(1.2311, 0.7, 0.4286);

	const float3 blockLightColor = torch1900K;
	const float3 skyLightColor = float3(0.4, 0.5, 0.6);
	const float3 sunLightColor = torch5500K;

	float3 light;
    light  = light_mclightmap_attenuation(blockLight * 1.2) * blockLightColor;
	light += light_mclightmap_attenuation(skyLight) * skyLightColor * builtin_skylight;
	light += sunLight * sunLightColor * builtin_skylight;

    return light;
}

float4 alphaComposite(float4 color, float3 addition) {
	return float4(color.rgb + addition / color.a, color.a);
}

#endif
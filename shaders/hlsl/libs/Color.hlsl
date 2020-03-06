#ifndef __INCLUDE_COLOR_HLSL
#define __INCLUDE_COLOR_HLSL

float3 ACESToneMap(float3 color) {
	const float luminance = 0.7;
	
	const float a = 2.51;
	const float b = 0.03;
	const float c = 2.43;
	const float d = 0.59;
	const float e = 0.14;

	return (color*(a*color+b))/(color*(c*color+d)+e);
}

float luma(float3 c) {
	return dot(c, float3(0.2126, 0.7152, 0.0722)); // sRGB / BT.709
}

#define gamma 2.2
#define agamma 1.0 / 2.2

float4 fromGamma(float4 c) {
	return pow(c, float4(gamma, gamma, gamma, gamma));
}

float4 toGamma(float4 c) {
	return pow(c, float4(agamma, agamma, agamma, agamma));
}

float3 fromGamma(float3 c) {
	return pow(c, float3(gamma, gamma, gamma));
}

float3 toGamma(float3 c) {
	return pow(c, float3(agamma, agamma, agamma));
}

float3 calcFogColor(float3 reference) {
	return reference * luma(reference) * float3(0.3, 0.5, 0.7);
}

#endif
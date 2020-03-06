#ifndef __INCLUDE_NOISE
#define __INCLUDE_NOISE

float hash(float2 p) {
	float3 p3 = frac(float3(p.xyx) * 0.2031);
	p3 += dot(p3, p3.yzx + 19.19);
	return frac((p3.x + p3.y) * p3.z);
}

float noise2d(float2 p) {
	float2 i = floor(p);
	float2 f = frac(p);
	float2 u = (f * f) * mad(float2(-2.0f, -2.0f), f, float2(3.0f, 3.0f));
	return mad(2.0f, lerp(
		lerp(hash(i),                     hash(i + float2(1.0f,0.0f)), u.x),
		lerp(hash(i + float2(0.0f,1.0f)), hash(i + float2(1.0f,1.0f)), u.x),
	u.y), -1.0f);
}

#endif
#include "ShaderConstants.fxh"

struct PS_Input
{
    float4 position : SV_Position;
    float4 color : COLOR;
    float3 wPos : SURFACE_POS;
};

struct PS_Output
{
    float4 color : SV_Target;
};

static float2x2 octave_c = float2x2(1.4,1.2,-1.2,1.4);

#include "libs/Noise.hlsl"
#include "libs/Color.hlsl"

float calc_clouds(in float3 sphere, in float3 cam) {
	if (sphere.y < 0.0) return 0.0;

	float rain = 1.0 - smoothstep(0.8, 1.0, FOG_CONTROL.y);

	float3 c = sphere / max(sphere.y, 0.001) * 768.0;
	c += noise2d((c.xz + cam.xz) * 0.001 + TIME * 0.01) * 200.0 / sphere.y;
	float2 uv = (c.xz + cam.xz);

	uv.x += TIME * 10.0;
	uv *= 0.002;
	float n  = noise2d(uv * float2(0.5, 1.0)) * 0.5;
		uv += mul(float2(n * 0.6, 0.0), octave_c); uv *= 6.0;
		  n += noise2d(uv) * 0.25;
		uv += mul(float2(n * 0.4, 0.0), octave_c) + float2(TIME * 0.1, 0.2); uv *= 3.01;
		  n += noise2d(uv) * 0.105;
		uv += mul(float2(n, 0.0), octave_c) + float2(TIME * 0.03, 0.1); uv *= 2.02;
		  n += noise2d(uv) * 0.0625;
	n = smoothstep(0.0, 1.0, n + rain * 0.6);

	n *= smoothstep(0.0, 140.0, sphere.y);

	return n;
}

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
    float4 color = PSInput.color;

    color.rgb = fromGamma(color.rgb);

    float3 nwpos = normalize(PSInput.wPos);

    float coverage = calc_clouds(nwpos * 512.0, float3(0.0, 64.0, 0.0));
    float3 cloudColor = float3(1.0, 1.0, 1.0) * luma(color.rgb) * 3.0;

    color.rgb = lerp(color.rgb, cloudColor, coverage);

    color.rgb = toGamma(ACESToneMap(color.rgb));

    color.rgb = lerp(color.rgb, FOG_COLOR.rgb, smoothstep(0.0, 0.95, 1.0 - nwpos.y));

    PSOutput.color = color;
}
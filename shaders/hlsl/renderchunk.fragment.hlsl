#include "ShaderConstants.fxh"
#include "util.fxh"

#include "libs/Color.hlsl"
#include "libs/Light.hlsl"

struct PS_Input
{
	float4 position : SV_Position;

#ifndef BYPASS_PIXEL_SHADER
	lpfloat4 color : COLOR;
	snorm float2 uv0 : TEXCOORD_0_FB_MSAA;
	snorm float2 uv1 : TEXCOORD_1_FB_MSAA;
#endif

	float4 wPos : PLANE_INFO;
};

struct PS_Output
{
	float4 color : SV_Target;
};

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
#ifdef BYPASS_PIXEL_SHADER
    PSOutput.color = float4(0.0f, 0.0f, 0.0f, 0.0f);
    return;
#else

#if USE_TEXEL_AA
	float4 diffuse = texture2D_AA(TEXTURE_0, TextureSampler0, PSInput.uv0 );
#else
	float4 diffuse = TEXTURE_0.Sample(TextureSampler0, PSInput.uv0);
#endif
	diffuse = fromGamma(diffuse);

#ifdef SEASONS_FAR
	diffuse.a = 1.0f;
#endif

#if USE_ALPHA_TEST
	#ifdef ALPHA_TO_COVERAGE
		#define ALPHA_THRESHOLD 0.05
	#else
		#define ALPHA_THRESHOLD 0.5
	#endif
	if(diffuse.a < ALPHA_THRESHOLD)
		discard;
#endif

	bool isWater = false;

//#if defined(BLEND)
	float fresnel;
	float3 normal = normalize(cross(ddx(PSInput.wPos.xyz), ddy(PSInput.wPos.xyz)));
	fresnel = 1.0 - abs(dot(normal, -normalize(PSInput.wPos.xyz)));
	fresnel *= fresnel;
	if (PSInput.color.a < 0.95 && PSInput.color.b > PSInput.color.r) {
		PSInput.color.a = fresnel * 0.95 + 0.05;
		isWater = true;
		diffuse.rgb *= float3(0.7, 0.7, 0.7);
	} else {
		diffuse.a *= PSInput.color.a;
	}

	if (diffuse.a < 0.9 && !isWater) {
		diffuse.a = lerp(fresnel, diffuse.a, fresnel);
	}
//#endif

#if !defined(ALWAYS_LIT)
	float blockLight = PSInput.uv1.x;
	float skyLight = PSInput.uv1.y;
#else
	float blockLight = 0.0;
	float skyLight = 0.87;
#endif

	//float tAng = TIME / 240.0 * 3.1415926 * 2.0;
	float3 sunVec = float3(0.0, -1.0, 0.0); //float3(cos(tAng), sin(tAng), 0.0);

	float rain = 1.0 - smoothstep(0.8, 1.0, FOG_CONTROL.y);

	float sunLight = sunLightFromSkyLight(skyLight) * (dot(sunVec, normal) * 0.5 + 0.5) * (1.0 - rain * 0.9);
	skyLight *= dot(sunVec, normal) * 0.25 + 0.75;
	float3 builtin_skylight = fromGamma(TEXTURE_1.Sample(TextureSampler1, float2(0.0, 0.87)).rgb);

	float3 light = lighting(blockLight, skyLight, sunLight, builtin_skylight);

	float3 fogColor = calcFogColor(FOG_COLOR.rgb);

#ifndef SEASONS
	#if !USE_ALPHA_TEST && !defined(BLEND)
		diffuse.a = PSInput.color.a;
	#endif	

	diffuse.rgb *= PSInput.color.rgb;
#else
	float2 uv = PSInput.color.xy;
	diffuse.rgb *= lerp(1.0f, TEXTURE_2.Sample(TextureSampler2, uv).rgb*2.0f, PSInput.color.b);
	diffuse.rgb *= PSInput.color.aaa;
	diffuse.a = 1.0f;
#endif

	float4 color = float4(diffuse.rgb * light, diffuse.a);

	if (isWater) {
		// Skylight reflection
		color = alphaComposite(color, fogColor * (1.0 - fresnel) * 0.5);

		#ifdef BLEND
		color.a = PSInput.color.a;
		#else
		color.rgb *= PSInput.color.a * 0.75 + 0.25; // If no alpha blending is enabled, pretend it is
		#endif
	}

	color.rgb = lerp(color.rgb, fogColor, abs(PSInput.wPos.a));

	color.rgb = ACESToneMap(color.rgb);

	PSOutput.color = toGamma(color);

#ifdef VR_MODE
	// On Rift, the transition from 0 brightness to the lowest 8 bit value is abrupt, so clamp to 
	// the lowest 8 bit value.
	PSOutput.color = max(PSOutput.color, 1 / 255.0f);
#endif

#endif // BYPASS_PIXEL_SHADER
}
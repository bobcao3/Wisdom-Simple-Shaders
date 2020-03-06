
#if !defined(TEXEL_AA) || !defined(TEXEL_AA_FEATURE) || (VERSION < 0xa000 /*D3D_FEATURE_LEVEL_10_0*/) 
#define USE_TEXEL_AA 0
#else
#define USE_TEXEL_AA 1
#endif

#ifdef ALPHA_TEST
#define USE_ALPHA_TEST 1
#else
#define USE_ALPHA_TEST 0
#endif

#if USE_TEXEL_AA

static const float TEXEL_AA_LOD_CONSERVATIVE_ALPHA = -1.0f;
static const float TEXEL_AA_LOD_RELAXED_ALPHA = 2.0f;

float4 texture2D_AA(in Texture2D source, in sampler bilinearSampler, in float2 originalUV) {

	const float2 dUV_dX = ddx(originalUV) * TEXTURE_DIMENSIONS.xy;
	const float2 dUV_dY = ddy(originalUV) * TEXTURE_DIMENSIONS.xy;

	const float2 delU = float2(dUV_dX.x, dUV_dY.x);
	const float2 delV = float2(dUV_dX.y, dUV_dY.y);
	const float2 adjustmentScalar = max(1.0f / float2(length(delU), length(delV)), 1.0f);

	const float2 fractionalTexel = frac(originalUV * TEXTURE_DIMENSIONS.xy);
	const float2 adjustedFractionalTexel = clamp(fractionalTexel * adjustmentScalar, 0.0f, 0.5f) + clamp(fractionalTexel * adjustmentScalar - (adjustmentScalar - 0.5f), 0.0f, 0.5f);

	const float lod = log2(sqrt(max(dot(dUV_dX, dUV_dX), dot(dUV_dY, dUV_dY))) * 2.0f);
	const float samplingMode = smoothstep(TEXEL_AA_LOD_RELAXED_ALPHA, TEXEL_AA_LOD_CONSERVATIVE_ALPHA, lod);

	const float2 adjustedUV = (adjustedFractionalTexel + floor(originalUV * TEXTURE_DIMENSIONS.xy)) / TEXTURE_DIMENSIONS.xy;
	const float4 blendedSample = source.Sample(bilinearSampler, lerp(originalUV, adjustedUV, samplingMode));

	#if USE_ALPHA_TEST
		return float4(blendedSample.rgb, lerp(blendedSample.a, smoothstep(1.0f/2.0f, 1.0f, blendedSample.a), samplingMode));
	#else
		return blendedSample;
	#endif
}

#endif // USE_TEXEL_AA

float MakeDepthLinear(float z, float n, float f, bool scaleZ)
{
	//Remaps z from [0, 1] to [-1, 1].
	if (scaleZ) {
		z = 2.f * z - 1.f;
	}
	return (2.f * n) / (f + n - z * (f - n));
}

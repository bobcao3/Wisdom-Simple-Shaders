#include "ShaderConstants.fxh"

struct VS_Input {
	float3 position : POSITION;
    float4 color : COLOR;
    float2 uv : TEXCOORD_0;
    float2 light_uv : TEXCOORD_1;
	#ifdef INSTANCEDSTEREO
		uint instanceID : SV_InstanceID;
	#endif
};


struct PS_Input {
	float4 position : SV_Position;

	// passing color so we can avoid having an extra shader and just use renderchunk.fragment
	lpfloat4 color : COLOR;
    snorm float2 uv : TEXCOORD_0_FB_MSAA;
    snorm float2 light_uv : TEXCOORD_1_FB_MSAA;
};

ROOT_SIGNATURE
void main(in VS_Input VSInput, out PS_Input PSInput) {
	float3 inputPos = VSInput.position.xyz * CHUNK_ORIGIN_AND_SCALE.w + CHUNK_ORIGIN_AND_SCALE.xyz;
	float3 center = inputPos + float3(0.5f, 0.5f, 0.5f);

	// the view position needs to be in sortof-steve space
	// the translation seems to be already embedded for some reason.
	float3 viewPos = VIEW_POS * CHUNK_ORIGIN_AND_SCALE.w;

	float3 forward = normalize(center - viewPos);
	// not orthogonal so need to normalize
	float3 right = normalize(cross(float3(0.0f, 1.0f, 0.0f), forward));
	// orthogonal so dont need to normalize
	float3 up = cross(forward, right);


	// color is only positive, so we have to offset by .5
	// we have to subtract because we passed in uvs

	// we multiply our offsets by the basis vectors and subtract them to get our verts
	float3 vertPos = center - up * (VSInput.color.z - 0.5f) - right * (VSInput.color.x - 0.5f);


	#ifdef INSTANCEDSTEREO
		int i = VSInput.instanceID;

		PSInput.position = mul(WORLDVIEW_STEREO[i], float4(vertPos, 1 ));
		PSInput.position = mul(PROJ_STEREO[i], PSInput.position);
	#else
		PSInput.position = mul(WORLDVIEW, float4( vertPos, 1.0f ));
		PSInput.position = mul(PROJ, PSInput.position);
	#endif 
	PSInput.uv = VSInput.uv;
	PSInput.light_uv = VSInput.light_uv;

	// color is hardcoded white
	PSInput.color = float4(1.0f, 1.0f, 1.0f, 1.0f);
}

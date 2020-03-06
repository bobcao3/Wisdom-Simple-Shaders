#include "ShaderConstants.fxh"

struct VS_Input
{
    float3 position : POSITION;
#ifdef USE_SKINNING
	uint boneId : BONEID_0;
#endif
    float2 uv : TEXCOORD_0;
#ifdef INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
};


struct PS_Input
{
    float4 position : SV_Position;
    float2 uv : TEXCOORD_0;
#ifdef GEOMETRY_INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
#ifdef VERTEXSHADER_INSTANCEDSTEREO
	uint renTarget_id : SV_RenderTargetArrayIndex;
#endif
};

ROOT_SIGNATURE
void main(in VS_Input VSInput, out PS_Input PSInput)
{
    PSInput.uv = VSInput.uv * GLINT_UV_SCALE.xy;

#ifdef INSTANCEDSTEREO
	int i = VSInput.instanceID;
#ifdef USE_SKINNING
	PSInput.position = mul(WORLDVIEWPROJ_STEREO[i], mul(BONES[VSInput.boneId], float4( VSInput.position, 1 )));
#else
	PSInput.position = mul(WORLDVIEWPROJ_STEREO[i], float4(VSInput.position, 1));
#endif
#else
#ifdef USE_SKINNING
	PSInput.position = mul(WORLDVIEWPROJ, mul(BONES[VSInput.boneId], float4(VSInput.position, 1)));
#else
	PSInput.position = mul(WORLDVIEWPROJ, float4(VSInput.position, 1));
#endif
#endif
#ifdef GEOMETRY_INSTANCEDSTEREO
	PSInput.instanceID = VSInput.instanceID;
#endif 
#ifdef VERTEXSHADER_INSTANCEDSTEREO
	PSInput.renTarget_id = VSInput.instanceID;
#endif
}
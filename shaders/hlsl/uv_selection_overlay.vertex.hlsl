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
    PSInput.uv = VSInput.uv;
#ifdef INSTANCEDSTEREO
	int i = VSInput.instanceID;
#ifdef USE_SKINNING
	float4 pos = mul(WORLDVIEW_STEREO[i], mul(BONES[VSInput.boneId], float4(VSInput.position, 1)));
#else
	float4 pos = mul(WORLDVIEW_STEREO[i], float4(VSInput.position, 1));
#endif
	PSInput.position = mul(PROJ_STEREO[i], pos);
#else
#ifdef USE_SKINNING
	float4 pos = mul(WORLDVIEW, mul(BONES[VSInput.boneId], float4(VSInput.position, 1)));
#else
	float4 pos = mul(WORLDVIEW, float4(VSInput.position, 1));
#endif
	PSInput.position = mul(PROJ, pos);
#endif
#ifdef GEOMETRY_INSTANCEDSTEREO
	PSInput.instanceID = VSInput.instanceID;
#endif 
#ifdef VERTEXSHADER_INSTANCEDSTEREO
	PSInput.renTarget_id = VSInput.instanceID;
#endif
}
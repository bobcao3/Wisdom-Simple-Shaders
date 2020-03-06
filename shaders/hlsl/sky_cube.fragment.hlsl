#include "ShaderConstants.fxh"

#include "libs/Color.hlsl"

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
	float3 wPos : SURFACE_POS;
};

struct PS_Output
{
    float4 color : SV_Target;
};

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
    discard;
/*    float3 V = -normalize(PSInput.wPos);

    float4 color = float4(calcFogColor(FOG_COLOR.rgb), 1.0);

    color.rgb = toGamma(ACESToneMap(color.rgb));

    PSOutput.color = color;*/
}
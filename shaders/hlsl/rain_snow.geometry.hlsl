#include "ShaderConstants.fxh"

struct GeometryShaderInput
{
	float4 position : SV_Position;
	float2 uv : TEXCOORD_0;
	float4 color : COLOR;
	float4 worldPosition : TEXCOORD_1;
	float4 fogColor : FOG_COLOR;

#ifdef INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
};

// Per-pixel color data passed through the pixel shader.
struct GeometryShaderOutput
{
	float4 position : SV_Position;
	float2 uv : TEXCOORD_0;
	float4 color : COLOR;
	float4 worldPosition : TEXCOORD_1;
	float4 fogColor : FOG_COLOR;

#ifdef INSTANCEDSTEREO
	uint renTarget_id : SV_RenderTargetArrayIndex;
#endif
};

// passes through the triangles, except changint the viewport id to match the instance
[maxvertexcount(3)]
void main(triangle GeometryShaderInput input[3], inout TriangleStream<GeometryShaderOutput> outStream)
{
	GeometryShaderOutput output = (GeometryShaderOutput)0;

#ifdef INSTANCEDSTEREO
	int i = input[0].instanceID;
#endif
		for (int j = 0; j < 3; j++)	{
			output.position = input[j].position;
			output.uv = input[j].uv;
			output.color = input[j].color;
			output.worldPosition = input[j].worldPosition;
			output.fogColor = input[j].fogColor;

#ifdef INSTANCEDSTEREO
			output.renTarget_id = i;
#endif
			outStream.Append(output);
		}
//	}
}
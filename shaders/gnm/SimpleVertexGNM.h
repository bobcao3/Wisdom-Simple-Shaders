#ifndef __SHADER_VERTEX_GNM_H
#define __SHADER_VERTEX_GNM_H

#include "ShaderConstantsGNM.h"

struct VS_Input
{
	float3 position : POSITION;
	float4 color : COLOR;
};

struct PS_Input
{
	float4 position : S_POSITION;
	float4 color : COLOR;
};


PS_Input main( in VS_Input VSInput )
{
	PS_Input PSInput = (PS_Input)0;

	PSInput.color = VSInput.color;
	PSInput.position = mul(WORLDVIEWPROJ, float4(VSInput.position, 1));

	return PSInput;
}

#endif // __SHADER_VERTEX_GNM_H
#include "ShaderConstants.fxh"

// be sure to change the shader type to pertex shader and shader model to ps_40 (in visual studio)

struct PS_Input {
	float4 position : SV_Position;
	float2 uv : TEXCOORD_0;
};

struct PS_Output {
	float4 color : SV_Target;
};

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput) 
{
	float4 diffuse = TEXTURE_0.Sample(TextureSampler0, PSInput.uv);

#ifdef ALPHA_TEST
	if (diffuse.a < 0.5) {
		discard;
	}
#endif

	float grayscale = (CURRENT_COLOR.r * diffuse.r * 0.3 + CURRENT_COLOR.g * diffuse.g * 0.59 + CURRENT_COLOR.b * diffuse.b * 0.11);
	float4 gray_color = float4(grayscale, grayscale, grayscale, CURRENT_COLOR.a * diffuse.a);
	PSOutput.color = gray_color;
}


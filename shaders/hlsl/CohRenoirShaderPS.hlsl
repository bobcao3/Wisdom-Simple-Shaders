/*
This file is part of Renoir, a modern graphics library.

Copyright (c) 2012-2016 Coherent Labs AD and/or its licensors. All
rights reserved in all media.

The coded instructions, statements, computer programs, and/or related
material (collectively the "Data") in these files contain confidential
and unpublished information proprietary Coherent Labs and/or its
licensors, which is protected by United States of America federal
copyright law and by international treaties.

This software or source code is supplied under the terms of a license
agreement and nondisclosure agreement with Coherent Labs AD and may
not be copied, disclosed, or exploited except in accordance with the
terms of that agreement. The Data may not be disclosed or distributed to
third parties, in whole or in part, without the prior written consent of
Coherent Labs AD.

COHERENT LABS MAKES NO REPRESENTATION ABOUT THE SUITABILITY OF THIS
SOURCE CODE FOR ANY PURPOSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT
HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY, NONINFRINGEMENT, AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER, ITS AFFILIATES,
PARENT COMPANIES, LICENSORS, SUPPLIERS, OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OR PERFORMANCE OF THIS SOFTWARE OR SOURCE CODE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include "ShaderConstants.fxh"

struct PS_Input {
	float4 Position : SV_Position;
	float4 Color : TEXCOORD0;
	float4 Additional: TEXCOORD1;
	float3 ScreenNormalPosition : TEXCOORD2;
	float4 VaryingParam0 : TEXCOORD3;
	float4 VaryingParam1 : TEXCOORD4;
};

struct PS_Output {
	float4 color : SV_Target;
};

#define PS_INPUT_ADDITIONAL_INTERP_MODIFIER centroid
#define SAMPLE2D(tex, uv) tex.Sample(TextureSampler0, uv)
#define txMask TEXTURE_1
#define txGradient TEXTURE_2

static const int PSTF_ColorFromTexture = 0x1;
static const int PSTF_GradientLinear = 0x2;
static const int PSTF_GradientRadial = 0x4;
static const int PSTF_Gradient2Point = 0x8;
static const int PSTF_Gradient3PointSymmetrical = 0x10;
static const int PSTF_GradientFromTexture = 0x20;
static const int PSTF_HasMask = 0x40;

#define IS_SET(value, flag) value & flag

void main(in PS_Input input, out PS_Output PSOutput) {
	float tVal = 0.f;

	if (IS_SET(SHADER_TYPE, PSTF_GradientLinear)) {
		tVal = input.VaryingParam0.x;
	}
	else if (IS_SET(SHADER_TYPE, PSTF_GradientRadial)) {
		tVal = length(input.VaryingParam0.xy);
	}

	float4 colorTemp;
	if (IS_SET(SHADER_TYPE, PSTF_Gradient2Point)) {
		colorTemp = lerp(RENOIR_SHADER_PS_PROPS_0, RENOIR_SHADER_PS_PROPS_2, saturate(tVal));
	}
	else if (IS_SET(SHADER_TYPE, PSTF_Gradient3PointSymmetrical)) {
		float oneMinus2t = 1.0 - (2.0 * tVal);
		colorTemp = clamp(oneMinus2t, 0.0, 1.0) * RENOIR_SHADER_PS_PROPS_0;
		colorTemp += (1.0 - min(abs(oneMinus2t), 1.0)) * RENOIR_SHADER_PS_PROPS_1;
		colorTemp += clamp(-oneMinus2t, 0.0, 1.0) * RENOIR_SHADER_PS_PROPS_2;
	}
	else if (IS_SET(SHADER_TYPE, PSTF_GradientFromTexture)) {
		float2 coord = float2(tVal, RENOIR_SHADER_PS_PROPS_3.x);
		colorTemp = SAMPLE2D(txGradient, coord);
	}
	else if (IS_SET(SHADER_TYPE, PSTF_ColorFromTexture)) {
		colorTemp = SAMPLE2D(TEXTURE_0, input.Additional.xy);
	}

	// Warning X4000 for usage of potentially uninitialized variable can be
	// safely ignored, as there are no ShaderTypes that don't enter any of the
	// branches above.
	if (IS_SET(SHADER_TYPE, PSTF_HasMask)) {
		float mask = SAMPLE2D(txMask, input.VaryingParam1.xy).r;
		colorTemp *= mask;
	}

	PSOutput.color = colorTemp;
}

#undef IS_SET

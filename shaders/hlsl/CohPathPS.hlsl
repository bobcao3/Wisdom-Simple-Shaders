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

struct PS_Input
{
	float4 Position : SV_Position; // Why not position3
	float2 ExtraParams : TEXCOORD0;
};

struct PS_Output {
	float4 color : SV_Target;
};

void main(in PS_Input PSInput, out PS_Output PSOutput)
{
	if (SHADER_TYPE == 14)
	{
		// Hairline quads
		float2 px = ddx(PSInput.ExtraParams);
		float2 py = ddy(PSInput.ExtraParams);

		float fx = (2 * PSInput.ExtraParams.x) * px.x - px.y;
		float fy = (2 * PSInput.ExtraParams.x) * py.x - py.y;

		float edgeAlpha = (PSInput.ExtraParams.x * PSInput.ExtraParams.x - PSInput.ExtraParams.y);
		float sd = sqrt((edgeAlpha * edgeAlpha) / (fx * fx + fy * fy));

		float alpha = 1.0 - sd;

		PSOutput.color = PRIM_PROPS_0 * PRIM_PROPS_1.x * alpha;
	}
	else if (SHADER_TYPE == 11)
	{
		// Hairline lines
		PSOutput.color = PRIM_PROPS_0 * min(1.0f, (1.0f - abs(PSInput.ExtraParams.y)) * PRIM_PROPS_1.x);
	}
	else
	{
		// non-hairline paths
		PSOutput.color = PRIM_PROPS_0 * PSInput.ExtraParams.y;
	}
}

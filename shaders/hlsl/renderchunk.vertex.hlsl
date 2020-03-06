#include "ShaderConstants.fxh"

#include "libs/Color.hlsl"

struct VS_Input {
	float3 position : POSITION;
	float4 color : COLOR;
	float2 uv0 : TEXCOORD_0;
	float2 uv1 : TEXCOORD_1;
#ifdef INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
};


struct PS_Input {
	float4 position : SV_Position;

#ifndef BYPASS_PIXEL_SHADER
	lpfloat4 color : COLOR;
	snorm float2 uv0 : TEXCOORD_0_FB_MSAA;
	snorm float2 uv1 : TEXCOORD_1_FB_MSAA;
#endif

	float4 wPos : PLANE_INFO;

#ifdef GEOMETRY_INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
#ifdef VERTEXSHADER_INSTANCEDSTEREO
	uint renTarget_id : SV_RenderTargetArrayIndex;
#endif
};


static const float rA = 1.0;
static const float rB = 1.0;
static const float3 UNIT_Y = float3(0, 1, 0);
static const float DIST_DESATURATION = 56.0 / 255.0; //WARNING this value is also hardcoded in the water color, don'tchange


ROOT_SIGNATURE
void main(in VS_Input VSInput, out PS_Input PSInput)
{
#ifndef BYPASS_PIXEL_SHADER
	PSInput.uv0 = VSInput.uv0;
	PSInput.uv1 = VSInput.uv1;
	PSInput.color = VSInput.color;
#endif

	

#ifdef AS_ENTITY_RENDERER
	#ifdef INSTANCEDSTEREO
		int i = VSInput.instanceID;
		PSInput.position = mul(WORLDVIEWPROJ_STEREO[i], float4(VSInput.position, 1));
	#else
		PSInput.position = mul(WORLDVIEWPROJ, float4(VSInput.position, 1));
	#endif
		float3 worldPos = PSInput.position;
#else
		float3 worldPos = (VSInput.position.xyz * CHUNK_ORIGIN_AND_SCALE.w) + CHUNK_ORIGIN_AND_SCALE.xyz;

		float3 aPos = fmod(mul(WORLD, float4(VSInput.position.xyz, 1.0)).xyz * CHUNK_ORIGIN_AND_SCALE.w, 16.0);

		if (VSInput.color.a < 0.95 && VSInput.color.b > VSInput.color.r) {
			// Water, we assume
			worldPos.y += (sin(aPos.x - aPos.y + TOTAL_REAL_WORLD_TIME * 3.14159) + cos(aPos.z + aPos.y - TOTAL_REAL_WORLD_TIME * 3.14159 / 2)) * 0.05 - 0.15;
		}

	#if defined(ALPHA_TEST) && defined(FANCY)
		if (PSInput.color.g >= PSInput.color.b && PSInput.color.g > PSInput.color.r || PSInput.color.b > PSInput.color.r) {
			worldPos.x += (sin(aPos.z - aPos.y + TOTAL_REAL_WORLD_TIME * 3.14159 / 2) + cos(aPos.z + aPos.x - TOTAL_REAL_WORLD_TIME * 3.14159 / 3)) * 0.05;
			worldPos.z += (sin(aPos.x - aPos.z + TOTAL_REAL_WORLD_TIME * 3.14159 / 2) + cos(aPos.x + aPos.y - TOTAL_REAL_WORLD_TIME * 3.14159 / 3)) * 0.05;
		}
	#endif

		// Transform to view space before projection instead of all at once to avoid floating point errors
		// Not required for entities because they are already offset by camera translation before rendering
		// World position here is calculated above and can get huge
	#ifdef INSTANCEDSTEREO
		int i = VSInput.instanceID;
	
		PSInput.position = mul(WORLDVIEW_STEREO[i], float4(worldPos, 1 ));
		PSInput.position = mul(PROJ_STEREO[i], PSInput.position);
	
	#else
		PSInput.position = mul(WORLDVIEW, float4( worldPos, 1 ));
		PSInput.position = mul(PROJ, PSInput.position);
	#endif

#endif
#ifdef GEOMETRY_INSTANCEDSTEREO
		PSInput.instanceID = VSInput.instanceID;
#endif 
#ifdef VERTEXSHADER_INSTANCEDSTEREO
		PSInput.renTarget_id = VSInput.instanceID;
#endif
///// find distance from the camera

	float3 relPos = -worldPos;
	float cameraDepth = length(relPos);

	float len = saturate(cameraDepth / (RENDER_DISTANCE * FOG_CONTROL.y));

	PSInput.wPos.rgb = worldPos;
	PSInput.wPos.a = len;

///// blended layer (mostly water) magic
#ifdef BLEND
	//Mega hack: only things that become opaque are allowed to have vertex-driven transparency in the Blended layer...
	//to fix this we'd need to find more space for a flag in the vertex format. color.a is the only unused part
	//bool shouldBecomeOpaqueInTheDistance = VSInput.color.a < 0.95;
	/*if(shouldBecomeOpaqueInTheDistance) {
		float alphaFadeOut = clamp(len, 0.0, 1.0);
		PSInput.color.a = lerp(VSInput.color.a * 0.5, 1.0, alphaFadeOut);
	}*/
#endif

}

#ifndef __SHADER_PIXEL_GNM_H
#define __SHADER_PIXEL_GNM_H

#include "ShaderConstantsGNM.h"

struct PS_Input
{
    float4 position : S_POSITION;
    float4 color : COLOR;
}; 
   
float4 main( in PS_Input PSInput ) : S_TARGET_OUTPUT
{
    return PSInput.color;
}

#endif // __SHADER_PIXEL_GNM_H
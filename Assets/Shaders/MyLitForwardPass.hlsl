#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

struct Attributes {
    float3 positionOS : POSITION;
    float2 uv : TEXCOORD0;
};


struct Interpolators {
    float4 positionCS: SV_POSITION;
    float2 uv : TEXCOORD0;
};

// tint color
float4 _ColorTint;
// Textures
TEXTURE2D(_ColorMap); SAMPLER(sampler_ColorMap);
float4 _ColorMap_ST;

Interpolators Vertex(Attributes input) {
    Interpolators output;
    VertexPositionInputs posInputs = GetVertexPositionInputs(input.positionOS);
    output.positionCS = posInputs.positionCS;
    output.uv = TRANSFORM_TEX(input.uv, _ColorMap);
    return output;
}

float4 Fragment(Interpolators input) : SV_TARGET {
    float2 uv = input.uv;
    float colorSample = SAMPLE_TEXTURE2D(_ColorMap, sampler_ColorMap, uv);
    return colorSample * _ColorTint;
}
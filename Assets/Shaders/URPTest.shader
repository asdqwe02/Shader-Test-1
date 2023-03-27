Shader "Custom/URPTest"
{
    Properties {
        [Header(Surface options)]
        _ColorTint("Tint", Color) = (1,1,1,1)
        _ColorMap("Color", 2D) = "white" {}
        _Smoothness("Smoothness", Float) = 0 
    }
    SubShader { 
        Tags{"RenderPipeline" = "UniversalPipeline"}
        Pass {
            Name "FowardLit"
            Tags {"LightMode" = "UniversalForward"}
            HLSLPROGRAM 

            #define _SPECULAR_COLOR

            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE 
            #pragma multi_compile_fragment _ _SHADOWS_SOFT  




            // #include "MyLitForwardPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            struct Attributes {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS: NORMAL;
            };
            struct Interpolators {
                float4 positionCS: SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
            };

            // ------------------ DEFINE PROPERTY ------------------
            // tint color
            float4 _ColorTint;
            // Textures
            TEXTURE2D(_ColorMap); SAMPLER(sampler_ColorMap);
            float4 _ColorMap_ST;
            // Smoothness
            float _Smoothness;

            Interpolators Vertex(Attributes input) {
                Interpolators output;
                VertexPositionInputs posInputs = GetVertexPositionInputs(input.positionOS);
                VertexNormalInputs normInputs = GetVertexNormalInputs(input.normalOS);
                output.positionCS = posInputs.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _ColorMap);
                output.normalWS = normInputs.normalWS;
                output.positionWS = posInputs.positionWS;
                return output;
            }

            float4 Fragment(Interpolators input) : SV_TARGET {
                float2 uv = input.uv;
                float4 colorSample = SAMPLE_TEXTURE2D(_ColorMap, sampler_ColorMap, uv);
                
                InputData lightingInput = (InputData)0;
                lightingInput.normalWS = normalize(input.normalWS);
                lightingInput.positionWS = input.positionWS;    
                lightingInput.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
                lightingInput.shadowCoord = TransformWorldToShadowCoord(input.positionWS);

                SurfaceData surfaceInput = (SurfaceData)0; 
                surfaceInput.albedo = colorSample.rgb * _ColorTint.rgb;
                surfaceInput.alpha = colorSample.a * _ColorTint.a;
                surfaceInput.specular = 1; // white specular
                surfaceInput.smoothness = _Smoothness;

                // return colorSample * _ColorTint;
                return UniversalFragmentBlinnPhong(lightingInput,surfaceInput);
            }
            ENDHLSL
        }
        Pass {
            Name "ShadowCaster"
            Tags {"Lightmode" = "ShadowCaster"}
            HLSLPROGRAM
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl"

            #pragma vertex Vertex
            #pragma fragment Fragment

            struct Attributes {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL; 
            };
            
            struct Interpolators {
                float4 positionCS: SV_POSITION;
            };

            float3 _LightDirection;

            float4 GetShadowCasterPositionCS(float3 positionWS, float3 normalWS) {
                float3 lightDirectionWS = _LightDirection;
                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
                #if UNITY_REVERSED_Z
                    positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
                #else
                    positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
                #endif
                return positionCS;
            }


            Interpolators Vertex(Attributes input)
            {
                Interpolators output;

                VertexPositionInputs posInputs = GetVertexPositionInputs(input.positionOS);
                VertexNormalInputs normInputs = GetVertexNormalInputs(input.normalOS);
                output.positionCS = GetShadowCasterPositionCS(posInputs.positionWS, normInputs.normalWS);
                return output;
            }
            float Fragment(Interpolators input) : SV_TARGET {
                return 0;
            }
            ENDHLSL
        }
    }
}

Shader "Custom/Test"
{
    Properties {
        _ColorA("Color A", Color) = (1,1,1,1)
        _ColorB("Color B", Color) = (1,1,1,1)
        // _Offset("Offset", Float) = 0
        // _Scale("UV Scale", Range(0,20)) = 1
        _ColorStart("Color Start", Range(0,1)) = 0
        _ColorEnd("Color End", Range(0,1)) = 1 
        
    }
    SubShader {
        Name "TestShader"
        Tags { "RenderType" = "Opaque" }
        pass {
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex Vertex
            #pragma fragment Fragment

            struct MeshData {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
                float2 uv : TEXCOORD;

            };
            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD;
                float3 normals: TEXCOORD1;

            };

            fixed4 _ColorA;
            fixed4 _ColorB;
            float _ColorStart;
            float _ColorEnd;
            // float _Scale;
            // float _Offset;

            float InverseLerp(float a ,float b, float v) {
                return (v-a)/(b-a);
            }

            Interpolators Vertex(MeshData input) {
                Interpolators output;
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.normals = UnityObjectToWorldNormal(input.normals);   
                output.uv = input.uv;  // (input.uv+_Offset)*_Scale;
                return output;
            }
            float4 Fragment(Interpolators input) : SV_TARGET {

                //lerp blend 2 color based on x uv coord
                float t = saturate(InverseLerp(_ColorStart,_ColorEnd,input.uv.x));
                float4 outColor = lerp(_ColorA, _ColorB, t);
                // return outColor;

                //frac 
                // t = frac(t);
                return outColor;
            }
            ENDCG 
        }
        
    }
}

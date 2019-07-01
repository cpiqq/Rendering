// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "custom/My First Lighting Shader" {
    Properties{
        _Tint("_Tint", Color)  = (1,1,1,1)
        _MainTex("_MainTex", 2D) = "white"{}
    }
    Subshader{
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #include "UnityCG.cginc"
            #include "UnityStandardBRDF.cginc" // 含有 UnityCG.cginc， 并定义了 DotClamped()，分情况的使用max或saturate

            struct VertexData{
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct Interpolators{
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
            };

            float4 _Tint;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            Interpolators vert(VertexData v) {
                Interpolators i;
                // i.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw; //用TRANSFORM_TEX 代替
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                i.position = UnityObjectToClipPos(v.position);
				i.normal = UnityObjectToWorldNormal(v.normal);
                i.normal = normalize(i.normal);
                return i;
            }
            float4 frag(Interpolators i) : SV_TARGET{
                i.normal = normalize(i.normal);
                float3 lightDir = _WorldSpaceLightPos0;
				// return float4(i.normal * 0.5 + 0.5, 1);
                return  DotClamped(lightDir, i.normal);
            }
            ENDCG
        }
    }
} 
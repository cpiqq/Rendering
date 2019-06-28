// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "custom/Textured With Detail" {
    Properties{
        _Tint("_Tint", Color)  = (1,1,1,1)
        _MainTex("_MainTex", 2D) = "white"{}
		_DetailTex("_DetailTex", 2D) = "gray"{}
    }
    Subshader{
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct VertexData{
                float4 position : POSITION;
                float2 uv : TEXCOORD0;

            };

            struct Interpolators{
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
				float2 uvDetail : TEXCOORD1;
            };

            float4 _Tint;
            sampler2D _MainTex, _DetailTex;
            float4 _MainTex_ST, _DetailTex_ST;


            Interpolators vert(VertexData v) {
                Interpolators i;
                // i.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw; //用TRANSFORM_TEX 代替
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
				i.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);
                i.position = UnityObjectToClipPos(v.position);
                return i;
            }
            float4 frag(Interpolators i) : SV_TARGET{
				float4 color = tex2D(_MainTex, i.uv) * _Tint;
				color *= tex2D(_DetailTex, i.uvDetail) * unity_ColorSpaceDouble;
                return color;
            }
            ENDCG
        }
    }
} 
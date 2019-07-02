// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "custom/My First Lighting Shader" {
    Properties{
        _Tint("_Tint", Color)  = (1,1,1,1)
        _MainTex("_MainTex", 2D) = "white"{}
		_Smoothness("_Smoothness", Range(0,1)) = 0.5
        // _SpecularTint("_SpecularTint", Color) = (0.5, 0.5, 0.5, 1)
        [Gamma]_Metallic ("_Metallic", Range(0, 1)) = 0
    }
    Subshader{
        Pass{
            Tags{"LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #include "UnityCG.cginc"
            // 含有 UnityCG.cginc， 并定义了 DotClamped()，分情况的使用max或saturate
            #include "UnityStandardBRDF.cginc" 
            #include "UnityStandardUtils.cginc"

            struct VertexData{
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct Interpolators{
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
            };

            float4 _Tint/* _SpecularTint*/;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _Smoothness, _Metallic;


            Interpolators vert(VertexData v) {
                Interpolators i;
                // i.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw; //用TRANSFORM_TEX 代替
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                i.position = UnityObjectToClipPos(v.position);
				i.worldPos = mul(unity_ObjectToWorld, v.position);
				i.normal = UnityObjectToWorldNormal(v.normal);
                i.normal = normalize(i.normal);
                return i;
            }
            float4 frag(Interpolators i) : SV_TARGET{
                i.normal = normalize(i.normal);
				float3 lightColor = _LightColor0.rgb;
                float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                
                float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
                float3 specularTint; // = albedo * _Metallic;
                float oneMinusReflectivity; // = 1 - _Metallic;
                // albedo *= oneMinusReflectivity;
                albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity);


                float3 diffuse = albedo * lightColor * DotClamped(lightDir, i.normal);
				float3 halfDir = normalize(lightDir + viewDir);
                float3 specular = specularTint * lightColor * pow(DotClamped(i.normal, halfDir), _Smoothness * 100);

                return  float4(diffuse + specular, 1);
            }
            ENDCG
        }
    }
} 
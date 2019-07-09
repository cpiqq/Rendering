// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "custom/Multi Lighting Shader" {
    Properties{
        _Tint("_Tint", Color)  = (1,1,1,1)
        _MainTex("_MainTex", 2D) = "white"{}
		_Smoothness("_Smoothness", Range(0,1)) = 0.5
        // _SpecularTint("_SpecularTint", Color) = (0.5, 0.5, 0.5, 1)
        [Gamma]_Metallic ("_Metallic", Range(0, 1)) = 0
        [NoScaleOffset]_HeightMap("_HeightMap", 2D) = "gray"{}
    }
    Subshader{
        Pass{
            Tags{"LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile _ VERTEXLIGHT_ON
            #pragma vertex vert
            #pragma fragment frag
            
            #define FORWARD_BASE_PASS

            #include "My Lighting.cginc"
            
            ENDCG
        }
        Pass{
            Tags{"LightMode" = "ForwardAdd" }
            //在第一个pass的基础上叠加
            Blend One One
            //因为是跟第一个pass是同一表面，没必要再写入深度缓存，所以这个pass里关掉它 
            ZWrite Off 

            CGPROGRAM
            #pragma target 3.0
            
            #pragma multi_compile_fwdadd
            // #pragma multi_compile DIRECTIONAL DIRECTIONAL_COOKIE POINT SPOT 

            #pragma vertex vert
            #pragma fragment frag
            
            #include "My Lighting.cginc"

            
            ENDCG
        }
    }
} 
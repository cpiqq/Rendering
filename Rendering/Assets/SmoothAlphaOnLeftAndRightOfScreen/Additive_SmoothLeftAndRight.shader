// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)
//由 particle/Additive 改编
//物体在靠近屏幕两侧时会渐变为透明

Shader "Custom/SmoothLeftAndRight" {
    Properties {
    _TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
    _MainTex ("Particle Texture", 2D) = "white" {}
    _InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
}

Category {
    Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
    Blend SrcAlpha One
    ColorMask RGB
    Cull Off Lighting Off ZWrite Off

    SubShader {
        Pass {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_particles
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _TintColor;

            struct appdata_t {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                // float4 vertex : SV_POSITION; //和 VPOS冲突
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                #ifdef SOFTPARTICLES_ON
                float4 projPos : TEXCOORD2;
                #endif
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float4 _MainTex_ST;

            //SV_POSITION和VPOS冲突，所以在这里输出
            v2f vert (appdata_t v, out float4 outpos : SV_POSITION)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                //输出裁剪空间坐标，下边一些操作都要用outpos变量
                outpos = UnityObjectToClipPos(v.vertex);
                #ifdef SOFTPARTICLES_ON
                o.projPos = ComputeScreenPos (outpos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                #endif
                o.color = v.color;
                o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
                UNITY_TRANSFER_FOG(o,outpos);
                return o;
            }

            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
            float _InvFade;

            //UNITY_VPOS_TYPE screenPos : VPOS 屏幕空间坐标 https://docs.unity3d.com/Manual/SL-ShaderSemantics.html
            fixed4 frag (v2f i, UNITY_VPOS_TYPE screenPos : VPOS) : SV_Target
            {
                //从屏幕左侧到屏幕中间平滑过渡 0 - 1                
                float smoothleft = smoothstep(0, _ScreenParams.x * 0.5, screenPos.x);
                //从屏幕中间到屏幕右侧平滑过渡 0 - 1
                float smoothright = smoothstep(_ScreenParams.x * 0.5, _ScreenParams.x, screenPos.x);
                //相减的效果是 0 - 1 - 0 过度的 https://blog.csdn.net/libing_zeng/article/details/68924521
                float smooth = smoothleft - smoothright;

                #ifdef SOFTPARTICLES_ON
                float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
                float partZ = i.projPos.z;
                float fade = saturate (_InvFade * (sceneZ-partZ));
                i.color.a *= fade;
                #endif

                fixed4 col = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
                col.a = saturate(col.a); // alpha should not have double-brightness applied to it, but we can't fix that legacy behaior without breaking everyone's effects, so instead clamp the output to get sensible HDR behavior (case 967476)
                col.a *= smooth;

                UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0)); // fog towards black due to our blend mode
                return col;
            }
            ENDCG
        }
    }
}
}

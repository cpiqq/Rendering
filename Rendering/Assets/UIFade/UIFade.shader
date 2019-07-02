Shader "UI/Fade"
{
    Properties
    {
        [PerRendererData]_MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Offset ("Offset", Range(-0.1,1.5)) = 0
        _InOut ("InOut", Range(0,1)) = 0

        _StencilComp("Stencil Comparison", Float) = 8
        _Stencil("Stencil ID", Float) = 0
        _StencilOp("Stencil Operation", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255

        _ColorMask("Color Mask", Float) = 15
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="true"
            "RenderType"="Transparent"
        }

        Stencil
        {
            Ref[_Stencil]
            Comp[_StencilComp]
            Pass[_StencilOp]
            ReadMask[_StencilReadMask]
            WriteMask[_StencilWriteMask]
        }

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                half2 texcoord  : TEXCOORD0;
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
            };

            sampler2D _MainTex;
            fixed4 _Color;
            float _Offset;
            float _InOut;

            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color;
                return OUT;
            }

            float4 frag (v2f i) : COLOR
            {
                float2 uv = i.texcoord.xy;
                float4 tex = tex2D(_MainTex, uv) * i.color;
                float alpha = tex.a;
                float2 center = float2(0, 1);
                float dist = 1.0 - smoothstep(_Offset, _Offset + 0.5, length(center - float2(i.texcoord.x, i.texcoord.y - 0.25)));
                float c;
                if (_InOut == 0)
                {
                    c = dist;
                }
                else
                {
                    c= 1-dist;
                }
                tex.a = alpha * c;

                return tex;
            }
            ENDCG
        }
    }
    Fallback "Sprites/Default"

}

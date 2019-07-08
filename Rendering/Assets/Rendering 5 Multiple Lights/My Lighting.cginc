#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED

#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"

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
UnityLight CreateLight(Interpolators i){
    UnityLight light;
    light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);// 点光源的话得算一下 lightDir

    //已经不需要自己计算attenuation了
    // float3 lightVec = _WorldSpaceLightPos0.xyz - i.worldPos;
    // float attenuation = 1 / (1 + dot(lightVec, lightVec)); // 点光源得衰减 1/(d的平方) ，加1为了避免距离趋近0时衰减值趋近无限大

    //unity内置得代替自己计算
    UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);//attenuation 是已经被声明了得在AutoLight.cginc
    light.color = _LightColor0.rgb * attenuation; //把点光源得衰减计算在内
    light.ndotl = DotClamped(i.normal, light.dir);
    return light;
}

float4 frag(Interpolators i) : SV_TARGET{
    i.normal = normalize(i.normal);
    float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
    
    float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
    float3 specularTint; // = albedo * _Metallic;
    float oneMinusReflectivity; // = 1 - _Metallic;
    // albedo *= oneMinusReflectivity;
    albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity);


    UnityIndirect indirectLight;
    indirectLight.diffuse = 0;
    indirectLight.specular = 0;

    return UNITY_BRDF_PBS(
        albedo, specularTint, 
        oneMinusReflectivity, _Smoothness, 
        i.normal, viewDir, 
        CreateLight(i), indirectLight);
}         
#endif
            

            
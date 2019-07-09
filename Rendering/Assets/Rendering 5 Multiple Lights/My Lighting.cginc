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
    #if defined(VERTEXLIGHT_ON)
        float3 vertexLightColor : TEXCOORD3;
    #endif
};

float4 _Tint/* _SpecularTint*/;
sampler2D _MainTex, _HeightMap;
float4 _MainTex_ST;
float _Smoothness, _Metallic;

void ComputeVertexLightColor(inout Interpolators i)
{
    #if defined(VERTEXLIGHT_ON)
        i.vertexLightColor = Shade4PointLights(
            unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			unity_LightColor[0].rgb, unity_LightColor[1].rgb,
			unity_LightColor[2].rgb, unity_LightColor[3].rgb,
			unity_4LightAtten0, i.worldPos, i.normal
        );
    #endif
}

Interpolators vert(VertexData v) {
    Interpolators i;
    // i.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw; //用TRANSFORM_TEX 代替
    i.uv = TRANSFORM_TEX(v.uv, _MainTex);
    i.position = UnityObjectToClipPos(v.position);
    i.worldPos = mul(unity_ObjectToWorld, v.position);
    i.normal = UnityObjectToWorldNormal(v.normal);
    i.normal = normalize(i.normal);
    ComputeVertexLightColor(i);
    return i;
}
UnityLight CreateLight(Interpolators i){
    UnityLight light;
    
    #if defined(POINT) || defined(SPOT) || defined(POINT_COOKIE)
        light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);// 点光源的话得算一下 lightDir
    #else
        light.dir = _WorldSpaceLightPos0.xyz;
    #endif

    //unity内置得代替自己计算
    UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);//attenuation 是已经被声明了得在AutoLight.cginc
    light.color = _LightColor0.rgb * attenuation; //把点光源得衰减计算在内
    light.ndotl = DotClamped(i.normal, light.dir);
    return light;
}
UnityIndirect CreateIndirectLight(Interpolators i)
{
    UnityIndirect indirectLight;
    indirectLight.specular = 0;
    indirectLight.diffuse = 0;
    #if defined(VERTEXLIGHT_ON)
        indirectLight.diffuse = i.vertexLightColor;
    #endif
    
    #if defined(FORWARD_BASE_PASS)
    indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
    #endif

    return indirectLight;
}
void initFragNormal(inout Interpolators i)
{
    float h = tex2D(_HeightMap, i.uv).r;
    i.normal = float3(0,h,0);
    i.normal = normalize(i.normal);

}

float4 frag(Interpolators i) : SV_TARGET{
    initFragNormal(i);
    
    float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
    
    float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
    // albedo *= tex2D(_HeightMap, i.uv);

    float3 specularTint; // = albedo * _Metallic;
    float oneMinusReflectivity; // = 1 - _Metallic;
    // albedo *= oneMinusReflectivity;
    albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity);

    // float3 shColor = ShadeSH9(float4(i.normal, 1));
    // return float4(shColor, 1);

    return UNITY_BRDF_PBS(
        albedo, specularTint, 
        oneMinusReflectivity, _Smoothness, 
        i.normal, viewDir, 
        CreateLight(i), CreateIndirectLight(i));
}         
#endif
            

            
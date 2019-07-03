#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED

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


    // float3 diffuse = albedo * lightColor * DotClamped(lightDir, i.normal);
    // float3 halfDir = normalize(lightDir + viewDir);
    // float3 specular = specularTint * lightColor * pow(DotClamped(i.normal, halfDir), _Smoothness * 100);

    // return  float4(diffuse + specular, 1);

    UnityLight light;
    light.color = lightColor;
    light.dir = lightDir;
    light.ndotl = DotClamped(i.normal, lightDir);

    UnityIndirect indirectLight;
    indirectLight.diffuse = 0;
    indirectLight.specular = 0;

    return UNITY_BRDF_PBS(albedo, specularTint, oneMinusReflectivity, _Smoothness, i.normal, viewDir, light, indirectLight);
}         
#endif
            

            
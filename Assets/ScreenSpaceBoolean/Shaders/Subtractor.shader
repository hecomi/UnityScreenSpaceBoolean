Shader "ScreenSpaceBoolean/Subtractor"
{

SubShader
{

Tags { "RenderType"="Opaque" "PerformanceChecks"="False" "Queue"="Geometry-100" "DisableBatching"="True" }

CGINCLUDE

#include "UnityCG.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
};

struct v2f
{
    float4 position : SV_POSITION;
    float3 normal: NORMAL;
};

struct gbuffer_out
{
    half4 diffuse  : SV_Target0; // rgb: diffuse,  a: occlusion
    half4 specular : SV_Target1; // rgb: specular, a: smoothness
    half4 normal   : SV_Target2; // rgb: normal,   a: unused
    half4 emission : SV_Target3; // rgb: emission, a: unused
//  float  depth    : SV_Depth;
};

v2f vert(appdata v)
{
    v2f o;
    o.position = UnityObjectToClipPos(v.vertex);
    o.normal = mul(unity_ObjectToWorld, -v.normal) * 0.5 + 0.5;
    return o;
}

gbuffer_out frag(v2f i)
{
    gbuffer_out o;

    o.diffuse = float4(0.0, 0.0, 0.5, 1.0);
    o.specular = float4(0.0, 0.0, 0.5, 0.0);
    o.normal = float4(i.normal, 1.0);
    o.emission = float4(0.0, 0.0, 0.0, 1.0);
#ifndef UNITY_HDR_ON
    o.emission = exp2(-o.emission);
#endif

    return o;
}

ENDCG

Pass
{
    Tags { "LightMode" = "Deferred" }

    ZWrite Off
    Cull Front
    ZTest Equal

    CGPROGRAM
    #pragma target 3.0
    #pragma vertex vert
    #pragma fragment frag
    #pragma multi_compile ___ UNITY_HDR_ON
    ENDCG
}

}
}

Shader "ScreenSpaceBoolean/Depth"
{

SubShader
{

CGINCLUDE

#include "UnityCG.cginc"

float ComputeDepth(float4 spos)
{
#if defined(UNITY_UV_STARTS_AT_TOP)
    return (spos.z / spos.w);
#else
    return (spos.z / spos.w) * 0.5 + 0.5;
#endif
}

struct appdata
{
    float4 vertex : POSITION;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float4 spos : TEXCOORD0;
};

v2f vert(appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.spos = ComputeScreenPos(o.vertex);
    return o;
}

float4 frag(v2f i) : SV_Target
{
    return ComputeDepth(i.spos);
}

ENDCG

Pass
{
    Cull Back
    ZTest Less
    ZWrite On

    CGPROGRAM
    #pragma vertex vert
    #pragma fragment frag
    ENDCG
}

Pass
{
    Cull Front
    ZTest Greater
    ZWrite On

    CGPROGRAM
    #pragma vertex vert
    #pragma fragment frag
    ENDCG
}

}
}

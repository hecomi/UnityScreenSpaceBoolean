Shader "ScreenSpaceBoolean/Mask"
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

struct gbuffer_out 
{
    half4 color : SV_Target;
    float depth : SV_Depth;
};

sampler2D _SubtracteeBackDepth;

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

gbuffer_out frag_depth(v2f i)
{
    float2 uv = i.spos.xy / i.spos.w;
    float subtracteeBackDepth = tex2D(_SubtracteeBackDepth, uv);
    float subtractorBackDepth = ComputeDepth(i.spos);

    gbuffer_out o;
#if defined(UNITY_REVERSED_Z)
    if (subtractorBackDepth >= subtracteeBackDepth) discard;
    o.color = o.depth = 0.0;
#else
    if (subtractorBackDepth <= subtracteeBackDepth) discard;
    o.color = o.depth = 1.0;
#endif
    
    return o;
}
ENDCG

Pass 
{
    Stencil 
    {
        Ref 1
        Comp Always
        Pass Replace
    }

    Cull Back
    ZTest Less
    ZWrite Off
    ColorMask 0

    CGPROGRAM
    #pragma target 3.0
    #pragma vertex vert
    #pragma fragment frag
    ENDCG
}

Pass 
{
    Stencil 
    {
        Ref 1
        Comp Equal
    }

    Cull Front
    ZTest Greater
    ZWrite On

    CGPROGRAM
    #pragma target 3.0
    #pragma vertex vert
    #pragma fragment frag
    ENDCG
}

Pass 
{
    Stencil 
    {
        Ref 1
        Comp Equal
    }

    Cull Front
    ZTest Greater
    ZWrite On

    CGPROGRAM
    #pragma target 3.0
    #pragma vertex vert
    #pragma fragment frag_depth
    ENDCG
}

Pass 
{
    Stencil 
    {
        Ref 0
        Comp Always
        Pass Replace
    }

    Cull Back
    ZTest Always
    ZWrite Off
    ColorMask 0

    CGPROGRAM
    #pragma target 3.0
    #pragma vertex vert
    #pragma fragment frag
    ENDCG
}

}
}
Shader "ScreenSpaceBoolean/CompositeSubtraction"
{

SubShader
{

CGINCLUDE

sampler2D _SubtractionDepth;

struct appdata
{
    float4 vertex : POSITION;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float4 spos   : TEXCOORD0;
};

struct gbuffer_out
{
    half4 color : SV_Target;
    float depth : SV_Depth;
};

v2f vert(appdata v)
{
    v2f o;
    o.vertex = o.spos = v.vertex;
    o.spos.y *= _ProjectionParams.x;
    return o;
}

gbuffer_out frag(v2f i)
{
    float2 uv = i.spos.xy * 0.5 + 0.5;

    gbuffer_out o;
    o.color = o.depth = tex2D(_SubtractionDepth, uv).x;
    if (o.depth == 1.0) discard;

    return o;
}

ENDCG

Pass 
{
    Cull Off
    ZTest LEqual
    ZWrite On
    ColorMask 0

    CGPROGRAM
    #pragma vertex vert
    #pragma fragment frag
    ENDCG
}

}
}
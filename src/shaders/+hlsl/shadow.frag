cbuffer ConstantBuffer : register(b0)
{
    float4x4 qt_Matrix;
    float qt_Opacity;
    float2 offset;
    float2 delta;
    float darkness;
};

Texture2D source : register(t0);
SamplerState sourceSampler : register(s0);
Texture2D shadow : register(t1);
SamplerState shadowSampler : register(s1);

float4 main(float4 position : SV_POSITION, float2 coord : TEXCOORD0) : SV_TARGET
{
    float4 fg = source.Sample(sourceSampler, coord);
    float4 bg = shadow.Sample(shadowSampler, coord + delta);
    return (fg + float4(0.0, 0.0, 0.0, darkness * bg.a) * (1.0 - fg.a)) * qt_Opacity;
}

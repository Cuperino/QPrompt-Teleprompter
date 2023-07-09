cbuffer ConstantBuffer : register(b0)
{
    float4x4 qt_Matrix;
    float qt_Opacity;
    float2 delta;
};

Texture2D source : register(t0);
SamplerState sourceSampler : register(s0);

float4 main(float4 position : SV_POSITION, float2 coord : TEXCOORD0) : SV_TARGET
{
    return (0.0538 * source.Sample(sourceSampler, coord - 3.182 * delta)
        + 0.3229 * source.Sample(sourceSampler, coord - 1.364 * delta)
        + 0.2466 * source.Sample(sourceSampler, coord)
        + 0.3229 * source.Sample(sourceSampler, coord + 1.364 * delta)
        + 0.0538 * source.Sample(sourceSampler, coord + 3.182 * delta)) * qt_Opacity;
}

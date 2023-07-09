#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 delta;
} ubuf;

void main()
{
    fragColor =(0.0538 * texture(source, qt_TexCoord0 - 3.182 * ubuf.delta)
                + 0.3229 * texture(source, qt_TexCoord0 - 1.364 * ubuf.delta)
                + 0.2466 * texture(source, qt_TexCoord0)
                + 0.3229 * texture(source, qt_TexCoord0 + 1.364 * ubuf.delta)
                + 0.0538 * texture(source, qt_TexCoord0 + 3.182 * ubuf.delta)) * ubuf.qt_Opacity;
}

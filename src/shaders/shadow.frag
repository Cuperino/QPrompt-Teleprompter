uniform lowp float qt_Opacity;
uniform highp vec2 offset;
uniform sampler2D source;
uniform sampler2D shadow;
uniform highp float darkness;
uniform highp vec2 delta;

varying highp vec2 qt_TexCoord0;

void main() {
    lowp vec4 fg = texture2D(source, qt_TexCoord0);
    lowp vec4 bg = texture2D(shadow, qt_TexCoord0 + delta);
    gl_FragColor = (fg + vec4(0., 0., 0., darkness * bg.a) * (1. - fg.a)) * qt_Opacity;
}

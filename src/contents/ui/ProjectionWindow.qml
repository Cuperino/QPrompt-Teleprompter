import QtQuick 2.15
import QtQuick.Window 2.15

// External Windows
Window {
    id: projectionWindow
    title: "Projection Window"
    //transientParent: parent.parent
    //transientParent: null
    visible: false
    color: "#000"
    //color: "transparent"
    width: parent.width
    height: parent.height
    Rectangle {
        color: "#222"
        anchors.fill: parent
        // Bad, glitchy, experiment. Takes control away from original Item and transfers it to ShaderEffect object...
        /*ShaderEffect {
            *                        width: parent.width; height: parent.height
            *                        property variant source: prompter
            *                        //property variant color: Qt.vector3d(0.344, 0.5, 0.156)
            *                        //fragmentShader: "qrc:shaders/effect.frag" // selects the correct variant automatically
            *                        fragmentShader: "
            *                        uniform sampler2D source: source; //prompter item
            *                        uniform lowp float qt_Opacity; // inherited opacity of this item
            *                        varying highp vec2 qt_TexCoord0;
            *                        void main() {
            *                            lowp vec4 p = texture2D(source, qt_TexCoord0);
            *                            lowp float g = dot(p.xyz, vec3(0.344, 0.5, 0.156));
            *                            gl_FragColor = vec4(g, g, g, p.a) * qt_Opacity;
    }"
    }*/
    }
}

import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
    id: shaderRoot
    anchors.fill: parent

    property color themeColor
    property real shaderTime: 0.0
    property bool reverseGradient: false

    layer.enabled: true

    ShaderEffect {
        anchors.fill: parent

        property color innerColor: !shaderRoot.reverseGradient ? Qt.lighter(shaderRoot.themeColor, 1.3) : Qt.darker(shaderRoot.themeColor, 1.3)
        property color outerColor: !shaderRoot.reverseGradient ? Qt.darker(shaderRoot.themeColor, 1.3) : Qt.lighter(shaderRoot.themeColor, 1.3)
        property point center: Qt.point(0.5, 0.5)
        property real noiseIntensity: 0.10	
        property real patternDensity: 50.0   // 모바일에서는 낮춤
        property real time: shaderRoot.shaderTime / 10.0

        fragmentShader: "
            precision highp float;

            varying highp vec2 qt_TexCoord0;
            uniform lowp vec4 innerColor;
            uniform lowp vec4 outerColor;
            uniform highp vec2 center;
            uniform lowp float noiseIntensity;
            uniform highp float patternDensity;
            uniform highp float time;

            highp float rand(highp vec2 co) {
                return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
            }

            void main() {
                highp float dist = distance(qt_TexCoord0, center);
                highp float t = smoothstep(0.0, 0.9, dist);
                lowp vec4 color = mix(innerColor, outerColor, t);

                highp vec2 noiseCoord = qt_TexCoord0 * patternDensity + vec2(time);
                highp float noise = rand(noiseCoord);

                highp float lighting = noise * 2.0 - 1.0;	
                color.rgb += lighting * noiseIntensity;

                gl_FragColor = color;
            }
        "
    }
}
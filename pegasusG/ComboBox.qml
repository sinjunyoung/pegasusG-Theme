import QtQuick 2.15
import "configs.js" as CONFIGS

Row {
    id: root

    property alias fontSize: labeltext.font.pixelSize
    property alias value: currentValue.text
    property alias label: labeltext.text
    property alias textColor: labeltext.color
    property Item focusTarget
    property var model: []

    signal valueChange

    property var model_i: value ? model.indexOf(value) : 0

    Keys.onUpPressed: {
        event.accepted = true;
        model_i = model_i == 0 ? model.length - 1 : model_i - 1
        value = model[model_i]
        valueChange()
    }
    Keys.onDownPressed: {
        event.accepted = true;
        model_i = model_i == model.length - 1 ? 0 : model_i + 1
        value = model[model_i]
        valueChange()
    }
    Keys.onPressed: {
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            model_i = model_i == model.length - 1 ? 0 : model_i + 1
            value = model[model_i]
            valueChange()
        }
        if (api.keys.isCancel(event)) {
            event.accepted = true;
            if (focusTarget) focusTarget.focus = true
        }
    }

    Rectangle {
        id: slider
        width: parent.fontSize * 8
        height: parent.fontSize * 1.5
        radius: vpx(6)

        property color baseColor: (typeof CONFIGS !== "undefined" && CONFIGS.THEME_COLORS && CONFIGS.THEME_COLORS[api.memory.get("main_top")]) ? CONFIGS.THEME_COLORS[api.memory.get("main_top")] : "#1a1a1a"

        // 배경 강조: 포커스 시만 밝은 배경
        color: root.activeFocus ? Qt.lighter(baseColor, 1.8) : "transparent"
        border.color: root.activeFocus ? Qt.lighter(baseColor, 2.5) : "transparent"
        border.width: root.activeFocus ? 2 : 0

        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 5

        Text {
            id: currentValue
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            font.family: subtitleFont.name
            font.pixelSize: parent.height * (root.activeFocus ? 0.8 : 0.7)
            font.bold: true // 항상 볼드
            style: Text.Outline
            styleColor: root.activeFocus ? "#000000" : "#555555"
            color: root.activeFocus ? "#ffffff" : "#cccccc"
            opacity: 1.0

            anchors {
                right: arrowright.left
                leftMargin: 5
                rightMargin: 5
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!root.focus) root.focus = true
                    else {
                        model_i = model_i == model.length - 1 ? 0 : model_i + 1
                        value = model[model_i]
                        valueChange()
                    }
                }
            }
        }

        Text {
            id: arrowright
            text: "↑↓"
            font.bold: true
            font.pixelSize: parent.height * 0.5
            verticalAlignment: Text.AlignVCenter
            color: currentValue.color

            anchors {
                top: parent.top
                topMargin: parent.height * 0.2
                right: parent.right
                rightMargin: parent.height * 0.6
            }
        }
    }

    Text {
        id: labeltext
        visible: false
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        color: "#eee"
        font.family: subtitleFont.name
        style: Text.Outline
        styleColor: "black"
        anchors.leftMargin: 5
    }
}
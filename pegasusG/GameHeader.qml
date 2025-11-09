import QtQuick 2.8
import QtGraphicalEffects 1.12
import "utils.js" as Utils
import "configs.js" as CONFIGS
import "constants.js" as CONSTANTS

Rectangle {
    id: header
    
    property var currentCollection
    property bool isSquareScreen
    property bool isAndroid
    property int headerHeight
    property alias searchText: searchBox.text
    property alias searchBoxFocused: searchBox.activeFocus
    
    signal searchChanged(string text)
    signal requestGameListFocus()
    signal requestCollectionsViewFocus()
    
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: headerHeight
    
    readonly property int paddingH: vpx(0)
    readonly property int paddingV: vpx(0)
    
    property color themeColor: CONFIGS.getThemeColor(api)

    property real shaderTime: 0.0 
    
    Timer {
        id: shaderTimer
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            header.shaderTime += 0.01;
        }
    }
    
    BackgroundShader {
        anchors.fill: parent
        themeColor: header.themeColor
        shaderTime: header.shaderTime
    }

    Row {
        height: parent.height - header.paddingV*1.1
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: vpx(10)
        }
        spacing: vpx(15)
        
        Image {
            id: logoImage
            height: parent.height
            width: vpx(50)
            fillMode: Image.PreserveAspectFit
            source: currentCollection && currentCollection.shortName ? "../Resource/Images/%1.png".arg(Utils.getPlatformName(currentCollection.shortName)) : ""
            asynchronous: true
            mipmap: true
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Item {
            width: labelText.width
            height: labelText.height
            anchors.verticalCenter: parent.verticalCenter		
            Text {
                id: labelText
                text: currentCollection && currentCollection.shortName ? Utils.getPlatformName(currentCollection.shortName) : ""
                color: "#ffffff"
                font.pixelSize: vpx(30)
                font.family: subtitleFont.name
                font.weight: Font.Bold
                
                layer.enabled: true
                layer.effect: Glow {
                    color: "#FFC107"
                    radius: 10
                    samples: 12
                    spread: 0.05
                    cached: true
                }
            }
        }
    }

    Rectangle {
        id: searchBoxContainer
        width: vpx(250)
        height: isSquareScreen ? vpx(80) : vpx(55)
        radius: isSquareScreen ? vpx(25) : vpx(20)
        color: "#33000000"
        border.color: searchBox.activeFocus ? "#06fbf2" : "#66ffffff"
        border.width: 2
        visible: true
        opacity: 0.85
        z: 100
        
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: vpx(30)
        }

        Row {
            anchors.fill: parent
            anchors.margins: vpx(8)
            spacing: vpx(8)

            Text {
                text: "🔍"
                font.pixelSize: isSquareScreen ? vpx(24) : vpx(20)
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
            }

            TextInput {
                id: searchBox
                width: parent.width - vpx(60)
                height: parent.height
                font.pixelSize: isSquareScreen ? vpx(22) : vpx(18)
                font.family: subtitleFont.name
                color: "#ffffff"
                verticalAlignment: TextInput.AlignVCenter
                selectByMouse: true
                selectionColor: "#06fbf2"
                selectedTextColor: "#000000"
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                
                property string lastText: ""
                property bool ignoreChange: false
                
                Text {
                    text: isAndroid ? "터치로 검색" : "F3 또는 S 키로 검색"
                    font: parent.font
                    color: "#88ffffff"
                    visible: parent.text.length === 0 && !parent.activeFocus
                    anchors.verticalCenter: parent.verticalCenter
                }

                Timer {
                    id: changeDebounce
                    interval: 100
                    onTriggered: {
                        searchBox.ignoreChange = false;
                    }
                }

                onActiveFocusChanged: {
                    if (activeFocus) {
                        Qt.inputMethod.show();
                        lastText = text;
                    } else {
                        Qt.inputMethod.hide();
                        ignoreChange = false;
                    }
                }

                onTextChanged: {
                    if (ignoreChange) {
                        return;
                    }
                    
                    if (text === lastText + lastText.slice(-10)) {
                        text = lastText;
                        ignoreChange = true;
                        changeDebounce.restart();
                        return;
                    }
                    
                    lastText = text;
                    searchChanged(text);
                }

                Keys.onReturnPressed: {
                    event.accepted = true;
                    ignoreChange = true;
                    changeDebounce.restart();
                    Qt.inputMethod.commit();
                    requestGameListFocus();
                    Qt.inputMethod.hide();
                }
                
                Keys.onEnterPressed: {
                    event.accepted = true;
                    ignoreChange = true;
                    changeDebounce.restart();
                    Qt.inputMethod.commit();
                    requestGameListFocus();
                    Qt.inputMethod.hide();
                }

                Keys.onUpPressed: {
                    event.accepted = true;
                    requestGameListFocus();
                    Qt.inputMethod.hide();
                }
                Keys.onDownPressed: {
                    event.accepted = true;
                    requestGameListFocus();
                    Qt.inputMethod.hide();
                }
            }

            Text {
                text: "✕"
                font.pixelSize: isSquareScreen ? vpx(22) : vpx(18)
                color: "#ffffff"
                visible: searchBox.text.length > 0
                anchors.verticalCenter: parent.verticalCenter
                
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: vpx(-5)
                    onClicked: {
                        searchBox.text = "";
                        requestGameListFocus();
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            z: 10
            onClicked: {
                searchBox.forceActiveFocus();
                searchBox.selectAll();
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked:{
            requestCollectionsViewFocus();
        }
    }
    
    function clearSearch() {
        searchBox.text = "";
    }

    function clearFocus() {
        searchBox.focus = false;
    }
    
    function focusSearchBox() {
        searchBox.forceActiveFocus();
        searchBox.selectAll();
    }
}
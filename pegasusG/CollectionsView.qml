import QtQuick 2.8
import QtMultimedia 5.15
import QtGraphicalEffects 1.12
import "utils.js" as Utils
import "configs.js" as CONFIGS

FocusScope {
    id: root

    width: parent.width
    height: parent.height
    enabled: focus
    visible: y + height >= 0

    signal collectionSelected

    property alias currentCollectionIndex: logoAxis.currentIndex
    readonly property var currentCollection: allCollections[collectionsView.currentCollectionIndex]
    
    property color themeColor: CONFIGS.getThemeColor(api)
    
    property real shaderTime: 0.0
    
    Timer {
        id: shaderTimer
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            root.shaderTime += 0.01;
        }
    }
    function selectNext() {
        logoAxis.incrementCurrentIndex();
    }
    function selectPrev() {
        logoAxis.decrementCurrentIndex();
    }

    Carousel {
        id: bgAxis

        anchors.fill: parent
        itemWidth: width

        model: allCollections
        delegate: bgAxisItem
        currentIndex: logoAxis.currentIndex
        onCurrentIndexChanged: {
            if (currentIndex !== currentCollectionIndex){
                const temp = currentIndex
                currentCollectionIndex = temp
            }
        }

        highlightMoveDuration: 300
    }
    
    Component {
        id: bgAxisItem

        Item {
            width: root.width
            height: root.height
            visible: PathView.onPath

            BackgroundShader {
                anchors.fill: parent
                themeColor: root.themeColor
                shaderTime: root.shaderTime
            }

            Image {
                id: realBg
                width: parent.width * 0.5
                height: parent.height * 0.5
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                source: modelData.shortName ? "../Resource/Images/%1.png".arg(Utils.getPlatformName(modelData.shortName)) : ""
                asynchronous: true
                smooth: true
                antialiasing: true
            }

            DropShadow {
                anchors.fill: realBg
                source: realBg
                horizontalOffset: 0
                verticalOffset: 30
                radius: 60
                samples: 64
                color: "#cc000000"
                transparentBorder: true
                cached: true
            }
        }
    }

    Text {
        id: galleryTitle
        text: "레트로 게임기 갤러리"

        anchors {
            left: parent.left;
            leftMargin: parent.height * .07;
            top: parent.top;
        }

        color: "white"
        font.family: subtitleFont.name
        font.weight: Font.Bold
        font.letterSpacing: 2
        style: Text.Outline;
        font.pixelSize: headerWidgets.height * .26;
        horizontalAlignment: Text.Left
        font.capitalization: Font.SmallCaps
        
        height: headerWidgets.height	
        verticalAlignment: Text.AlignVCenter
        
        layer.enabled: true
        layer.effect: Glow {
            color: "#06fbf2"
            radius: 10
            samples: 16
            spread: 0.1
            cached: true
        }
    }
    
    Row {
        id: headerWidgets;
        spacing: vpx(20);
        height: vpx(100)

        anchors {
            right: parent.right;
            rightMargin: parent.height * .07;
            top: parent.top;
        }
        
        Text {
            id: sysTime

            property var timeSetting: "hh:mm";
            anchors.verticalCenter: parent.verticalCenter;
            
            function set() {
                sysTime.text = Qt.formatTime(new Date(), timeSetting)	
            }

            Timer {
                id: textTimer
                interval: 60000
                repeat: true
                running: true
                triggeredOnStart: true
                onTriggered: sysTime.set()
            }
            
            color: "white"
            font.family: subtitleFont.name
            font.weight: Font.Bold
            font.letterSpacing: 2
            style: Text.Outline;
            font.pixelSize: parent.height * .26;
            horizontalAlignment: Text.Right
            font.capitalization: Font.SmallCaps
        }
    
        Battery {
            id: battery;
            visible: Math.floor(api.device.batteryPercent*100) > 0
            opacity: 1;
            shade: "light";
            height: parent.height*0.3;
            width: parent.height*0.55;
            anchors.verticalCenter: parent.verticalCenter;
            anchors.verticalCenterOffset: vpx(2)
            
            Image{
                id: chargingIcon

                property bool chargingStatus: api.device.batteryCharging

                width: height/2
                height: sysTime.paintedHeight*.8
                fillMode: Image.PreserveAspectFit
                source: "../Resource/charging.svg"
                sourceSize.width: 32
                sourceSize.height: 64
                smooth: true
                anchors.horizontalCenter: parent.horizontalCenter;
                anchors.verticalCenter: parent.verticalCenter;
                horizontalAlignment: Image.AlignLeft
                visible: chargingStatus && api.device.batteryPercent*100 < 99

                function set() {
                    chargingStatus = api.device.batteryCharging;
                }

                Timer {
                    id: chargingIconTimer
                    interval: 500
                    running: true
                    repeat: true
                    onTriggered: chargingIcon.set()
                }
                
                Image{
                    id: chargingIcon2

                    property bool chargingStatus: api.device.batteryCharging

                    width: height/2
                    height: sysTime.paintedHeight*.75
                    fillMode: Image.PreserveAspectFit
                    source: "../Resource/charging.svg"
                    sourceSize.width: 32
                    sourceSize.height: 64
                    smooth: true
                    anchors.horizontalCenter: parent.horizontalCenter;
                    anchors.verticalCenter: parent.verticalCenter;
                    horizontalAlignment: Image.AlignLeft
                    visible: chargingStatus && api.device.batteryPercent*100 < 99
                    layer.enabled: true
                    layer.effect: ColorOverlay {
                        color: "white"
                        antialiasing: true
                        cached: true
                    }

                    function set() {
                        chargingStatus = api.device.batteryCharging;
                    }

                    Timer {
                        id: chargingIconTimer2
                        interval: 500
                        repeat: true
                        running: true
                        onTriggered: chargingIcon2.set()
                    }
                }
            }
        }
        
        Text {
            id: batteryPercentage
            text: {
                if(Math.floor(api.device.batteryPercent*100) > 0 ){
                    return Math.floor(api.device.batteryPercent*100) + "%"
                } else {
                    return "배터리 없음"
                }
            }
            visible: Math.floor(api.device.batteryPercent*100) > 0
            opacity: 1;
            color: "#fff";
            anchors.verticalCenter: parent.verticalCenter;
            font {
                family: subtitleFont.name;
                pixelSize: parent.height * .26;
                bold: true;
            }
            style: Text.Outline;
        }
    }
    
    Item {
        id: logoBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: vpx(170)

        Rectangle {
            anchors.fill: parent
            color: "#8b8b8b"
            opacity: 0
        }
        
        Carousel {
            id: logoAxis

            anchors.fill: parent
            itemWidth: vpx(500)

            model: allCollections
            delegate: CollectionLogo {
                longName: modelData.name
                shortName: Utils.getPlatformName(modelData.shortName)
            }

            focus: true

            Keys.onPressed: {
                if (api.keys.isNextPage(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    if(currentIndex == allCollections.length-1) {
                        currentIndex = 0;return;
                    }
                    else if (currentIndex + 5 > allCollections.length-1) {
                        currentIndex = allCollections.length-1;return;
                    }
                    currentIndex = currentIndex+5;
                }
                else if (api.keys.isPrevPage(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    if(currentIndex == 0) {
                        currentIndex = allCollections.length-1;return;
                    }
                    else if (currentIndex - 5 < 0) {
                        currentIndex = 0;return;
                    }
                    currentIndex = currentIndex-5;
                }
                else if (api.keys.isPageUp(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    currentIndex = 0;
                }
                else if (api.keys.isPageDown(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    currentIndex = allCollections.length-1;
                }
            }

            onItemSelected: root.collectionSelected()
        }
    }
}
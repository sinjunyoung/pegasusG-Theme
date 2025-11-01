import QtQuick 2.8
import QtMultimedia 5.15
import QtGraphicalEffects 1.12
import "utils.js" as Utils

FocusScope {
    id: root

    width: parent.width
    height: parent.height
    enabled: focus
    visible: y + height >= 0

    signal collectionSelected

    property alias currentCollectionIndex: logoAxis.currentIndex
    readonly property var currentCollection: allCollections[collectionsView.currentCollectionIndex]

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

            Rectangle {
                anchors.fill: parent
                color: "#777"
                visible: false
            }
            Image {
                id: realBg
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: modelData.shortName ? "../Resource/Background_image1/%1.jpg".arg(Utils.getPlatformImageName(modelData.shortName)) : ""
                asynchronous: true
            }
        }
    }

    Image{
        id: pegasusLogo
        source: '../Resource/Background_image1/Pegasus G-2.png';
        fillMode: Image.PreserveAspectFit;
        horizontalAlignment: Image.AlignLeft;
        height: headerWidgets.height*.65;
        mipmap:true
        opacity: 1
        
        anchors {
            verticalCenter: headerWidgets.verticalCenter;
            verticalCenterOffset: vpx(4)
            left: parent.left;
            leftMargin: 24;
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
            visible: Math.floor(api.device.batteryPercent*100) > 0  // 배터리가 있을 때만 표시
            opacity: 1;
            shade: parent.shade;
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
                source: "assets/charging.svg"
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
                    source: "assets/charging.svg"
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
            visible: Math.floor(api.device.batteryPercent*100) > 0  // 배터리가 있을 때만 표시
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
            itemWidth: vpx(480)

            model: allCollections
            delegate: CollectionLogo {
                longName: modelData.name
                shortName: Utils.getPlatformImageName(modelData.shortName)
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

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: logoBar.top
        height: label.height * 1.5

        Rectangle {
            anchors.fill: parent
            color: "#c20214"
            opacity: 0
        }
        
        Image {
            id: realBg
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: currentCollection.shortName ? "../Resource/Background_image1/%1_art_blur.jpg".arg(Utils.getPlatformImageName(currentCollection.shortName)) : ""
            asynchronous: true
        }
    }
}
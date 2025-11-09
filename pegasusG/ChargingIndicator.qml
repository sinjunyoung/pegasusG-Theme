import QtQuick 2.8
import QtGraphicalEffects 1.12

Image {
    id: chargingIndicator

    property var api: null 
    property real requiredHeight: 0
    property bool useColorOverlay: false

    property bool chargingStatus: api && api.device ? api.device.batteryCharging : false
    
    width: height/2
    height: requiredHeight * (useColorOverlay ? .75 : .8) 
    fillMode: Image.PreserveAspectFit
    source: "assets/charging.svg"
    sourceSize.width: 32
    sourceSize.height: 64
    smooth: true
    anchors.horizontalCenter: parent.horizontalCenter;
    anchors.verticalCenter: parent.verticalCenter;
    horizontalAlignment: Image.AlignLeft
    visible: chargingStatus && api && api.device && api.device.batteryPercent*100 < 99
    
    layer.enabled: useColorOverlay
    layer.effect: ColorOverlay {
        color: "white"
        antialiasing: true
        cached: true
    }

    function set() {
        if (api && api.device) {
            chargingStatus = api.device.batteryCharging;
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: chargingIndicator.set()
    }
}
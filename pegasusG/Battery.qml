import QtQuick 2.15
Item {
    property string shade: 'light';
    property color batteryColorLight: "#ffffff"  // 기본 색상 정의
    property color batteryColorDark: "#666666"   // 기본 색상 정의
    
    property color shadeColor: {
        return shade === 'light' ? batteryColorLight : batteryColorDark;
    }
    
    // border
    Rectangle {
        id: batteryBorder;
        height: parent.height;
        width: parent.width;
        radius: 3;
        color: "white";
        border {
            color: "black";
            width: 1;
        }
    }
    
    // fill level
    Rectangle {
        color: "green";
        width: Math.max(api.device.batteryPercent * (parent.width - 6), 2);
        height: parent.height - 6;
        radius: 1;
        anchors {
            left: parent.left;
            leftMargin: 3;
            top: parent.top;
            topMargin: 3;
        }
    }
    
    // button
    Rectangle {
        height: parent.height * .42;
        width: parent.height * .14;
        radius: width;
        color: "white";
        border.color: "black";
        anchors {
            verticalCenter: parent.verticalCenter;
            left: parent.right;
            leftMargin: 1;
        }
    }
}
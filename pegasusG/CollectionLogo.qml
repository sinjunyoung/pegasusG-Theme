import QtQuick 2.8
import "utils.js" as Utils
import QtMultimedia 5.15
import QtGraphicalEffects 1.12

Item {
    property string longName: ""
    property string shortName: ""
    property var colIdx: currentCollectionIndex + 1
    property var colCt: api.collections.count + 3
    readonly property bool selected: PathView.isCurrentItem
    width: vpx(480)
    height: vpx(120)
    visible: PathView.onPath
    opacity: selected ? 1.0 : 0.6
    
    Behavior on opacity { NumberAnimation { duration: 150 } }
    
    Item {
        id: contentContainer
        anchors.horizontalCenter: parent.horizontalCenter 
        anchors.verticalCenter: parent.verticalCenter
        width: image.width + rightLabel.width + vpx(20)
        height: image.height
        
        Image {
            id: image
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            
            width: vpx(50)
            height: vpx(50)
            fillMode: Image.PreserveAspectFit
            source: shortName ? "../Resource/Images/%1.png".arg(Utils.getPlatformName(shortName)) : ""
            sourceSize.width: vpx(50)
            sourceSize.height: vpx(50)
            
            asynchronous: true
            cache: true       
            mipmap: true
            smooth: true
            onStatusChanged: {
                if (status === Image.Error) {
                    colorOverlay.visible = true
                }
            }
        }
        
        Rectangle {
            id: colorOverlay
            anchors.fill: image
            color: "red"
            visible: false
            z: 100
        }
        
        Item {
            id: rightLabel
            anchors.verticalCenter: image.verticalCenter
            anchors.left: image.right
            anchors.leftMargin: vpx(20)
            width: labelText.width
            height: labelText.height
          
            Text {
                id: labelText
                text: shortName
                color: "#ffffff"
                font.pixelSize: vpx(40)
                font.family: subtitleFont.name
                font.weight: Font.Bold
                
                layer.enabled: true
                layer.effect: Glow {
                    color: "#FFD700"
                    radius: 15
                    samples: 32
                    spread: 0.2
                    cached: true
                }
            }
        }
    }
    
    Text {
        visible: selected
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -vpx(15)
        text: "%1 GAMES".arg(currentCollection.games.count) + "     " +
              "페이지：" + colIdx + "/" + colCt
        color: "#ffffff"
        font.pixelSize: vpx(26)
        font.family: subtitleFont.name
    }
}
import QtQuick 2.8
import QtMultimedia 5.15

// The collection logo on the collection carousel. Just an image that gets scaled
// and more visible when selected. Also has a fallback text if there's no image.
Item {
    property string longName: "" // set on the PathView side
    property string shortName: "" // set on the PathView side
	property var colIdx: currentCollectionIndex+1
	property var colCt: api.collections.count+3
    readonly property bool selected: PathView.isCurrentItem

    width: vpx(480)
    height: vpx(120)
    visible: PathView.onPath // optimization: do not draw if not visible

    opacity: selected ? 1.0 : 0.6
    Behavior on opacity { NumberAnimation { duration: 150 } }


    Image {
        id: image
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit

        source: shortName ? "../Resource/Logo1/%1.png".arg(shortName) : ""
        asynchronous: true
        // sourceSize { width: 256; height: 256 } // optimization: render SVGs in at most 256x256
		// antialiasing: true		
		mipmap: true
        scale: selected ? 0.9 : 0.55
        Behavior on scale { NumberAnimation { duration: 200 } }
    }
	
	Text {
            visible: selected ? true : false ;
            anchors.horizontalCenter: parent.horizontalCenter
			anchors.horizontalCenterOffset: -vpx(10)
			anchors.bottom: parent.bottom
			anchors.bottomMargin: -vpx(15)
            text: "%1 GAMES".arg(currentCollection.games.count)+"    "+"페이지："+colIdx+"/"+colCt
            // text: currentCollection.name
		
            color: "#ffffff"
            font.pixelSize: vpx(26)
            font.family: subtitleFont.name
			style: Text.Outline;styleColor:"black"
			Behavior on visible { NumberAnimation { duration: 200 } }
    }

    Text {
        id: label
        anchors.centerIn: parent
        color: "#000"
        font.family: subtitleFont.name
		style: Text.Outline;styleColor:"black"
        font.pixelSize: vpx(50)
        text: shortName || longName

        visible: false//image.status != Image.Ready

        scale: selected ? 1.5 : 1.0
        Behavior on scale { NumberAnimation { duration: 150 } }
    }
}

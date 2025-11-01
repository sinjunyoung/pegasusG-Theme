import QtQuick 2.15


Item {
    id: root

    readonly property real titleFontSize: vpx(20)
    property bool selected: false
    property int pixelsPerSecond: vpx(30)
    property alias text: verticalMarquee.text



    readonly property int spacing: vpx(20)

    clip: true

    Text {
        id: verticalMarquee

        width: root.width
        height: Math.max(contentHeight, root.height)
        color: "#FFFFFF"
		font.family: subtitleFont.name
        font.pixelSize: titleFontSize
        //fontSizeMode: Text.VerticalFit
        elide: Text.ElideNoneuuu
        horizontalAlignment: Text.AlignHLeft
        verticalAlignment: Text.AlignVTop
        style: Text.Outline
		wrapMode: Text.WordWrap
		lineHeight: 1.2
		
		
        NumberAnimation on y {
            id: anim
            running: root.height < verticalMarquee.contentHeight && selected
            from: 0
            to: -child.y
            duration: Math.abs(anim.to) / root.pixelsPerSecond * 700
            loops: Animation.Infinite
			easing.type: Easing.InOutQuad
					
            onRunningChanged: {  
               if (!running) {
                  verticalMarquee.y = 0;
               }
            }
        }
		
        Text {
            id: child
		
            y: verticalMarquee.contentHeight + root.spacing
            text: anim.running ? parent.text : ''
            visible: anim.running
		
            width: parent.width
            height: parent.height
            color: parent.color
            font: parent.font
            elide: parent.elide
            horizontalAlignment: parent.horizontalAlignment
            verticalAlignment: parent.verticalAlignment
            style: parent.style
			wrapMode: Text.WordWrap
			lineHeight: parent.lineHeight
        }
    }
}
import QtQuick 2.0

Row {
    id: root

    property alias fontSize: labeltext.font.pixelSize
    property alias value: currentValue.text
    property alias label: labeltext.text
    property alias textColor: labeltext.color
    property var model: []

    signal valueChange

    // private
    property var model_i: value ? model.indexOf(value): 0


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
		if (api.keys.isAccept(event)&& !event.isAutoRepeat) {
        event.accepted = true;
        model_i = model_i == model.length - 1 ? 0 : model_i + 1
        value = model[model_i]
        valueChange()
        }
		if (api.keys.isCancel(event)) {
            event.accepted = true;
			gameList.focus = true 
        }
	}
	


    Rectangle {

        id: slider
        width: parent.fontSize*8//150
        height: parent.fontSize * 1.5

        color: 'transparent'//"#50000000"
        border.color: 'transparent'//"#60000000"
        border.width: vpx(1)

        anchors {
            verticalCenter: parent.verticalCenter
            rightMargin: 5
        }

        // Text {
            // id: arrowleft
            // color: "#eee"
            // font {
                // bold: true
                // pixelSize: parent.height * 1
            // }
            // verticalAlignment: Text.AlignVCenter

            // anchors {
                // top: parent.top
                // topMargin:1
                // left: parent.left
                // leftMargin: 5
            // }
            // text: '↑'
        // }
        Text {
            id: currentValue
			// opacity: 0.5
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            // horizontalAlignment: Text.AlignHCenter
            horizontalAlignment: Text.AlignRight
			// font.underline: root.activeFocus		
            // color: root.activeFocus ? "#06fbf2" : "#ffffff"
            anchors {
                // left: parent.left
                // left: arrowleft.right
                right: arrowright.left
                leftMargin: 5
                rightMargin: 5
            }

        font.family: subtitleFont.name
        // style: Text.Outline; styleColor: "#666666"
			color:  if (root.activeFocus && (!api.memory.has("main_top") || api.memory.get("main_top")=="블랙테마")){return "#06fbf2"}
				else if (root.activeFocus && api.memory.get("main_top")=="화이트테마"){return "#e52d28"}
				else if (root.activeFocus && api.memory.get("main_top")=="레트로테마"){return "#06fbf2"}
				else if (root.activeFocus && api.memory.get("main_top")=="닌텐도테마"){return "#e52d28"}
				else if(api.memory.has("main_top") && api.memory.get("main_top")=="화이트테마"){return "#555555"}
				else if(api.memory.has("main_top") && api.memory.get("main_top")=="레트로테마"){return "#ffffff"}
				else if(api.memory.has("main_top") && api.memory.get("main_top")=="닌텐도테마"){return "#555555"}
				else {return "#ffffff"}
			style: if(api.memory.has("main_top") && api.memory.get("main_top")=="화이트테마"){return Text.Normal}
                                                  else if(api.memory.has("main_top") && api.memory.get("main_top")=="닌텐도테마"){return Text.Normal}
				else {return Text.Outline;styleColor:"#555555"}
			opacity: if(api.memory.has("main_top") && api.memory.get("main_top")=="화이트테마"){return 1}
                                                  else if(api.memory.has("main_top") && api.memory.get("main_top")=="닌텐도테마"){return 1}
				else {return 0.5}
	    font.pixelSize: parent.height * .7
         MouseArea {
				anchors.fill: parent;

				onClicked: {
									if(!root.focus){root.focus = true}
									else {model_i = model_i == model.length - 1 ? 0 : model_i + 1
									value = model[model_i]
									valueChange()}
				}
			}
        }
        Text {
            id: arrowright
			// color: root.activeFocus ? "#06fbf2" : "#ffffff"
            // color: arrowleft.color
			// style: Text.Outline; styleColor: "#666666"
			font {
                bold: true
                pixelSize: parent.height * .7
            }
			verticalAlignment: Text.AlignVCenter
            // font: arrowleft.font
			anchors {
                top: parent.top
                topMargin: parent.height * .2
                right: parent.right
                rightMargin: parent.height * .6
            }
			color:  if (root.activeFocus && (!api.memory.has("main_top") || api.memory.get("main_top")=="블랙테마")){return "#06fbf2"}
				else if (root.activeFocus && api.memory.get("main_top")=="화이트테마"){return "#e52d28"}
				else if (root.activeFocus && api.memory.get("main_top")=="레트로테마"){return "#06fbf2"}
				else if (root.activeFocus && api.memory.get("main_top")=="닌텐도테마"){return "#e52d28"}
				else if(api.memory.has("main_top") && api.memory.get("main_top")=="화이트테마"){return "#555555"}
				else if(api.memory.has("main_top") && api.memory.get("main_top")=="레트로테마"){return "#ffffff"}
				else if(api.memory.has("main_top") && api.memory.get("main_top")=="닌텐도테마"){return "#555555"}
				else {return "#ffffff"}
			style: if(api.memory.has("main_top") && api.memory.get("main_top")=="화이트테마"){return Text.Normal}
                                             else if(api.memory.has("main_top") && api.memory.get("main_top")=="닌텐도테마"){return Text.Normal}
				else {return Text.Outline;styleColor:"#555555"}
			opacity: if(api.memory.has("main_top") && api.memory.get("main_top")=="화이트테마"){return 1}
                                                else if(api.memory.has("main_top") && api.memory.get("main_top")=="닌텐도테마"){return 1}
				else {return 0.5}
            // anchors {
                // top: arrowleft.anchors.top
                // topMargin: arrowleft.anchors.topMargin
                // right: parent.right
                // rightMargin: 5
            // }
            text: '↑↓'
        }
    }

    Text {
        id: labeltext
        visible: false
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        color: "#eee"
        font.family: subtitleFont.name
        style: Text.Outline; styleColor: "black"
         anchors {             leftMargin: 5         }
    }
	

}

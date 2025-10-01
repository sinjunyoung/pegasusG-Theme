import QtQuick 2.15

Item {
    property string shade: api.memory.has('darkMode') ? api.memory.get('darkMode') : 'true'//'light';
    property string shadeColor: {
        return shade === 'light'
			? theme.current.settingsColorDark
			: theme.current.settingsColorLight;
    }
	    
	property string shadeColor2: {
        return shade === 'false'
			? theme.current.defaultHeaderNameColor//theme.current.settingsColorLight
			: theme.current.defaultHeaderNameColor//theme.current.settingsColorDark;
			 
    }

    width: clockText.width;

    Component.onCompleted: {
        clockTimer.start();
        settings.addCallback('twelveHour', clockTimer.restart);
    }

    Timer {
        id: clockTimer;

        interval: 30000;
        repeat: true;
        triggeredOnStart: true;

        onTriggered: {
            let format = 'hh:mm';

            if (settings.get('twelveHour')) {
                format = 'h:mm ap';
            }

            clockText.text = Qt.formatTime(new Date(), format);

        }
    }

    Text {
        id: clockText;

        text: '00:00';
        color: currentView == 'collectionList' ? "#fff" : shadeColor2;
         font.family: subtitleFont.name
        anchors.verticalCenter: parent.verticalCenter;
        style: currentView == 'collectionList' ? Text.Outline : Text.Normal
        font {
            pixelSize: parent.height * .33;
            letterSpacing: -0.3;
            bold: true;
        }

        MouseArea {
            anchors.fill: parent;
            onClicked: {
                settings.toggle('twelveHour');
            }
        }
    }
}

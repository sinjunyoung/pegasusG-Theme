import QtQuick 2.8
import "utils.js" as Utils
import QtMultimedia 5.15
import QtGraphicalEffects 1.12
import "configs.js" as CONFIGS
import "constants.js" as CONSTANTS

Rectangle {
    id: content
    
    // Props
    property var currentGame
    property var currentCollection
    property var filteredGames
    property alias currentGameIndex: gameList.currentIndex
    property alias gameList: gameList
    property bool isSquareScreen
    property int contentPaddingH
    property int contentPaddingV
    property real gameListWidthRatio
    
    // Signals
    signal gameLaunched()
    signal favoriteToggled(int sourceIndex)
    
    color: "transparent"
    
    readonly property int paddingH: contentPaddingH
    readonly property int paddingV: contentPaddingV

    Image {
        id: clearLogoSquare
        asynchronous: true
        source: currentGame ? currentGame.assets.logo : ""
        sourceSize { width: 256; height: 256 }
        height: vpx(90)
        width: vpx(280)
        visible: currentCollection.games.count >0 && (!api.memory.has("main_right") || api.memory.get("main_right")=="미리보기") && isSquareScreen
        fillMode: Image.PreserveAspectFit
        readonly property double aspectRatio: 2
        anchors {
            top: parent.top
            topMargin: 0
            left: parent.left
            leftMargin: content.paddingH * 2
        } 
        horizontalAlignment: Image.AlignLeft
    }

    Image {
        id: boxFrontSquare
        asynchronous: true
        source: currentGame ? (currentGame.assets.boxFront || currentGame.assets.logo) : ""
        sourceSize { width: 256; height: 256 }
        visible: currentCollection.games.count >0 && (!api.memory.has("main_right") || api.memory.get("main_right")=="미리보기") && isSquareScreen
        width: vpx(280)
        height: vpx(300)
        fillMode: Image.PreserveAspectFit
        readonly property double aspectRatio: (implicitWidth / implicitHeight) || 0
        anchors {
            top: clearLogoSquare.bottom
            topMargin: vpx(2)
            left: parent.left
            leftMargin: content.paddingH * 2
        } 
        horizontalAlignment: Image.AlignLeft
    }

    Rectangle{
        id: boxart
        color: 'transparent'
        height: isSquareScreen ? vpx(365) : vpx(300)
        width: isSquareScreen ? vpx(500) : vpx(480)
        anchors {
            top: parent.top
            topMargin: content.paddingV*.3
            left: clearLogoSquare.right
            leftMargin: isSquareScreen ? vpx(15) : 0
            right: gameList.left
            rightMargin: content.paddingH
        }
        
        Connections {
            target: Qt.application;
            function onStateChanged() {
                if (Qt.application.state === Qt.ApplicationActive) {
                    screenshotImage.play();
                } else {
                    screenshotImage.pause();
                }
            }
        }
    
        Video {
            id: screenshotImage
            anchors.fill: parent
            source: currentGame ? (currentGame.assets.videos.length ? currentGame.assets.videos[0] : "") : ""
            fillMode: VideoOutput.PreserveAspectFit
            visible: currentCollection.games.count >0 && (!api.memory.has("main_right") || api.memory.get("main_right")=="미리보기")
            volume: (api.memory.has(CONSTANTS.MAIN_SOUND) && api.memory.get(CONSTANTS.MAIN_SOUND) == '게임소리') && detailsView.focus ? 0.7 : 0;
            loops: MediaPlayer.Infinite
            autoPlay: true
        }
        
        z:1;
    }

    Column {
        id: gameLabels
        anchors {
            top: parent.top;
            left: parent.left
            leftMargin: isSquareScreen ? (content.paddingH * 2) : (content.paddingH*3)
        }
    }

    Row {
        id: textcount
        spacing: vpx(18)
        anchors {
            top: isSquareScreen ? boxFrontSquare.bottom : boxFront.bottom
            topMargin: isSquareScreen ? vpx(8) : vpx(4)
            left: isSquareScreen ? parent.left : flickable.left
            leftMargin: isSquareScreen ? (content.paddingH * 2) : 0
            right: isSquareScreen ? gameList.left : boxart.left
            rightMargin: isSquareScreen ? content.paddingH : 0
        }
        height: isSquareScreen ? vpx(28) : vpx(20)
        visible: currentCollection.games.count >0 && (!api.memory.has("main_right") || api.memory.get("main_right")=="미리보기")

        Text {
            id: timecount
            width: parent.width*.5
            horizontalAlignment: Text.AlignLeft
            text: {
                if (!currentGame)
                    return "-";
                if (isNaN(currentGame.lastPlayed))
                    return "기록:" + "한판해요!! ";

                var now = new Date();
                var diffHours = (now.getTime() - currentGame.lastPlayed.getTime()) / 1000 / 60 / 60;
                if (diffHours < 24 && now.getDate() === currentGame.lastPlayed.getDate())
                    return "기록:" + "오늘놀았네요! " + Utils.formatPlayTime(currentGame.playTime)

                var diffDays = Math.round(diffHours / 24);
                if (diffDays <= 1)
                    return "기록:" + "어제놀았네요! " + Utils.formatPlayTime(currentGame.playTime)

                return "기록:" + diffDays + "일 이전 " + Utils.formatPlayTime(currentGame.playTime)
            }
            style: Text.Outline
            styleColor:"#000000"
            color: "#ffffff"
            opacity: 0.8
            font {
                pixelSize: isSquareScreen ? vpx(28) : vpx(20)
                family: subtitleFont.name
            }
        }
    }

    Flickable {
        id: flickable
        width: parent.width
        flickableDirection: Flickable.VerticalFlick
        anchors {
            top: textcount.bottom
            topMargin: isSquareScreen ? vpx(8) : vpx(15)
            left: parent.left
            leftMargin: content.paddingH
            right: gameList.left
            rightMargin: content.paddingH * 2
            bottom: parent.bottom
            bottomMargin: isSquareScreen ? vpx(5) : (content.paddingV*.4)
        }
        contentWidth: parent.width
        contentHeight: fullDesc.height
        clip: true
        boundsBehavior: Flickable.DragAndOvershootBounds

        Text {
            id: fullDesc
            color: "#ffffff"
            text: currentGame ? (Utils.getPlatformName(currentCollection.shortName) + ' / ' + currentGame.title + '\n' + currentGame.description) : ""
            width: flickable.width
            opacity: 0.8
            wrapMode: Text.WrapAnywhere
            visible: currentCollection.games.count >0 && (!api.memory.has("main_right") || api.memory.get("main_right")=="미리보기")
            horizontalAlignment: Text.AlignJustify
            style: Text.Outline
            styleColor:"#000000"
            font {
                pixelSize: isSquareScreen ? (vpx(32)*CONFIGS.getMainTextsize(api)) : (vpx(24)*CONFIGS.getMainTextsize(api))
                family: subtitleFont.name
            }
        }
    }

    Image {
        id: boxFront
        asynchronous: true
        source: currentGame ? (currentGame.assets.boxFront || currentGame.assets.logo) : ""
        sourceSize { width: 256; height: 256 }
        visible: currentCollection.games.count >0 && (!api.memory.has("main_right") || api.memory.get("main_right")=="미리보기") && !isSquareScreen
        width: vpx(220)
        height: vpx(230)
        fillMode: Image.PreserveAspectFit
        readonly property double aspectRatio: (implicitWidth / implicitHeight) || 0
        anchors {
            top: clearLogo.bottom
            topMargin: vpx(5)
            right: boxart.left
            left: flickable.left
        } 
        horizontalAlignment: Image.AlignHCenter
    }

    Image {
        id: clearLogo
        asynchronous: true
        source: currentGame ? currentGame.assets.logo : ""
        sourceSize { width: 256; height: 256 }
        height: vpx(70)
        width: vpx(220)
        visible: currentCollection.games.count >0 && (!api.memory.has("main_right") || api.memory.get("main_right")=="미리보기") && !isSquareScreen
        fillMode: Image.PreserveAspectFit
        readonly property double aspectRatio: 2
        anchors {
            top: parent.top
            topMargin: vpx(2)
            right: boxart.left
            left: flickable.left
        } 
        horizontalAlignment: Image.AlignHCenter
    }

    ListView {
        id: gameList
        width: parent.width * gameListWidthRatio
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        focus: true

        model: filteredGames
        delegate: Rectangle {
            readonly property bool selected: ListView.isCurrentItem
            readonly property color clrDark: "#202151"
            readonly property color clrLight: "#06fbf2"
            width: ListView.view.width
            height: gameTitle.height
            color:"transparent"
            
            MouseArea {
                anchors.fill: parent;

                onClicked: {
                    gameList.forceActiveFocus()
                    if (currentGameIndex === index && gameList.focus) {
                        gameLaunched();
                    } else {
                        currentGameIndex = index
                    }
                }

                onPressAndHold: {
                    gameList.forceActiveFocus()
                    if (currentGameIndex === index) {
                        var sourceIndex = filteredGames.mapToSource(currentGameIndex);
                        favoriteToggled(sourceIndex);
                    } else {
                        currentGameIndex = index
                    }
                }
            }
                        
            Text {
                id: gameTitle
                text: modelData.title
                color: parent.selected && gameList.focus ? parent.clrLight : "#ffffff"
                font.pixelSize: isSquareScreen ? (vpx(32)*CONFIGS.getMainTextsize(api)) : (vpx(24)*CONFIGS.getMainTextsize(api))
                font.capitalization: Font.AllUppercase
                font.family: subtitleFont.name
                font.underline: selected && gameList.focus ? true : false
                style: Text.Outline
                styleColor:"#000000"
                opacity: 0.8
                lineHeight: isSquareScreen ? 1.1 : 1.2
                verticalAlignment: Text.AlignVCenter
                width: parent.width
                elide: Text.ElideRight
                leftPadding: isSquareScreen ? vpx(10) : vpx(30)
                rightPadding: vpx(10)
                
                Text {
                    visible: favorite && collectionsView.currentCollectionIndex != 2
                    text: glyphs.favorite;
                    verticalAlignment: Text.AlignVCenter;
                    style: Text.Outline
                    styleColor:"#000000"
                    color: "white"
                    height: parent.height;
                    font {
                        family: glyphs.name;
                        pixelSize: parent.height * .5;
                    }
                    anchors {
                        verticalCenter: parent.verticalCenter;
                        left: gameTitle.left;
                        leftMargin: vpx(5);
                    }
                    opacity: .8
                }
            }
        }

        highlightRangeMode: ListView.ApplyRange
        highlightMoveDuration: 0
        preferredHighlightBegin: height * 0.5 - vpx(15)
        preferredHighlightEnd: height * 0.5 + vpx(15)

        onCurrentIndexChanged: {
            if (visible) {
                if (currentIndex >= 0) {
                    sounds.nav()
                }
            }
        }
    }
    
    function scrollDescription(delta) {
        if(flickable.contentHeight > flickable.height){
            flickable.contentY = flickable.contentY + delta;
            if(flickable.contentY < -flickable.topMargin) {
                flickable.contentY = -flickable.topMargin
            }
            if(flickable.contentY > flickable.contentHeight-flickable.height+flickable.bottomMargin){
                flickable.contentY = flickable.contentHeight-flickable.height+flickable.bottomMargin
            }
        }
    }
    
    function resetScroll() {
        flickable.contentY = -flickable.topMargin;
    }
}
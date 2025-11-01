import QtQuick 2.8
import "utils.js" as Utils
import QtMultimedia 5.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import "configs.js" as CONFIGS
import "constants.js" as CONSTANTS

FocusScope {
    id: root

    property var currentCollection
    property var tpIndex
    property var colIdx: collectionsView.currentCollectionIndex+1
    property var colCt: api.collections.count+3
    property alias currentGameIndex: gameList.currentIndex
    readonly property var currentGame: {
        if (filteredGames.count === 0) return null;
        var sourceIndex = filteredGames.mapToSource(currentGameIndex);
        return currentCollection.games.get(sourceIndex);
    }
    
    // 플랫폼 감지
    readonly property bool isAndroid: Qt.platform.os === "android" || api.device.type === "handheld"
    
    // 화면 비율 감지
    readonly property real aspectRatio: parent.width / parent.height
    readonly property bool isSquareScreen: aspectRatio >= 0.9 && aspectRatio <= 1.1  // 1:1 비율 (0.9~1.1)
    readonly property bool isWideScreen: aspectRatio > 1.5  // 16:9 이상
    
    // 반응형 레이아웃 값 (큐브용 원본 참고)
    readonly property real gameListWidthRatio: isSquareScreen ? 0.4 : 0.3
    readonly property int contentPaddingH: isSquareScreen ? vpx(10) : vpx(15)
    readonly property int contentPaddingV: isSquareScreen ? vpx(15) : vpx(20)
    readonly property int headerHeight: isSquareScreen ? vpx(85) : vpx(85)
    readonly property int footerHeight: isSquareScreen ? vpx(35) : vpx(25)
    
    width: parent.width
    height: parent.height
    enabled: focus
    visible: y < parent.height
    
    signal cancel
    signal nextCollection
    signal prevCollection
    signal launchGame
    
    function zeroPad(number, width) {
        var str = number.toString();
        var strlen = str.length;
        if (strlen >= width)
            return str;
        return new Array(width - strlen + 1).join('0') + number;
    }

    onCurrentGameChanged: {
        flickable.contentY = -flickable.topMargin;
    }

    // 검색 필터 모델 추가
    SortFilterProxyModel {
        id: filteredGames
        sourceModel: currentCollection.games  // 현재 컬렉션의 게임만 필터링
        filters: [
            RegExpFilter {
                roleName: "title"
                pattern: searchBox.text
                caseSensitivity: Qt.CaseInsensitive
                enabled: searchBox.text.length > 0
            }
        ]
    }

    Keys.onLeftPressed: {
        if(searchBox.activeFocus) {
            return;
        }
        if(flickable.contentHeight > flickable.height){
            flickable.contentY = flickable.contentY-vpx(30);
            if(flickable.contentY < -flickable.topMargin) {
                flickable.contentY = -flickable.topMargin
            }
        }
    }
    
    Keys.onRightPressed:{
        if(searchBox.activeFocus) {
            return;
        }
        if(flickable.contentHeight > flickable.height){
            flickable.contentY = flickable.contentY+vpx(30);
            if(flickable.contentY > flickable.contentHeight-flickable.height+flickable.bottomMargin){
                flickable.contentY = flickable.contentHeight-flickable.height+flickable.bottomMargin
            }
        }
    }
    
    Keys.onPressed: {
        // 검색창에 포커스가 있을 때
        if(searchBox.activeFocus) {
            if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                event.accepted = true;
                searchBox.text = "";
                gameList.forceActiveFocus();
                sounds.back();
                return;
            }
            if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                event.accepted = true;
                gameList.forceActiveFocus();
                return;
            }
            return;
        }

        // F3 키로 검색창 활성화
        if (event.key === Qt.Key_F3 && !event.isAutoRepeat) {
            event.accepted = true;
            searchBox.forceActiveFocus();
            searchBox.selectAll();
            sounds.nav();
            return;
        }
        
        // S 키로도 검색창 활성화
        if (event.key === Qt.Key_S && !event.isAutoRepeat && gameList.focus) {
            event.accepted = true;
            searchBox.forceActiveFocus();
            sounds.nav();
            return;
        }

        if (api.keys.isAccept(event)&& !event.isAutoRepeat) {
            event.accepted = true;
            launchGame();
            sounds.launchSound()
            return;
        }
        if (api.keys.isCancel(event)&& !event.isAutoRepeat) {
            event.accepted = true;
            if (searchBox.text.length > 0) {
                searchBox.text = "";
                return;
            }
            cancel();
            sounds.back()
            return;
        }
        if (api.keys.isNextPage(event)&& !event.isAutoRepeat) {
            event.accepted = true;
            nextCollection();
            sounds.nav();
            return;
        }
        if (api.keys.isPrevPage(event)&& !event.isAutoRepeat) {
            event.accepted = true;
            prevCollection();
            sounds.nav();
            return;
        }
        
        if (api.keys.isFilters(event) && !event.isAutoRepeat) {
            if(itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus || itemBacksound.activeFocus ){return gameList.focus = true;}
            
            var sourceIndex = filteredGames.mapToSource(currentGameIndex);
            if(collectionsView.currentCollectionIndex == 1){
                api.allGames.get(allLastPlayed.mapToSource(sourceIndex)).favorite=!api.allGames.get(allLastPlayed.mapToSource(sourceIndex)).favorite;
                return;
            }
            if(collectionsView.currentCollectionIndex == 2){
                api.allGames.get(allFavorites.mapToSource(sourceIndex)).favorite=!api.allGames.get(allFavorites.mapToSource(sourceIndex)).favorite;
                return;
            }
            currentCollection.games.get(sourceIndex).favorite = !currentCollection.games.get(sourceIndex).favorite;
        }
        
        if (api.keys.isDetails(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if(itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus || itemBacksound.activeFocus ){return gameList.forceActiveFocus();}
            else {return itemColour.forceActiveFocus();}
            return;
        }
        
        if (api.keys.isPageUp(event) || api.keys.isPageDown(event)) {
            event.accepted = true;
            var games_to_skip = Math.round(gameList.height / gameList.currentItem.height );
            if (api.keys.isPageUp(event))            
                currentGameIndex = Math.max(currentGameIndex - games_to_skip, 0);
            else
                currentGameIndex = Math.min(currentGameIndex + games_to_skip, filteredGames.count - 1);
            return;
        }
    }
    
    onCurrentCollectionChanged: {
        searchBox.text = "";
        if(api.memory.get(CONSTANTS.MAIN_COLOUR) == "무작위"){return bgPlaylistSJ.next();}
    }
    
    Connections {
        target: Qt.application;
        function onStateChanged() {
            if (Qt.application.state === Qt.ApplicationActive) {
                player.play();
            } else {
                player.pause();
            }
        }
    }

    // 동영상 Playlist - constants.js의 AVAILABLE_COLOURS 사용
    Playlist {
        id: bgPlaylistSJ
        playbackMode: Playlist.Loop
        
        Component.onCompleted: {
            // '무작위' 제외하고 모든 테마 추가
            for (var i = 0; i < CONSTANTS.AVAILABLE_COLOURS.length; i++) {
                if (CONSTANTS.AVAILABLE_COLOURS[i] !== '무작위') {
                    addItem(Qt.resolvedUrl('../Resource/Background_video/' + CONSTANTS.AVAILABLE_COLOURS[i] + '/영상.mp4'));
                }
            }
        }
    }
    
    MediaPlayer{
        id:player
        playlist: 
        if(api.memory.get(CONSTANTS.MAIN_COLOUR) == "무작위"){return bgPlaylistSJ;}
        else {return '';}
        source: if(api.memory.get(CONSTANTS.MAIN_COLOUR) != "무작위"){return '../Resource/Background_video/'+api.memory.get(CONSTANTS.MAIN_COLOUR)+'/영상.mp4'} 
        loops: MediaPlayer.Infinite
    }
    
    VideoOutput {
        id: videoPlayer
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        source: player   
        fillMode: VideoOutput.PreserveAspectCrop
        flushMode:VideoOutput.FirstFrame
    }

    LinearGradient {
        width: parent.width * 0.3
        height: parent.height
        anchors.left: parent.left
        opacity: 0.6
        start: Qt.point(0, 0)
        end: Qt.point(width, 0)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
    
    Timer {
        id: playerTimer;
        interval: 300
        running: true
        repeat: false;
        onTriggered: {
            bgPlaylistSJ.shuffle();
            player.play();
        }
    }

    Rectangle {
        id: header
        
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: vpx(85)
        color: "#e5e5e5"
        
        readonly property int paddingH: vpx(0)
        readonly property int paddingV: vpx(0)

        Image {
            id: background
            anchors.fill: parent
            asynchronous: true
            source: '../Resource/Background_image1/'+CONFIGS.getMainTop(api)+'.png'
            opacity: 1
        }

        Image {
            height: parent.height - header.paddingV*1.1
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left; leftMargin: header.paddingH*.4
                right: searchBoxContainer.left; rightMargin: vpx(20)
            }
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignLeft
            source: currentCollection.shortName ? "../Resource/Logo1/%1.png".arg(Utils.getPlatformImageName(currentCollection.shortName)) : ""
            asynchronous: true
            mipmap: true
        }

        // 검색 박스 컨테이너
        Rectangle {
            id: searchBoxContainer
            width: vpx(250)
            height: vpx(40)
            radius: vpx(20)
            color: "#33000000"
            border.color: searchBox.activeFocus ? "#06fbf2" : "#66ffffff"
            border.width: 2
            visible: true
            opacity: 0.85
            z: 100
            
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: vpx(30)
            }

            Row {
                anchors.fill: parent
                anchors.margins: vpx(8)
                spacing: vpx(8)

                Text {
                    text: "🔍"
                    font.pixelSize: vpx(20)
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextInput {
                    id: searchBox
                    width: parent.width - vpx(60)
                    height: parent.height
                    font.pixelSize: vpx(18)
                    font.family: subtitleFont.name
                    color: "#ffffff"
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    selectionColor: "#06fbf2"
                    selectedTextColor: "#000000"
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                    
                    property string lastText: ""
                    property bool ignoreChange: false
                    
                    Text {
                        text: root.isAndroid ? "터치로 검색" : "F3 또는 S 키로 검색"
                        font: parent.font
                        color: "#88ffffff"
                        visible: parent.text.length === 0 && !parent.activeFocus
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Timer {
                        id: changeDebounce
                        interval: 100
                        onTriggered: {
                            searchBox.ignoreChange = false;
                        }
                    }

                    onActiveFocusChanged: {
                        if (activeFocus) {
                            Qt.inputMethod.show();
                            lastText = text;
                        } else {
                            Qt.inputMethod.hide();
                            ignoreChange = false;
                        }
                    }

                    onTextChanged: {
                        if (ignoreChange) {
                            return;
                        }
                        
                        // 같은 텍스트가 다시 들어오면 무시
                        if (text === lastText + lastText.slice(-10)) {
                            // 이중 입력 감지 - 마지막 부분이 반복됨
                            text = lastText;
                            ignoreChange = true;
                            changeDebounce.restart();
                            return;
                        }
                        
                        lastText = text;
                        
                        if (text.length > 0) {
                            currentGameIndex = 0;
                        }
                    }

                    Keys.onReturnPressed: {
                        event.accepted = true;
                        ignoreChange = true;
                        changeDebounce.restart();
                        Qt.inputMethod.commit();
                        gameList.forceActiveFocus();
                        Qt.inputMethod.hide();
                    }
                    
                    Keys.onEnterPressed: {
                        event.accepted = true;
                        ignoreChange = true;
                        changeDebounce.restart();
                        Qt.inputMethod.commit();
                        gameList.forceActiveFocus();
                        Qt.inputMethod.hide();
                    }

                    Keys.onUpPressed: {
                        event.accepted = true;
                        gameList.forceActiveFocus();
                        Qt.inputMethod.hide();
                    }
                    Keys.onDownPressed: {
                        event.accepted = true;
                        gameList.forceActiveFocus();
                        Qt.inputMethod.hide();
                    }
                }

                Text {
                    text: "✕"
                    font.pixelSize: vpx(18)
                    color: "#ffffff"
                    visible: searchBox.text.length > 0
                    anchors.verticalCenter: parent.verticalCenter
                    
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: vpx(-5)
                        onClicked: {
                            searchBox.text = "";
                            gameList.forceActiveFocus();
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                z: 10
                onClicked: {
                    searchBox.forceActiveFocus();
                    searchBox.selectAll();
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked:{
                collectionsView.focus = true;
                api.memory.set('pageIdx',1);
            }
        }
    }

    DropShadow {
        anchors.fill: content
        source: content
        horizontalOffset: 2
        verticalOffset: 2
        radius: 8
        samples: 16
        color: "black"
    }

    Rectangle {
        id: content
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        color: "transparent"

        readonly property int paddingH: contentPaddingH
        readonly property int paddingV: contentPaddingV

        Rectangle{
            id: boxart
            color: 'transparent'
            height: isSquareScreen ? vpx(180) : vpx(300)  // 정사각형 화면에서 더 작게
            width: isSquareScreen ? vpx(240) : vpx(480)
            visible: isSquareScreen
            anchors {
                top: parent.top; topMargin: content.paddingV*.3
                right: parent.right; rightMargin: content.paddingH * (isSquareScreen ? 1 : 3)
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
                left: gameList.right; leftMargin: content.paddingH*3
            }
        }

        Row {
            id: textcount
            spacing: vpx(18)
            anchors {
                top: boxFront.bottom;
                right: boxart.left;
                left: flickable.left;
            }
            height: vpx(20)
            topPadding: vpx(4)
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
                        return "기록:" + "오늘놀았네요!";

                    var diffDays = Math.round(diffHours / 24);
                    if (diffDays <= 1)
                        return "기록:" + "어제놀았네요!";

                    return "기록:" + diffDays + "일 이전"
                }
                style: Text.Outline;styleColor:"#000000"
                color: "#ffffff"
                opacity: 0.8
                font {
                    pixelSize: vpx(20)
                    family: subtitleFont.name
                }
            }
        }

        Flickable {
            id: flickable
            width: parent.width
            flickableDirection: Flickable.VerticalFlick
            anchors {
                top: textcount.bottom; topMargin: isSquareScreen ? vpx(8) : vpx(15)
                left: gameList.right; leftMargin: content.paddingH * (isSquareScreen ? 0.8 : 2.45)
                right: parent.right; rightMargin: isSquareScreen ? content.paddingH : vpx(40)
                bottom: parent.bottom; bottomMargin: content.paddingV*.4
            }
            contentWidth: parent.width
            contentHeight: fullDesc.height
            clip: true
            boundsBehavior: Flickable.DragAndOvershootBounds

            Text {
                id: fullDesc
                color: "#ffffff"
                text: currentGame ? (currentCollection.shortName+'-'+currentGame.title+'\n'+currentGame.description) : ""
                width: flickable.width
                opacity: 0.8
                wrapMode: Text.WrapAnywhere
                visible: currentCollection.games.count >0 && (!api.memory.has("main_right") || api.memory.get("main_right")=="미리보기")
                horizontalAlignment: Text.AlignJustify
                style: Text.Outline;styleColor:"#000000"
                font.capitalization: Font.AllUppercase
                font {
                    pixelSize: isSquareScreen ? vpx(20)*CONFIGS.getMainTextsize(api) : vpx(24)*CONFIGS.getMainTextsize(api)
                    family: subtitleFont.name
                }
            }
        }

        Image {
            id: boxFront
            asynchronous: true
            source: currentGame ? (currentGame.assets.boxFront || currentGame.assets.logo) : ""
            sourceSize { width: 256; height: 256 }
            visible: currentCollection.games.count >0 && (!api.memory.has("main_right") || api.memory.get("main_right")=="미리보기")
            width: isSquareScreen ? vpx(180) : vpx(220)
            height: isSquareScreen ? vpx(200) : vpx(230)
            fillMode: Image.PreserveAspectFit
            readonly property double aspectRatio: (implicitWidth / implicitHeight) || 0
            anchors {
                top: clearLogo.bottom; topMargin: vpx(2)
                right: isSquareScreen ? parent.right : boxart.left
                rightMargin: isSquareScreen ? content.paddingH : 0
                left: flickable.left;
            } 
            horizontalAlignment: Image.AlignHCenter
        }

        Image {
            id: clearLogo
            asynchronous: true
            source: currentGame ? currentGame.assets.logo : ""
            sourceSize { width: 256; height: 256 }
            height: isSquareScreen ? vpx(60) : vpx(70)
            width: isSquareScreen ? vpx(180) : vpx(220)
            visible: currentCollection.games.count >0 && (!api.memory.has("main_right") || api.memory.get("main_right")=="미리보기")
            fillMode: Image.PreserveAspectFit
            readonly property double aspectRatio: 2
            anchors {
                top: parent.top; topMargin: vpx(2)
                right: isSquareScreen ? parent.right : boxart.left
                rightMargin: isSquareScreen ? content.paddingH : 0
                left: flickable.left;
            } 
            horizontalAlignment: Image.AlignHCenter
        }

        ListView {
            id: gameList
            width: parent.width * gameListWidthRatio  // 반응형 너비
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: gameList.right
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
                        if (currentGameIndex === index && gameList.focus) {
                            launchGame();
                        } else {
                            currentGameIndex = index
                        }
                        
                        if(itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus  || itemBacksound.activeFocus ){
                            gameList.focus = forceActiveFocus();
                        }
                    }

                    onPressAndHold: {
                        if (currentGameIndex === index) {
                            var sourceIndex = filteredGames.mapToSource(currentGameIndex);
                            if(collectionsView.currentCollectionIndex == 1){
                                api.allGames.get(allLastPlayed.mapToSource(sourceIndex)).favorite=!api.allGames.get(allLastPlayed.mapToSource(sourceIndex)).favorite;
                                return;
                            }
                            if(collectionsView.currentCollectionIndex == 2){
                                api.allGames.get(allFavorites.mapToSource(sourceIndex)).favorite=!api.allGames.get(allFavorites.mapToSource(sourceIndex)).favorite;
                                return;
                            }
                            currentCollection.games.get(sourceIndex).favorite = !currentCollection.games.get(sourceIndex).favorite;
                        } else {
                            currentGameIndex = index
                        }
                    }
                }
                            
                Text {
                    id: gameTitle
                    text: modelData.title
                    color: parent.selected && gameList.focus ? parent.clrLight : "#ffffff"
                    font.pixelSize: isSquareScreen ? vpx(20)*CONFIGS.getMainTextsize(api) : vpx(24)*CONFIGS.getMainTextsize(api)
                    font.capitalization: Font.AllUppercase
                    font.family: subtitleFont.name
                    font.underline: selected && gameList.focus ? true : false
                    style: Text.Outline;styleColor:"#000000"
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
                        style: Text.Outline;styleColor:"#000000"
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
    }

    Component.onCompleted: {
        gameList.positionViewAtIndex(currentGameIndex, ListView.Center);
    }
    
    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: vpx(25)
        color: 'transparent'
        opacity: 1

        Image {
            id: backgroundmain3
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            asynchronous: true
            source: '../Resource/Background_image1/'+CONFIGS.getMainTop(api)+'F.png'
            opacity: 1
            fillMode: Image.PreserveAspectStretch
        }    

        Text {
            id: footerbar
            text: {
                if (searchBox.activeFocus) {
                    return "ESC 검색취소, 엔터 확인";
                }
                if (root.isAndroid) {
                    return "↑↓게임선택, ←→내용스크롤, L1/R1에뮬선택, L2/R2빠른이동, Y 즐겨찾기, X 설정, 🔍터치 검색";
                }
                return "↑↓게임선택, ←→내용스크롤, L1/R1에뮬선택, L2/R2빠른이동, Y 즐겨찾기, X 설정, F3/S 검색";
            }
            font.capitalization: Font.AllUppercase
            font.family: subtitleFont.name
            font.pixelSize: vpx(20)
            font.weight: Font.Light
            color: api.memory.has("main_top") && (api.memory.get("main_top") == "화이트테마" || api.memory.get("main_top") == "닌텐도테마")  ? "#555555" : "#ffffff"
            style: if(api.memory.has("main_top") && (api.memory.get("main_top") == "화이트테마" || api.memory.get("main_top") == "닌텐도테마")){return Text.Normal}
            else {return Text.Outline;styleColor:"#000000"}
            opacity: if(api.memory.has("main_top") && (api.memory.get("main_top") == "화이트테마" || api.memory.get("main_top") == "닌텐도테마")){return 1}
            else {return 0.5}
            visible: itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus  || itemBacksound.activeFocus ? false : true
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: vpx(40)
            }
            
            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    if(gameList.focus){itemColour.focus = true;}
                    else if(itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus ){return gameList.focus = true;}
                }
            }
        }

        ComboBox {
            id: itemColour
            width: parent.width*.08
            fontSize: vpx(20)
            label: CONFIGS.getMainColour(api)
            visible: itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus || itemBacksound.activeFocus ? true : false
            model: CONSTANTS.AVAILABLE_COLOURS
            value: api.memory.get(CONSTANTS.MAIN_COLOUR) || ''
            onValueChange: updateColour()
            KeyNavigation.right: itemTop
            anchors {
                right: itemTop.left
                rightMargin:itemColour.width*.38
            }
        }
        
        ComboBox {
            id: itemTop
            width: parent.width*.08
            fontSize: vpx(20)
            label: CONFIGS.getMainTop(api)
            model: CONSTANTS.AVAILABLE_TOPS
            value: api.memory.get(CONSTANTS.MAIN_TOP) || ''
            onValueChange: updateTop()
            visible: itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus || itemBacksound.activeFocus ? true : false
            KeyNavigation.right: itemSound
            anchors {
                right: itemSound.left
                rightMargin:itemColour.width*.38
            }
        }
        
        ComboBox {
            id: itemSound
            width: parent.width*.08
            fontSize: vpx(20)
            label: CONFIGS.getMainSound(api)
            model: CONSTANTS.AVAILABLE_SOUNDS
            value: api.memory.get(CONSTANTS.MAIN_SOUND) || ''
            onValueChange: updateSound()
            visible: itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus || itemBacksound.activeFocus ? true : false
            anchors {
                right: itemBacksound.left
                rightMargin:itemColour.width*.38
            }
            KeyNavigation.right: itemBacksound
        }

        ComboBox {
            id: itemBacksound
            width: parent.width*.08
            fontSize: vpx(20)
            label: CONFIGS.getMainBacksound(api)
            model: CONSTANTS.AVAILABLE_BACKSOUNDS
            value: api.memory.get(CONSTANTS.MAIN_BACKSOUND) || ''
            onValueChange: updateBacksound()
            visible: itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus || itemBacksound.activeFocus ? true : false
            anchors {
                right: itemTextsize.left
                rightMargin:itemColour.width*.38
            }
            KeyNavigation.right: itemTextsize
        }
        
        ComboBox {
            id: itemTextsize
            width: parent.width*.08
            fontSize: vpx(20)
            label: CONFIGS.getMainTextsize(api)
            model: CONSTANTS.AVAILABLE_TEXTSIZES
            value: api.memory.get(CONSTANTS.MAIN_TEXTSIZE) || ''
            onValueChange: updateTextsize()
            visible: itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus || itemBacksound.activeFocus ? true : false
            KeyNavigation.right: itemRight
            anchors {
                right: itemRight.left
                rightMargin:itemColour.width*.38
            }
        }
        
        ComboBox {
            id: itemRight
            width: parent.width*.08
            fontSize: vpx(20)
            label: CONFIGS.getMainRight(api)
            model: CONSTANTS.AVAILABLE_RIGHTS
            value: api.memory.get(CONSTANTS.MAIN_RIGHT) || ''
            onValueChange: updateRight()
            visible: itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus || itemBacksound.activeFocus ? true : false
            KeyNavigation.right: itemColour
            anchors {
                right: parent.right
                rightMargin: vpx(60)
            }
        }

        Text {
            id: gameAmount
            text: searchBox.text.length > 0 ? 
                "검색결과: " + filteredGames.count + "개 (전체: " + currentCollection.games.count + ")    페이지: " + zeroPad(colIdx,colCt.toString().length) + "/" + colCt :
                "게임수: " + zeroPad((currentGameIndex + 1), (searchBox.text.length > 0 ? filteredGames.count : currentCollection.games.count).toString().length) + "/" + (searchBox.text.length > 0 ? filteredGames.count : currentCollection.games.count) + "    " + "페이지: " + zeroPad(colIdx,colCt.toString().length) + "/" + colCt
            wrapMode: Text.WordWrap
            font.capitalization: Font.AllUppercase
            font.family: subtitleFont.name
            font.pixelSize: vpx(20)
            font.weight: Font.Light
            horizontalAlignment: Text.AlignRight
            color: api.memory.has("main_top") && (api.memory.get("main_top") == "화이트테마" || api.memory.get("main_top") == "닌텐도테마")  ? "#555555" : "#ffffff"
            style: if(api.memory.has("main_top") && (api.memory.get("main_top") == "화이트테마" || api.memory.get("main_top") == "닌텐도테마")){return Text.Normal}
            else {return Text.Outline;styleColor:"#000000"}
            opacity: if(api.memory.has("main_top") && (api.memory.get("main_top") == "화이트테마" || api.memory.get("main_top") == "닌텐도테마")){return 1}
            else {return 0.5}
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left;
                leftMargin: vpx(30)
            }
            
            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    if(gameList.focus){itemColour.forceActiveFocus();}
                    else if(itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus || itemBacksound.activeFocus ){return gameList.forceActiveFocus();}
                }
            }
        }
    }
    
    function updateColour() {
        api.memory.set(CONSTANTS.MAIN_COLOUR, itemColour.value);
        player.play();
    }
    function updateTop() {
        api.memory.set(CONSTANTS.MAIN_TOP, itemTop.value);
    }
    function updateTextsize() {
        api.memory.set(CONSTANTS.MAIN_TEXTSIZE, itemTextsize.value)
    }
    function updateSound() {
        api.memory.set(CONSTANTS.MAIN_SOUND, itemSound.value)
    }
    function updateRight() {
        api.memory.set(CONSTANTS.MAIN_RIGHT, itemRight.value)
    }
    function updateBacksound() {
        api.memory.set(CONSTANTS.MAIN_BACKSOUND, itemBacksound.value)
    }
}
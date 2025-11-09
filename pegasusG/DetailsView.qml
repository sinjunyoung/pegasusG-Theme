import QtQuick 2.8
import "utils.js" as Utils
import QtMultimedia 5.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import "configs.js" as CONFIGS
import "constants.js" as CONSTANTS

FocusScope {
    id: root

    Sounds {
        id: sounds
    }

    property var currentCollection
    property var tpIndex
    property var colIdx: collectionsView.currentCollectionIndex+1
    property var colCt: api.collections.count+3
    property alias currentGameIndex: gameContent.currentGameIndex
    readonly property var currentGame: {
        if (filteredGames.count === 0) return null;
        var sourceIndex = filteredGames.mapToSource(currentGameIndex);
        return currentCollection.games.get(sourceIndex);
    }
    
    readonly property bool isAndroid: Qt.platform.os === "android" || api.device.type === "handheld"
    readonly property real aspectRatio: parent.width / parent.height
    readonly property bool isSquareScreen: aspectRatio >= 0.9 && aspectRatio <= 1.1
    readonly property bool isWideScreen: aspectRatio > 1.5
    
    readonly property real gameListWidthRatio: isSquareScreen ? 0.4 : 0.3
    readonly property int contentPaddingH: isSquareScreen ? vpx(15) : vpx(15)
    readonly property int contentPaddingV: isSquareScreen ? vpx(20) : vpx(20)
    readonly property int headerHeight: isSquareScreen ? vpx(100) : vpx(65)
    readonly property int footerHeight: isSquareScreen ? vpx(50) : vpx(25)
    
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
        gameContent.resetScroll();
    }

    SortFilterProxyModel {
        id: filteredGames
        sourceModel: currentCollection.games
        filters: [
            RegExpFilter {
                roleName: "title"
                pattern: header.searchText
                caseSensitivity: Qt.CaseInsensitive
                enabled: header.searchText.length > 0
            }
        ]
    }

    Keys.onLeftPressed: {
        if(header.searchBoxFocused) {
            return;
        }
        gameContent.scrollDescription(-vpx(30));
    }
    
    Keys.onRightPressed:{
        if(header.searchBoxFocused) {
            return;
        }
        gameContent.scrollDescription(vpx(30));
    }
    
    Keys.onPressed: {
        if(header.searchBoxFocused) {
            if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                event.accepted = true;
                header.clearSearch();
                gameContent.gameList.forceActiveFocus();
                sounds.back();
                return;
            }
            if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                event.accepted = true;
                gameContent.gameList.forceActiveFocus();
                return;
            }
            return;
        }

        if (event.key === Qt.Key_F3 && !event.isAutoRepeat) {
            event.accepted = true;
            header.focusSearchBox();
            sounds.nav();
            return;
        }
        
        if (event.key === Qt.Key_S && !event.isAutoRepeat && gameContent.gameList.focus) {
            event.accepted = true;
            header.focusSearchBox();
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
            if (header.searchText.length > 0) {
                header.clearSearch();
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
            if(footer.settingsVisible){return gameContent.gameList.focus = true;}
            
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
            if(footer.settingsVisible){
                return gameContent.gameList.forceActiveFocus();
            } else {
                return footer.focusFirstSetting();
            }
            return;
        }
        
        if (api.keys.isPageUp(event) || api.keys.isPageDown(event)) {
            event.accepted = true;
            var games_to_skip = Math.round(gameContent.gameList.height / gameContent.gameList.currentItem.height );
            if (api.keys.isPageUp(event))            
                currentGameIndex = Math.max(currentGameIndex - games_to_skip, 0);
            else
                currentGameIndex = Math.min(currentGameIndex + games_to_skip, filteredGames.count - 1);
            return;
        }
    }
    
    onCurrentCollectionChanged: {
        header.clearSearch();
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

    Playlist {
        id: bgPlaylistSJ
        playbackMode: Playlist.Loop
        
        Component.onCompleted: {
            for (var i = 0; i < CONSTANTS.AVAILABLE_COLOURS.length; i++) {
                if (CONSTANTS.AVAILABLE_COLOURS[i] !== '무작위') {
                    addItem(Qt.resolvedUrl('../Resource/Videos/' + CONSTANTS.AVAILABLE_COLOURS[i] + '.mp4'));
                }
            }
        }
    }
    
    MediaPlayer {
        id: player
        loops: MediaPlayer.Infinite
        autoPlay: true

        Component.onCompleted: {
            var colour = api.memory.get(CONSTANTS.MAIN_COLOUR);
            if (colour === "무작위") {
                player.source = ""
                player.playlist = bgPlaylistSJ
            } else {
                player.playlist = null
                player.source = Qt.resolvedUrl('../Resource/Videos/' + colour + '.mp4')
            }
        }
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

    GameHeader {
        id: header
        currentCollection: root.currentCollection
        isSquareScreen: root.isSquareScreen
        isAndroid: root.isAndroid
        headerHeight: root.headerHeight
        
        onSearchChanged: {
            if (text.length > 0) {
                currentGameIndex = 0;
            }
        }
        
        onRequestGameListFocus: gameContent.focus = true
        
        onRequestCollectionsViewFocus: {
            header.clearFocus();
            collectionsView.focus = true;
            api.memory.set('pageIdx',1);
        }
    }

    DropShadow {
        anchors.fill: gameContent
        source: gameContent
        horizontalOffset: 2
        verticalOffset: 2
        radius: 8
        samples: 16
        color: "black"
    }

    GameContent {
        id: gameContent
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        
        currentGame: root.currentGame
        currentCollection: root.currentCollection
        filteredGames: filteredGames
        currentGameIndex: root.currentGameIndex
        isSquareScreen: root.isSquareScreen
        contentPaddingH: root.contentPaddingH
        contentPaddingV: root.contentPaddingV
        gameListWidthRatio: root.gameListWidthRatio
        
        onGameLaunched: root.launchGame()
        onFavoriteToggled: {
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
    }

    Component.onCompleted: {
        gameContent.currentGameIndex = currentGameIndex;
    }
    
    GameFooter {
        id: footer
        gameContent:gameContent
        isSquareScreen: root.isSquareScreen
        isAndroid: root.isAndroid
        footerHeight: root.footerHeight
        searchBoxActive: header.searchBoxFocused
        filteredGamesCount: filteredGames.count
        totalGamesCount: currentCollection.games.count
        currentGameIndex: root.currentGameIndex
        colIdx: root.colIdx
        colCt: root.colCt

       onColourChanged: updateColour(value)
       onTopChanged: updateTop(value)
       onSoundChanged: updateSound(value)
       onTextsizeChanged: updateTextsize(value)
       onRightChanged: updateRight(value)
        onRequestGameListFocus: gameContent.gameList.forceActiveFocus()
        onRequestSettingsFocus: {
            if(gameContent.gameList.focus) {
                footer.focusFirstSetting();
            } else {
                gameContent.gameList.forceActiveFocus();
            }
        }
    }

    function updateColour(colour) {
        api.memory.set(CONSTANTS.MAIN_COLOUR, colour);

        if (colour === "무작위") {
            player.source = "";
            player.playlist = bgPlaylistSJ;
            bgPlaylistSJ.shuffle();
        } else {
            player.playlist = null;
            player.source = Qt.resolvedUrl('../Resource/Videos/' + colour + '.mp4');
        }
        player.play();
    }

    function updateTop(top) {
        api.memory.set(CONSTANTS.MAIN_TOP, top);
    }

    function updateTextsize(size) {
        api.memory.set(CONSTANTS.MAIN_TEXTSIZE, size)
    }

    function updateSound(sound) {
        api.memory.set(CONSTANTS.MAIN_SOUND, sound)
    }

    function updateRight(right) {
        api.memory.set(CONSTANTS.MAIN_RIGHT, right)
    }

}
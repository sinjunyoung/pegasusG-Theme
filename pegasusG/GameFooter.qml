import QtQuick 2.8
import QtGraphicalEffects 1.12
import "configs.js" as CONFIGS
import "constants.js" as CONSTANTS

Rectangle {
    id: footer
    
    property GameContent gameContent
    property bool isSquareScreen
    property bool isAndroid
    property int footerHeight
    property bool searchBoxActive
    property int filteredGamesCount
    property int totalGamesCount
    property int currentGameIndex
    property int colIdx
    property int colCt
    property bool settingsVisible: itemColour.activeFocus || itemTop.activeFocus || itemSound.activeFocus || itemTextsize.activeFocus || itemRight.activeFocus
    
    signal requestGameListFocus()
    signal requestSettingsFocus()
    signal colourChanged(string value)
    signal topChanged(string value)
    signal soundChanged(string value)
    signal textsizeChanged(string value)
    signal rightChanged(string value)
    
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    height: footerHeight
    opacity: 1
    
    property color themeColor: CONFIGS.getThemeColor(api)
    
    property real shaderTime: 0.0 
    
    Timer {
        id: shaderTimer
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            footer.shaderTime += 0.01;
        }
    }
    
    BackgroundShader {
        anchors.fill: parent
        themeColor: footer.themeColor
        shaderTime: footer.shaderTime
        reverseGradient: true
    }

    function zeroPad(number, width) {
        var str = number.toString();
        var strlen = str.length;
        if (strlen >= width)
            return str;
        return new Array(width - strlen + 1).join('0') + number;
    }

    Text {
        id: footerbar
        text: {
            if (searchBoxActive) {
                return "ESC 검색취소, 엔터 확인";
            }
            if (isAndroid) {
                return "↑↓게임선택, ←→내용스크롤, L1/R1에뮬선택, L2/R2빠른이동, Y 즐겨찾기, X 설정, 🔍터치 검색";
            }
            return "↑↓게임선택, ←→내용스크롤, A/D 에뮬선택, 페이지업/페이지다운 빠른이동, F 즐겨찾기, I 설정, F3/S 검색";
        }
        font.capitalization: Font.AllUppercase
        font.family: subtitleFont.name
        font.pixelSize: isSquareScreen ? vpx(22) : vpx(20)
        font.weight: Font.Light
        color: "#ffffff"
        style: Text.Outline	
        styleColor: "#000000"
        opacity: 0.5
        visible: !settingsVisible
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: vpx(40)
        }
        
        MouseArea {
            anchors.fill: parent;
            onClicked: {
                requestSettingsFocus();
            }
        }
    }

    ComboBox {
        id: itemColour
        width: parent.width*.12
        focusTarget: gameContent.gameList
        fontSize: isSquareScreen ? vpx(22) : vpx(20)
        label: CONFIGS.getMainColour(api)
        visible: settingsVisible
        model: CONSTANTS.AVAILABLE_COLOURS
        value: api.memory.get(CONSTANTS.MAIN_COLOUR) || ''
        onValueChange: colourChanged(value)
        
        KeyNavigation.right: itemTop
        KeyNavigation.left: itemRight
        KeyNavigation.up: gameContent.gameList 
        KeyNavigation.down: gameContent.gameList 
        
        anchors {
            right: itemTop.left
            rightMargin: vpx(20)
            verticalCenter: parent.verticalCenter
        }
    }
    
    ComboBox {
        id: itemTop
        width: parent.width*.08
        focusTarget: gameContent.gameList
        fontSize: isSquareScreen ? vpx(22) : vpx(20)
        label: "테마"
        model: CONSTANTS.AVAILABLE_TOPS
        value: api.memory.get(CONSTANTS.MAIN_TOP) || ''
        onValueChange: topChanged(value)

        Component.onCompleted: {
            if (!api.memory.get(CONSTANTS.MAIN_TOP)) {
                api.memory.set(CONSTANTS.MAIN_TOP, CONSTANTS.DEFAULT_MAIN_TOP)
            }
            itemTop.value = api.memory.get(CONSTANTS.MAIN_TOP)
        }

        visible: settingsVisible
        
        KeyNavigation.right: itemSound
        KeyNavigation.left: itemColour
        KeyNavigation.up: gameContent.gameList
        KeyNavigation.down: gameContent.gameList
        
        anchors {
            right: itemSound.left
            rightMargin: vpx(40)
            verticalCenter: parent.verticalCenter
        }
    }
    
    ComboBox {
        id: itemSound
        width: parent.width*.08
        focusTarget: gameContent.gameList
        fontSize: isSquareScreen ? vpx(22) : vpx(20)
        label: CONFIGS.getMainSound(api)
        model: CONSTANTS.AVAILABLE_SOUNDS
        value: api.memory.get(CONSTANTS.MAIN_SOUND) || ''
        onValueChange: soundChanged(value)
        visible: settingsVisible
        
        KeyNavigation.right: itemTextsize
        KeyNavigation.left: itemTop
        KeyNavigation.up: gameContent.gameList
        KeyNavigation.down: gameContent.gameList
        
        anchors {
            right: itemTextsize.left
            rightMargin: vpx(40)
            verticalCenter: parent.verticalCenter
        }
    }

    ComboBox {
        id: itemTextsize
        width: parent.width*.08
        focusTarget: gameContent.gameList
        fontSize: isSquareScreen ? vpx(22) : vpx(20)
        label: CONFIGS.getMainTextsize(api)
        model: CONSTANTS.AVAILABLE_TEXTSIZES
        value: api.memory.get(CONSTANTS.MAIN_TEXTSIZE) || ''
        onValueChange: textsizeChanged(value)
        visible: settingsVisible
        
        KeyNavigation.right: itemRight
        KeyNavigation.left: itemSound
        KeyNavigation.up: gameContent.gameList
        KeyNavigation.down: gameContent.gameList
        
        anchors {
            right: itemRight.left
            rightMargin: vpx(40)
            verticalCenter: parent.verticalCenter
        }
    }
    
    ComboBox {
        id: itemRight
        width: parent.width*.08
        focusTarget: gameContent.gameList
        fontSize: isSquareScreen ? vpx(22) : vpx(20)
        label: CONFIGS.getMainRight(api)
        model: CONSTANTS.AVAILABLE_RIGHTS
        value: api.memory.get(CONSTANTS.MAIN_RIGHT) || ''
        onValueChange: rightChanged(value)
        visible: settingsVisible
        
        KeyNavigation.right: itemColour
        KeyNavigation.left: itemTextsize
        KeyNavigation.up: gameContent.gameList
        KeyNavigation.down: gameContent.gameList
        
        anchors {
            right: parent.right
            rightMargin: vpx(60)
            verticalCenter: parent.verticalCenter
        }
    }

    Text {
        id: gameAmount
        text: filteredGamesCount !== totalGamesCount ? 
            "검색결과: " + filteredGamesCount + "개 (전체: " + totalGamesCount + ")	 페이지: " + zeroPad(colIdx, colCt.toString().length) + "/" + colCt :
            "게임수: " + zeroPad((currentGameIndex + 1), totalGamesCount.toString().length) + "/" + totalGamesCount + "	 " + "페이지: " + zeroPad(colIdx, colCt.toString().length) + "/" + colCt
        wrapMode: Text.WordWrap
        font.capitalization: Font.AllUppercase
        font.family: subtitleFont.name
        font.pixelSize: isSquareScreen ? vpx(22) : vpx(20)
        font.weight: Font.Light
        horizontalAlignment: Text.AlignLeft // 왼쪽 정렬로 수정
        color: "#ffffff"
        style: Text.Outline
        styleColor: "#000000"
        opacity: 0.5
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left;
            leftMargin: vpx(30)
        }
        
        MouseArea {
            anchors.fill: parent;
            onClicked: {
                requestSettingsFocus();
            }
        }
    }
    
    function focusFirstSetting() {
        itemColour.forceActiveFocus();
    }
}
import QtQuick 2.8 // note the version: Text padding is used below and that was added in 2.7 as per docs
import "utils.js" as Utils // some helper functions
import QtMultimedia 5.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import "configs.js" as CONFIGS
import "constants.js" as CONSTANTS


// The details "view". Consists of some images, a bunch of textual info and a game list.
FocusScope {
    id: root

    // This will be set in the main theme file
    property var currentCollection
	property var tpIndex
    // Shortcuts for the game list's currently selected game
	property var colIdx: collectionsView.currentCollectionIndex+1
	property var colCt: api.collections.count+3
    property alias currentGameIndex: gameList.currentIndex
    readonly property var currentGame: currentCollection.games.get(currentGameIndex)
	    
    // Nothing particularly interesting, see CollectionsView for more comments
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
	//onCurrentGameChanged: {
		  //gameDescription.selected = false;
		 //gameDescription.selected = true;
	//}
	
	// FilterLayer {
        // id: filter
        // anchors.fill: parent
        // onCloseRequested: gameList.focus = true
    // }

    // Key handling. In addition, pressing left/right also moves to the prev/next collection.
	Keys.onLeftPressed: {
		if(flickable.contentHeight > flickable.height){
			flickable.contentY = flickable.contentY-vpx(30);
			if(flickable.contentY < -flickable.topMargin) {
				flickable.contentY = -flickable.topMargin
			}
		}
    }
	Keys.onRightPressed:{
		if(flickable.contentHeight > flickable.height){
			flickable.contentY = flickable.contentY+vpx(30);
			if(flickable.contentY > flickable.contentHeight-flickable.height+flickable.bottomMargin){
				flickable.contentY = flickable.contentHeight-flickable.height+flickable.bottomMargin
			}
		}
    }
    Keys.onPressed: {
        //if (event.isAutoRepeat)
            //return;

        if (api.keys.isAccept(event)&& !event.isAutoRepeat) {
            event.accepted = true;
            launchGame();
            sounds.launchSound()
            return;
        }
        if (api.keys.isCancel(event)&& !event.isAutoRepeat) {
            event.accepted = true;
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
		//if (api.keys.isDetails(event)) {
		    //gameDescription.selected = !gameDescription.selected;
            //event.accepted = true;
            //cancel();
            //sounds.back()
            //return;
        //}
		// && !event.isAutoRepeat
		
		// if (api.keys.isFilters(event) && !event.isAutoRepeat) {
            // event.accepted = true;
			// if(itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus  || itemBacksound.activeFocus ){return gameList.focus = true;}
            // else {return itemTextsize.focus = true;}
            // return;
        // }		
		if (api.keys.isFilters(event) && !event.isAutoRepeat) {
			
			if(itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus || itemBacksound.activeFocus ){return gameList.focus = true;}
			
			if(collectionsView.currentCollectionIndex == 1){
					api.allGames.get(allLastPlayed.mapToSource(currentGameIndex)).favorite=!api.allGames.get(allLastPlayed.mapToSource(currentGameIndex)).favorite;
					return;
				}
			if(collectionsView.currentCollectionIndex == 2){
					api.allGames.get(allFavorites.mapToSource(currentGameIndex)).favorite=!api.allGames.get(allFavorites.mapToSource(currentGameIndex)).favorite;
					return;
				}
			currentGame.favorite = ! currentGame.favorite;
		   
        }
		if (api.keys.isDetails(event) && !event.isAutoRepeat) {
            event.accepted = true;
			if(itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus || itemBacksound.activeFocus ){return gameList.forceActiveFocus();}
            else {return itemColour.forceActiveFocus();}
            return;
        }
		
        //添加PgUp、PgDn支持

        if (api.keys.isPageUp(event) || api.keys.isPageDown(event)) {
            event.accepted = true;
            var games_to_skip = Math.round(gameList.height / gameList.currentItem.height );
            if (api.keys.isPageUp(event))            
                currentGameIndex = Math.max(currentGameIndex - games_to_skip, 0);
            else
                currentGameIndex = Math.min(currentGameIndex + games_to_skip, currentCollection.games.count - 1);
            return;
        }
    }
	
	
   onCurrentCollectionChanged: {
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
			id: bgPlaylistSJ;
			playbackMode: Playlist.Loop;
			PlaylistItem { source: '../Resource/Background_video/게임01/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/게임02/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/게임03/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/게임04/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/게임05/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/게임06/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/게임07/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/게임08/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/게임09/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/레트로01/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/레트로02/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/레트로03/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/레트로04/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/레트로05/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/블루아카이브01/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/블루아카이브02/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/블루아카이브03/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/블루아카이브04/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/블루아카이브05/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/블루아카이브06/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/블루아카이브07/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/블루아카이브08/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/블루아카이브09/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/스팀걸01/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/스팀걸02/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/스팀걸03/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/스팀걸04/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/아리01/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/아리02/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/애니01/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/애니02/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/애니03/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/애니04/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/애니05/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/애니06/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/애니07/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/젠존제01/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/젠존제02/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/젠존제03/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/젠존제04/영상.mp4'; }
			PlaylistItem { source: '../Resource/Background_video/젠존제05/영상.mp4'; }
          }
		  
    //主体视频背景
        MediaPlayer{
            id:player
		    playlist: 
			if(api.memory.get(CONSTANTS.MAIN_COLOUR) == "무작위"){return bgPlaylistSJ;}
			else {return '';}
			source: if(api.memory.get(CONSTANTS.MAIN_COLOUR) != "무작위"){return '../Resource/Background_video/'+api.memory.get(CONSTANTS.MAIN_COLOUR)+'/영상.mp4'} 
            loops: MediaPlayer.Infinite
            // autoPlay: false
                    }
        VideoOutput {
			id: videoPlayer
            //anchors{fill: parent}
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: footer.top
            // anchors.bottom: parent.bottom
            source: player   
			fillMode: VideoOutput.PreserveAspectCrop//Stretch
			flushMode:VideoOutput.FirstFrame
        }


    LinearGradient {
        width: parent.width * 0.3
        height: parent.height

        anchors.left: parent.left
        opacity: 0.6
        // since it goes straight horizontally from the left,
        // the Y of the point doesn't really matter
        start: Qt.point(0, 0)
        end: Qt.point(width, 0)
        // at the left side (0%), it starts with a fully visible black
        // at the right side (100%), it blends into transparency
        gradient: Gradient {
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

		
		Timer {
			id: playerTimer;
			interval: 300
			running: true
			// triggeredOnStart:true
			repeat: false;
			onTriggered: {
                bgPlaylistSJ.shuffle();
				player.play();
		  }
		 }
		


    // The header ba on the top, with the collection's logo and name


        Rectangle {
            id: header
            Image {
                    id: background
                   anchors {fill: parent}
                    asynchronous: true
                    source: '../Resource/Background_image1/'+CONFIGS.getMainTop(api)+'.png'
                    opacity: 1
                    //fillMode: Image.PreserveAspectFit
					
                 }

            Image {
                height: parent.height - header.paddingV*1.1
                anchors {
                    verticalCenter: parent.verticalCenter
					// verticalCenterOffset: -vpx(8)
                    left: parent.left; leftMargin: header.paddingH*.4
                    right: gameList.right//; rightMargin: header.paddingH
                }
                fillMode: Image.PreserveAspectFit
				width: gameList.width
                horizontalAlignment: Image.AlignLeft

                source: currentCollection.shortName ? "../Resource/Logo1/%1.png".arg(currentCollection.shortName) : ""
                asynchronous: true
				mipmap: true
            }

            readonly property int paddingH: vpx(0) // H as horizontal
            readonly property int paddingV: vpx(0) // V as vertical

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: vpx(85)
            color: "#e5e5e5"
        //#f4961d
		
			MouseArea {
								anchors.fill: parent;

								onClicked:{collectionsView.focus = true,api.memory.set('pageIdx',1)}
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
        //color: "#010623"

//主体图片背景
//Image {
                  //id: backgroundmain

                  //anchors.top: boxart.bottom
                 // anchors.left: gameList.right
                 // anchors.right: parent.right
                 // anchors.bottom: parent.bottom
                 // asynchronous: true
                  //source: 'bg/sky2.png'

                 // opacity: 0.4
                    //fillMode: Image.PreserveAspectFit
              //   }
//Image {
                 // id: backgroundmain2
                //  anchors.top: parent.top
               //   anchors.left: parent.left
                //  anchors.right: gameList.right
                //  anchors.bottom: parent.bottom
                //  asynchronous: true
                //  source: 'bg/sky2.png'

                //  opacity: 0.4
                    //fillMode: Image.PreserveAspectFit
             //    }						 

//视频预览
        readonly property int paddingH: vpx(15)
        readonly property int paddingV: vpx(20)
        // Item {
            // id: boxart
            // height: vpx(360)
            // width: vpx(480)  
            // anchors {
                // top: parent.top; //topMargin: content.paddingV*2
                // right: parent.right; rightMargin: content.paddingH*3        
            // }
			


            // GameVideoItem {
                // id: screenshotImage
                // anchors { fill: parent }

                // game: currentGame
                // collectionView: collectionsView.focus
                // detailView: detailsView.focus
                // collectionShortName: currentCollection.shortName
            // }
        // }
		
		Rectangle{
		 id: boxart
		 color: 'transparent'
         height: vpx(300)
         width: vpx(480)  
            anchors {
                top: parent.top; topMargin: content.paddingV*.3
                right: parent.right; rightMargin: content.paddingH*3        
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
				source: currentGame.assets.videos.length ? currentGame.assets.videos[0] : ""
				fillMode: VideoOutput.PreserveAspectFit
				visible: currentCollection.games.count >0 && (!api.memory.has("main_right") || api.memory.get("main_right")=="미리보기")
				volume: (api.memory.has(CONSTANTS.MAIN_SOUND) && api.memory.get(CONSTANTS.MAIN_SOUND) == '게임소리') && detailsView.focus ? 0.7 : 0;
				loops: MediaPlayer.Infinite
				autoPlay: true
			}
			
				z:1;
		}

            //游戏预览
            

        // While the game details could be a grid, I've separated them to two
        // separate columns to manually control thw width of the second one below.
        Column {
            id: gameLabels
            anchors {
                top: parent.top;
                left: gameList.right; leftMargin: content.paddingH*3
            }
        }


    // Rectangle {
        // id: titleBg
        // height: titleTX.height*1.15
        // anchors {
                // top: header.bottom
                // right: boxart.left; 
                // left: gamelist.right; 
        // }
        // color: "#666666"
        // opacity: 0
    // }

    // Text {
		// id: titleTX
		// lineHeight: 0.8
		// visible: currentCollection.games.count >0
        // anchors {
                // right: boxart.left;
                // left: flickable.left; 

        // }

        // text: currentGame.developer 
		// wrapMode:Text.Wrap
        // horizontalAlignment: Text.AlignHCenter
		// style: Text.Outline;styleColor:"black"
        // color: "#eee"
        // font {
            // pixelSize: vpx(22)*CONFIGS.getMainTextsize(api)
            // family: subtitleFont.name
        // }
    // }


       // Column {
           // id: gameDetails
           // anchors {
            //    top: parent.top
            //    right: boxart.left; //rightMargin: content.paddingH
           //     left: gameLabels.right; //leftMargin: content.paddingH
		//		horizontalCenter: clearLogo.horizontalCenter
           // }
          //  GameInfoText { width: parent.width; text: currentGame.developer || "unknown"
			//font.family: subtitleFont.name
			//style: Text.Outline;styleColor:"black"
        //layer.enabled: true
           // color: "#ffffff" }


        //GameInfoText {
        //    id: gameDescription
        //    anchors {
        //        top: boxart.bottom; //topMargin: content.paddingV
        //        left: gameList.right; leftMargin: content.paddingH*3
        //        right: parent.right; rightMargin: content.paddingH
        //        bottom: parent.bottom; bottomMargin: content.paddingV
        //    }
        //    font.family: subtitleFont.name
		//	style: Text.Outline;styleColor:"black"
        //    text: currentGame.description
        //    wrapMode: Text.WordWrap
        //    elide: Text.ElideRight
        //    color: "#ffffff"
        //    font.pixelSize: vpx(20)
        //}


		
	Row {
		id: textcount
		// width: parent.width
        spacing: vpx(18)
		anchors {
                top: boxFront.bottom; //topMargin: vpx(5)
				right: boxart.left; //rightMargin: content.paddingH
                left: flickable.left;
                // left: gameList.right; leftMargin: content.paddingH*3
                // right: parent.right; rightMargin: vpx(40)
                // bottom: parent.bottom; bottomMargin: content.paddingV*.4
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

//Text {
//    id: timecount2
//    width: parent.width * 0.5
//    horizontalAlignment: Text.AlignLeft
//    text: {Utils.formatPlayTime(currentGame.playTime)
//    }
//
//    style: Text.Outline
//    styleColor: "#000000"
//    color: "#ffffff"
//    opacity: 0.8
//
//    font {
//        pixelSize: vpx(20)
//        family: subtitleFont.name
//    }
//}
}

		
		
	  Flickable {
        id: flickable
        width: parent.width
        flickableDirection: Flickable.VerticalFlick
        anchors {
                top: textcount.bottom; topMargin: vpx(15)
                left: gameList.right; leftMargin: content.paddingH*2.45
                right: parent.right; rightMargin: vpx(40)
                bottom: parent.bottom; bottomMargin: content.paddingV*.4
            }
		contentWidth: parent.width
		contentHeight: fullDesc.height
		clip: true
		boundsBehavior: Flickable.DragAndOvershootBounds
		//boundsBehavior: Flickable.DragOverBounds
	    //boundsBehavior: Flickable.StopAtBounds
       // bottomMargin: 600
       // leftMargin: -5
       // rightMargin: -5
       // topMargin: -10






        Text {
            id: fullDesc
            color: "#ffffff"
            text: currentCollection.shortName+'-'+currentGame.title+'\n'+currentGame.description
            width: flickable.width
			opacity: 0.8
            wrapMode: Text.WrapAnywhere
			visible: currentCollection.games.count >0 && (!api.memory.has("main_right") || api.memory.get("main_right")=="미리보기")
            horizontalAlignment: Text.AlignJustify
			style: Text.Outline;styleColor:"#000000"
			font.capitalization: Font.AllUppercase
            font {
                pixelSize: vpx(24)*CONFIGS.getMainTextsize(api)
				
                family: subtitleFont.name
            }
        }
    }
		




		//VerticalMarquee {
            //id: gameDescription
            //anchors {
               // top: boxart.bottom; //topMargin: content.paddingV
               // left: gameList.right; leftMargin: content.paddingH*3
               // right: parent.right; rightMargin: content.paddingH
               // bottom: parent.bottom; bottomMargin: content.paddingV
           // }
           // text: currentGame.description
			//selected: false
			
       // }



        //游戏封面图
        Image {
                id: boxFront
                //anchors { fill: parent; margins: vpx(5) }
                asynchronous: true
                source: currentGame.assets.boxFront || currentGame.assets.logo
                sourceSize { width: 256; height: 256 }
                //height: vpx(240)
				visible: currentCollection.games.count >0 && (!api.memory.has("main_right") || api.memory.get("main_right")=="미리보기")
                width: vpx(220)
				height: vpx(230)
                fillMode: Image.PreserveAspectFit
                readonly property double aspectRatio: (implicitWidth / implicitHeight) || 0
                anchors {
                    top: clearLogo.bottom; topMargin: vpx(2)
					right: boxart.left; //rightMargin: content.paddingH
                    left: flickable.left; //leftMargin: content.paddingH
					// bottom: flickable.top
					// bottomMargin: vpx(55)
                 } 
                horizontalAlignment: Image.AlignHCenter
        }

        //游戏Logo图
        Image {
                id: clearLogo
                //anchors { fill: parent; margins: vpx(5) }
                asynchronous: true
                source: currentGame.assets.logo
                sourceSize { width: 256; height: 256 }
                height: vpx(70)
                width: vpx(220)
				visible: currentCollection.games.count >0 && (!api.memory.has("main_right") || api.memory.get("main_right")=="미리보기")
                fillMode: Image.PreserveAspectFit
                readonly property double aspectRatio: 2
                anchors {
                    top: parent.top; topMargin: vpx(2)
					right: boxart.left; //rightMargin: content.paddingH
                    left: flickable.left; //leftMargin: content.paddingH
                 } 
				
                horizontalAlignment: Image.AlignHCenter
        }
		
			

        ListView {
            id: gameList
            width: parent.width * 0.3
			anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: gameList.right
            anchors.bottom: parent.bottom
            //anchors {
			
			
              //  top: parent.top; topMargin: vpx(26)
                //left: parent.left
                //bottom: parent.bottom; bottomMargin: vpx(26)
            //}
            clip: true

            focus: true

            // model: currentCollection.games
            model: allCollections[collectionsView.currentCollectionIndex].games
            delegate: Rectangle {
                readonly property bool selected: ListView.isCurrentItem
                readonly property color clrDark: "#202151"
                readonly property color clrLight: "#06fbf2"
                width: ListView.view.width
                height: gameTitle.height
                //列表文本部分背景色
                color:"transparent"//selected ? clrDark : "transparent"
				
				  MouseArea {
								anchors.fill: parent;

								onClicked: {
									if (currentGameIndex === index && gameList.focus) {
										launchGame();
							
									} else {
										currentGameIndex = index}
										
									if(itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus  || itemBacksound.activeFocus ){
										gameList.focus = forceActiveFocus();
										// itemColour.focus = false;
										// itemTop.focus = false;
										// itemSound.focus = false;
										// itemTextsize.focus = false;
										// footerbar.visible = !footerbar.visible;
										// itemColour.visible = !itemColour.visible;
										// itemTop.visible= !itemTop.visible;
										// itemSound.visible= !itemSound.visible;
										// itemTextsize.visible= !itemTextsize.visible;
									}
									
								}

								onPressAndHold: {
									if (currentGameIndex === index) {
										if(collectionsView.currentCollectionIndex == 1){
												api.allGames.get(allLastPlayed.mapToSource(currentGameIndex)).favorite=!api.allGames.get(allLastPlayed.mapToSource(currentGameIndex)).favorite;
												return;
											}
										if(collectionsView.currentCollectionIndex == 2){
												api.allGames.get(allFavorites.mapToSource(currentGameIndex)).favorite=!api.allGames.get(allFavorites.mapToSource(currentGameIndex)).favorite;
												return;
											}
										currentGame.favorite = ! currentGame.favorite;
									} else {
										currentGameIndex = index}
									
								}
							}
								
								
								
                Text {
                    id: gameTitle
                    text: modelData.title
                    //color: parent.selected ? parent.clrLight : parent.clrDark
                       color: parent.selected && gameList.focus ? parent.clrLight : "#ffffff"
                    font.pixelSize: vpx(24)*CONFIGS.getMainTextsize(api)
                    font.capitalization: Font.AllUppercase
                    font.family: subtitleFont.name
					font.underline: selected && gameList.focus ? true : false
					style: Text.Outline;styleColor:"#000000"
                    opacity: 0.8
                    lineHeight: 1.2
                    verticalAlignment: Text.AlignVCenter

                    width: parent.width
                    elide: Text.ElideRight
                    leftPadding: vpx(30)
                    rightPadding: vpx(10)
					// favorite && collectionsView.currentCollectionIndex != 2 ? parent.height * .36 + 10 : 10;
					
							Text {
							visible: favorite && collectionsView.currentCollectionIndex != 2 //&& onlyFavorite === false;
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
        color: 'transparent'//header.color
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
        //增加操作提示显示
        Text {
			id: footerbar
            text: "↑↓게임선택，←→내용스크롤，L1/R1에뮬선택，L2/R2빠른이동，Y 즐겨찾기，X 설정"
            font.capitalization: Font.AllUppercase
            font.family: subtitleFont.name
            font.pixelSize: vpx(20)
            font.weight: Font.Light // this is how you use the light variant
            // horizontalAlignment: Text.AlignLeft
			color: api.memory.has("main_top") && (api.memory.get("main_top") == "화이트테마" || api.memory.get("main_top") == "닌텐도테마")  ? "#555555" : "#ffffff"
			style: if(api.memory.has("main_top") && (api.memory.get("main_top") == "화이트테마" || api.memory.get("main_top") == "닌텐도테마")){return Text.Normal}
			else {return Text.Outline;styleColor:"#000000"}
			opacity: if(api.memory.has("main_top") && (api.memory.get("main_top") == "화이트테마" || api.memory.get("main_top") == "닌텐도테마")){return 1}
			else {return 0.5}
			visible: itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus  || itemBacksound.activeFocus ? false : true
            // width: parent.width
            anchors {
                verticalCenter: parent.verticalCenter
				// horizontalCenter: parent.horizontalCenter
				right: parent.right
				rightMargin: vpx(40)
				// left: parent.left; leftMargin: content.paddingH
               
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
            fontSize: vpx(20)//content.normalTextSize
			label: CONFIGS.getMainColour(api)
            //label: {
			//text:" 主题色"
			//font.family: subtitleFont.name
			//style: Text.Underline;
			//}
			//textBackground: "green"
            //textColor: focus ? "#ffffff" : "#ddd"
			visible: itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus || itemBacksound.activeFocus ? true : false
            model: CONSTANTS.AVAILABLE_COLOURS
            value: api.memory.get(CONSTANTS.MAIN_COLOUR) || ''
            onValueChange: updateColour()
		     KeyNavigation.right: itemTop
			// KeyNavigation.up: gameList
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
			// anchors {
				// left:itemColour.right
				// leftMargin:itemColour.width*.3
			// }
			anchors {
				right: itemSound.left
				rightMargin:itemColour.width*.38
			}

        }
		
		ComboBox {
            id: itemSound
			width: parent.width*.08
            fontSize: vpx(20)//content.normalTextSize
            label: CONFIGS.getMainSound(api)
			//text:" 主题色"
			//font.family: subtitleFont.name
			//style: Text.Underline;
			//}
			//textBackground: "green"
            //textColor: focus ? "#ffffff" : "#ddd"
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
            fontSize: vpx(20)//content.normalTextSize
            label: CONFIGS.getMainBacksound(api)
			//text:" 主题色"
			//font.family: subtitleFont.name
			//style: Text.Underline;
			//}
			//textBackground: "green"
            //textColor: focus ? "#ffffff" : "#ddd"
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
            fontSize: vpx(20)//content.normalTextSize
            label: CONFIGS.getMainTextsize(api)
			//text:" 主题色"
			//font.family: subtitleFont.name
			//style: Text.Underline;
			//}
			//textBackground: "green"
            //textColor: focus ? "#ffffff" : "#ddd"
            model: CONSTANTS.AVAILABLE_TEXTSIZES
            value: api.memory.get(CONSTANTS.MAIN_TEXTSIZE) || ''
            onValueChange: updateTextsize()
			visible: itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus || itemBacksound.activeFocus ? true : false
			KeyNavigation.right: itemRight
			// anchors {
				// left: itemSound.right
				// leftMargin: itemColour.width*.3
			// }
			
			anchors {
				right: itemRight.left
				rightMargin:itemColour.width*.38
			}

        }
		
		ComboBox {
            id: itemRight
			width: parent.width*.08
            fontSize: vpx(20)//content.normalTextSize
            label: CONFIGS.getMainRight(api)
			//text:" 主题色"
			//font.family: subtitleFont.name
			//style: Text.Underline;
			//}
			//textBackground: "green"
            //textColor: focus ? "#ffffff" : "#ddd"
            model: CONSTANTS.AVAILABLE_RIGHTS
            value: api.memory.get(CONSTANTS.MAIN_RIGHT) || ''
            onValueChange: updateRight()
			visible: itemColour.activeFocus|| itemTop.activeFocus || itemSound.activeFocus ||itemTextsize.activeFocus ||itemRight.activeFocus || itemBacksound.activeFocus ? true : false
			KeyNavigation.right: itemColour
			// anchors {
				// left: itemSound.right
				// leftMargin: itemColour.width*.3
			// }
			
			anchors {
				right: parent.right
				rightMargin: vpx(60)
			}

        }
     
		

        //增加游戏索引显示
        Text {
			id: gameAmount
            text: "게임수: " + zeroPad((currentGameIndex + 1),currentCollection.games.count.toString().length) + "/" + currentCollection.games.count+"    " + "페이지: " + zeroPad(colIdx,colCt.toString().length )+ "/" + colCt
            wrapMode: Text.WordWrap
            font.capitalization: Font.AllUppercase
            font.family: subtitleFont.name
			//style: Text.Outline;styleColor:"black"
            font.pixelSize: vpx(20)
            font.weight: Font.Light // this is how you use the light variant
            horizontalAlignment: Text.AlignRight
            color: api.memory.has("main_top") && (api.memory.get("main_top") == "화이트테마" || api.memory.get("main_top") == "닌텐도테마")  ? "#555555" : "#ffffff"
			style: if(api.memory.has("main_top") && (api.memory.get("main_top") == "화이트테마" || api.memory.get("main_top") == "닌텐도테마")){return Text.Normal}
			else {return Text.Outline;styleColor:"#000000"}
			opacity: if(api.memory.has("main_top") && (api.memory.get("main_top") == "화이트테마" || api.memory.get("main_top") == "닌텐도테마")){return 1}
			else {return 0.5}
            // width: parent.width * 0.4
            anchors {
                verticalCenter: parent.verticalCenter
                // right: parent.right; rightMargin: header.paddingH*.3
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


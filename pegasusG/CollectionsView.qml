import QtQuick 2.8
import QtMultimedia 5.15
import QtGraphicalEffects 1.12

// The collections view consists of two carousels, one for the collection logo bar
// and one for the background images. They should have the same number of elements
// to be kept in sync.
FocusScope {
    id: root

    // This element has the same size as the whole screen (ie. its parent).
    // Because this screen itself will be moved around when a collection is
    // selected, I've used width/height instead of anchors.
    width: parent.width
    height: parent.height
    enabled: focus // do not receive key/mouse events when unfocused
    visible: y + height >= 0 // optimization: do not render the item when it's not on screen

    signal collectionSelected

    // Shortcut for the currently selected collection. They will be used
    // by the Details view too, for example to show the collection's logo.
    property alias currentCollectionIndex: logoAxis.currentIndex
    // readonly property var currentCollection: logoAxis.model.get(logoAxis.currentIndex)
    readonly property var currentCollection: allCollections[collectionsView.currentCollectionIndex]

    // These functions can be called by other elements of the theme if the collection
    // has to be changed manually. See the connection between the Collection and
    // Details views in the main theme file.
    function selectNext() {
        logoAxis.incrementCurrentIndex();
    }
    function selectPrev() {
        logoAxis.decrementCurrentIndex();
    }

    // The carousel of background images. This isn't the item we control with the keys,
    // however it reacts to mouse and so should still update the Index.
    Carousel {
        id: bgAxis

        anchors.fill: parent
        itemWidth: width

        // model: api.collections
        model: allCollections
        delegate: bgAxisItem
        currentIndex: logoAxis.currentIndex
		onCurrentIndexChanged: {
			if (currentIndex !== currentCollectionIndex){
				const temp = currentIndex
				currentCollectionIndex = temp
			}
		}

        highlightMoveDuration: 300 // it's moving a little bit slower than the main bar
    }
    Component {
        // Either the image for the collection or a single colored rectangle
        id: bgAxisItem

        Item {
            width: root.width
            height: root.height
            visible: PathView.onPath // optimization: do not draw if not visible

            Rectangle {
                anchors.fill: parent
                color: "#777"
                visible: false//realBg.status != Image.Ready // optimization: only draw if the image did not load (yet)
            }
            Image {
                id: realBg
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop // fill the screen without black bars
                source: modelData.shortName ? "../Resource/Background_image1/%1.jpg".arg(modelData.shortName) : ""
                // source: modelData.shortName ? "../Resource/Background_image1/"+modelData.shortName+".jpg" : ""
                asynchronous: true
				
            }
        }
    }

	Image{
		id: pegasusLogo
		source: '../Resource/Background_image1/Pegasus G-2.png';
		fillMode: Image.PreserveAspectFit;
        horizontalAlignment: Image.AlignLeft;
		// width: parent.width * .05;
        height: headerWidgets.height*.65;
		mipmap:true
		opacity: 1
		
		anchors {
			// top:headerWidgets.top
            verticalCenter: headerWidgets.verticalCenter;
			verticalCenterOffset: vpx(4)
            left: parent.left;
            leftMargin: 24;
        }
	}
    // I've put the main bar's parts inside this wrapper item to change the opacity
    // of the background separately from the carousel. You could also use a Rectangle
	Row {
        id: headerWidgets;
		spacing: vpx(20);
        height: vpx(100)

        anchors {
            right: parent.right;
            rightMargin: parent.height * .07;
			top: parent.top;
        }
		
	       Text {
                    id: sysTime

                    //12HR-"h:mmap" 24HR-"hh:mm"
                    property var timeSetting: "hh:mm";
					anchors.verticalCenter: parent.verticalCenter;
                    function set() {
                        sysTime.text = Qt.formatTime(new Date(), timeSetting) 
                    }

                    Timer {
                        id: textTimer
                        interval: 60000 // Run the timer every minute
                        repeat: true
                        running: true
                        triggeredOnStart: true
                        onTriggered: sysTime.set()
                    }

                    // onTimeSettingChanged: sysTime.set()
					
				     //anchors {
                       //  verticalCenter: topBar.verticalCenter;
                       //  right: batteryIcon.left; //rightMargin: vpx(15)
                    // }
					
                    color: "white"
                    font.family: subtitleFont.name
                    font.weight: Font.Bold
                    font.letterSpacing: 2
					style: Text.Outline;
                    font.pixelSize: parent.height * .26;
                    horizontalAlignment: Text.Right
                    font.capitalization: Font.SmallCaps
					
			}
   
			Battery {
            id: battery;
//			visible: showBattery;         
			opacity: 1;
            shade: parent.shade;
            height: parent.height*0.3;
            width: parent.height*0.55;
            anchors.verticalCenter: parent.verticalCenter;
			anchors.verticalCenterOffset: vpx(2)
			Image{
                        id: chargingIcon

                        property bool chargingStatus: api.device.batteryCharging

                        width: height/2
                        height: sysTime.paintedHeight*.8
                        fillMode: Image.PreserveAspectFit
                        source: "assets/charging.svg"
                        sourceSize.width: 32
                        sourceSize.height: 64
                        smooth: true
						anchors.horizontalCenter: parent.horizontalCenter;
						anchors.verticalCenter: parent.verticalCenter;
                        horizontalAlignment: Image.AlignLeft
                        visible: chargingStatus && api.device.batteryPercent*100 < 99
                        // layer.enabled: true
                        // layer.effect: ColorOverlay {
                            // color: "green"
                            // antialiasing: true
                            // cached: true
                        // }

                        function set() {
                            chargingStatus = api.device.batteryCharging;
                        }

                        Timer {
                            id: chargingIconTimer
                            interval: 500 // Run the timer every minute
							running: true
							repeat: true
                            onTriggered: chargingIcon.set()
                        }
						
						Image{
                        id: chargingIcon2

                        property bool chargingStatus: api.device.batteryCharging

                        width: height/2
                        height: sysTime.paintedHeight*.75
                        fillMode: Image.PreserveAspectFit
                        source: "assets/charging.svg"
                        sourceSize.width: 32
                        sourceSize.height: 64
                        smooth: true
						anchors.horizontalCenter: parent.horizontalCenter;
						anchors.verticalCenter: parent.verticalCenter;
                        horizontalAlignment: Image.AlignLeft
                        visible: chargingStatus && api.device.batteryPercent*100 < 99
                        layer.enabled: true
                        layer.effect: ColorOverlay {
                            color: "white"
                            antialiasing: true
                            cached: true
                        }

                        function set() {
                            chargingStatus = api.device.batteryCharging;
                        }

                        Timer {
                            id: chargingIconTimer2
                            interval: 500 // Run the timer every minute
							repeat: true
							running: true
                            onTriggered: chargingIcon2.set()
                        }

                   }

                }
			}
			
			Text {
			id: batteryPercentage
			text:
				if(Math.floor(api.device.batteryPercent*100) > 0 ){
					Math.floor(api.device.batteryPercent*100) + "%"
				}else{
					"无电池"
				}
			//Math.floor(api.device.batteryPercent*100) + "%";
			opacity: 1;
            color: "#fff";
            anchors.verticalCenter: parent.verticalCenter;
            font {
                family: subtitleFont.name;//family: glyphs.name;
                pixelSize: parent.height * .26;
				bold: true;
            }
			style: Text.Outline;
			// style: Text.Outline;styleColor:'#666666'
		   }
		
		   
	}
    // with a color that has alpha value.
    Item {
        id: logoBar
        anchors.left: parent.left
        anchors.right: parent.right
        // anchors.verticalCenter: parent.verticalCenter
		anchors.bottom: parent.bottom
		// anchors.bottomMargin: vpx(5)
        height: vpx(170)

        // Background
        Rectangle {
            anchors.fill: parent
            color: "#8b8b8b"
            opacity: 0
        }
        // The main carousel that we actually control
        Carousel {
            id: logoAxis

            anchors.fill: parent
            itemWidth: vpx(480)

            // model: api.collections
            model: allCollections
            delegate: CollectionLogo {
                longName: modelData.name
                shortName: modelData.shortName
            }
			

            focus: true

            Keys.onPressed: {
                //if (event.isAutoRepeat)
                    //return;

                if (api.keys.isNextPage(event) && !event.isAutoRepeat) {
                    event.accepted = true;
					if(currentIndex == allCollections.length-1) {
						currentIndex = 0;return;
						}
					else if (currentIndex + 5 > allCollections.length-1) {
						currentIndex = allCollections.length-1;return;
						}
					currentIndex = currentIndex+5;
                    // incrementCurrentIndex();
                }
				else if (api.keys.isPrevPage(event) && !event.isAutoRepeat) {
                    event.accepted = true;
					if(currentIndex == 0) {
						currentIndex = allCollections.length-1;return;
						}
					else if (currentIndex - 5 < 0) {
						currentIndex = 0;return;
						}
					currentIndex = currentIndex-5;
                    // incrementCurrentIndex();
                }
                else if (api.keys.isPageUp(event) && !event.isAutoRepeat) {
                    event.accepted = true;
					currentIndex = 0;
                    // decrementCurrentIndex();
                }
				else if (api.keys.isPageDown(event) && !event.isAutoRepeat) {
                    event.accepted = true;
					currentIndex = allCollections.length-1;
                    // incrementCurrentIndex();
                }
            }

            onItemSelected: root.collectionSelected()
        }
    }

    // Game count bar -- like above, I've put it in an Item to separately control opacity
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: logoBar.top
        height: label.height * 1.5

        Rectangle {
            anchors.fill: parent
            color: "#c20214"
            opacity: 0
        }
Image {
                id: realBg
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop // fill the screen without black bars
                source: modelData.shortName ? "../Resource/Background_image1/%1_art_blur.jpg".arg(modelData.shortName) : ""
                asynchronous: true
				
            }
        // Text {
            // id: label
            // anchors.centerIn: parent
            // text: "%1 GAMES".arg(currentCollection.games.count)
            // color: "#ffffff"
            // font.pixelSize: vpx(30)
            // font.family: subtitleFont.name
			// style: Text.Outline;styleColor:"black"
        // }
    }
}

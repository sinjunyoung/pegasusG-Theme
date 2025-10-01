import QtQuick 2.0
import SortFilterProxyModel 0.2
import 'components/resources' as Resources
import 'resources' as Resourcesm
// Welcome! This is the entry point of the theme; it defines two "views"
// and a way to move (and animate moving) between them.
FocusScope {
	
	Resourcesm.Music { id: music
	
	}
	
	// Resources.CollectionsView { id: colView; }
	
	SortFilterProxyModel {
        id: allFavorites
        sourceModel: api.allGames
        filters: ValueFilter { roleName: "favorite"; value: true; }
		// sorters: RoleSorter { roleName: "collections"; sortOrder: Qt.DescendingOrder; }
		
    }
    SortFilterProxyModel {
        id: allLastPlayed
        sourceModel: api.allGames
        filters: ValueFilter { roleName: "lastPlayed"; value: ""; inverted: true; }
        sorters: RoleSorter { roleName: "lastPlayed"; sortOrder: Qt.DescendingOrder }
    }
    SortFilterProxyModel {
        id: filterLastPlayed
        sourceModel: allLastPlayed
        filters: IndexFilter { maximumIndex: {
            if (allLastPlayed.count >= 49) return 49
            return allLastPlayed.count
        } }
    }

    property var allCollections: {
       const collections = api.collections.toVarArray()
       collections.unshift({"name": "收藏", "shortName": "즐겨찾기", "games": allFavorites})
       collections.unshift({"name": "最后", "shortName": "최근실행", "games": filterLastPlayed})
       collections.unshift({"name": "全部", "shortName": "전체게임", "games": api.allGames})
        return collections
    }

    // When the theme loads, try to restore the last selected game
    // and collection. If this is the first time launching this theme, these
    // values will be undefined, which is why there are zeroes as fallback
    Component.onCompleted: {
	// detailsView.focus = true;
        collectionsView.currentCollectionIndex = api.memory.get('collectionIndex') || 0;
		detailsView.currentGameIndex = api.memory.get('gameIndex') || 0 ;	
        // if(currentCollection.shortName === "최근실행"){detailsView.currentGameIndex = 0}
        sounds.start()
		if(api.memory.has('pageIdx') != true) collectionsView.focus = true;
		else if(api.memory.get('pageIdx') == 1) collectionsView.focus = true;
		else if(api.memory.get('pageIdx') == 2) detailsView.focus = true;
    }
	


    // Loading the fonts here makes them usable in the rest of the theme
    // and can be referred to using their name and weight.
    FontLoader { id: subtitleFont; source: "../Resource/Fonts/Font.otf" }
	
	FontLoader {
        id: glyphs;
        property string favorite: '\ue805';
        property string unfavorite: '\ue802';
        property string settings: '\uf1de';
        property string enabled: '\ue800';
        property string disabled: '\uf096';
        property string play: '\ue801';
        property string ascend: '\uf160';
        property string descend: '\uf161';
        property string fullStar: '\ue803';
        property string halfStar: '\uf123';
        property string emptyStar: '\ue804';
        property string search: '\ue806';
        property string cancel: '\ue807';
        source: "assets/fontello.ttf";
       }
    // The actual views are defined in their own QML files. They activate
    // each other by setting the focus. The details view is glued to the bottom
    // of the collections view, and the collections view to the bottom of the
    // screen for animation purposes (see below).

    // 加载音频文件
    Resources.Sounds { id: sounds; }


    CollectionsView {
        id: collectionsView
        anchors.bottom: parent.bottom

        focus: true
        onCollectionSelected: {detailsView.focus = true,api.memory.set('pageIdx',2)}
		MouseArea {
			        height:vpx(130)
					anchors.left: parent.left;
					anchors.right: parent.right;
					anchors.bottom: parent.bottom;
					

					onClicked:{detailsView.focus = true,api.memory.set('pageIdx',2)}
				  }
    }
	


    DetailsView {
        id: detailsView
        anchors.top: collectionsView.bottom
		

        // currentCollection: collectionsView.currentCollection
        currentCollection: allCollections[collectionsView.currentCollectionIndex]

        onCancel: {collectionsView.focus = true,api.memory.set('pageIdx',1)}
        onNextCollection: collectionsView.selectNext()
        onPrevCollection: collectionsView.selectPrev()
        onLaunchGame: {
            api.memory.set('collectionIndex', collectionsView.currentCollectionIndex);
            api.memory.set('gameIndex', currentGameIndex);
			// let currentGame
			// if(currentGame.launch()) currentGame.launch();
			if (currentCollection.shortName === "즐겨찾기")
			{api.allGames.get(allFavorites.mapToSource(currentGameIndex)).launch()}
			else if (currentCollection.shortName === "최근실행")
			{api.allGames.get(allLastPlayed.mapToSource(currentGameIndex)).launch();
			api.memory.set('gameIndex', 0);}
			else  currentGame.launch()
			// currentGame.launch();
        }
    }
	

    // I animate the collection view's bottom anchor to move it to the top of
    // the screen. This, in turn, pulls up the details view.
    states: [
        State {
            when: detailsView.focus
            AnchorChanges {
                target: collectionsView;
                anchors.bottom: parent.top
            }
        }
    ]
    // Add some animations. There aren't any complex State definitions so I just
    // set a generic smooth anchor animation to get the job done.
    transitions: Transition {
        AnchorAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }
    }
}

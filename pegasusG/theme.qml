import QtQuick 2.0
import SortFilterProxyModel 0.2

FocusScope {		
	
        SortFilterProxyModel {
        id: allFavorites
        sourceModel: api.allGames
        filters: ValueFilter { roleName: "favorite"; value: true; }
		
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
       collections.unshift({"name": "Favorites", "shortName": "Favorites", "games": allFavorites})
       collections.unshift({"name": "LastPlayed", "shortName": "Last Played", "games": filterLastPlayed})
       collections.unshift({"name": "AllGames", "shortName": "All Games", "games": api.allGames})
        return collections
    }

    Component.onCompleted: {
        collectionsView.currentCollectionIndex = api.memory.get('collectionIndex') || 0;
		detailsView.currentGameIndex = api.memory.get('gameIndex') || 0 ;	
		if(api.memory.has('pageIdx') != true) collectionsView.focus = true;
		else if(api.memory.get('pageIdx') == 1) collectionsView.focus = true;
		else if(api.memory.get('pageIdx') == 2) detailsView.focus = true;
    }
	


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
        source: "../Resource/Fonts/fontello.ttf";
    }

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
		

        currentCollection: allCollections[collectionsView.currentCollectionIndex]

        onCancel: {collectionsView.focus = true,api.memory.set('pageIdx',1)}
        onNextCollection: collectionsView.selectNext()
        onPrevCollection: collectionsView.selectPrev()
        onLaunchGame: {
            api.memory.set('collectionIndex', collectionsView.currentCollectionIndex);
            api.memory.set('gameIndex', currentGameIndex);
			if (currentCollection.shortName === "Favorites")
			{api.allGames.get(allFavorites.mapToSource(currentGameIndex)).launch()}
			else if (currentCollection.shortName === "LastPlayed")
			{api.allGames.get(allLastPlayed.mapToSource(currentGameIndex)).launch();
			api.memory.set('gameIndex', 0);}
			else  currentGame.launch()
        }
    }
	

    states: [
        State {
            when: detailsView.focus
            AnchorChanges {
                target: collectionsView;
                anchors.bottom: parent.top
            }
        }
    ]

    transitions: Transition {
        AnchorAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }
    }
}

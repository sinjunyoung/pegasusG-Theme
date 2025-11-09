import QtQuick 2.0

PathView {
    id: root

    Sounds {
        id: sounds
    }

    property int itemWidth // set this on the calling site
    readonly property int pathWidth: pathItemCount * itemWidth

    signal itemSelected

    Keys.onLeftPressed: {
        sounds.nav()
        decrementCurrentIndex()
    }
	Keys.onUpPressed: {
        sounds.nav()
        decrementCurrentIndex()
    }
    Keys.onRightPressed: {
        sounds.nav()
        incrementCurrentIndex()
    }
	Keys.onDownPressed: {
        sounds.nav()
        incrementCurrentIndex()
    }
    Keys.onPressed: {
        if (api.keys.isAccept(event)&& !event.isAutoRepeat) {
            event.accepted = true;
            itemSelected();
            sounds.forward()
        }
    }

    snapMode: PathView.SnapToItem
    preferredHighlightBegin: 0.5
    preferredHighlightEnd: 0.5

    pathItemCount: Math.ceil(width / itemWidth) + 2
    path: Path {
        startX: (root.width - root.pathWidth) / 2
        startY: root.height / 2
        PathLine {
            x: root.path.startX + root.pathWidth
            y: root.path.startY
        }
    }
}

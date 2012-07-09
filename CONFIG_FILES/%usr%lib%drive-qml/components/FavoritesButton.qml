import QtQuick 1.1
import "styles.js" as Style

Item {
    id: favoritesButton
    property variant style: Style.Favorites
    property bool isFavorite

    signal addFavorite
    signal removeFavorite

    width: style.button.width
    height: style.button.height

    states: [
        State {
            name: "favorite"
            when: isFavorite && !mouseArea.pressed
            PropertyChanges {
                target: buttonImage
                source: style.icon.uri + style.button.icon.remove
            }
        },
        State {
            name: "not_favorite"
            when: !isFavorite && !mouseArea.pressed
            PropertyChanges {
                target: buttonImage
                source: style.icon.uri + style.button.icon.add
            }
        },
        State {
            name: "favorite_pressed"
            when: isFavorite && mouseArea.pressed
            PropertyChanges {
                target: buttonImage
                source: style.icon.uri + style.button.icon.removeDown
            }
        },
        State {
            name: "not_favorite_pressed"
            when: !isFavorite && mouseArea.pressed
            PropertyChanges {
                target: buttonImage
                source: style.icon.uri + style.button.icon.addDown
            }
        }
    ]

    Image {
        id: buttonImage
        anchors.fill: parent
        clip: true
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {

            if(isFavorite) {
                removeFavorite();
            }
            else {
                addFavorite();
            }
        }
    }
}

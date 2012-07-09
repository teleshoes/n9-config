import QtQuick 1.1
import "styles.js" as Styles

Text {
    id: addressTextLine
    property bool landscape: parent.landscape

    states: [
        State {
            name: "headline"
            PropertyChanges {
                target: addressTextLine
                color: Styles.WHITE
                font.pixelSize: Styles.FONT_BIG
                maximumLineCount: (text.search(/\W+/) == -1) ? 1
                                                             : (landscape ? 3 : 2)
            }
        },
        State {
            name: "bottomLine"
            PropertyChanges {
                target: addressTextLine
                maximumLineCount: landscape ? 2 : 1
            }
        }
    ]

    anchors.left: parent.left
    anchors.right: parent.right
    color: Styles.SUBTITLE_GRAY
    font.family: Styles.NOKIA_SANS_WIDE
    font.pixelSize: Styles.FONT_NORMAL
    elide: Text.ElideRight
    wrapMode: Text.Wrap
    maximumLineCount: landscape ? 3 : 2
}

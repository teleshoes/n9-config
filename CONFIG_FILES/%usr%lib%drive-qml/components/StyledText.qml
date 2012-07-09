import QtQuick 1.1


Text {
    font.family: textStyle.family
    font.pixelSize: textStyle.size
    color: textStyle.color
    wrapMode: Text.WordWrap
    property variant textStyle
}

import QtQuick 1.1
import components 1.0
import "../components/styles.js" as Styles

Page {
    id: page
    title: qsTrId("qtn_drive_credits_hdr")

    property string lineBreak: '<br /><br />'
    property variant team: [
        'Adrian',
        'Alejandro',
        'Alexey',
        'Antje',
        'Anton',
        'Dmitry',
        'Egor',
        'Ehsun',
        'Emil',
        'Erol',
        'Giovanni',
        'Hengzhi',
        'Jani',
        'Juho',
        'Krzysztof',
        'Luis',
        'Maria',
        'Mika',
        'Pawel',
        'Roland',
        'Sergey',
        'Seshu',
        'Simon',
        'Stephan',
        'Sylwia',
        'Tomi'
    ]
    property variant toMos: [
        'Diego',
        'Jeremie',
        'Mirko',
        'Paul'
    ]
    property variant toSearch: [
        'Benjamin'
    ]
    property variant toLocal: [
        'Luis',
        'Uwa'
    ]

    function format(title, names) {
        return '<b>' + qsTrId(title) + '</b><br />' + names.sort().join(', ');
    }

    Flickable {
        id: flicker
        anchors.top: page.titleBottom
        anchors.left: page.left
        anchors.right: page.right
        anchors.bottom: page.bottom
        anchors.margins: 16
        clip: true
        contentWidth: width
        contentHeight: Math.max(height, content.height) // flickable only when necessary
        Text {
            id: content
            width: parent.width - 32
            font.family: Styles.RegularText.family
            font.pixelSize: Styles.RegularText.size
            color: Styles.RegularText.color
            text: [
                format('qtn_drive_credits_team', team),
                format('qtn_drive_credits_thankstomos', toMos),
                format('qtn_drive_credits_thankstosearch', toSearch),
                format('qtn_drive_credits_thankstolocal', toLocal)
            ].join(lineBreak)
            wrapMode: Text.WordWrap
        }

    }

    ScrollPositionIndicator {
        flickable: flicker
        anchors.bottom: page.bottom
        anchors.top: page.titleBottom
        anchors.right: page.right
        anchors.topMargin: 16
        anchors.bottomMargin: 16
    }
}

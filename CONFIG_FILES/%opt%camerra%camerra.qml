
import QtQuick 1.1
import com.nokia.meego 1.0

PageStackWindow {
    initialPage: Page {
        Text {
            anchors.centerIn: parent
            width: parent.width * .8
            font.pixelSize: 20
            text: '<p style="text-align: center;">
            <b>Ye Olde Camerra Hack!</b><br><br>
            While this application is running, you can<br>
            use the <b>Volume +</b> button on your N9<br>
            to capture photos in the camera application.<br>
            <br><br>
            http://thp.io/2012/camerra/
            </p>'
        }

        Image {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            source: 'camerra-instructions.png'
        }
    }
}

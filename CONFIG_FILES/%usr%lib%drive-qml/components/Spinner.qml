import QtQuick 1.1
import "styles.js" as Style


AnimatedImage {
    id: spinner
    property variant spinnerStyle: Style.Spinner
    width: spinnerStyle.width
    height: spinnerStyle.height
    source: spinnerStyle.source
}

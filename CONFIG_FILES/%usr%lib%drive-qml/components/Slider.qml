import QtQuick 1.1
import "styles.js" as Styles

Item {
    id: progressBar

    //private
    property variant sliderStyle: Styles.Slider

    //public
    property int initialValue: 1
    property int minValue: 1
    property int maxValue: 2
    property string unit: ""
    property int value: initialValue
    property alias valueTextFont: progress_value.font
    property alias unitTextFont: progress_unit.font
    function setValue(val) {
       !isNaN(val) && //is number
                (val = Number(val)) != undefined && // convert to number
                val >= minValue && //check range
                val <= maxValue &&
                (progress = (val - minValue) * step) //set progress
    }

    property bool valueSet: progress_value.text !== ""

    //private
    property real step: 90 / (maxValue - minValue)
    property int progress: (initialValue - minValue) * step

    //marking height private, since requires flikering with border image itself
    //TODO: make progress bar images strechale vertiucally
    property int barHeight: 10

    function progressChangedCB() {
        var newValue = Math.round(progressBar.progress / step)
        value = newValue + minValue
        progress_value.text = value
        progressBar.progress = newValue * step
    }

    Component.onCompleted: {
        //placeing change listener here, so initial value settings wont fire
        progressBar.progressChanged.connect(progressChangedCB)
    }
    Item {
        id: thebar
        anchors {
            left: minValueText.right
            leftMargin: progress_nobe.width / 2 + 5
            right: maxValueText.left
            rightMargin: progress_nobe.width / 2 + 5
            verticalCenter: parent.verticalCenter
        }
        BorderImage {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            border { left: 10; top: 5; right: 10; bottom: 5 }
            height: barHeight
            horizontalTileMode: BorderImage.Stretch
            source: sliderStyle.backgroundSource
            verticalTileMode: BorderImage.Stretch
            MouseArea {
                width: parent.width
                height:  sliderStyle.backgroundTouchAreaHeight
                anchors.centerIn: parent
                onClicked: {
                    progressBar.progress = mouseX / parent.width * 90
                }
            }
        }

        //tap


        BorderImage {
            id: progressIndicator
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            border { left: 5; top: 5; right: 5; bottom: 5 }
            height: barHeight
            horizontalTileMode: BorderImage.Stretch
            source: sliderStyle.foregroundSource
            verticalTileMode: BorderImage.Stretch
            width: {
                return dragArea.drag.active ?
                            (progress_nobe.x + progress_nobe.width / 2) :
                            (Math.max(progressBar.progress, 1) / 90 * parent.width)
            }

            Behavior on width {
                enabled: !dragArea.pressed
                SmoothedAnimation { duration: 400 }
            }
        }

        BorderImage {
            id: progress_value_bg
            source: sliderStyle.valueBackgroundSource
            anchors {
                bottom: progress_value_arrow.top
                bottomMargin: -2
            }
            border { left: 19; right: 19; top: 17; bottom: 23 }
            x: {
                var margin = (progressBar.width - thebar.width) / 2;
                var cap = thebar.width + margin - width;
                var common = progress_nobe.x + progress_nobe.width / 2 - width / 2;
                return Math.min(cap, Math.max(-margin, common));
            }
            horizontalTileMode: BorderImage.Stretch
            verticalTileMode: BorderImage.Stretch
            visible: (progress_value.text !== "")
            width: Math.max(40, valueContainer.width + valueContainer.anchors.leftMargin + valueContainer.anchors.rightMargin)
            Row {
                id: valueContainer
                anchors {
                    centerIn: parent
                    leftMargin: progress_unit.visible ? 15 : 0
                    rightMargin: progress_unit.visible ? 15 : 0
                }
                Text {
                    id: progress_value
                    color: progressBar.sliderStyle.valueColor
                    font.family: progressBar.sliderStyle.valueFamily
                    font.pixelSize: progressBar.sliderStyle.valueSize
                    text: ""
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    id: progress_unit
                    anchors.baseline: progress_value.baseline
                    color: progressBar.sliderStyle.valueColor
                    font.pixelSize: progressBar.sliderStyle.valueSize
                    font.family: progressBar.sliderStyle.valueFamily
                    text: " " + unit
                    visible: !!unit
                }
            }
        }

        Image {
            id: progress_value_arrow
            visible: progress_value_bg.visible
            source: sliderStyle.arrowSource
            anchors {
                bottom: progress_nobe.top
                bottomMargin: sliderStyle.arrowBottomMargin
                horizontalCenter: progress_nobe.horizontalCenter
            }
        }

        Image {
            id: progress_nobe
            anchors {
                horizontalCenter: dragArea.drag.active ? undefined : progressIndicator.right
                verticalCenter: parent.verticalCenter
            }
            source: sliderStyle.handleSource[dragArea.pressed ? "down" : "normal"]
            width: sliderStyle.handleWidth
            onXChanged: dragArea.drag.active && (progressBar.progress = (x + width / 2) / parent.width * 90)

            MouseArea {
                id: dragArea
                anchors.centerIn: parent
                height: sliderStyle.handleTouchAreaWidth
                width: sliderStyle.handleTouchAreaHeight
                drag {
                    axis: Drag.XAxis
                    minimumX: -progress_nobe.width / 2
                    maximumX: thebar.width - progress_nobe.width / 2
                    target: progress_nobe
                }
            }
        }
    } //thebar

    Text {
        id: minValueText
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
        }
        font.pixelSize: sliderStyle.minimumValueTextSize
        font.family: sliderStyle.minimumValueTextFamily
        color: sliderStyle.minimumValueTextColor
        text: minValue
    }

    Text {
        id: maxValueText
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
        }
        font.pixelSize: sliderStyle.maximumValueTextSize
        font.family: sliderStyle.maximumValueTextFamily
        color: sliderStyle.maximumValueTextColor
        text: maxValue
    }
}

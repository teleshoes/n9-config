import QtQuick 1.1
import "styles.js" as Style


Item {
     id: scrollBar
     width: 12
     property Flickable flickable
     visible: flickable.visibleArea.heightRatio < 1.0
     clip:  true
     opacity: 0

     property variant scrollPositionIndicatorStyle: Style.ScrollPositionIndicator

     states: [
         State {
             name: "show"
             when: flickable.moving
             PropertyChanges {
                 target: scrollBar
                 opacity: 1.0
             }
         }
     ]

     transitions: [
         Transition {
             PropertyAnimation {
                id: opacityAnimation
                properties: "opacity"
                easing.type: Easing.InOutQuad
                target: scrollBar
             }
         }
     ]



     // A light, semi-transparent background
     Rectangle {
         id: background
         anchors.fill: parent
         radius: width/2 - 1
         color: scrollPositionIndicatorStyle.backgroundColor
         opacity: scrollPositionIndicatorStyle.backgroundOpacity
     }

     // Size the bar to the required size, depending upon the orientation.
     Rectangle {
         x: 1
         y: flickable.visibleArea.yPosition * (scrollBar.height - 2) + 1
         width: parent.width-2
         height: flickable.visibleArea.heightRatio * (scrollBar.height - 2)
         radius: width / 2 - 1
         color: scrollPositionIndicatorStyle.indicatorColor
         opacity: scrollPositionIndicatorStyle.indicatorOpacity
     }
 }

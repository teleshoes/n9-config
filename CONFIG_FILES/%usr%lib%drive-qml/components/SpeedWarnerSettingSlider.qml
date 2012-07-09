import QtQuick 1.1
import "styles.js" as Styles
import "../utils/Units.js" as Units

Slider {
    id: speedWarnerSettingSlider
    height: Styles.SpeedWarnerSettingsPage.sliderHeight
    initialValue: -1
    minValue: 0
    maxValue: Units.usingImperial() ? 18 : 30
    anchors.left: parent.left
    anchors.right: parent.right

    valueTextFont.family: Styles.SpeedWarnerSettingsPage.textFontFamily
    valueTextFont.pixelSize: Styles.SpeedWarnerSettingsPage.sliderValueFontSize

    unitTextFont.family: Styles.SpeedWarnerSettingsPage.textFontFamily
    unitTextFont.pixelSize: Styles.SpeedWarnerSettingsPage.sliderUnitFontSize

    unit: Units.getCurrentSpeedUnit()
}

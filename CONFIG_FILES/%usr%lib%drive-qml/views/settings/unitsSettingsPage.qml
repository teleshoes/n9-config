import QtQuick 1.1
import components 1.0
import "../../components/components.js" as Components
import models 1.0


Page {
    id: root
    title: qsTrId("qtn_drive_units_hdr")
    scrollableList: list
    property variant appSettings: modelFactory.getModel("AppSettingsModel")
    property variant guidanceSettings: modelFactory.getModel("GuidanceSettingsModel")

    CheckableGroup {
        id: group
    }

    VisualItemModel {
        id: listModel

        ButtonItem {
            id: unitMetricItem
            itemId: "metric"
            title: qsTrId("qtn_drive_metrics_item")
            iconUrl:  "../../resources/listitems/units_metric.png"
            subtitle: qsTrId("qtn_drive_units_metric_subitem")
            style: Components.RadioButton
            group: group
        }

        ButtonItem {
            id: unitImpUKItem
            itemId: "impUK"
            title: qsTrId("qtn_drive_imperial_uk_item")
            iconUrl:  "../../resources/listitems/units_UK.png"
            subtitle: qsTrId("qtn_drive_units_imperial_uk_subitem")
            style: Components.RadioButton
            group: group
        }

        ButtonItem {
            id: unitImpUSItem
            itemId: "impUS"
            title: qsTrId("qtn_drive_imperial_us_item")
            iconUrl:  "../../resources/listitems/units_US.png"
            subtitle: {
                var text;
                if (isActive) {
                    text = qsTrId("qtn_drive_units_imperial_us_subitem");
                } else {
                    var voiceSkinModel = modelFactory.getModel("VoiceSkinModel"),
                        voiceSkinId = Number(guidanceSettings.getVoiceSkinId()),
                        localizedSkin = voiceSkinModel.getLocalVoiceSkin(voiceSkin),
                        localizedSkinTitle = localizedSkin ? localizedSkin.language : qsTrId("qtn_drive_voice_none");
                    text = qsTrId("qtn_drive_not_available_for_subitem").replace("[§]", localizedSkinTitle);
                }

                return text;
            }
            style: Components.RadioButton
            group: group
            isActive: guidanceSettings.voiceSkinSupportsImpUS(guidanceSettings.voiceSkinId)
        }
    }

    List {
        id: list
        listModel: listModel
        anchors.top: titleBottom
        width: parent.width
        height: parent.height - titleBox.height
        onItemClicked: {
            var selectedUnit = (itemId == "impUS" ? appSettings.units_impUS :
                               (itemId == "impUK" ? appSettings.units_impUK : appSettings.units_metric));
            appSettings.setUnitSystem(selectedUnit);
            window.pop(params.invokingPage);
        }
    }

    onBeforeShow: {
        var unitSystem = appSettings.getUnitSystem(),
            itemToSelect = (unitSystem == appSettings.units_impUS ? unitImpUSItem :
                           (unitSystem == appSettings.units_impUK ? unitImpUKItem : unitMetricItem));
        itemToSelect.buttonChecked = true;
    }
}

import QtQuick 1.1
import MapsPlugin 1.0
import components 1.0
import "../../components/components.js" as Components

Page {
    id: page
    title: qsTrId("qtn_drive_place_categories_hdr")
    scrollableList: list
    property variant mapSettingsModel
    property string originalSettings: ""

    ListModel {
        id: listModel
    }

    List {
        id: list
        anchors.top: titleBottom
        width: parent.width
        height: parent.height - titleBox.height

        listModel: listModel
        delegate: Component {
            ButtonItem  {
                itemId: id
                title: categoryTitle
                index: indx
                centerIcon: true
                iconUrl: imageUrl
                checkable: true
                buttonChecked: turnOn
                style: Components.CheckBox
            }
        }

        onItemClicked: {
            var poi = listModel.get(index);
            poi.turnOn = !poi.turnOn;
            mapSettingsModel.changePoiVisibility(itemId);
        }
    }

    onBeforeShow: {
        mapSettingsModel = modelFactory.getModel("MapSettingsModel");
        if (firstShow) populatePlacesList();

        page.originalSettings = mapSettingsModel.serializePois();
    }

    function onNavigateButtonClicked() {
        if (page.originalSettings != mapSettingsModel.serializePois()) {
            window.pop(params.invokingPage);
        }
    }

    function populatePlacesList() {
        var pois = mapSettingsModel.getPoiCategories();

        for (var i = 0, len = pois.length; i < len; i++) {
            var poi = pois[i];

            poi.imageUrl = "image://poi/" + poi.id;
            poi.indx = i;

            listModel.append(poi);
        }
    }
}

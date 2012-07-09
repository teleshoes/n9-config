.pragma library

var models = []
var modelParent;
var settingsManager;

function getModel(model) {
    if (models[model] === null || models[model] === undefined) {
        var component = Qt.createComponent(model + ".qml");

        //console.log("Error loading model " + component.url + ", error: " + component.errorString());

        models[model] = component.createObject(modelParent);
    }

    return models[model];
}

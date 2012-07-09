import QtQuick 1.1
import "ModelFactory.js" as ModelFactoryEngine

Item {
    id: modelFactory
    property variant standByModel

    function getModel(modelName) {
        return ModelFactoryEngine.getModel(modelName);
    }

    Component.onCompleted: {
        ModelFactoryEngine.modelParent = modelFactory;
        ModelFactoryEngine.settingsManager = settingsManager;
        standByModel = Qt.createQmlObject("import QtQuick 1.1; QtObject{}", modelFactory);
    }
}

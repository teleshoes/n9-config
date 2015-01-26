import QtQuick 1.1

Rectangle {
  id: main
  width: 1; height: 1 //retarded hack to get resizing to work
  function navToPage(page){
    accountPage.visible = false
    headerPage.visible = false
    bodyPage.visible = false
    if(page == accountPage){
      controller.setupAccounts()
      backButton.visible = false
      moreButton.visible = false
    }else if(page == headerPage){
      backButton.visible = true
      moreButton.visible = true
    }else if(page == bodyPage){
      backButton.visible = true
      moreButton.visible = false
    }
    page.visible = true
  }
  function backPage(){
    if(headerPage.visible){
      navToPage(accountPage);
    }else if(bodyPage.visible){
      navToPage(headerPage);
    }
  }
  Rectangle {
    anchors.top: parent.top
    anchors.bottom: toolBar.top
    width: parent.width
    Rectangle {
      id: accountPage
      anchors.fill: parent
      anchors.margins: 30
      ListView {
        id: accountView
        spacing: 50
        anchors.fill: parent
        model: accountModel
        delegate: Component  {
          Rectangle {
            height: 150
            width: parent.width
            MouseArea{
              anchors.fill: parent
              onClicked: {
                controller.accountSelected(model.account)
                main.navToPage(headerPage)
              }
            }
            Text {
              anchors.centerIn: parent
              text: model.account.Name + ": " + model.account.Unread
              font.pointSize: 36
            }
          }
        }
      }
    }

    Rectangle {
      id: headerPage
      anchors.fill: parent
      visible: false
      anchors.margins: 30
      ListView {
        id: headerView
        spacing: 10
        anchors.fill: parent
        model: headerModel
        delegate: Component  {
          Rectangle {
            color: "#AAAAAA"
            height: 125
            width: parent.width
            MouseArea {
              anchors.fill: parent
              onClicked: {
                bodyText.text = controller.getBodyText(model.header)
                navToPage(bodyPage)
              }
            }
            Column {
              id: col
              anchors.fill: parent
              Text {
                text: model.header.From
                font.pointSize: 24
              }
              Text {
                text: model.header.Date
                font.pointSize: 20
              }
              Text {
                text: model.header.Subject
                font.pointSize: 16
                wrapMode: Text.Wrap
              }
            }
          }
        }
      }
    }

    Rectangle {
      id: bodyPage
      visible: false
      anchors.fill: parent
      anchors.margins: 30

      Flickable {
        id: bodyView
        contentWidth: bodyText.paintedWidth
        contentHeight: bodyText.paintedHeight
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        Rectangle{
          anchors.fill: parent
          color: "#DDDDDD"
          Text {
            id: bodyText
            anchors.fill: parent
            font.pointSize: 24
          }
        }
      }
    }
  }

  Rectangle {
    id: toolBar
    anchors.bottom: parent.bottom
    height: backButton.height
    width: parent.width
    Row {
      spacing: 10
      Btn {
        id: backButton
        text: "back"
        onClicked: main.backPage()
        visible: false
      }
      Btn {
        id: moreButton
        text: "more"
        onClicked: controller.moreHeaders()
        visible: false
      }
    }
  }
}

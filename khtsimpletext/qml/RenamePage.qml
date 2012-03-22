import QtQuick 1.1
import com.nokia.meego 1.0
import "components"
import 'common.js' as Common

Page {
    id: root

    property string filePath;
    property string fileName;

    tools: commonTools

    PageHeader {
        id: header
        title: 'KhtSimpleText : Rename'
        subtitle: Common.beautifulPath(filePath);
    }

    Column {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 12
        spacing: 12

        Label {
            text: 'Rename ' + fileName + ' to :'
        }

        TextField {
            id: inputField
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: fileName
        }

        Button {
            anchors.left: parent.left
            anchors.right: parent.right
            enabled: inputField.text != ""
            text: "Rename"
            onClicked: {
                pageStack.pop();
                if (!QmlFileReaderWriter.rename(filePath + fileName, filePath + inputField.text))
                      errorRenameBanner.show();
            }
        }
    }
}
import QtQuick 1.1
import com.nokia.meego 1.0
import 'components'
import 'common.js' as Common

Page {
    tools: editTools
    id: editPage

    property int index
    property bool modified;

    function exitFile() {
        modified = false;
        pageStack.pop();
    }

    function saveFile() {
        DocumentsModel.writeDocument(index, textEditor.text);
    }

    QueryDialog {
                id:unsavedDialog
                titleText:"Unsaved"
                icon: Qt.resolvedUrl('../icons/khtsimpletext.png')
                message:"Did you want to save file before closing it ?";
                acceptButtonText: 'Save';
                rejectButtonText: 'Close';
                onRejected: { exitFile(); }
                onAccepted: { saveFile();exitFile(); }
                }

        PageHeader {
         id: header
         title: 'KhtSimpleText'
         subtitle: Common.beautifulPath(DocumentsModel.currentDocumentFilepath);
    }

     BusyIndicator {
        id: busyindicator
        platformStyle: BusyIndicatorStyle { size: "large" }
        running: DocumentsModel.currentDocumentReady ? false : true;
        opacity: DocumentsModel.currentDocumentReady ? 0.0 : 1.0;
        anchors.centerIn: parent
    }

    Flickable {
         id: flick
         opacity: DocumentsModel.currentDocumentReady ? 1.0 : 0.0
         flickableDirection: Flickable.HorizontalAndVerticalFlick
         //boundsBehavior: Flickable.DragOverBounds
         anchors.top: header.bottom
         anchors.left: parent.left
         anchors.leftMargin: -2
         anchors.right: parent.right
         anchors.rightMargin: -2
         anchors.bottom: parent.bottom
         anchors.bottomMargin: -2
         anchors.topMargin: -2
         clip: true

         contentWidth: textEditor.width
         contentHeight: textEditor.height
         pressDelay: 200


             KhtTextArea {
                 id: textEditor
                 anchors.top: parent.top
                 anchors.left: parent.left
                 text: Document.data
                 height: paintedHeight + 28
                 width: paintedWidth + 28
                 wrapMode: TextEdit.NoWrap
                 inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                 textFormat: TextEdit.AutoText
                 font { bold: false; family: Settings.fontFamily; pixelSize: Settings.fontSize;}
                 onTextChanged: { modified = true; autoTimer.restart() }
                 opacity: 1.0
         }
         Timer {
            id: autoTimer
            interval: 10000
            onTriggered:{
                var index = textEditor.cursorPosition;
                textEditor.text = DocumentsModel.recolorIt(textEditor.text);
                textEditor.cursorPosition = index;
            } 
            
         }

         
         onOpacityChanged: {
           if (flick.opacity == 1.0) modified = false;
         }
     }

    ScrollDecorator {
        flickableItem: flick
        platformStyle: ScrollDecoratorStyle {
        }}

    Menu {
        id: editMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: qsTr("About"); onClicked: pushAbout()}
            MenuItem { text: qsTr("MarkDown Preview"); onClicked: pageStack.push(previewPage, {atext:textEditor.text}); }
            MenuItem { text: qsTr("ReHighlight Text"); onClicked:{ textEditor.text = DocumentsModel.recolorIt(textEditor.text);} }
            MenuItem { text: qsTr("Save"); onClicked: saveFile()}
            /*MenuItem { text: qsTr("Preferences"); onClicked: notYetAvailableBanner.show(); }*/
        }
    }

    ToolBarLayout {
        id: editTools
        visible: true
        ToolIcon {
            platformIconId: "toolbar-back"
            anchors.left: (parent === undefined) ? undefined : parent.left
            onClicked: {
                   if (modified == true ) unsavedDialog.open();
                   else exitFile();
                   }
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (editMenu.status === DialogStatus.Closed) ? editMenu.open() : editMenu.close()
        }
    }
}



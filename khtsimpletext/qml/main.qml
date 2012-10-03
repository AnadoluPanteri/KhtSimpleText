import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'components'
import 'common.js' as Common

PageStackWindow {
    id: appWindow

    initialPage: fileBrowserPage

    MainPage {
        id: fileBrowserPage
        objectName: 'fileBrowserPage'
    }


    ItemMenu {
        id: itemMenu
    }

    ToolBarLayout {
        id: mainTools
        visible: true
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (myMenu.status === DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }


    ToolBarLayout {
        id: commonTools
        visible: false
        ToolIcon {
            platformIconId: "toolbar-back"
            anchors.left: (parent === undefined) ? undefined : parent.left
            onClicked: pageStack.pop();
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (myMenu.status === DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }


    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: qsTr("About"); onClicked: pushAbout()}
            MenuItem { text: qsTr("New File"); onClicked: {
                       var newFilePage = Qt.createComponent(Qt.resolvedUrl("NewFilePage.qml"));
                       pageStack.push(newFilePage, {filePath: DocumentsModel.currentpath});
                       }
            }
            MenuItem { text: qsTr("New Folder");onClicked: {
                       var newFolderPage = Qt.createComponent(Qt.resolvedUrl("NewFolderPage.qml"));
                       pageStack.push(newFolderPage, {filePath: DocumentsModel.currentpath});
                       }
            }
            MenuItem { text: qsTr("Report a bug");onClicked: {
                       Qt.openUrlExternally('https://github.com/khertan/KhtSimpleText/issues/new');
                       }
            }
            MenuItem { text: qsTr("Preferences"); onClicked: {
                      var editingPage = Qt.createComponent(Qt.resolvedUrl("EditPage.qml"));
                      Document.filepath = '/home/user/.khtsimpletext.cfg';
                      Document.load();
                      pageStack.push(editingPage, {index: -1, 
                                                   modified: false}); 
                    }
            }
        }
    }

    InfoBanner{
                      id:notYetAvailableBanner
                      text: 'This feature is not yet available'
                      timerShowTime: 5000
                      timerEnabled:true
                      anchors.top: parent.top
                      anchors.topMargin: 60
                      anchors.horizontalCenter: parent.horizontalCenter
                 }

    InfoBanner{
                      id:errorBanner
                      text: 'An error occur while creating new folder'
                      timerShowTime: 15000
                      timerEnabled:true
                      anchors.top: parent.top
                      anchors.topMargin: 60
                      anchors.horizontalCenter: parent.horizontalCenter
                 }

    function onError(errMsg) {
        errorEditBanner.text = errMsg;
        errorEditBanner.show();
    }

    InfoBanner{
                      id:errorEditBanner
                      text: ''
                      timerShowTime: 15000
                      timerEnabled:true
                      anchors.top: parent.top
                      anchors.topMargin: 60
                      anchors.horizontalCenter: parent.horizontalCenter
                 }

   showStatusBar: true

    QueryDialog {
        property string filepath
        id: deleteQueryDialog
        icon: Qt.resolvedUrl('../icons/khtsimpletext.png')
        titleText: "Delete"
        message: "Are you sure you want to delete : " + Common.beautifulPath(filepath) + '?'
        acceptButtonText: qsTr("Delete")
        rejectButtonText: qsTr("Cancel")
        onAccepted: {
                if (!(QmlDirReaderWriter.rm(filepath))) {
                    errorBanner.text = 'An error occur while deleting item';
                    errorBanner.show();
                }
                else {fileBrowserPage.refresh();}
        }
    }

    function pushAbout() {
        pageStack.push(Qt.createComponent(Qt.resolvedUrl("components/AboutPage.qml")),
             {
                          title : 'KhtSimpleText ' + __version__,
                          iconSource: Qt.resolvedUrl('../icons/khtsimpletext.png'),
                          slogan : 'Code everywhere !',
                          text : 
                             'A simple plain text editor with Syntax Highlighting.' +
                             '\nWeb Site : http://khertan.net/khtsimpletext' +
                             '\n\nBy Benoît HERVIER (Khertan)' +
                             '\nLicenced under GPLv3' +
                             '\n\nReport bugs on http://github.com/khertan/KhtSimpleText/Issues' 
             }
             );
    }                

    //State used to detect when we should refresh view
    states: [
            State {
                        name: "fullsize-visible"
                        when: platformWindow.viewMode == WindowState.Fullsize && platformWindow.visible
                        StateChangeScript {
                                 script: {
                                 console.log('objectName:'+pageStack.currentPage.objectName);
                                 if (pageStack.currentPage.objectName == 'fileBrowserPage') {
                                 pageStack.currentPage.refresh();}
                                 }       }
                  }
            ]
}

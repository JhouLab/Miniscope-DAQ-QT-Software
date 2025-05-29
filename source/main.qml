import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0

Window {
    id: root
    objectName: "windowMain"
    visible: true
    width: 720
    height: 720
    color: "#afafaf"
    title: qsTr("Miniscope DAQ")



    FileDialog {
        // Used to select user config file

        id: fileDialog
        title: "Please choose a user configuration file."
        folder: shortcuts.home
        nameFilters: [ "JSON files (*.json)", "All files (*)" ]
        onAccepted: {
            // Send file name to c++ backend
            backend.userConfigFileName = fileDialog.currentFile  // fileUrl
            treeView.visible = true;
            view.visible = false;
            //            rbRun.enabled = true
        }
        onRejected: {
            console.log("Canceled")
        }
        visible: false
    }


    FileDialog {
        // Used to save config file

        id: fileSaveDialog
        title: "Please choose file to save to."
        nameFilters: [ "JSON files (*.json)", "All files (*)" ]
        fileMode: FileDialog.SaveFile
        defaultSuffix: "json"
        onAccepted: {
            // Send file name to c++ backend
            backend.userSaveConfigFileName = fileSaveDialog.currentFile  // fileUrl
        }
        onRejected: {
            console.log("Canceled")
        }
        visible: false
    }

    Window {
        id: helpDialog
        width: 600
        height: 200
        visible: false
        title: "Miniscope DAQ Help"
        ColumnLayout {
            anchors.fill: parent

            TextArea {
                text: "Miniscope DAQ Software version " + backend.versionNumber + "<br/>" +
                      "Your OpenGL verions: " + OpenGLInfo.majorVersion + "." + OpenGLInfo.minorVersion + "<br/>" +
                      "Developed by the <a href='https://aharoni-lab.github.io/'>Aharoni Lab</a>, UCLA <br/> " +
                      "Overview of the UCLA Miniscope project: <a href='http://www.miniscope.org'>click here</a> <br/>" +
                      "Miniscope Wiki for newest projects: <a href='https://github.com/Aharoni-Lab/Miniscope-v4/wiki'>click here</a> <br/>" +
                      "Miniscope Discussion Board: <a href='https://groups.google.com/d/forum/miniscope'>click here</a> <br/>" +
                      "Please submit issues, comments, suggestions to the Miniscope DAQ Software Github Repository: <a href='https://github.com/Aharoni-Lab/Miniscope-DAQ-QT-Software'>click here</a> <br/>" +
                      "Miniscope Twitter Link: <a href='https://twitter.com/MiniscopeTeam'>click here</a> <br/> <br/>" +
                      "Icons from <a href='https://icons8.com/'>icon8</a>"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.margins: 5
                Layout.fillWidth: true
                textFormat: Text.RichText
                onLinkActivated: Qt.openUrlExternally(link)
                font.pointSize: 12
                font.family: "Arial"
                wrapMode: Text.WordWrap
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
            Button {
                text: "Close"
                font.family: "Arial"
                font.pointSize: 12
                font.bold: true
                font.weight: Font.Normal
                background: Rectangle {
                    id: closeRect
                    border.width: 1
                    color: "#a8a7fd"
                }
                Layout.margins: 5
                Layout.fillWidth: true
                onClicked: helpDialog.visible = false
                onHoveredChanged: hovered ? closeRect.color = "#f8a7fd" : closeRect.color = "#a8a7fd"
            }
        }
    }

    MessageDialog {
        id: errorMessageDialog
        title: "User Config File Error"
        text: "The selected user configuration file contains device name repeats. Please edit the file the so each 'deviceName' entry is unique."
        onAccepted: {
            visible = false
        }
        visible: false
    }

    MessageDialog {
        id: errorMessageDialogCompression
        title: "User Config File Error"
        text: "The selected user configuration file contains video compression(s) that are not supported by your computer. Please edit the file so each 'compression' entry is a supported option from the following list: " + backend.availableCodecList
        onAccepted: {
            visible = false
        }
        visible: false
    }

    MessageDialog {
        id: saveMessageDialog
        property string fName: backend.userConfigFileName
        title: "User Config File Saved"
        text:  "The user config file has been saved with *_new.json extension to " + fName.replace(".json", "_new.json")
        onAccepted: {
            visible = false
        }
        visible: false
    }


    ColumnLayout {
        id: columnLayout
        anchors.rightMargin: 10
        anchors.leftMargin: 10
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        spacing: 10
        anchors.fill: parent

        RowLayout {
            id: rowLayoutTop
            height: 40
            Layout.minimumHeight: 40
            Layout.preferredHeight: 40
            Layout.fillHeight: false
            Layout.fillWidth: true
            spacing: 10


            RoundButton {
                id: rbSelectUserConfig
                height: 40
                text: "Select Config File"
                Layout.minimumHeight: 40
                Layout.preferredHeight: 40
                Layout.fillHeight: false
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillWidth: true
                font.family: "Arial"
                font.pointSize: 18
                font.bold: true
                font.weight: Font.Normal
                radius: 10

                Layout.minimumWidth: 20
                Layout.preferredWidth: 300
                Layout.maximumWidth: 600

                background: Rectangle {
                    id: configRect
                    radius: rbSelectUserConfig.radius
                    border.width: 1
                    color: "#a8a7fd"
                }
                onClicked: fileDialog.visible = true //(1)
                onHoveredChanged: hovered ? configRect.color = "#f8a7fd" : configRect.color = "#a8a7fd"

            }

            RoundButton {
                id: rbSaveUserConfig
                height: 40
                text: "Save Config As"
                Layout.minimumHeight: 40
                Layout.preferredHeight: 40
                Layout.fillHeight: false
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillWidth: true
                font.family: "Arial"
                font.pointSize: 18
                font.bold: true
                font.weight: Font.Normal
                radius: 10
                enabled: backend.userConfigOK

                Layout.minimumWidth: 150
                Layout.preferredWidth: 250
                Layout.maximumWidth: 700

                background: Rectangle {
                    id: configSaveRect
                    radius: rbSaveUserConfig.radius
                    border.width: 1
                    color: "#a8a7fd"
                }
                onClicked: {

                    console.log(backend.userConfigFolderName)
                    fileSaveDialog.folder = backend.getConfigFolder()
                    // fileSaveDialog.currentFile = backend.getConfigFileName()   // File name has prepended forward slash, which messes things up. Skip for now.
                    fileSaveDialog.visible = true   // setVisible(1)
                }
                onHoveredChanged: hovered ? configSaveRect.color = "#f8a7fd" : configSaveRect.color = "#a8a7fd"

            }
        }
        TabBar {
            id: tabBar
            width: 240
            transformOrigin: Item.Center
            Layout.preferredHeight: 40
            Layout.fillWidth: true

            TabButton {
                id: tabButtonShowInfo
                x: 0
                y: 0
                width: 345
                height: 40
                text: qsTr("Show Info")
                transformOrigin: Item.Center
                onClicked: {
                    view.visible = true
                    treeView.visible = false
                }
            }

            TabButton {
                id: tabButtonShowConfig
                y: 0
                width: 355
                height: 40
                text: qsTr("Show Config")
                scale: 1
                anchors.left: parent.left
                anchors.leftMargin: 345
                onClicked: {
                    view.visible = false
                    treeView.visible = true
                }
            }
        }

        ColumnLayout {
            spacing: 5
            TreeViewerJSON {
                id: treeView
                objectName: "treeView"
                model: backend.jsonTreeModel

                visible: false
                Layout.rowSpan: 4
                Layout.fillHeight: true

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter



            }
            ScrollView {
                id: view2
                ScrollBar.horizontal.interactive: true
                ScrollBar.vertical.interactive: true

                visible: treeView.visible
                Layout.maximumHeight: 100
                Layout.minimumHeight: 30
                Layout.preferredHeight: 40
                Layout.fillHeight: true

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                TextArea {
                    ScrollBar {
                        enabled: true
                    }

                    text: "<b>Tool Tip:</b> " + treeView.toolTipText
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignTop
                    visible: treeView.visible

                    //                height: 200
                    Layout.fillHeight: true

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    readOnly: true
                    wrapMode: TextArea.WordWrap
                    textFormat: Text.RichText
                    font.pointSize: 12
                }
            }
        }


        ScrollView {
            id: view
            objectName: "view"
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.minimumHeight: 80
            Layout.preferredHeight: 80
            Layout.fillHeight: true
            Layout.rowSpan: 4
            ScrollBar.horizontal.interactive: true
            ScrollBar.vertical.interactive: true

            TextArea {
                id: taConfigDesc
                text: backend.userConfigDisplay
                //                wrapMode: Text.NoWrap
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                //                anchors.fill: parent
                font.pointSize: 12
                readOnly: true
                background: Rectangle {
                    radius: rbSelectUserConfig.radius
                    anchors.fill: parent
                    border.width: 1
                    color: "#ebebeb"
                }

                DropArea {
                    id: drop
                    anchors.fill: parent
                    onDropped: {
                        // Send file name to c++ backend
                        if (drop.hasUrls) {
                            backend.userConfigFileName = drop.urls[0];
                            backend.userConfigFileNameChanged();
                            treeView.visible = true;
                            view.visible = false;

                        }
                        //            rbRun.enabled = true
                    }
                }
            }

        }

        RoundButton {
            id: rbRun
            height: 40
            radius: 10
            text: "Run"
            enabled: backend.userConfigOK
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredHeight: 40
            font.family: "Arial"
            font.bold: true
            font.pointSize: 18
            Layout.minimumHeight: 40
            Layout.fillHeight: false
            font.weight: Font.Normal
            background: Rectangle {
                id: runRect
                color: "#a8a7fd"
                radius: rbRun.radius
                border.width: 1
            }

            Layout.fillWidth: true
            onClicked: backend.onRunClicked()
            onHoveredChanged: hovered ? runRect.color = "#f8a7fd" : runRect.color = "#a8a7fd"
        }

        RowLayout {
            id: rowLayout
            height: 40
            Layout.minimumHeight: 40
            Layout.preferredHeight: 40
            Layout.fillHeight: false
            Layout.fillWidth: true
            spacing: 10

            RoundButton {
                id: rbHelp
                height: 40
                radius: 10
                text: "Help"
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.family: "Arial"
                font.pointSize: 18
                font.bold: true
                font.weight: Font.Normal
                background: Rectangle {
                    id: helpRect
                    color: "#a8a7fd"
                    radius: rbSelectUserConfig.radius
                    border.width: 1
                }
                onClicked: {
                    helpDialog.visible = true
                }
                onHoveredChanged: hovered ? helpRect.color = "#f8a7fd" : helpRect.color = "#a8a7fd"
            }

            RoundButton {
                id: rbExit
                height: 40
                text: "Exit"
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                radius: 10
                font.family: "Arial"
                font.pointSize: 18
                font.bold: true
                font.weight: Font.Normal
                background: Rectangle {
                    id: exitRect
                    radius: rbSelectUserConfig.radius
                    border.width: 1
                    color: "#a8a7fd"
                }
                onHoveredChanged: hovered ? exitRect.color = "#f8a7fd" : exitRect.color = "#a8a7fd"
                onClicked: backend.exitClicked()
                //                onClicked: Qt.quit()
            }
        }


    }

    Connections{
        target: backend
        onShowErrorMessage: errorMessageDialog.visible = true
    }
    Connections{
        target: backend
        onShowErrorMessageCompression: errorMessageDialogCompression.visible = true
    }
    Component.onCompleted: {
        setX(Screen.width / 2 - width / 2);
        setY(Screen.height / 2 - height / 2);
    }
}

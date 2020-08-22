import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.15
import QtQuick.Controls 1.4
import QtQuick.Controls 2.15

import "assets/components/"

Window {
    id: mainWindow

    property double aspectRatio: (screen.width / screen.height)
    property int startHeight: (screen.height / 2)
    property bool isLandscapeMode: (mainWindow.width > mainWindow.height)
    // FOR TESTING ONLY
    height: 720
    width: 1280

    //    height: mainWindow.startHeight // 100%
    //    width: mainWindow.startHeight * mainWindow.aspectRatio

    minimumHeight: (mainWindow.startHeight / 2) + (mainWindow.startHeight / 4) // 75%
    minimumWidth: mainWindow.minimumHeight * mainWindow.aspectRatio

    maximumHeight: screen.height // 200%
    maximumWidth: mainWindow.maximumHeight * mainWindow.aspectRatio

    visible: true
    title: qsTr("Hello World")

    Component.onCompleted: {
        setX(screen.width/2 - mainWindow.width/2)
        setY(screen.height/2 - mainWindow.height/2)
    }

    color: "#31363b"

    ShaderEffect {
        height: mainWindow.height
        width: mainWindow.width

        fragmentShader: "
    varying highp vec2 qt_TexCoord0;
    void main() {
        gl_FragColor = vec4(0, qt_TexCoord0.x, qt_TexCoord0.y, 1.0);
    }";
    }

    FontLoader { id: sanFransicoPro; source: "assets/fonts/sf-pro-text-regular.otf" }

    //    flags: Qt.FramelessWindowHint TODO: Make an OP border system

    GridLayout {
        id : mainGridLayout
        anchors.margins: 10
        anchors.fill: parent
        focus: true
        columns: mainWindow.isLandscapeMode ? 5 : 1
        rows: mainWindow.isLandscapeMode ? 1 : 5

        ImageUI {
            id: origImageUI
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Original Image"
        }

        Label {
            id: plusLabel
            Layout.alignment: Qt.AlignCenter

            font.bold: true
            font.pixelSize: origImageUI.titleSize
            color: "#eff0f1"
            text: "+"
        }

        ImageUI {
            id: payloadImageUI
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Payload Image"
        }

        GridLayout {
            id: flowGridLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter

            columns: mainWindow.isLandscapeMode ? 1 : 3
            rows: mainWindow.isLandscapeMode ? 3 : 1

            Button {
                id: backwardLabel
                opacity: 0.8
                flat: true
                font.bold: true
                font.pixelSize: origImageUI.titleSize * 2

                text: "<font color='#eff0f1'>" + (mainWindow.isLandscapeMode ? "\u21e6" : "\u21e7") + "</font>"
                //                onClicked: imageProc.doStuff();
            }

            TextField {
                id: bitCountTextField

                Layout.preferredWidth: backwardLabel.width
                horizontalAlignment: TextInput.AlignHCenter

                background: Item {
                    Rectangle {
                        id: bitCountBackgroundRectangle
                        anchors.fill: parent
                        color:  "#88000000"
                    }
                }

                validator: IntValidator { bottom: 1 ; top: 3 }

                font.bold: true
                color: "#eff0f1"
                placeholderText: "<b>Bits (1/2/3)</b>"

                ToolTip.text: "Number of bits to use for the process (1- poor payload quality, 2, 3- best payload quality)"

                onFocusChanged: bitCountTextField.ToolTip.visible = (bitCountTextField.focus !== Boolean(Qt.NoFocus))

                onTextEdited: {
                    if (bitCountTextField.acceptableInput) {
                        bitCountTextField.state = "acceptable"
                    } else {
                        bitCountTextField.state = ""
                    }
                }

                states: [
                    State {
                        name: "acceptable"
                        PropertyChanges { target: bitCountBackgroundRectangle; color: "#8800cc00" }
                        PropertyChanges { target: bitCountTextField; ToolTip.visible: false }
                    }
                ]
            }

            Button {
                id: forwardLabel
                opacity: 0.7
                flat: true
                font.bold: true
                font.pixelSize: origImageUI.titleSize * 2

                text: "<font color='#eff0f1'>" + (mainWindow.isLandscapeMode ? "\u21e8" : "\u21e9") + "</font"
                onClicked: {
                    var returnCode = imageProc.hideImage();
                    if (returnCode === 0) {
                        console.log("hideImage returned successfully");
                    } else {
                        console.log("hideImage had an error!", returnCode);
                    }
                }
            }
        }


        ImageUI {
            id: resultImageUI
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Result"
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_Escape) {
                mainWindow.close();
                event.accepted = true;
            }
        }


        // Bindings for ImageProc members
        Binding {
            target: imageProc
            property: "originalImageUrl"
            value: origImageUI.imageSource
        }

        Binding {
            target: imageProc
            property: "payloadImageUrl"
            value: payloadImageUI.imageSource
        }

        Binding {
            target: imageProc
            property: "resultImageUrl"
            value: resultImageUI.imageSource
        }

        Binding {
            target: imageProc
            property: "bitCount"
            value: if (bitCountTextField.acceptableInput) parseInt(bitCountTextField.text)
        }
    }
}



/*##^##
Designer {
    D{i:0;formeditorZoom:0.75}
}
##^##*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 640
    height: 480

    // Background Image
    Image {
        id: bgImage
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        clip: true
    }

    // Gruvbox dark overlay tint
    Rectangle {
        anchors.fill: parent
        color: "#c01d2021" // Semi-transparent dark Gruvbox hard color
    }

    // Top Clock and Date
    Column {
        id: clockContainer
        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        Text {
            id: timeText
            font.family: "Inter"
            font.pixelSize: 84
            font.bold: true
            color: "#ebdbb2" // Gruvbox fg
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: dateText
            font.family: "Inter"
            font.pixelSize: 18
            font.weight: Font.DemiBold
            color: "#a89984" // Gruvbox gray
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                var date = new Date();
                timeText.text = Qt.formatTime(date, "HH:mm");
                dateText.text = Qt.formatDate(date, "dddd, d MMMM yyyy");
            }
        }
    }

    // Central Login Panel
    Rectangle {
        id: loginPanel
        width: 360
        height: 290
        anchors.centerIn: parent
        color: "#3c3836" // Gruvbox bg1
        border.color: "#504945" // Gruvbox bg2
        border.width: 1.5
        radius: 20

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 16

            // User Welcome Label
            Text {
                text: "Chào hieunx"
                font.family: "Inter"
                font.pixelSize: 22
                font.bold: true
                color: "#ebdbb2"
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 4
            }

            // Password Field
            TextField {
                id: passwordInput
                placeholderText: "Nhập mật khẩu"
                echoMode: TextInput.Password
                font.family: "Inter"
                font.pixelSize: 14
                color: "#ebdbb2"
                placeholderTextColor: "#928374"
                Layout.preferredWidth: 280
                Layout.preferredHeight: 46
                Layout.alignment: Qt.AlignHCenter
                focus: true
                leftPadding: 16
                rightPadding: 16
                verticalAlignment: TextInput.AlignVCenter

                background: Rectangle {
                    color: "#282828" // Gruvbox bg
                    border.color: passwordInput.activeFocus ? "#8ec07c" : "#504945" // Aqua active border
                    border.width: passwordInput.activeFocus ? 2 : 1
                    radius: 12
                }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        tryLogin();
                        event.accepted = true;
                    }
                }
            }

            // Caps Lock Warning
            Text {
                text: "⚠️ Caps Lock đang bật!"
                font.family: "Inter"
                font.pixelSize: 11
                font.bold: true
                color: "#fb4934" // Gruvbox red
                visible: keyboard ? keyboard.capsLock : false
                Layout.alignment: Qt.AlignHCenter
            }

            // Login Button
            Button {
                id: loginBtn
                text: "ĐĂNG NHẬP"
                Layout.preferredWidth: 280
                Layout.preferredHeight: 46
                Layout.alignment: Qt.AlignHCenter

                contentItem: Text {
                    text: loginBtn.text
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.bold: true
                    color: "#282828"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: loginBtn.hovered ? "#a9b665" : "#8ec07c" // Aqua -> Greenish on hover
                    radius: 12
                    scale: loginBtn.pressed ? 0.98 : (loginBtn.hovered ? 1.02 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }

                onClicked: tryLogin()
            }

            // Status/Error text
            Text {
                id: errorMessage
                text: ""
                font.family: "Inter"
                font.pixelSize: 12
                font.bold: true
                color: "#fb4934"
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // Bottom Navigation Bar
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 40
        anchors.rightMargin: 40

        // Session Selection Dropdown
        Row {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: "Môi trường:"
                font.family: "Inter"
                font.pixelSize: 12
                color: "#a89984"
                anchors.verticalCenter: parent.verticalCenter
            }

            ComboBox {
                id: sessionBox
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex
                width: 140
                height: 32
                anchors.verticalCenter: parent.verticalCenter

                background: Rectangle {
                    color: "#3c3836"
                    border.color: sessionBox.hovered ? "#8ec07c" : "#504945"
                    border.width: 1
                    radius: 6
                }

                contentItem: Text {
                    text: sessionBox.displayText
                    font.family: "Inter"
                    font.pixelSize: 11
                    font.bold: true
                    color: "#ebdbb2"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 8
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        // Power Options
        Row {
            spacing: 15
            Layout.alignment: Qt.AlignVCenter

            Button {
                id: rebootBtn
                text: "Khởi động lại"
                height: 32

                contentItem: Text {
                    text: rebootBtn.text
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.bold: true
                    color: rebootBtn.hovered ? "#ebdbb2" : "#a89984"
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle { color: "transparent" }
                onClicked: sddm.reboot()
            }

            Button {
                id: shutdownBtn
                text: "Tắt máy"
                height: 32

                contentItem: Text {
                    text: shutdownBtn.text
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.bold: true
                    color: shutdownBtn.hovered ? "#fb4934" : "#a89984"
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle { color: "transparent" }
                onClicked: sddm.powerOff()
            }
        }
    }

    // SDDM Authentication signals
    Connections {
        target: sddm
        function onLoginSucceeded() {
            // Standard success
        }
        function onLoginFailed() {
            errorMessage.text = "Mật khẩu không chính xác!";
            passwordInput.text = "";
            passwordInput.forceActiveFocus();
        }
    }

    Component.onCompleted: {
        passwordInput.forceActiveFocus();
    }

    function tryLogin() {
        var username = userModel.lastUser ? userModel.lastUser : "hieunx";
        errorMessage.text = "";
        sddm.login(username, passwordInput.text, sessionBox.currentIndex);
    }
}

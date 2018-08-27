import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: appearancePage

    property alias cfg_boldFontWeight: boldFontWeight.checked
    property alias cfg_showWindowIcon: showWindowIcon.checked
    property alias cfg_iconAndTextSpacing: iconAndTextSpacing.value
    property alias cfg_titleReplacements: titleReplacements.text

    property alias cfg_noWindowText: noWindowText.text
    property string cfg_noWindowIcon: plasmoid.configuration.noWindowIcon

    GridLayout {
        columns: 2

        Label {
            text: i18n('Plasmoid version: ') + '0.0.1'
            Layout.columnSpan: 2
        }

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }

        GridLayout {
            columns: 2

            Layout.columnSpan: 2

            CheckBox {
                id: boldFontWeight
                text: i18n("Bold text")
                Layout.columnSpan: 2
            }

            CheckBox {
                id: showWindowIcon
                text: i18n("Show window icon")
                Layout.columnSpan: 2
            }

            Label {
                text: i18n("Spacing:")
            }
            SpinBox {
                id: iconAndTextSpacing
                decimals: 1
                stepSize: 0.5
                minimumValue: 0
                maximumValue: 100
            }

            Label {
                text: i18n('Replacements: \n "orig 1", "new 1"; "orig 2", "new 2"; ...')
                wrapMode: Text.Wrap
            }
            TextArea {
                id: titleReplacements
                text: '"Mozilla ", ""; "Google ", ""; ": Chromium", " — Chromium"; " Player", ""'
                onTextChanged: cfg_titleReplacements = text
                Layout.preferredWidth: 500
            }

        }

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }

        GridLayout {
            columns: 2

            Label {
              text: i18n('No window text: \n (use %activity% for activity name)')
                wrapMode: Text.Wrap
            }
            TextField {
                id: noWindowText
                placeholderText: 'plasma-kde@%activity%'
                onTextChanged: cfg_noWindowText = text
                Layout.preferredWidth: 300
            }

            Label {
                text: i18n("No window icon:")
            }
            IconPicker {
                currentIcon: cfg_noWindowIcon
                defaultIcon: ''
                onIconChanged: cfg_noWindowIcon = iconName
            }
        }

    }

}

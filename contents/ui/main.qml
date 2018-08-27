/*
 * Copyright 2018  avlas <jsardid@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.activities 0.1 as Activities

Item {
    id: main

    property bool noWindowActive: true
    property bool mouseHover: false
    property var activeTaskLocal: null
    property string tooltipText: ''

    anchors.fill: parent

    Layout.fillWidth: false
    Layout.minimumWidth: activeWindow.width
    Layout.maximumWidth: activeWindow.width

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    //
    // MODEL
    //
    TaskManager.TasksModel {
        id: tasksModel

        onActiveTaskChanged: {
            updateActiveWindowInfo()
        }
        onDataChanged: {
            updateActiveWindowInfo()
        }
        onCountChanged: {
            updateActiveWindowInfo()
        }
    }

    TaskManager.ActivityInfo {
        id: activityInfo

        onCurrentActivityChanged: {
            if (noWindowActive) {
                updateActiveWindowInfo();
            }
        }
    }

    Activities.ActivityModel {
        id: activityModel
    }

    function activeTask() {
        return activeTaskLocal
    }

    function activeTaskExists() {
        return activeTaskLocal.display !== undefined
    }

    function updateTooltip() {
        tooltipText = activeTask().display || ''
    }

    function composeNoWindowText() {
        return plasmoid.configuration.noWindowText.replace('%activity%', activityInfo.activityName(activityInfo.currentActivity))
    }

    function updateActiveWindowInfo() {

        var activeTaskIndex = tasksModel.activeTask

        var abstractTasksModel = TaskManager.AbstractTasksModel
        var isActive = abstractTasksModel.IsActive

        if (!tasksModel.data(activeTaskIndex, isActive)) {
            activeTaskLocal = {}
        } else {
            activeTaskLocal = {
                display: tasksModel.data(activeTaskIndex, Qt.DisplayRole),
                decoration: tasksModel.data(activeTaskIndex, Qt.DecorationRole),
            }
        }

        var actTask = activeTask()
        noWindowActive = !activeTaskExists()
        if (noWindowActive) {
            windowTitleText.text = composeNoWindowText()
            iconItem.source = plasmoid.configuration.noWindowIcon
        } else {
            windowTitleText.text = reverseTitleOrder(fineTuning(actTask.display))
            iconItem.source = actTask.decoration
        }
        updateTooltip()
    }

    //
    // ACTIVE WINDOW INFO
    //
    Item {
        id: activeWindow

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        anchors.leftMargin: plasmoid.configuration.iconAndTextSpacing
        anchors.rightMargin: plasmoid.configuration.iconAndTextSpacing

        width: plasmoid.configuration.showWindowIcon ? anchors.leftMargin + iconItem.width + plasmoid.configuration.iconAndTextSpacing + windowTitleText.width + anchors.rightMargin : anchors.leftMargin + windowTitleText.width + anchors.rightMargin

        Item {
            height: main.height

            // window icon
            PlasmaCore.IconItem {
                id: iconItem

                anchors.left: parent.left
                height: parent.height

                source: plasmoid.configuration.noWindowIcon
                visible: plasmoid.configuration.showWindowIcon
            }

            // window title
            PlasmaComponents.Label {
                id: windowTitleText

                anchors.left: parent.left
                anchors.leftMargin: plasmoid.configuration.showWindowIcon ? iconItem.width + plasmoid.configuration.iconAndTextSpacing : 0
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                height: parent.height
                text: plasmoid.configuration.noWindowText
                wrapMode: Text.NoWrap
                elide: Text.ElideNone
                font.weight: plasmoid.configuration.boldFontWeight ? Font.Bold : theme.defaultFont.weight
            }

        }
    }

    function reverseTitleOrder(title) {

        var revTitle;
        var lastPos = title.lastIndexOf(" — "); //  U+2014 "EM DASH"
        if (lastPos > -1) {
            revTitle = title.slice(lastPos + 3, title.length);
        }
        else {
            lastPos = title.lastIndexOf(" – "); // U+2013 "EN DASH"
            if (lastPos > -1) {
                revTitle = title.slice(lastPos + 3, title.length);
            }
            else {
                lastPos = title.lastIndexOf(" - "); // ASCII Dash
                if (lastPos > -1) {
                    revTitle = title.slice(lastPos + 3, title.length);
                }
                else {
                    lastPos = title.lastIndexOf(": "); // semicolon
                    if (lastPos > -1) {
                        revTitle = title.slice(lastPos + 2, title.length);
                    }
                    else
                        revTitle = title;
                }
            }
        }
        return revTitle;
    }

    function fineTuning(title) {

        var replacements = plasmoid.configuration.titleReplacements;

        replacements = replacements.replace(/; | ;/g, ";");
        replacements = replacements.replace(/, | ,/g, ",");

        var appReplacements = replacements.split(";");

        for (var iReplacement = 0; iReplacement < appReplacements.length; iReplacement++){
            appReplacements[iReplacement] = appReplacements[iReplacement].replace(/"/g, "");

            var repText = appReplacements[iReplacement].split(",");

            title = title.replace(repText[0],repText[1]);
        }
        return title;
    }

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true

        onEntered: {
            mouseHover = true
        }

        onExited: {
            mouseHover = false
        }

        PlasmaCore.ToolTipArea {

            anchors.fill: parent

            active: tooltipText !== ''
            interactive: true
            location: plasmoid.location

            mainItem: Row {

                spacing: 0

                Layout.minimumWidth: fullText.width + units.largeSpacing
                Layout.minimumHeight: childrenRect.height
                Layout.maximumWidth: Layout.minimumWidth
                Layout.maximumHeight: Layout.minimumHeight

                Item {
                    width: units.largeSpacing / 2
                    height: 2
                }

                PlasmaComponents.Label {
                    id: fullText
                    text: tooltipText
                }
            }
        }
    }
}

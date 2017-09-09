/*
 *  Copyright 2013 Marco Martin <mart@kde.org>
 *  Copyright 2014 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.5
import QtQuick.Controls 1.0 as QtControls
import QtQuick.Dialogs 1.1 as QtDialogs
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0 // for Screen
//We need units from it
import org.kde.plasma.core 2.0 as Plasmacore
import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import org.kde.kquickcontrolsaddons 2.0

ColumnLayout {
    id: root
    property alias cfg_Color: colorDialog.color
    property string cfg_Image
    property int cfg_FillMode
    property var cfg_SlidePaths: ""
    property int cfg_SlideInterval: 0
    property int cfg_AnimationDuration: 400
    property int cfg_TickInterval: 10000
    property double cfg_TickDelta: 0.05

    function saveConfig() {
        imageWallpaper.commitDeletion();
    }

    SystemPalette {
        id: syspal
    }

    Wallpaper.Image {
        id: imageWallpaper
        targetSize: {
            if (typeof plasmoid !== "undefined") {
                return Qt.size(plasmoid.width, plasmoid.height)
            }
            // Lock screen configuration case
            return Qt.size(Screen.width, Screen.height)
        }
        onSlidePathsChanged: cfg_SlidePaths = slidePaths
    }

    onCfg_SlidePathsChanged: {
        imageWallpaper.slidePaths = cfg_SlidePaths
    }

    property int hoursIntervalValue: Math.floor(cfg_SlideInterval / 3600)
    property int minutesIntervalValue: Math.floor(cfg_SlideInterval % 3600) / 60
    property int secondsIntervalValue: cfg_SlideInterval % 3600 % 60

    //Rectangle { color: "orange"; x: formAlignment; width: formAlignment; height: 20 }

    TextMetrics {
        id: textMetrics
        text: "00"
    }

    Row {
        //x: formAlignment - positionLabel.paintedWidth
        spacing: units.largeSpacing / 2
        QtControls.Label {
            id: positionLabel
            width: formAlignment - units.largeSpacing
            anchors {
                verticalCenter: resizeComboBox.verticalCenter
            }
            text: i18nd("plasma_applet_org.kde.image", "Positioning:")
            horizontalAlignment: Text.AlignRight
        }
        QtControls.ComboBox {
            id: resizeComboBox
            property int textLength: 24
            width: theme.mSize(theme.defaultFont).width * textLength
            model: [
                        {
                            'label': i18nd("plasma_applet_org.kde.image", "Scaled and Cropped"),
                            'fillMode': Image.PreserveAspectCrop
                        },
                        {
                            'label': i18nd("plasma_applet_org.kde.image","Scaled"),
                            'fillMode': Image.Stretch
                        },
                        {
                            'label': i18nd("plasma_applet_org.kde.image","Scaled, Keep Proportions"),
                            'fillMode': Image.PreserveAspectFit
                        },
                        {
                            'label': i18nd("plasma_applet_org.kde.image", "Centered"),
                            'fillMode': Image.Pad
                        },
                        {
                            'label': i18nd("plasma_applet_org.kde.image","Tiled"),
                            'fillMode': Image.Tile
                        }
                    ]

            textRole: "label"
            onCurrentIndexChanged: cfg_FillMode = model[currentIndex]["fillMode"]
            Component.onCompleted: setMethod();

            function setMethod() {
                for (var i = 0; i < model.length; i++) {
                    if (model[i]["fillMode"] == wallpaper.configuration.FillMode) {
                        resizeComboBox.currentIndex = i;
                        var tl = model[i]["label"].length;
                        //resizeComboBox.textLength = Math.max(resizeComboBox.textLength, tl+5);
                    }
                }
            }
        }
    }

    QtDialogs.ColorDialog {
        id: colorDialog
        modality: Qt.WindowModal
        showAlphaChannel: false
        title: i18nd("plasma_applet_org.kde.image", "Select Background Color")
    }

    Row {
        id: colorRow
        spacing: units.largeSpacing / 2
        QtControls.Label {
            width: formAlignment - units.largeSpacing
            anchors.verticalCenter: colorButton.verticalCenter
            horizontalAlignment: Text.AlignRight
            text: i18nd("plasma_applet_org.kde.image", "Background Color:")
        }
        QtControls.Button {
            id: colorButton
            width: units.gridUnit * 3
            text: " " // needed to it gets a proper height...
            onClicked: colorDialog.open()

            Rectangle {
                id: colorRect
                anchors.centerIn: parent
                width: parent.width - 2 * units.smallSpacing
                height: theme.mSize(theme.defaultFont).height
                color: colorDialog.color
            }
        }
    }


    Component {
        id: thumbnailsComponent
        QtControls.ScrollView {
            anchors.fill: parent

            frameVisible: true
            highlightOnFocus: true;

            Component.onCompleted: {
                //replace the current binding on the scrollbar that makes it visible when content doesn't fit

                //otherwise we adjust gridSize when we hide the vertical scrollbar and
                //due to layouting that can make everything adjust which changes the contentWidth/height which
                //changes our scrollbars and we continue being stuck in a loop

                //looks better to not have everything resize anyway.
                //BUG: 336301
                __verticalScrollBar.visible = true
            }

            GridView {
                id: wallpapersGrid
                model: imageWallpaper.wallpaperModel
                currentIndex: -1
                focus: true

                cellWidth: Math.floor(wallpapersGrid.width / Math.max(Math.floor(wallpapersGrid.width / (units.gridUnit*12)), 1))
                cellHeight: Math.round(cellWidth / (imageWallpaper.targetSize.width / imageWallpaper.targetSize.height))

                anchors.margins: 4
                boundsBehavior: Flickable.StopAtBounds

                delegate: WallpaperDelegate {
                    color: cfg_Color
                }

                onContentHeightChanged: {
                    wallpapersGrid.currentIndex = imageWallpaper.wallpaperModel.indexOf(cfg_Image);
                    wallpapersGrid.positionViewAtIndex(wallpapersGrid.currentIndex, GridView.Visible)
                }

                Keys.onPressed: {
                    if (count < 1) {
                        return;
                    }

                    if (event.key == Qt.Key_Home) {
                        currentIndex = 0;
                    } else if (event.key == Qt.Key_End) {
                        currentIndex = count - 1;
                    }
                }

                Keys.onLeftPressed: moveCurrentIndexLeft()
                Keys.onRightPressed: moveCurrentIndexRight()
                Keys.onUpPressed: moveCurrentIndexUp()
                Keys.onDownPressed: moveCurrentIndexDown()

                Connections {
                    target: imageWallpaper
                    onCustomWallpaperPicked: {
                        wallpapersGrid.currentIndex = 0
                    }
                }

            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true

        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: thumbnailsComponent
        }

        ColumnLayout {
            Layout.minimumWidth: parent.width / 3
            Layout.preferredWidth: parent.width / 3
            Layout.maximumWidth: parent.width * 2/3
            Layout.fillHeight: true

            RowLayout {
                QtControls.Label {
                    text: i18n("Change hue by ")
                }
                QtControls.SpinBox {
                    id: tickDeltaSpinBox
                    value: cfg_TickDelta
                    onValueChanged: cfg_TickDelta = value
                    decimals: 2
                    stepSize: 0.05
                    minimumValue: 0.00 // No change
                    maximumValue: 0.99 // "1" will also be no change, so prevent the user from selecting it.
                }
                QtControls.Label {
                    text: i18n(" over ")
                }
                QtControls.SpinBox {
                    id: animationDurationSpinBox
                    value: cfg_AnimationDuration
                    onValueChanged: cfg_AnimationDuration = value
                    maximumValue: 2000000000
                    stepSize: 100
                    suffix: i18n("ms")
                }
            }
            RowLayout {
                QtControls.Label {
                    text: i18n(" every ")
                }
                QtControls.SpinBox {
                    decimals: cfg_TickInterval % 1000 == 0 ? 0 : 3
                    value: cfg_TickInterval / 1000
                    onValueChanged: cfg_TickInterval = value * 1000
                    minimumValue: 1
                    maximumValue: 2000000000
                    stepSize: 1
                    suffix: i18n("sec")
                }
                QtControls.Label {
                    text: "("
                }
                QtControls.SpinBox {
                    id: tickIntervalSpinBox
                    value: cfg_TickInterval
                    onValueChanged: cfg_TickInterval = value
                    minimumValue: 1000
                    maximumValue: 2000000000
                    stepSize: 1000
                    suffix: i18n("ms")
                }
                QtControls.Label {
                    text: ")"
                }
            }
            

            HslShiftedWallpaper {
                id: previewImage
                Layout.fillWidth: true
                Layout.fillHeight: true

                source: cfg_Image
                fillMode: Image.PreserveAspectFit
                running: false
            }

            QtControls.Label {
                Layout.fillWidth: true
                text: i18n("Hue: %1", previewImage.hue)
            }

            QtControls.Slider {
                Layout.fillWidth: true
                // defaults to a real range of [0..1]
                // value: previewImage.hue
                onValueChanged: previewImage.hue = value
            }
        }
    }

    RowLayout {
        id: buttonsRow
        anchors {
            right: parent.right
        }
        QtControls.Button {
            iconName: "document-open-folder"
            text: i18nd("plasma_applet_org.kde.image","Open...")
            onClicked: imageWallpaper.showFileDialog();
        }
        QtControls.Button {
            iconName: "get-hot-new-stuff"
            text: i18nd("plasma_applet_org.kde.image","Get New Wallpapers...")
            onClicked: imageWallpaper.getNewWallpaper();
        }
    }
}

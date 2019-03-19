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
import QtQuick.Controls 2.3 as QtControls2
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0 // for Screen
//We need units from it
import org.kde.plasma.core 2.0 as Plasmacore
import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import org.kde.kquickcontrols 2.0 as KQuickControls
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kconfig 1.0 // for KAuthorized
import org.kde.draganddrop 2.0 as DragDrop
import org.kde.kcm 1.1 as KCM
import org.kde.kirigami 2.5 as Kirigami

ColumnLayout {
    id: root
    property alias cfg_Color: colorButton.color
    property string cfg_Image
    property int cfg_FillMode
    property alias cfg_Blur: blurRadioButton.checked
    property var cfg_SlidePaths: ""
    property int cfg_SlideInterval: 0

    property int cfg_AnimationDuration: 400
    property int cfg_BlurRadius: 40

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
        QtControls2.Label {
            id: positionLabel
            width: formAlignment - units.largeSpacing
            anchors {
                verticalCenter: resizeComboBox.verticalCenter
            }
            text: i18nd("plasma_wallpaper_org.kde.image", "Positioning:")
            horizontalAlignment: Text.AlignRight
        }

        // TODO: port to QQC2 version once we've fixed https://bugs.kde.org/show_bug.cgi?id=403153
        QtControls.ComboBox {
            id: resizeComboBox
            TextMetrics {
                id: resizeTextMetrics
                text: resizeComboBox.currentText
            }
            width: resizeTextMetrics.width + Kirigami.Units.smallSpacing * 2 + Kirigami.Units.gridUnit * 2
            model: [
                {
                    'label': i18nd("plasma_wallpaper_org.kde.image", "Scaled and Cropped"),
                    'fillMode': Image.PreserveAspectCrop
                },
                {
                    'label': i18nd("plasma_wallpaper_org.kde.image", "Scaled"),
                    'fillMode': Image.Stretch
                },
                {
                    'label': i18nd("plasma_wallpaper_org.kde.image", "Scaled, Keep Proportions"),
                    'fillMode': Image.PreserveAspectFit
                },
                {
                    'label': i18nd("plasma_wallpaper_org.kde.image", "Centered"),
                    'fillMode': Image.Pad
                },
                {
                    'label': i18nd("plasma_wallpaper_org.kde.image", "Tiled"),
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

    QtControls2.ButtonGroup { id: backgroundGroup }

    Row {
        id: blurRow
        spacing: units.largeSpacing / 2
        visible: cfg_FillMode === Image.PreserveAspectFit || cfg_FillMode === Image.Pad
        QtControls2.Label {
            id: blurLabel
            width: formAlignment - units.largeSpacing
            anchors.verticalCenter: blurRadioButton.verticalCenter
            horizontalAlignment: Text.AlignRight
            text: i18nd("plasma_wallpaper_org.kde.image", "Background:")
        }
        QtControls2.RadioButton {
            id: blurRadioButton
            text: i18nd("plasma_wallpaper_org.kde.image", "Blur")
            QtControls2.ButtonGroup.group: backgroundGroup
        }
    }

    Row {
        id: colorRow
        visible: cfg_FillMode === Image.PreserveAspectFit || cfg_FillMode === Image.Pad
        spacing: units.largeSpacing / 2
        QtControls2.Label {
            width: formAlignment - units.largeSpacing
        }
        QtControls2.RadioButton {
            id: colorRadioButton
            text: i18nd("plasma_wallpaper_org.kde.image", "Solid color")
            QtControls2.ButtonGroup.group: backgroundGroup
            checked: !cfg_Blur
        }
        KQuickControls.ColorButton {
            id: colorButton
            dialogTitle: i18nd("plasma_wallpaper_org.kde.image", "Select Background Color")
        }
    }

    Row {
        id: inactiveBlurRow
        spacing: units.largeSpacing / 2
        QtControls2.Label {
            width: formAlignment - units.largeSpacing
            anchors.verticalCenter: blurRadiusSpinBox.verticalCenter
            horizontalAlignment: Text.AlignRight
            text: i18n("Blur:")
        }
        QtControls2.Label {
            anchors.verticalCenter: blurRadiusSpinBox.verticalCenter
            text: i18n(" by ")
        }
        QtControls2.SpinBox {
            id: blurRadiusSpinBox
            value: cfg_BlurRadius
            onValueChanged: cfg_BlurRadius = value
            stepSize: 1
            from: 1
            to: 2000000000
            editable: true
        }
        QtControls2.Label {
            anchors.verticalCenter: blurRadiusSpinBox.verticalCenter
            text: i18n(" over ")
        }
        QtControls2.SpinBox {
            id: animationDurationSpinBox
            value: cfg_AnimationDuration
            onValueChanged: cfg_AnimationDuration = value
            from: 0
            to: 2000000000
            stepSize: 100
            editable: true
            textFromValue: function(value, locale) {
                // var x = Number(value).toLocaleString(locale, 'f', 0);
                return i18n("%1ms", value)
            }
        }

    }


    Component {
        id: thumbnailsComponent
        KCM.GridView {
            id: wallpapersGrid
            anchors.fill: parent

            //that min is needed as the module will be populated in an async way
            //and only on demand so we can't ensure it already exists
            view.currentIndex: Math.min(imageWallpaper.wallpaperModel.indexOf(cfg_Image), imageWallpaper.wallpaperModel.count-1)
            //kill the space for label under thumbnails
            view.model: imageWallpaper.wallpaperModel
            view.delegate: WallpaperDelegate {
                color: cfg_Color
            }
        }
    }

    Loader {
        Layout.fillWidth: true
        Layout.fillHeight: true
        sourceComponent: thumbnailsComponent
    }

    RowLayout {
        id: buttonsRow
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        QtControls2.Button {
            icon.name: "list-add"
            text: i18nd("plasma_wallpaper_org.kde.image","Add Image...")
            onClicked: imageWallpaper.showFileDialog();
        }
        QtControls2.Button {
            icon.name: "get-hot-new-stuff"
            text: i18nd("plasma_wallpaper_org.kde.image","Get New Wallpapers...")
            visible: KAuthorized.authorize("ghns")
            onClicked: imageWallpaper.getNewWallpaper(this);
        }
    }
}

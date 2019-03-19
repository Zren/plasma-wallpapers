/*
 *  Copyright 2013 Marco Martin <mart@kde.org>
 *  Copyright 2014 Sebastian Kügler <sebas@kde.org>
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

import QtQuick 2.0
import QtQuick.Controls.Private 1.0
import QtGraphicalEffects 1.0
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.4 as Kirigami
import org.kde.kcm 1.1 as KCM

KCM.GridDelegate {
    id: wallpaperDelegate

  
    property alias color: backgroundRect.color
    property bool selected: (wallpapersGrid.currentIndex == index)
    opacity: model.pendingDeletion ? 0.5 : 1

    text: model.display
    
    toolTip: model.author.length > 0 ? i18nd("plasma_wallpaper_org.kde.image", "%1 by %2", model.display, model.author) : ""

    hoverEnabled: true

    actions: [
        Kirigami.Action {
            icon.name: "document-open-folder"
            tooltip: i18nd("plasma_wallpaper_org.kde.image", "Open Containing Folder")
            onTriggered: imageWallpaper.wallpaperModel.openContainingFolder(index)
        },
        Kirigami.Action {
            icon.name: "edit-undo"
            visible: model.pendingDeletion
            tooltip: i18nd("plasma_wallpaper_org.kde.image", "Restore wallpaper")
            onTriggered: imageWallpaper.wallpaperModel.setPendingDeletion(index, !model.pendingDeletion)
        },
        Kirigami.Action {
            icon.name: "edit-delete"
            tooltip: i18nd("plasma_wallpaper_org.kde.image", "Remove Wallpaper")
            visible: model.removable && !model.pendingDeletion
            onTriggered: {
                imageWallpaper.wallpaperModel.setPendingDeletion(index, true);
                if (wallpapersGrid.currentIndex === index) {
                    wallpapersGrid.currentIndex = (index + 1) % wallpapersGrid.count;
                }
            }
        }
    ]

    thumbnail: Rectangle {
        id: backgroundRect
        color: cfg_Color
        anchors.fill: parent

        QIconItem {
            anchors.centerIn: parent
            width: units.iconSizes.large
            height: width
            icon: "view-preview"
            visible: !walliePreview.visible
        }

        QPixmapItem {
            id: blurBackgroundSource
            visible: cfg_Blur
            anchors.fill: parent
            smooth: true
            pixmap: model.screenshot
            fillMode: QPixmapItem.PreserveAspectCrop
        }

        FastBlur {
            visible: cfg_Blur
            anchors.fill: parent
            source: blurBackgroundSource
            radius: 4
        }

        QPixmapItem {
            id: walliePreview
            anchors.fill: parent
            visible: model.screenshot != null
            smooth: true
            pixmap: model.screenshot
            fillMode: {
                if (cfg_FillMode == Image.Stretch) {
                    return QPixmapItem.Stretch;
                } else if (cfg_FillMode == Image.PreserveAspectFit) {
                    return QPixmapItem.PreserveAspectFit;
                } else if (cfg_FillMode == Image.PreserveAspectCrop) {
                    return QPixmapItem.PreserveAspectCrop;
                } else if (cfg_FillMode == Image.Tile) {
                    return QPixmapItem.Tile;
                } else if (cfg_FillMode == Image.TileVertically) {
                    return QPixmapItem.TileVertically;
                } else if (cfg_FillMode == Image.TileHorizontally) {
                    return QPixmapItem.TileHorizontally;
                }
                return QPixmapItem.PreserveAspectFit;
            }
        }

        FastBlur {
            id: wallieBlurPreview
            anchors.fill: parent
            source: walliePreview
            visible: radius > 0
            radius: wallpaperDelegate.hovered ? cfg_BlurRadius : 0

            Behavior on radius {
                NumberAnimation { duration: cfg_AnimationDuration }
            }
        }
    }

    onClicked: {
        cfg_Image = model.path;
        wallpapersGrid.forceActiveFocus();
    }
}

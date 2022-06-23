// Version 3

/*
	SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
	SPDX-FileCopyrightText: 2014 Kai Uwe Broulik <kde@privat.broulik.de>

	SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.0
import QtQuick.Controls.Private 1.0
import QtQuick.Controls 2.3 as QtControls2
import QtGraphicalEffects 1.0
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.4 as Kirigami
import org.kde.kcm 1.1 as KCM

KCM.GridDelegate {
	id: wallpaperDelegate

	property alias color: backgroundRect.color
	property bool selected: (wallpapersGrid.currentIndex === index)
	opacity: model.pendingDeletion ? 0.5 : 1

	text: model.display
	
	toolTip: model.author.length > 0 ? i18ndc("plasma_wallpaper_org.kde.image", "<image> by <author>", "By %1", model.author) : ""

	hoverEnabled: true

	actions: [
		Kirigami.Action {
			icon.name: "document-open-folder"
			tooltip: i18nd("plasma_wallpaper_org.kde.image", "Open Containing Folder")
			onTriggered: imageModel.openContainingFolder(index)
		},
		Kirigami.Action {
			icon.name: "edit-undo"
			visible: model.pendingDeletion
			tooltip: i18nd("plasma_wallpaper_org.kde.image", "Restore wallpaper")
			onTriggered: imageModel.setPendingDeletion(index, !model.pendingDeletion)
		},
		Kirigami.Action {
			icon.name: "edit-delete"
			tooltip: i18nd("plasma_wallpaper_org.kde.image", "Remove Wallpaper")
			visible: model.removable && !model.pendingDeletion && !cfg_Slideshow
			onTriggered: {
				imageModel.setPendingDeletion(index, true);
				if (wallpapersGrid.currentIndex === index) {
					wallpapersGrid.currentIndex = (index + 1) % wallpapersGrid.rowCount();
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
			visible: model.screenshot !== null
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

		// --- inactiveblur ---
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
		// -------------------

		QtControls2.CheckBox {
			visible: cfg_Slideshow
			anchors.right: parent.right
			anchors.top: parent.top
			checked: visible ? model.checked : false
			onToggled: imageWallpaper.toggleSlide(model.path, checked)
		}
	}

	onClicked: {
		if (!cfg_Slideshow) {
			cfg_Image = model.path;
		}
		view.currentIndex = index;
	}
}

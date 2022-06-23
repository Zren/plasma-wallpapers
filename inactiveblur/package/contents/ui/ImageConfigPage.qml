// Version 3

/*
	SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
	SPDX-FileCopyrightText: 2014 Kai Uwe Broulik <kde@privat.broulik.de>

	SPDX-License-Identifier: GPL-2.0-or-later
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
	property int cfg_SlideshowMode
	property alias cfg_Blur: blurRadioButton.checked
	property var cfg_SlidePaths: ""
	property int cfg_SlideInterval: 0
	property var cfg_UncheckedSlides: []

	property alias cfg_Slideshow: slideshowCheckBox.checked

	function saveConfig() {
		imageWallpaper.commitDeletion();
	}

	SystemPalette {
		id: syspal
	}

	Wallpaper.ImageBackend {
		id: imageWallpaper
		targetSize: {
			if (typeof plasmoid !== "undefined") {
				return Qt.size(plasmoid.width, plasmoid.height)
			}
			// Lock screen configuration case
			return Qt.size(Screen.width, Screen.height)
		}
		onSlidePathsChanged: cfg_SlidePaths = slidePaths
		onUncheckedSlidesChanged: cfg_UncheckedSlides = uncheckedSlides
		onSlideshowModeChanged: cfg_SlideshowMode = slideshowMode
	}

	onCfg_SlidePathsChanged: {
		imageWallpaper.slidePaths = cfg_SlidePaths
	}
	onCfg_UncheckedSlidesChanged: {
		imageWallpaper.uncheckedSlides = cfg_UncheckedSlides
	}
	onCfg_SlideshowModeChanged: {
		imageWallpaper.slideshowMode = cfg_SlideshowMode
	}

	property int hoursIntervalValue: Math.floor(cfg_SlideInterval / 3600)
	property int minutesIntervalValue: Math.floor(cfg_SlideInterval % 3600) / 60
	property int secondsIntervalValue: cfg_SlideInterval % 3600 % 60

	//Rectangle { color: "orange"; x: formAlignment; width: formAlignment; height: 20 }

	Kirigami.FormLayout {
		id: twinFormLayout
		twinFormLayouts: parentLayout
		QtControls2.ComboBox {
			id: resizeComboBox
			Kirigami.FormData.label: i18nd("plasma_wallpaper_org.kde.image", "Positioning:")
			model: [
				{
					'label': i18nd("plasma_wallpaper_org.kde.image", "Scaled and Cropped"),
					'fillMode': Image.PreserveAspectCrop
				},
				{
					'label': i18nd("plasma_wallpaper_org.kde.image","Scaled"),
					'fillMode': Image.Stretch
				},
				{
					'label': i18nd("plasma_wallpaper_org.kde.image","Scaled, Keep Proportions"),
					'fillMode': Image.PreserveAspectFit
				},
				{
					'label': i18nd("plasma_wallpaper_org.kde.image", "Centered"),
					'fillMode': Image.Pad
				},
				{
					'label': i18nd("plasma_wallpaper_org.kde.image","Tiled"),
					'fillMode': Image.Tile
				}
			]

			textRole: "label"
			onCurrentIndexChanged: cfg_FillMode = model[currentIndex]["fillMode"]
			Component.onCompleted: setMethod();

			function setMethod() {
				for (var i = 0; i < model.length; i++) {
					if (model[i]["fillMode"] === wallpaper.configuration.FillMode) {
						resizeComboBox.currentIndex = i;
						var tl = model[i]["label"].length;
						//resizeComboBox.textLength = Math.max(resizeComboBox.textLength, tl+5);
					}
				}
			}
		}

		QtControls2.ButtonGroup { id: backgroundGroup }

		QtControls2.RadioButton {
			id: blurRadioButton
			visible: cfg_FillMode === Image.PreserveAspectFit || cfg_FillMode === Image.Pad
			Kirigami.FormData.label: i18nd("plasma_wallpaper_org.kde.image", "Background:")
			text: i18nd("plasma_wallpaper_org.kde.image", "Blur")
			QtControls2.ButtonGroup.group: backgroundGroup
		}

		RowLayout {
			id: colorRow
			visible: cfg_FillMode === Image.PreserveAspectFit || cfg_FillMode === Image.Pad
			QtControls2.RadioButton {
				id: colorRadioButton
				text: i18nd("plasma_wallpaper_org.kde.image", "Solid color")
				checked: !cfg_Blur
				QtControls2.ButtonGroup.group: backgroundGroup
			}
			KQuickControls.ColorButton {
				id: colorButton
				dialogTitle: i18nd("plasma_wallpaper_org.kde.image", "Select Background Color")
			}
		}
	}

	default property alias contentData: contentLayout.data
	Kirigami.FormLayout {
		id: contentLayout
		twinFormLayouts: parentLayout
	}

	Kirigami.FormLayout {
		id: slideshowRow
		twinFormLayouts: parentLayout
		QtControls2.CheckBox {
			id: slideshowCheckBox
			Kirigami.FormData.label: i18n("Slideshow:")
		}
	}

	Component {
		id: foldersComponent
		ColumnLayout {
			Connections {
				target: root
				onHoursIntervalValueChanged: hoursInterval.value = root.hoursIntervalValue
				onMinutesIntervalValueChanged: minutesInterval.value = root.minutesIntervalValue
				onSecondsIntervalValueChanged: secondsInterval.value = root.secondsIntervalValue
			}
			//FIXME: there should be only one spinbox: QtControls spinboxes are still too limited for it tough
			Kirigami.FormLayout {
				twinFormLayouts: parentLayout

				QtControls2.ComboBox {
					id: slideshowComboBox
					visible: cfg_Slideshow
					Kirigami.FormData.label: i18nd("plasma_wallpaper_org.kde.image", "Order:")
					model: [
						{
							'label': i18nd("plasma_wallpaper_org.kde.image", "Random"),
							'slideshowMode': Wallpaper.ImageBackend.Random
						},
						{
							'label': i18nd("plasma_wallpaper_org.kde.image", "A to Z"),
							'slideshowMode': Wallpaper.ImageBackend.Alphabetical
						},
						{
							'label': i18nd("plasma_wallpaper_org.kde.image", "Z to A"),
							'slideshowMode': Wallpaper.ImageBackend.AlphabeticalReversed
						},
						{
							'label': i18nd("plasma_wallpaper_org.kde.image", "Date modified (newest first)"),
							'slideshowMode': Wallpaper.ImageBackend.ModifiedReversed
						},
						{
							'label': i18nd("plasma_wallpaper_org.kde.image", "Date modified (oldest first)"),
							'slideshowMode': Wallpaper.ImageBackend.Modified
						}
					]
					textRole: "label"
					onCurrentIndexChanged: {
						cfg_SlideshowMode = model[currentIndex]["slideshowMode"]
					}
					Component.onCompleted: setMethod();
					function setMethod() {
						for (var i = 0; i < model.length; i++) {
							if (model[i]["slideshowMode"] === wallpaper.configuration.SlideshowMode) {
								slideshowComboBox.currentIndex = i
							}
						}
					}
				}

				RowLayout {
					Kirigami.FormData.label: i18nd("plasma_wallpaper_org.kde.image","Change every:")
					QtControls2.SpinBox {
						id: hoursInterval
						value: root.hoursIntervalValue
						from: 0
						to: 24
						editable: true
						onValueChanged: cfg_SlideInterval = hoursInterval.value * 3600 + minutesInterval.value * 60 + secondsInterval.value
					}
					QtControls2.Label {
						text: i18nd("plasma_wallpaper_org.kde.image","Hours")
					}
					QtControls2.SpinBox {
						id: minutesInterval
						value: root.minutesIntervalValue
						from: 0
						to: 60
						editable: true
						onValueChanged: cfg_SlideInterval = hoursInterval.value * 3600 + minutesInterval.value * 60 + secondsInterval.value
					}
					QtControls2.Label {
						text: i18nd("plasma_wallpaper_org.kde.image","Minutes")
					}
					QtControls2.SpinBox {
						id: secondsInterval
						value: root.secondsIntervalValue
						from: root.hoursIntervalValue === 0 && root.minutesIntervalValue === 0 ? 1 : 0
						to: 60
						editable: true
						onValueChanged: cfg_SlideInterval = hoursInterval.value * 3600 + minutesInterval.value * 60 + secondsInterval.value
					}
					QtControls2.Label {
						text: i18nd("plasma_wallpaper_org.kde.image","Seconds")
					}
				}
			}
			Kirigami.Heading {
				text: i18nd("plasma_wallpaper_org.kde.image","Folders")
				level: 2
			}
			GridLayout {
				columns: 2
				Layout.fillWidth: true
				Layout.fillHeight: true
				columnSpacing: Kirigami.Units.largeSpacing
				QtControls2.ScrollView {
					id: foldersScroll
					Layout.fillHeight: true
					Layout.preferredWidth: 0.25 * parent.width
					Component.onCompleted: foldersScroll.background.visible = true;
					ListView {
						id: slidePathsView
						anchors.margins: 4
						model: imageWallpaper.slidePaths
						delegate: Kirigami.SwipeListItem {
							id: folderDelegate
							actions: [
								Kirigami.Action {
									iconName: "list-remove"
									tooltip: i18nd("plasma_wallpaper_org.kde.image", "Remove Folder")
									onTriggered: imageWallpaper.removeSlidePath(modelData)
								},
								Kirigami.Action {
									icon.name: "document-open-folder"
									tooltip: i18nd("plasma_wallpaper_org.kde.image", "Open Folder")
									onTriggered: imageWallpaper.openFolder(modelData)
								}
							]
							QtControls2.Label {
								text: modelData.endsWith("/") ? modelData.split('/').reverse()[1] : modelData.split('/').pop()
								Layout.fillWidth: true
								QtControls2.ToolTip.text: modelData
								QtControls2.ToolTip.visible: folderDelegate.hovered
								QtControls2.ToolTip.delay: 1000
								QtControls2.ToolTip.timeout: 5000
							}
							width: slidePathsView.width
							height: paintedHeight;
						}
					}
				}
				Loader {
					sourceComponent: thumbnailsComponent
					Layout.fillWidth: true
					Layout.fillHeight: true
					anchors.fill: undefined
				}
				QtControls2.Button {
					Layout.alignment: Qt.AlignRight
					icon.name: "list-add"
					text: i18nd("plasma_wallpaper_org.kde.image","Add Folder...")
					onClicked: imageWallpaper.showAddSlidePathsDialog()
				}
				QtControls2.Button {
					Layout.alignment: Qt.AlignRight
					icon.name: "get-hot-new-stuff"
					text: i18nd("plasma_wallpaper_org.kde.image","Get New Wallpapers...")
					visible: KAuthorized.authorize("ghns")
					onClicked: imageWallpaper.getNewWallpaper(this);
				}
			}
		}
	}

	Component {
		id: thumbnailsComponent
		KCM.GridView {
			id: wallpapersGrid
			anchors.fill: parent
			property var imageModel: cfg_Slideshow ? imageWallpaper.slideFilterModel : imageWallpaper.wallpaperModel
			//that min is needed as the module will be populated in an async way
			//and only on demand so we can't ensure it already exists
			view.currentIndex: Math.min(imageModel.indexOf(cfg_Image), imageModel.rowCount()-1)
			//kill the space for label under thumbnails
			view.model: imageModel
			Component.onCompleted: {
				imageModel.usedInConfig = true
			}
			view.delegate: WallpaperDelegate {
				color: cfg_Color
			}
		}
	}

	DragDrop.DropArea {
		Layout.fillWidth: true
		Layout.fillHeight: true

		onDragEnter: {
			if (!event.mimeData.hasUrls) {
				event.ignore();
			}
		}
		onDrop: {
			event.mimeData.urls.forEach(function (url) {
				if (url.indexOf("file://") === 0) {
					var path = url.substr(7); // 7 is length of "file://"
					if (cfg_Slideshow) {
						imageWallpaper.addSlidePath(path);
					} else {
						imageWallpaper.addUsersWallpaper(path);
					}
				}
			});
		}

		Loader {
			anchors.fill: parent
			sourceComponent: cfg_Slideshow ? foldersComponent : thumbnailsComponent
		}
	}

	RowLayout {
		id: buttonsRow
		Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
		visible: !cfg_Slideshow
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

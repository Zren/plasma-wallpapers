/*
 *  Copyright 2013 Marco Martin <mart@kde.org>
 *  Copyright 2014 Sebastian Kügler <sebas@kde.org>
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
import QtQuick.Controls 2.1 as QQC2
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import org.kde.plasma.core 2.0 as PlasmaCore

QQC2.StackView {
    id: root

    readonly property string modelImage: imageWallpaper.wallpaperPath
    readonly property string configuredImage: wallpaper.configuration.Image
    readonly property int fillMode: wallpaper.configuration.FillMode
    readonly property string configColor: wallpaper.configuration.Color
    readonly property bool blur: wallpaper.configuration.Blur
    readonly property size sourceSize: Qt.size(root.width * Screen.devicePixelRatio, root.height * Screen.devicePixelRatio)

    //public API, the C++ part will look for those
    function setUrl(url) {
        wallpaper.configuration.Image = url
        imageWallpaper.addUsersWallpaper(url)
    }

    function action_next() {
        imageWallpaper.nextSlide()
    }

    function action_open() {
        Qt.openUrlExternally(modelImage)
    }

    //private

    onConfiguredImageChanged: {
        imageWallpaper.addUrl(configuredImage)
    }

    function updateContextMenu() {
        var action
        action = wallpaper.action("open")
        action.visible = wallpaper.configuration.Slideshow
        action = wallpaper.action("next")
        action.visible = wallpaper.configuration.Slideshow
    }

    Component.onCompleted: {
        wallpaper.setAction("open", i18nd("plasma_wallpaper_org.kde.image", "Open Wallpaper Image"), "document-open")
        wallpaper.setAction("next", i18nd("plasma_wallpaper_org.kde.image", "Next Wallpaper Image"), "user-desktop")
        updateContextMenu()
    }

    readonly property bool isSlideshow: wallpaper.configuration.Slideshow
    onIsSlideshowChanged: {
        updateContextMenu()

        // Warkaround to stop the slideshow timer
        if (isSlideshow) {
            imageWallpaper.slideTimer = Qt.binding(function(){ return wallpaper.configuration.SlideInterval })
        } else {
            imageWallpaper.slideTimer = -1
            Qt.callLater(root.configuredImageChanged) // Doesn't always work
        }
    }

    property var imageWallpaper: Wallpaper.Image {
        id: imageWallpaper
        //the oneliner of difference between image and slideshow wallpapers
        renderingMode: wallpaper.configuration.Slideshow ? Wallpaper.Image.SlideShow : Wallpaper.Image.SingleImage
        targetSize: Qt.size(root.width, root.height)
        slidePaths: wallpaper.configuration.SlidePaths
        slideTimer: wallpaper.configuration.SlideInterval
    }

    onFillModeChanged: Qt.callLater(loadImage)
    onModelImageChanged: Qt.callLater(loadImage)
    onConfigColorChanged: Qt.callLater(loadImage)
    onBlurChanged: Qt.callLater(loadImage)
    onWidthChanged: Qt.callLater(loadImage)
    onHeightChanged: Qt.callLater(loadImage)

    function loadImage() {
        var isFirst = (root.currentItem == undefined)
        var pendingImage = root.baseImage.createObject(root, {
            "source": root.modelImage,
            "fillMode": root.fillMode,
            "sourceSize": root.sourceSize,
            "color": root.configColor,
            "blur": root.blur,
            "opacity": isFirst ? 1 : 0,
        })

        function replaceWhenLoaded() {
            if (pendingImage.status != Image.Loading) {
                root.replace(pendingImage, {},
                    isFirst ? QQC2.StackView.Immediate : QQC2.StackView.Transition) // don't animate first show
                pendingImage.statusChanged.disconnect(replaceWhenLoaded)
            }
        }
        pendingImage.statusChanged.connect(replaceWhenLoaded)
        replaceWhenLoaded()
    }

    property Component baseImage: Component {
        Image {
            id: mainImage

            property alias color: backgroundColor.color
            property bool blur: false

            asynchronous: true
            cache: false
            autoTransform: true
            z: -1

            QQC2.StackView.onRemoved: destroy()

            Rectangle {
                id: backgroundColor
                anchors.fill: parent
                visible: mainImage.status === Image.Ready && !blurLoader.active
                z: -2
            }

            Loader {
                id: blurLoader
                anchors.fill: parent
                z: -3
                active: mainImage.blur && (mainImage.fillMode === Image.PreserveAspectFit || mainImage.fillMode === Image.Pad)
                sourceComponent: Item {
                    Image {
                        id: blurSource
                        anchors.fill: parent
                        asynchronous: true
                        cache: false
                        autoTransform: true
                        fillMode: Image.PreserveAspectCrop
                        source: mainImage.source
                        sourceSize: mainImage.sourceSize
                        visible: false // will be rendered by the blur
                    }

                    GaussianBlur {
                        id: blurEffect
                        anchors.fill: parent
                        source: blurSource
                        radius: 32
                        samples: 65
                        visible: blurSource.status === Image.Ready
                    }
                }
            }
        }
    }

    replaceEnter: Transition {
        OpacityAnimator {
            from: 0
            to: 1
            duration: wallpaper.configuration.TransitionAnimationDuration
        }
    }
    // Keep the old image around till the new one is fully faded in
    // If we fade both at the same time you can see the background behind glimpse through
    replaceExit: Transition {
        PauseAnimation {
            duration: wallpaper.configuration.TransitionAnimationDuration
        }
    }
}

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
import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import org.kde.plasma.core 2.0 as PlasmaCore

import QtGraphicalEffects 1.0

Item {
    id: root

    //public API, the C++ part will look for those
    function setUrl(url) {
        wallpaper.configuration.Image = url
    }

    Rectangle {
        id: backgroundColor
        anchors.fill: parent
        visible: shiftedImage.status === Image.Ready
        color: wallpaper.configuration.Color
        Behavior on color {
            ColorAnimation { duration: units.longDuration }
        }
    }

    HslShiftedWallpaper {
        id: shiftedImage
        anchors.fill: parent

        source: wallpaper.configuration.Image
        fillMode: wallpaper.configuration.FillMode

        animationDuration: Math.min(wallpaper.configuration.AnimationDuration, wallpaper.configuration.TickInterval)
        tickInterval: wallpaper.configuration.TickInterval
        tickDelta: wallpaper.configuration.TickDelta
    }
}

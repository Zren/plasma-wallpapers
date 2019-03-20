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
import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import org.kde.plasma.core 2.0 as PlasmaCore

import QtGraphicalEffects 1.0

ImageBaseMain {
    WindowModel {
        id: windowModel
        // onNoWindowActiveChanged: console.log('noWindowActive', noWindowActive)
    }

    baseImage: Component {
        BlurredWallpaper {
            id: blurredWallpaper
            blurRadius: windowModel.noWindowActive ? 0 : wallpaper.configuration.BlurRadius
            animationDuration: wallpaper.configuration.AnimationDuration

            // property url source
            // property int fillMode
            // property rect sourceSize
            // property float opacity
            property bool blur: false // Blur negative space (Ignored)
            property bool color: false // Color for negative space (Ignored)

            QQC2.StackView.onRemoved: destroy() // Causes a memory leak without this
        }
    }
}

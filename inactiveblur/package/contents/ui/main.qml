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

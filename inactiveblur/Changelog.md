## v6 - October 15 2022

* Plasma 5.25 bugfix as a class called Image was renamed to ImageBackend.
* Implement upstream Slideshow exclude image, slideshow mode.
* Code cleanup.

## v5 - October 2 2019

* Update to the Plasma 5.16 Kirigami twinFormLayout config gui. Requires Plasma Frameworks v5.53, which is only available in Ubuntu 19.04 and later.

## v4 - October 2 2019

* Fix parsing 400ms in the config spinbox. It previous only worked when using up/down arrows ever since updating to the QtQuickControls 2.0 spinboxes.

## v3 - March 20 2019

* Fix memory leak introduced in the port to the slideshow API. It is easily reproduced with the slideshow reaching 2Gb of RAM in under an hour (switching wallpapers every 10 seconds). I forgot a single line that destroyed the old image.

## v2 - March 19 2019

* Trigger blur event when a new window is created or a window is destroyed. It was previously only updating when you minimized a window or moved it (Issue #2).
* Update to the new image wallpaper config GUI
* Implement a simple toggle to enter slideshow mode (Issue #1).

## v1 - Jan 4 2018

* Wallpaper that blurs when inactive with an animation.

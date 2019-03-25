ARCHS = armv7 armv7s arm64
TARGET = iphone:clang

export THEOS_DEVICE_IP = xxx.xxx.xxx.xxx

THEOS_BUILD_DIR = Packages

PACKAGE_VERSION = 1.0

# development flag
DEBUG = 1

# production flag
# FINALPACKAGE = 1
# DEBUG = 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = OrganicEmojiScrubber
OrganicEmojiScrubber_FILES = Tweak.xm
OrganicEmojiScrubber_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"

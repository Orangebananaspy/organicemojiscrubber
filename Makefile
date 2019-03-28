ARCHS = armv7 armv7s arm64
TARGET = iphone:clang

# export THEOS_DEVICE_IP = xxx.xxx.xxx.xxx
export THEOS_DEVICE_IP = 192.168.0.102

THEOS_BUILD_DIR = Packages

PACKAGE_VERSION = 1.1

# development flag
DEBUG = 1

# production flags
# FINALPACKAGE = 1
# DEBUG = 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = OrganicEmojiScrubber
OrganicEmojiScrubber_FILES = Tweak.xm OESPreferences.m
OrganicEmojiScrubber_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
SUBPROJECTS += organicemojiscrubber
include $(THEOS_MAKE_PATH)/aggregate.mk

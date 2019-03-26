ARCHS = armv7 arm64

# iOS 10 is the maximum deployment target for 32-bit targets
TARGET = iphone::10

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = OrganicEmojiScrubber
OrganicEmojiScrubber_FILES = OESRootListController.m
OrganicEmojiScrubber_CFLAGS = -fobjc-arc
OrganicEmojiScrubber_INSTALL_PATH = /Library/PreferenceBundles
OrganicEmojiScrubber_FRAMEWORKS = UIKit
OrganicEmojiScrubber_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/OrganicEmojiScrubber.plist$(ECHO_END)

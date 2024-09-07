TARGET := iphone:clang:16.5:15.0
INSTALL_TARGET_PROCESSES = MuffinStore
ARCHS = arm64
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
PACKAGE_FORMAT = ipa

GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = MuffinStore

MuffinStore_FILES = $(wildcard *.m)
MuffinStore_FRAMEWORKS = UIKit CoreGraphics CoreServices
MuffinStore_PRIVATE_FRAMEWORKS = Preferences StoreKitUI
MuffinStore_CFLAGS = -fobjc-arc
MuffinStore_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/application.mk

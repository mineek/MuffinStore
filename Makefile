TARGET := iphone:clang:16.5:15.0
INSTALL_TARGET_PROCESSES = MuffinStore
ARCHS = arm64
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = MuffinStore

MuffinStore_FILES = $(wildcard *.m)
MuffinStore_FRAMEWORKS = UIKit CoreGraphics CoreServices
MuffinStore_PRIVATE_FRAMEWORKS = Preferences StoreKitUI
MuffinStore_CFLAGS = -fobjc-arc
MuffinStore_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/application.mk

after-package::
	@echo "Removing old files (if any)..."
	@rm -rf $(THEOS_OBJ_DIR)/Payload || true
	@rm -rf $(THEOS_OBJ_DIR)/$(APPLICATION_NAME).ipa || true
	@rm -rf $(THEOS_OBJ_DIR)/$(APPLICATION_NAME).tipa || true
	@rm -rf $(THEOS_PACKAGE_DIR)/$(APPLICATION_NAME).tipa || true
	@echo "Making .tipa..."
	@mkdir -p $(THEOS_OBJ_DIR)/Payload
	@mv $(THEOS_OBJ_DIR)/$(APPLICATION_NAME).app $(THEOS_OBJ_DIR)/Payload/$(APPLICATION_NAME).app
	@cd $(THEOS_OBJ_DIR) && zip -r $(APPLICATION_NAME).ipa Payload
	@mv $(THEOS_OBJ_DIR)/$(APPLICATION_NAME).ipa $(THEOS_OBJ_DIR)/$(APPLICATION_NAME).tipa
	@mv $(THEOS_OBJ_DIR)/$(APPLICATION_NAME).tipa $(THEOS_PACKAGE_DIR)
	@echo "Done, .tipa is at $(THEOS_PACKAGE_DIR)/$(APPLICATION_NAME).tipa"

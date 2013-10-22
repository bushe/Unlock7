export GO_EASY_ON_ME = 1
include theos/makefiles/common.mk

TWEAK_NAME = Unlock7
Unlock7_FILES = Tweak.xm
Unlock7_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

PRODUCT_NAME=ChurchDesk
WORKSPACE=$(PRODUCT_NAME).xcworkspace
SCHEME=$(PRODUCT_NAME)
CONFIGURATION=Release
SDK=iphoneos


APP_OUT_PATH=build/Products/$(CONFIGURATION)-$(SDK)/$(PRODUCT_NAME).app
ARGS=-workspace $(WORKSPACE) -scheme $(SCHEME) -configuration $(CONFIGURATION) -sdk $(SDK)

.PHONY: all build clean bump

all: bump clean build

ci: clean build

clean:
	-rm -rf pkg/
	-rm -rf build/
	mkdir build
	xctool $(ARGS) clean

build: just_build copy_files_make_ipa

just_build:
	xctool $(ARGS) build

copy_files_make_ipa:
	mkdir -p pkg/Payload
	cp -r $(APP_OUT_PATH) pkg/Payload/
	mkdir -p pkg/dist
	(cd pkg && zip -r -q dist/$(PRODUCT_NAME).ipa Payload)
	cp -r $(APP_OUT_PATH).dSYM pkg/Payload/

bump:
	agvtool bump -all


TOOL_NAMES = magia

PREFIX?=/usr/local
INSTALL_PATH = $(PREFIX)/bin/
BUILD_PATH = $(addprefix .build/release/,$(TOOL_NAMES))

.PHONY: install build test lint clean xcode

build:
	swift build --disable-sandbox -c release

install: build
	mkdir -p $(INSTALL_PATH)
	cp -f $(BUILD_PATH) $(INSTALL_PATH)

uninstall:
	rm -f $(addprefix $(INSTALL_PATH),$(TOOL_NAMES))

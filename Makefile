# Copyright (c) 2014-2016 Kylie McClain <somasis@exherbo.org>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

VERSION     =2.0.3

DESTDIR		?= /
PREFIX		?= /usr

TOPDIR      =   $(dir $(realpath $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))))
BASE        =   $(TOPDIR)/numix-themes
BASE_BASENAME:=  $(shell basename $(BASE))
GENERATED   ?=  $(TOPDIR)/generated
COLORS      =	Brave-Revival Human-Revival Illustrious-Revival         \
                Noble-Revival Wine-Revival Wise-Revival                 \
                Brave-Classic Human-Classic Illustrious-Classic         \
                Noble-Classic Wine-Classic Wise-Classic

WM          =   Shiki-Colors-Classic Shiki-Colors-Classic-EZ            \
                Shiki-Colors-Revival Shiki-Colors-Revival-EZ

PLANK       =   Shiki-Revival Shiki-Classic Shiki-panel Shiki-platform

Shiki-Brave-Revival_dark_bg         = 212121
Shiki-Human-Revival_dark_bg         = 212121
Shiki-Illustrious-Revival_dark_bg   = 212121
Shiki-Noble-Revival_dark_bg         = 212121
Shiki-Wine-Revival_dark_bg          = 212121
Shiki-Wise-Revival_dark_bg          = 212121

Shiki-Brave-Classic_dark_bg         = 3c3c3c
Shiki-Human-Classic_dark_bg         = 3c3c3c
Shiki-Illustrious-Classic_dark_bg   = 3c3c3c
Shiki-Noble-Classic_dark_bg         = 3c3c3c
Shiki-Wine-Classic_dark_bg          = 3c3c3c
Shiki-Wise-Classic_dark_bg          = 3c3c3c

Shiki-Brave-Revival_selected			= 729fcf
Shiki-Human-Revival_selected			= faa546
Shiki-Illustrious-Revival_selected		= f9a1ac
Shiki-Noble-Revival_selected			= ad7fa8
Shiki-Wine-Revival_selected				= df5757
Shiki-Wise-Revival_selected				= 97bf60

Shiki-Brave-Classic_selected			= 729fcf
Shiki-Human-Classic_selected			= faa546
Shiki-Illustrious-Classic_selected		= f9a1ac
Shiki-Noble-Classic_selected			= ad7fa8
Shiki-Wine-Classic_selected				= df5757
Shiki-Wise-Classic_selected				= 97bf60

all: $(GENERATED)/.success
submodules: $(GENERATED)/.submodules
prepare: $(GENERATED)/.prepare
Shiki-%: $(GENERATED)/.success-$*
generate: $(GENERATED)/.success

help:
	@echo "make targets:"
	@echo "    all                      Prepare, generate, and install theme"
	@echo "    clean                    Delete generated themes and base ($(BASE))"
	@echo "    prepare                  Run pre-generation modifications on base theme"
	@echo "    generate                 Generate all colors specified in the Makefile"
	@echo "    Shiki-<color>            Generate Shiki-<color>"
	@echo "    install                  Install themes to $(DESTDIR)$(PREFIX)/share/{plank/,}themes"
	@echo "    uninstall                Uninstall themes from $(DESTDIR)$(PREFIX)/share/{plank/,}themes"
	@echo
	@echo "Base theme: $(BASE)"
	@echo "Default themes to generate: $(foreach COLOR,$(COLORS),Shiki-$(COLOR))"
	@echo "Plank themes: $(PLANK)"
	@echo
	@echo "Notes:"
	@echo "    If you do not want to run \`git submodules update\` during the prepare"
	@echo "    phase, set ${no_git}; ex. \`no_git=true make prepare\`"

$(GENERATED)/.submodules:
	[[ "$(no_git)" ]] || git submodule init
	[[ "$(no_git)" ]] || git submodule update -f
	rm -rf "$(GENERATED)"
	mkdir "$(GENERATED)"
	touch "$(GENERATED)/.submodules"

$(GENERATED)/.success-Shiki-%: $(GENERATED)/.submodules
	$(eval TEMP_DIR := $(shell mktemp -d))
	$(foreach SRC_DIR,src scripts Makefile,cp -r $(BASE)/$(SRC_DIR) $(TEMP_DIR)/$(SRC_DIR);)
	find "$(TEMP_DIR)/src" -type f -iregex '.*\(\.css\|\.scss\|gtkrc\|\.svg\)$$' -print0 | xargs -0 sed -i \
		-e 's/#d64937/#$(Shiki-$*_selected)/g'  \
		-e 's/#f0544c/#$(Shiki-$*_selected)/g'  \
		-e 's/#444*/#$(Shiki-$*_dark_bg)/g'
	find "$(TEMP_DIR)/src/assets" -type f -iname "*png" -delete
	sed -i 's/#f1544d/#$(Shiki-$*_selected)/g' "$(TEMP_DIR)/src/assets/all-assets.svg"
	pushd "$(TEMP_DIR)/scripts";\
	./render-assets.sh;\
	popd
	mkdir "$(TEMP_DIR)/generated"
	$(MAKE) -C "$(TEMP_DIR)" install DESTDIR="$(TEMP_DIR)/generated"
	mv "$(TEMP_DIR)/generated/usr/share/themes/Numix" "$(GENERATED)/Shiki-$*"
	rm -rf "$(TEMP_DIR)"
	for f in $$(find $(GENERATED)/Shiki-$* -maxdepth 1 -type d);do \
	    cd "$$f";   \
	    [ -d "$$f/dist" ] && mv -f "$$f"/dist/* "$$f"/ || true;  \
	done
	find $(GENERATED)/Shiki-$* -empty -delete
	touch "$(GENERATED)/.success-Shiki-$*"

$(GENERATED)/.success: $(foreach COLOR,$(COLORS),$(GENERATED)/.success-Shiki-$(COLOR))
	$(foreach WM_THEME,$(WM),cp -r $(TOPDIR)/$(WM_THEME) $(GENERATED)/$(WM_THEME);)
	$(foreach PLANK_THEME,$(PLANK),cp -r $(TOPDIR)/plank/$(PLANK_THEME) $(GENERATED)/plank-$(PLANK_THEME);)
	touch $(GENERATED)/.success

clean:
	-rm -rf $(BASE)
	-rm -rf $(GENERATED)
	-git clean -fdx

install: $(GENERATED)/.success
	mkdir -p $(DESTDIR)$(PREFIX)/share/themes
	mkdir -p $(DESTDIR)$(PREFIX)/share/plank/themes
	$(foreach PLANK_THEME,$(PLANK),cp -r $(GENERATED)/plank-$(PLANK_THEME) $(DESTDIR)$(PREFIX)/share/plank/themes/$(PLANK_THEME);)
	$(foreach COLOR,$(COLORS),cp -r $(GENERATED)/Shiki-$(COLOR) $(DESTDIR)$(PREFIX)/share/themes/Shiki-$(COLOR);)
	$(foreach WM_THEME,$(WM),cp -r $(GENERATED)/$(WM_THEME) $(DESTDIR)$(PREFIX)/share/themes/$(WM_THEME);)

uninstall:
	$(foreach PLANK_THEME,$(PLANK),rm -rf $(DESTDIR)$(PREFIX)/share/plank/$(PLANK_THEME);)
	$(foreach COLOR,$(COLORS),rm -rf $(DESTDIR)$(PREFIX)/share/themes/Shiki-$(COLOR);)
	$(foreach WM_THEME,$(WM),rm -rf $(DESTDIR)$(PREFIX)/share/themes/$(WM_THEME);)

sync: $(GENERATED)/.submodules
	git -C $(BASE) reset --hard
	git -C $(BASE) pull origin master
	git -C $(TOPDIR) add $(BASE)
	git -C $(TOPDIR) commit -m "Synchronize with upstream $(BASE_BASENAME)"

.PHONY: clean sync install uninstall Shiki-% generate prepare submodules

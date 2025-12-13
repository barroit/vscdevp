# SPDX-License-Identifier: GPL-3.0-or-later

name := $(shell head -n1 README)

npm ?= pnpm

prefix := build
bundle := entry.js
vsix   := $(name).vsix

input := entry.js
input += $(wildcard cmd/*.js helper/*.js helper.patch/*.js)

module-prefix := node_modules

package       := package.json
package-input := $(wildcard package/*.json)

profile := --platform=node --format=esm
extern  := --external:vscode
define  := --define:NULL=null

ifneq ($(resize),)
	resize := -terser
endif

.PHONY: install uninstall publish

install:

-include patch.mak

$(prefix):
	mkdir -p $@

$(prefix)/$(bundle)1: $(input) $(prebundle) | $(prefix)
	trap 'rm -f $@.$$$$' EXIT && \
	esbuild $(profile) --bundle --sourcemap \
		$(define) $(extern) $< >$@.$$$$ && \
	mv $@.$$$$ $@

$(prefix)/$(bundle)1-terser: $(prefix)/$(bundle)1
	terser --module --ecma 2020 \
	       --compress 'passes=3,pure_getters=true,unsafe=true' \
	       --mangle --comments false <$< >$@

$(prefix)/$(bundle): $(prefix)/$(bundle)1$(resize)
	head -n1 entry.js >$@
	printf '\n' >>$@
	cat $< >>$@

$(package): $(package).in $(package-input)
	m4 $< >$@

$(prefix)/$(vsix): $(prefix)/$(bundle) $(package)
	vsce package --skip-license -o $@

install: $(prefix)/$(vsix)
	code --install-extension $<

uninstall:
	code --uninstall-extension \
	     $$(code --list-extensions | grep $(name) || printf '39\n')

publish: $(prefix)/$(vsix)
	vsce publish --skip-license

.PHONY: clean $(clean-prebundle) distclean $(distclean-prebundle)

clean: $(clean-prebundle)
	rm -f $(prefix)/$(vsix) $(prefix)/$(bundle)*

distclean: clean $(distclean-prebundle)
	rm -f $(package)
	rm -rf $(prefix) $(module-prefix)

# SPDX-License-Identifier: GPL-3.0-or-later

name := $(shell head -n1 README)

npm ?= pnpm
npm-install := $(npm) i -D

prefix := build
bundle := entry.js
vsix   := $(name).vsix

input := entry.js
input += $(wildcard cmd/*.js helper/*.js helper.patch/*.js)

module-prefix := node_modules

package       := package.json
package-input := $(wildcard package/*.json)

esbuild-profile := --platform=node --format=esm
esbuild-extern  := --external:vscode
esbuild-define  := --define:NULL=null --define:NAME='"$(name)"'
esbuild-extra   :=

ifneq ($(resize),)
	resize := -terser
endif

ifneq ($(debug),)
	debug := -debug
endif

.PHONY: install uninstall publish

install:

-include patch.mak

$(prefix):
	mkdir -p $@

$(prefix)/$(bundle)1: $(input) $(prebundle) | $(prefix)
	esbuild $(esbuild-profile) --bundle --sourcemap $(esbuild-extern) \
		$(esbuild-define) $(esbuild-extra) --outfile=$@ $<

$(prefix)/$(bundle)1-terser: $(prefix)/$(bundle)1
	terser --module --ecma 2020 \
	       --compress 'passes=3,pure_getters=true,unsafe=true' \
	       --mangle --comments false <$< >$@

$(prefix)/$(bundle): $(prefix)/$(bundle)1$(resize)
	head -n1 entry.js >$@
	printf '\n' >>$@
	cat $< >>$@

$(prefix)/$(bundle)-debug: %-debug: %1
	ln -f $< $@
	ln -f $< $*

$(package): $(package).in $(package-input)
	m4 $< >$@

$(prefix)/$(vsix): $(prefix)/$(bundle)$(debug) $(package)
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

# SPDX-License-Identifier: GPL-3.0-or-later

name := $(shell head -n1 README)

prefix := build
bundle := entry.js
vsix   := $(name).vsix

input := entry.js
input += $(wildcard cmd/*.js helper/*.js helper.patch/*.js)

package       := package.json
package-input := $(wildcard package/*.json)

profile := --platform=node --format=esm
extern  := --external:vscode
define  := --define:NULL=null

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

$(prefix)/$(bundle): $(prefix)/$(bundle)1
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

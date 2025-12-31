# SPDX-License-Identifier: GPL-3.0-or-later

name := $(shell head -n1 README)

npm ?= pnpm
npm += i -D

m4 ?= m4
m4 := printf 'changequote([[,]])' | $(m4) -

esbuild ?= esbuild
esbuild += --bundle --format=esm

terser ?= terser
terser += --module --ecma 2020
terser += --compress 'passes=3,pure_getters=true,unsafe=true'
terser += --mangle --comments false

prefix := build
patch-prefix := helper.patch

entry-in := entry.js
entry-y  := $(prefix)/$(entry-in)

vsix-in := $(name).vsix
vsix-y  := $(prefix)/$(vsix-in)

input := entry.js
input += $(wildcard cmd/*.js helper/*.js $(patch-prefix)/*.js)

module-prefix := node_modules
image-prefix  := image

package-in := $(wildcard package/*.json)
package-y  := package.json

esbuild-define  := --define:NULL=null --define:NAME='"$(name)"'
esbuild-require := --banner:js="import { createRequire } from 'node:module'; \
				const require = createRequire(import.meta.url);"

prebundle  :=
prepackage :=

bundle-y := $(entry-y)

ifneq ($(resize),)
	resize := -terser
endif

ifneq ($(debug),)
	debug := -debug
endif

.PHONY: install uninstall publish

install:

-include patch.mak

terser-y  := $(addsuffix 1-terser,$(bundle-y))
debug-y   := $(addsuffix -debug,$(bundle-y))
archive-y := $(addsuffix $(debug),$(bundle-y))

$(prefix):
	mkdir -p $@

$(entry-y)1: $(input) $(prebundle) | $(prefix)
	$(esbuild) $(esbuild-define) $(esbuild-require) \
		   --sourcemap --platform=node --external:vscode --outfile=$@ $<

$(terser-y): %1-terser: %1
	$(terser) <$< >$@

$(bundle-y): %: %1$(resize)
	head -n1 entry.js >$@
	printf '\n' >>$@
	cat $< >>$@

$(debug-y): %-debug: %1
	ln -f $< $@
	ln -f $< $*

$(package-y): $(package-y).in $(package-in)
	$(m4) $< >$@

$(vsix-y): $(archive-y) $(package-y) $(prepackage)
	vsce package --skip-license -o $@

install: $(vsix-y)
	code --install-extension $<

uninstall:
	code --uninstall-extension \
	     $$(code --list-extensions | grep $(name) || printf '39\n')

publish: $(vsix-y)
	vsce publish --skip-license

.PHONY: clean $(clean-prebundle) distclean $(distclean-prebundle)

clean: $(clean-prebundle)
	rm -f $(vsix-y) $(entry-y)*

distclean: clean $(distclean-prebundle)
	rm -f $(package-y)
	rm -rf $(prefix) $(module-prefix)

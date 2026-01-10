# SPDX-License-Identifier: GPL-3.0-or-later

name := $(shell head -n1 README)

npm ?= pnpm
npm-flag ?= add -D
npm += $(npm-flag)

gm4 ?= m4
gm4 := printf 'changequote([[, ]])' | $(gm4) -
m4   = $(gm4) -D__filename__=$(notdir $<) -D__build__=$(syth-prefix)

esbuild ?= esbuild
esbuild += --bundle --format=esm
esbuild += --define:NULL=null --define:NAME='"$(name)"'

terser ?= terser
terser += --module --ecma 2020 --mangle --comments false \
	  --compress 'passes=3,pure_getters=true,unsafe=true'

prefix := build
syth-prefix := $(prefix)/m4

ifneq ($(resize),)
	resize := -terser
endif

ifneq ($(debug),)
	debug := -debug
endif

m4-in :=
archive-in :=

bundle-y :=
prem4    :=

.PHONY: install uninstall publish
install:

-include patch.mak

main-in   := entry.js $(wildcard cmd/*.js helper/*.js helper.patch/*.js)
main-m4-y := $(addprefix $(syth-prefix)/,$(main-in))
main-y    := $(prefix)/entry.js

m4-in += $(main-in)
m4-y  := $(addprefix $(syth-prefix)/,$(m4-in))

$(m4-y): $(syth-prefix)/%: % $(prem4)
	mkdir -p $(@D)
	$(m4) $< >$@

$(main-y)1: $(main-m4-y)
	$(esbuild) --banner:js="import { createRequire } from 'node:module'; \
		   		var require = createRequire(import.meta.url);" \
		   --sourcemap --platform=node --external:vscode --outfile=$@ $<

bundle-y += $(main-y)
terser-y := $(addsuffix 1-terser,$(bundle-y))
debug-y  := $(addsuffix -debug,$(bundle-y))

$(terser-y): %1-terser: %1
	$(terser) <$< >$@

$(bundle-y): %: %1$(resize)
	head -n1 entry.js >$@
	printf '\n' >>$@
	cat $< >>$@

$(debug-y): %-debug: %1
	ln -f $< $@
	ln -f $< $*

package-in := $(wildcard package/*.json)
package-y  := package.json

$(package-y): %: %.in $(package-in)
	$(m4) $< >$@

archive-in += $(addsuffix $(debug),$(bundle-y))
archive-y  := $(prefix)/$(name).vsix

$(archive-y): $(archive-in) $(package-y)
	vsce package --skip-license -o $@

install: $(archive-y)
	code --install-extension $<

uninstall:
	code --uninstall-extension \
	     $$(code --list-extensions | grep $(name) || printf '39\n')

publish: $(archive-y)
	vsce publish --skip-license

.PHONY: clean $(preclean) distclean $(predistclean)

clean: $(preclean)
	rm -f $(archive-y)
	rm -f $(m4-y)
	rm -f $(bundle-y)*

distclean: clean $(predistclean)
	rm -f $(package-y)

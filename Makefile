# Copyright (C) 2022, 2023 Timothe Litt litt at acm ddot org

# Version $Id$
# Install targets - can override on command line

# Note that DESTDIR is supported for staging environments

prefix          := /usr/local
datarootdir     := $(prefix)/share
mandir          := $(datarootdir)/man
man1dir         := $(mandir)/man1
manext          := .1
man1ext         := .1
exec_prefix     := $(prefix)
sbindir          := $(exec_prefix)/sbin

INSTALL         := install -p
INSTALL_PROGRAM := $(INSTALL)
INSTALL_DATA    := $(INSTALL) -m 644

# Specify key="deadbeef" or key="deadbeef beeffeed" on command line (else default)
GPG          := gpg

PERL         := perl
PERLTIDY     := perltidy
PODCHECKER   := podchecker
POD2MAN      := pod2man
POD2MARKDOWN := pod2markdown
SHELLCHECK   := shellcheck

SHELL        := bash

# Extract release number from source

kitversion := $(patsubst V%,%,$(strip $(file <RELEASE)))
kitname    := certtools-$(kitversion)
kitowner   := 0:0

# If in a Git working directory and the git command is available,
# get the last tag in case making a distribution.

ifneq "$(strip $(shell [ -d '.git' ] && echo 'true' ))" ""
  gitcmd   := $(shell command -v git)
  ifneq "$(strip $(gitcmd))" ""
    gittag := $(shell git tag --sort=version:refname | tail -n1)
  endif
endif

# file types from which tar can infer compression, if tool is installed

# kittypes := gz xz lzop lz lzma Z zst bz bz2

# kittypes to build

kittypes := gz xz

# Make tools excluded from documentation build
xtools := required_modules makereadme

# Included tools

ptools := acme_token_check ssl_check_chain ssl_status $(xtools)
btools := getcert ssl_info

tools := $(ptools) $(btools)

.PHONY : all

all: docs perlmods

# Documents - the .mds are not installed; they are for GitHub browsers.

mans := $(foreach T,$(filter-out $(xtools), $(ptools)),$(T)$(man1ext))
mds  := $(foreach T,$(filter-out $(xtools), $(ptools)),$(T).md) README.md

docs := $(mans) $(mds)

# Files to package

kitfiles := INSTALL README.md LICENSE $(tools) $(docs) Makefile

docs: $(docs) podcheck

README.md : README.md.in $(btools) makereadme
	 ./makereadme $(btools) <README.md.in >$@

.PHONY : podcheck

podcheck : $(ptools)
	$(PODCHECKER) $(ptools)

%.md : %
	cat $^ | $(POD2MARKDOWN) - $@

%.1 : %
	$(POD2MAN) --section 1 --center "Certificate Tools" --release  "" --date "$(shell date -r $< +'%d-%b-%Y')" $< $@

# required_modules data

.PHONY : perlmods
perlmods : $(filter-out required_modules, $(ptools))
	./required_modules $^ >modules.tmp
	sed required_modules -i -Ee'/^__DATA__$$/,/^__END__$$/{/^__(DATA|END)__$$/!d; }; /^__DATA__$$/rmodules.tmp'
	rm -f modules.tmp

# Make tarball kits - various compressions

.PHONY : dist unsigned-dist signed-dist

dist : signed-dist

ifeq ($(strip $(gitcmd)),)
signed-dist : $(foreach type,$(kittypes),$(kitname).tar.$(type).sig)
else
signed-dist : $(foreach type,$(kittypes),$(kitname).tar.$(type).sig) .tagged
endif

unsigned-dist : $(foreach type,$(kittypes),$(kitname).tar.$(type))

# Tarball build directory

$(kitname)/% : %
	@mkdir -p $(dir $@)
	@-chown $(kitowner) $(dir $@)
	cp -p $< $@
	@-chown $(kitowner) $@

# Clean up after builds

.PHONY : clean

clean:
	rm -rf $(kitname) $(foreach type,$(kittypes),$(kitname).tar.$(type){,.sig})

# Install programs and doc

.PHONY : install

install : $(mans) $(tools) installdirs
	./required_modules --quiet
	$(INSTALL_PROGRAM) $(tools) $(DESTDIR)$(sbindir)/
	-$(INSTALL_DATA) $(mans) $(DESTDIR)$(man1dir)/

# un-install

.PHONY : uninstall

uninstall :
	-rm -f $(foreach tool,$(tools),$(DESTDIR)$(sbindir)/$(tool))
	-rm -f $(foreach man,$(mans),$(DESTDIR)$(man1dir)/$(man))

# create install directory tree (especially when staging)

installdirs :
	$(INSTALL) -d $(DESTDIR)$(sbindir) $(DESTDIR)$(man1dir)

# rules for making tarballs - $1 is file type that implies compression

define make_tar =

%.tar.$(1) : $$(foreach f,$$(kitfiles), %/$$(f))
	tar -caf $$@ $$^
	@-chown $(kitowner) $$@

endef

$(foreach type,$(kittypes),$(eval $(call make_tar,$(type))))

# Ensure that the release is tagged, providing the working directory is clean
# Depends on everything in git (not just kitfiles), everything compiled, and
# all the release kits.

ifneq ($(strip $(gitcmd)),)
.PHONY : tag

tag : .tagged

.tagged : $(shell git ls-tree --full-tree --name-only -r HEAD) unsigned-dist
	@if git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*' >/dev/null 2>/dev/null || \
	    [ -n "$$(git diff --name-only)$$(git diff --name-only --staged)" ]; then \
	    echo " *** Not tagging V$(kitversion) because working directory is dirty"; echo ""; false ;\
	 elif [ "$(strip $(gittag))" == "V$(kitversion)" ]; then                 \
	    echo " *** Not tagging because V$(kitversion) already exists";       \
	    echo ""; false;                                                      \
	 else                                                                    \
	    git tag V$(kitversion) && echo "Tagged as V$(kitversion)" | tee .tagged || true; \
	 fi

endif

# create a detached signature for a file

%.sig : % Makefile
	@-rm -f $<.sig
	$(GPG) --output $@ --detach-sig $(foreach k,$(key), --local-user "$(k)") $(basename $@)
	@-chown $(kitowner) $@

# perltidy

.PHONY : tidy

tidy : $(ptools)
	$(PERLTIDY) -b $(ptools)

# shellcheck

.PHONY : shellcheck

shellcheck: $(btools)
	$(foreach tool,$(ptools),$(SHELLCHECK) $(tool);)


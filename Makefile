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
sbindir         := $(exec_prefix)/sbin

installdirs     := $(sbindir) $(man1dir)

INSTALL         := install -p
INSTALL_PROGRAM := $(INSTALL)
INSTALL_DATA    := $(INSTALL) -m 644
INSTALL_DIR     := $(INSTALL) -d

# Specify key="deadbeef" or key="deadbeef beeffeed" on command line (else default)
GPG          := gpg

PERL         := perl
PERLTIDY     := perltidy
PODCHECKER   := podchecker
POD2MAN      := pod2man
POD2MARKDOWN := pod2markdown
SHELLCHECK   := shellcheck

CHMOD        := chmod
CHOWN        := chown
CP           := cp
DATE         := date
ECHO         := echo
GIT          := git
HEAD         := head
MKDIR        := mkdir
RM           := rm
SED          := sed
SORT         := sort
TAIL         := tail
TAR          := tar
TEE          := tee

SHELL        := bash

#sorttags := --sort=version:refname
sorttags :=  | $(SORT) -t. -k1.1,1.1 -k1.2,1n -k2,2n -k3,3n -k4,4n

# Extract release number from source

kitversion := $(patsubst V%,%,$(strip $(shell [ -s $(UNOFFICIAL)RELEASE ] && $(HEAD) -n1 RELEASE || $(ECHO) "unofficial")))
kitname    := certtools-$(kitversion)
kitowner   := 0:0

# If in a Git working directory and the git command is available,
# get the last tag in case making a distribution.
inGitWd    := $(strip $(shell [ -d '.git' ] && [ -n "$$(command -v $(GIT))" ] && $(ECHO) 'true'))
ifneq ($(inGitWd),)
    gittag := $(shell $(GIT) tag -l $(sorttags) | $(TAIL) -n1)
endif

# file types from which tar can infer compression, if tool is installed

# kittypes := gz xz lzop lz lzma Z zst bz bz2

# kittypes to build

kittypes := gz xz

# Make tools excluded from documentation build and install
xtools := required_modules module_checker makereadme

# Included tools

ptools := acme_token_check ssl_check_chain ssl_status $(xtools)
btools := getcert ssl_info

tools := $(ptools) $(btools)

.PHONY : all

all: docs

# Documents - the .mds are not installed; they are for GitHub browsers.

mans := $(foreach T,$(filter-out $(xtools), $(ptools)),$(T)$(man1ext))
mds  := $(foreach T,$(filter-out $(xtools), $(ptools)),$(T).md) README.md

docs := $(mans) $(mds)

# Files to package

kitfiles := INSTALL README.md LICENSE $(tools) $(docs) Makefile

docs: $(docs) podcheck

README.md : README.md.in $(btools) makereadme
	 $(PERL) makereadme $(btools) <README.md.in >$@

.PHONY : podcheck

podcheck : $(filter-out module_checker,$(ptools))
	$(PODCHECKER) $(ptools)

%.md : %
	cat $^ | $(POD2MARKDOWN) - $@

%.1 : %
	$(POD2MAN) --section 1 --center "Certificate Tools" --release  "" --date "$(shell $(DATE) -r $< +'%d-%b-%Y')" $< $@

# required_modules data

module_checker : required_modules $(filter-out module_checker, $(ptools))
	$(PERL) required_modules --include=IO::Socket::SSL --private=^TL:: $(filter-out required_modules,$^) | \
	$(SED) required_modules -Ee'/^__DATA__$$/,/^__END__$$/{/^__(DATA|END)__$$/!d; }; /^__DATA__$$/r/dev/stdin' >module_checker
	$(SED) -i module_checker -e'1s/$$/ -T/'
	$(CHMOD) +x module_checker

# Make tarball kits - various compressions

.PHONY : dist unsigned-dist signed-dist

dist : signed-dist

ifeq ($(inGitWd),)
signed-dist : $(foreach type,$(kittypes),$(kitname).tar.$(type).sig)
else
signed-dist : $(foreach type,$(kittypes),$(kitname).tar.$(type).sig) .tagged
endif

unsigned-dist : $(foreach type,$(kittypes),$(kitname).tar.$(type))

# Tarball build directory

$(kitname)/% : %
	@$(MKDIR)  -p $(dir $@)
	@-$(CHOWN) $(kitowner) $(dir $@)
	$(CP) -p $< $@
	@-$(CHOWN) $(kitowner) $@

# Clean up after builds

.PHONY : clean

clean:
	$(RM) -rf $(kitname) $(foreach type,$(kittypes),$(kitname).tar.$(type){,.sig}) module_checker

# Install programs and doc

.PHONY : install

install : $(mans) $(tools)
	$(PERL) module_checker --quiet
	$(INSTALL_DIR) $(foreach dir,$(installdirs),$(DESTDIR)$(dir))
	$(INSTALL_PROGRAM) $(filter-out $(xtools), $(tools)) $(DESTDIR)$(sbindir)/
	-$(INSTALL_DATA) $(mans) $(DESTDIR)$(man1dir)/

# un-install

.PHONY : uninstall

uninstall :
	-$(RM) -f $(foreach tool,$(filter-out $(xtools), $(tools)),$(DESTDIR)$(sbindir)/$(tool))
	-$(RM) -f $(foreach man,$(mans),$(DESTDIR)$(man1dir)/$(man))

# rules for making tarballs - $1 is file type that implies compression

define make_tar =

%.tar.$(1) : $(foreach f,$(kitfiles), %/$(f))
	$(TAR) -caf $$@ $$^
	@-$(CHOWN) $(kitowner) $$@

endef

$(foreach type,$(kittypes),$(eval $(call make_tar,$(type))))

# Ensure that the release is tagged, providing the working directory is clean
# Depends on everything in git (not just kitfiles), everything compiled, and
# all the release kits.

ifneq ($(inGitWd),)
.PHONY : tag

tag : .tagged

.tagged : $(shell $(GIT) ls-tree --full-tree --name-only -r HEAD) unsigned-dist
	@if $(GIT) ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*' >/dev/null 2>/dev/null || \
	    [ -n "$$($(GIT) diff --name-only)$$($(GIT) diff --name-only --staged)" ]; then                   \
	    $(ECHO) " *** Not tagging V$(kitversion) because working directory is dirty"; $(ECHO) ""; false ;\
	 elif [ "$(strip $(gittag))" == "V$(kitversion)" ]; then                 \
	    $(ECHO) " *** Not tagging because V$(kitversion) already exists";    \
	    $(ECHO) ""; false;                                                   \
	 else                                                                    \
	    $(GIT) tag V$(kitversion) && $(ECHO) "Tagged as V$(kitversion)" | $(TEE) .tagged || true; \
	 fi

endif

# create a detached signature for a file

%.sig : % Makefile
	@-$(RM) -f $<.sig
	$(GPG) --output $@ --detach-sig $(foreach k,$(key), --local-user "$(k)") $(basename $@)
	@-$(CHOWN) $(kitowner) $@

# perltidy

.PHONY : tidy

tidy : $(ptools)
	$(PERLTIDY) -b $(ptools)

# shellcheck

.PHONY : shellcheck

shellcheck: $(btools)
	$(foreach tool,$(btools),$(SHELLCHECK) $(tool);)


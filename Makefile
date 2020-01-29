SCRIPTS_BIN    = apk-deploy-pkg
SCRIPTS_SBIN   = apk-deploy-addkey

prefix        := /usr/local
bindir        := $(prefix)/bin
sbindir       := $(prefix)/sbin

INSTALL       := install
GIT           := git
SED           := sed

MAKEFILE_PATH  = $(lastword $(MAKEFILE_LIST))


#: Print list of targets.
help:
	@printf '%s\n\n' 'List of targets:'
	@$(SED) -En '/^#:.*/{ N; s/^#: (.*)\n([A-Za-z0-9_-]+).*/\2 \1/p }' $(MAKEFILE_PATH) \
		| while read label desc; do printf '%-20s %s\n' "$$label" "$$desc"; done

#: Install the scripts.
install:
	for script in $(SCRIPTS_BIN); do \
		$(INSTALL) -m 755 -D $$script "$(DESTDIR)$(bindir)/$$script"; \
	done
	for script in $(SCRIPTS_SBIN); do \
		$(INSTALL) -m 755 -D $$script "$(DESTDIR)$(sbindir)/$$script"; \
	done

#: Uninstall the scripts.
uninstall:
	for script in $(SCRIPTS_BIN); do \
		rm -f "$(DESTDIR)$(bindir)/$$script"; \
	done
	for script in $(SCRIPTS_SBIN); do \
		rm -f "$(DESTDIR)$(sbindir)/$$script"; \
	done

#: Update version in the script and README.adoc to $VERSION.
bump-version:
	test -n "$(VERSION)"  # $$VERSION
	$(SED) -E -i "s/^(readonly VERSION)=.*/\1='$(VERSION)'/" $(SCRIPTS_BIN) $(SCRIPTS_SBIN)
	$(SED) -E -i "s/^(:version:).*/\1 $(VERSION)/" README.adoc

#: Bump version to $VERSION, create release commit and tag.
release: .check-git-clean | bump-version
	test -n "$(VERSION)"  # $$VERSION
	$(GIT) add .
	$(GIT) commit -m "Release version $(VERSION)"
	$(GIT) tag -s v$(VERSION) -m v$(VERSION)


.check-git-clean:
	@test -z "$(shell $(GIT) status --porcelain)" \
		|| { echo 'You have uncommitted changes!' >&2; exit 1; }

.PHONY: help install uninstall bump-version release .check-git-clean

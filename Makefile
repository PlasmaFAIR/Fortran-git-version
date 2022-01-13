FORTRAN_GIT_WORKING_TREE ?= .

FORTRAN_GIT_DEFS += -DFORTRAN_GIT_DONT_USE_VERSION_HEADER

GIT_SHA1:=$(shell git -C "${FORTRAN_GIT_WORKING_TREE}" rev-parse HEAD)
FORTRAN_GIT_DEFS+=-DGIT_SHA1='"$(GIT_SHA1)"'

# Version string, including current commit if not on a release, plus '-dirty' if
# there are uncommitted changes
GIT_VERSION := $(shell git -C "${FORTRAN_GIT_WORKING_TREE}" describe --tags --dirty --always)
FORTRAN_GIT_DEFS += -DGIT_VERSION='"$(GIT_VERSION)"'

# Find if there are any modified tracked files (except Makefile.depend)
ifeq ($(shell git -C "${FORTRAN_GIT_WORKING_TREE}" status --short -uno -- . | wc -l), 0)
	GIT_STATE:="clean"
	FORTRAN_GIT_DEFS+=-DGIT_STATE='$(GIT_STATE)'
else
	GIT_STATE:="dirty"
	FORTRAN_GIT_DEFS+=-DGIT_STATE='$(GIT_STATE)'
endif

GIT_DATE := $(shell git -C "${FORTRAN_GIT_WORKING_TREE}" show -q --pretty=format:%as HEAD)
FORTRAN_GIT_DEFS += -DGIT_DATE='"$(GIT_DATE)"'

# Dump the compilation flags to a file, so we can check if they change between
# invocations of `make`. The `cmp` bit checks if the file contents
# change. Adding a dependency of a file on `fortran_git_version` causes it to be
# rebuilt when the git version/hash/state changes. Taken from
# https://stackoverflow.com/a/3237349/2043465
GIT_VERSION_MACROS = "$(GIT_VERSION) ${GIT_STATE} ${GIT_SHA1}"
.PHONY: force
fortran_git_version: force
	@echo -e $(GIT_VERSION_MACROS) | cmp -s - $@ || echo -e $(GIT_VERSION_MACROS) > $@

# This file needs to be rebuilt if any of the git version information
# changes. You may need to set up VPATH or customise the following line:
git_version_impl.o: fortran_git_version

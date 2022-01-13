Fortran-git-version
===================

A Fortran module plus helper Makefile and CMake module for capturing
the git version of your project in your application or library.

The implementation is split out into a Fortran submodule in order to
avoid re-compilation cascades from `use` of the parent module.

Requirements
------------

Fortran-git-version requires `git` and a Fortran compiler that supports
submodules -- this should be any recent-ish compiler, for example
`gfortran` has supported Fortran submodules since version 6.

Usage
-----

Fortran-git-version can be either copied wholesale into your project,
or used as a git submodule. The module `git_version` provides the
following functions:

- `get_git_version`: returns the version number from `git describe`
- `get_git_hash`: returns the hash of the latest commit
- `get_git_state`: returns either "clean" or "-dirty"

The full version as returned from `get_git_version` is the output of

```bash
git describe --tags --always --dirty
```

See [`git describe --help`][git-describe-help] for a full description,
but this gives a version number in the form
`<tag>[-N[-g<hash>][-dirty]]`, where `N` is the number of commits
since the latest `<tag>`.

CMake
-----

You can use Fortran-git-version in your CMake project like so:

```cmake
add_subdirectory(fortran-git-version)

target_link_libraries(<your target> PRIVATE fortran_git::fortran_git)
```

There are three configuration options:

- `FORTRAN_GIT_WORKING_TREE`: set the working tree to get the `git`
  information from
- `FORTRAN_GIT_DEBUG`: print some extra information during the
  configure/build process
- `FORTRAN_GIT_BUILD_EXAMPLES`: build the example program

You normally shouldn't need to set `FORTRAN_GIT_WORKING_TREE` as it
should be worked out automatically, but there may be scenarios where
you need to set it manually.

Makefile
--------

Fortran-git-version comes with a makefile snippet that you can
incorporate into your project. It has one option:

- `FORTRAN_GIT_WORKING_TREE`: set the directory to run the `git`
  executable in. Defaults to `.`
  
It creates a variable `FORTRAN_GIT_DEFS` that you should add to the
compilation line. You will need to compile `src/git_version.f90`, and
preprocess and compile `src/git_version_impl.F90`. 

Warning: the makefile snippet is much less developed than the CMake
implementation, so use at your own risk!

[git-describe-help]: https://git-scm.com/docs/git-describe

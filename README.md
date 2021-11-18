Fortran-git-version
===================

A Fortran module plus helper Makefile and CMake module for capturing
the git version of your project into your application or library.

The implementation is split out into a Fortran submodule in order to
avoid re-compilation cascades from `use` of the parent module.

Requirements
------------

Fortran-git-version requires `git` and a Fortran compiler that supports
submodules -- this should be any recent-ish compiler, for example
gfortran has supported submodules since version 6.

Usage
-----

You should include a copy of Fortran-git-version in your project. In
particular, you should **NOT** do any of the following:

- include Fortran-git-version as a git submodule
- compile or install Fortran-git-version separately from your project
- use Fortran-git-version via CMake's `FetchContent`

Doing any of the above will cause Fortran-git-version to capture _its
own_ version, and not your software's.

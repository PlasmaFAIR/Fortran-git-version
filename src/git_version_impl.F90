! SPDX-License-Identifier: MIT

#ifndef FORTRAN_GIT_DONT_USE_VERSION_HEADER
#include "fortran_git_version.h"
#endif

submodule (git_version) git_version_impl
  implicit none
contains
  module procedure get_git_version
    integer, parameter :: max_length = 40
    integer :: length

    length = min(max_length, len(GIT_VERSION))
    allocate(character(length)::get_git_version)
    get_git_version = GIT_VERSION(1:length)
    get_git_version = trim(get_git_version)
  end procedure get_git_version

  module procedure get_git_hash
    integer :: length

    length = 7
    if (present(length_in)) then
      if (length_in <= 40) then
        length = length_in
      end if
    end if

    allocate(character(length)::get_git_hash)
    get_git_hash = GIT_SHA1(1:length)
  end procedure get_git_hash

  module procedure get_git_state
    if (GIT_STATE == "clean") then
      get_git_state = ""
    else
      get_git_state = "-dirty"
    endif
  end procedure get_git_state

  module procedure get_git_date
    get_git_date = GIT_DATE
  end procedure get_git_date
end submodule git_version_impl

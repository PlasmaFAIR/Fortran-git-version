cmake_minimum_required(VERSION 3.18)

project(fortran-git
  DESCRIPTION "Interface to get git version/commit in compiled code"
  LANGUAGES Fortran
  )

string(COMPARE EQUAL
  "${PROJECT_NAME}" "${CMAKE_PROJECT_NAME}"
  PROJECT_IS_TOP_LEVEL
)


##################################################
# Build options

option(FORTRAN_GIT_DEBUG "Print some information during build" OFF)
option(FORTRAN_GIT_BUILD_EXAMPLES "Build the example" ${PROJECT_IS_TOP_LEVEL})
set(FORTRAN_GIT_WORKING_TREE "IGNORE" CACHE PATH
  "Working directory of repository to get git information from. \
Defaults to the current directory, or the parent superproject if in a submodule")

##################################################
# Library

add_library(fortran_git
  src/git_version.f90
  src/git_version_impl.F90
  )

set_source_files_properties(src/git_version_impl.F90
  PROPERTIES Fortran_PREPROCESS ON
  )

add_library(fortran_git::fortran_git ALIAS fortran_git)
target_include_directories(fortran_git PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

set(fortran_git_module_dir "${CMAKE_CURRENT_BINARY_DIR}/mod")
set_target_properties(fortran_git PROPERTIES
  Fortran_MODULE_DIRECTORY ${fortran_git_module_dir}
  )

target_include_directories(fortran_git PUBLIC
  $<BUILD_INTERFACE:${fortran_git_module_dir}>
  )

##################################################
# Git version information

find_package(Git)

# Work out what directory we should run git in, use one of the following:
# - user supplied directory
# - the current directory if we're in a standalone project
# - the superproject working tree if we're in a submodule
# - the current directory if the git version is to old to check the superproject
if (NOT FORTRAN_GIT_WORKING_TREE)
  if (PROJECT_IS_TOP_LEVEL)
    set(FORTRAN_GIT_WORKING_TREE ".")
  elseif (GIT_VERSION_STRING VERSION_LESS "2.13.0")
    message(WARN "Cannot automatically detect superproject. Using '${PROJECT_SOURCE_DIR}'")
    set(FORTRAN_GIT_WORKING_TREE "${PROJECT_SOURCE_DIR}")
  else()
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" rev-parse --show-superproject-working-tree
      OUTPUT_VARIABLE FORTRAN_GIT_WORKING_TREE
      ERROR_VARIABLE _git_error
      RESULT_VARIABLE _result
      OUTPUT_STRIP_TRAILING_WHITESPACE
      )
    if (NOT _result EQUAL 0)
      message(FATAL_ERROR "Could not determine superproject working tree: ${_git_error}")
    endif()
  endif()
endif()

if (FORTRAN_GIT_DEBUG)
  message(STATUS "Fortran_git_version: running git in '${FORTRAN_GIT_WORKING_TREE}'")
endif()

# This target gets rerun every build, ensuring that the git version
# information is always up-to-date. The file it generates only gets
# touched if its contents are different, which means rebuilds aren't
# triggered unnecessarily
add_custom_target(
  version_header
  ${CMAKE_COMMAND} -D SRC="${CMAKE_CURRENT_LIST_DIR}/src/fortran_git_version.h.in"
                   -D DST="${CMAKE_CURRENT_BINARY_DIR}/fortran_git_version.h"
                   -D GIT_EXECUTABLE="${GIT_EXECUTABLE}"
                   -D GIT_DIR="${FORTRAN_GIT_WORKING_TREE}"
                   -D FORTRAN_GIT_DEBUG="${FORTRAN_GIT_DEBUG}"
                   -P "${CMAKE_CURRENT_LIST_DIR}/cmake/get_git_version.cmake"
  COMMENT "Generating git version information"
  )
add_dependencies(fortran_git version_header)

##################################################
# Example use

if (FORTRAN_GIT_BUILD_EXAMPLES)
  add_executable(example test/test_program.f90)
  target_link_libraries(example fortran_git)
endif()

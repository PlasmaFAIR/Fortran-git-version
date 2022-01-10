cmake_minimum_required(VERSION 3.18)

project(fortran-git
  DESCRIPTION "Interface to get git version/commit in compiled code"
  LANGUAGES Fortran
  )

# The implementation file needs to `#include` a generated file which
# will be created in the binary directory, so we set the include path
# at configure time
configure_file(
  src/git_version_impl.F90.in
  "${CMAKE_CURRENT_BINARY_DIR}/git_version_impl.F90"
  @ONLY
  )

add_library(fortran_git
  src/git_version.f90
  "${CMAKE_CURRENT_BINARY_DIR}/git_version_impl.F90"
  )

set_source_files_properties("${CMAKE_CURRENT_BINARY_DIR}/git_version_impl.F90"
  PROPERTIES Fortran_PREPROCESS ON)

add_library(fortran_git::fortran_git ALIAS fortran_git)

find_package(Git)

# This target gets rerun every build, ensuring that the git version
# information is always up-to-date. The file it generates only gets
# touched if its contents are different, which means rebuilds aren't
# triggered unnecessarily
add_custom_target(
  version_header
  ${CMAKE_COMMAND} -D SRC="${CMAKE_CURRENT_LIST_DIR}/src/version.h.in"
                   -D DST="${CMAKE_CURRENT_BINARY_DIR}/version.h"
                   -D GIT_EXECUTABLE="${GIT_EXECUTABLE}"
                   -P "${CMAKE_CURRENT_LIST_DIR}/cmake/get_git_version.cmake"
  COMMENT "Generating git version information"
  )
add_dependencies(fortran_git version_header)

set(fortran_git_module_dir "${CMAKE_CURRENT_BINARY_DIR}/mod")
set_target_properties(fortran_git PROPERTIES
  Fortran_MODULE_DIRECTORY ${fortran_git_module_dir}
  )

target_include_directories(fortran_git PUBLIC
  $<BUILD_INTERFACE:${fortran_git_module_dir}>
  )

##################################################
# Example use

string(COMPARE EQUAL
  "${PROJECT_NAME}" "${CMAKE_PROJECT_NAME}"
  PROJECT_IS_TOP_LEVEL
)

option(FORTRAN_GIT_BUILD_EXAMPLES "Build the example" ${PROJECT_IS_TOP_LEVEL})

if (FORTRAN_GIT_BUILD_EXAMPLES)
  add_executable(example example/example.f90)
  target_link_libraries(example fortran_git)
endif()

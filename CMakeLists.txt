cmake_minimum_required(VERSION 3.12)

project(example-fortran-git
  LANGUAGES Fortran
  )

add_library(fortran_git
  src/git_version.f90
  src/git_version_impl.F90)

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})
include(GetGitRevisionDescription)
git_get_commit(GIT_SHA1)
git_get_version(GIT_VERSION)
git_local_changes(GIT_STATE)
message(STATUS "GIT_SHA1=${GIT_SHA1}")
message(STATUS "GIT_VERSION=${GIT_VERSION}")
message(STATUS "GIT_STATE=${GIT_STATE}")

target_compile_definitions(fortran_git PRIVATE
  "GIT_SHA1='${GIT_SHA1}'"
  "GIT_VERSION='${GIT_VERSION}'"
  "GIT_STATE='${GIT_STATE}'"
  )

add_executable(example
  example.f90)

target_link_libraries(example fortran_git)

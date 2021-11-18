cmake_minimum_required(VERSION 3.18)

project(test-fortran-git
  LANGUAGES Fortran)

add_subdirectory(fortran-git-version)

add_executable(test_program test_program.f90)
target_link_libraries(test_program fortran_git::fortran_git)

# This script runs git to get:
#
# - the current commit hash
# - the version description
# - whether the working tree is currently clean/dirty

execute_process(
  COMMAND "${GIT_EXECUTABLE}" rev-parse HEAD
  WORKING_DIRECTORY "${GIT_DIR}"
  OUTPUT_VARIABLE GIT_SHA1
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )

execute_process(
  COMMAND "${GIT_EXECUTABLE}" describe --tags --always --dirty
  WORKING_DIRECTORY "${GIT_DIR}"
  OUTPUT_VARIABLE GIT_VERSION
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )

execute_process(
  COMMAND "${GIT_EXECUTABLE}" diff-index --quiet HEAD --
  WORKING_DIRECTORY "${GIT_DIR}"
  RESULT_VARIABLE state_result
  ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)

if(state_result EQUAL 0)
  set(GIT_STATE "clean")
else()
  set(GIT_STATE "dirty")
endif()

execute_process(
  COMMAND "${GIT_EXECUTABLE}" show --quiet --pretty=format:%ai HEAD
  WORKING_DIRECTORY "${GIT_DIR}"
  OUTPUT_VARIABLE _git_date
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )
string(SUBSTRING "${_git_date}" 0 10 GIT_DATE)

if (FORTRAN_GIT_DEBUG)
  message(STATUS "GIT_SHA1=${GIT_SHA1}")
  message(STATUS "GIT_VERSION=${GIT_VERSION}")
  message(STATUS "GIT_STATE=${GIT_STATE}")
  message(STATUS "GIT_DATE=${GIT_DATE}")
endif()

configure_file(${SRC} ${DST} @ONLY)

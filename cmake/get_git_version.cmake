# This script runs git to get:
#
# - the current commit hash
# - the version description
# - whether the working tree is currently clean/dirty

execute_process(
  COMMAND "${GIT_EXECUTABLE}" rev-parse HEAD
  OUTPUT_VARIABLE GIT_SHA1
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )

execute_process(
  COMMAND "${GIT_EXECUTABLE}" describe --tags --always --dirty
  OUTPUT_VARIABLE GIT_VERSION
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )

execute_process(
  COMMAND "${GIT_EXECUTABLE}" diff-index --quiet HEAD --
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  RESULT_VARIABLE state_result
  ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)

if(state_result EQUAL 0)
  set(GIT_STATE "clean")
else()
  set(GIT_STATE "dirty")
endif()

message(STATUS "GIT_SHA1=${GIT_SHA1}")
message(STATUS "GIT_VERSION=${GIT_VERSION}")
message(STATUS "GIT_STATE=${GIT_STATE}")

configure_file(${SRC} ${DST} @ONLY)

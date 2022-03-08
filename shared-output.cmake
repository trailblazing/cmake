
# https://stackoverflow.com/questions/16485546/how-to-check-in-cmake-whether-a-given-header-file-is-available-for-c-project
# https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/How-To-Write-Platform-Checks
#   include(CheckIncludeFiles)
#   check_include_files("${CMAKE_CURRENT_LIST_DIR}/common.cmake" COMMON_CMAKE)
#   message (STATUS "COMMON_CMAKE=${COMMON_CMAKE}" )
if (NOT _common_cmake_included)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/common.cmake")
        include (${CMAKE_CURRENT_LIST_DIR}/common.cmake)
    endif()
endif ()
if (NOT _shared_definitions)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/shared-definitions.cmake")
        include (${CMAKE_CURRENT_LIST_DIR}/shared-definitions.cmake)
    endif()
endif ()
if (NOT _build_shard_libs)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/build-shard.cmake")
        include (${CMAKE_CURRENT_LIST_DIR}/build-shard.cmake)
    endif()
endif ()

#   set (CMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH FALSE)   # defined in common.cmake


list (REMOVE_DUPLICATES CMAKE_PREFIX_PATH)
foreach(module ${CMAKE_PREFIX_PATH})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "CMAKE_PREFIX_PATH" "="  "${module}")
endforeach()
list (REMOVE_DUPLICATES CMAKE_MODULE_PATH)
foreach(module ${CMAKE_MODULE_PATH})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "CMAKE_MODULE_PATH" "="  "${module}")
endforeach()

message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "\$ENV{PWD}" "=" "$ENV{PWD}")
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "CMAKE_C_COMPILER" "=" "${CMAKE_C_COMPILER}")
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "CMAKE_CXX_COMPILER" "=" "${CMAKE_CXX_COMPILER}")
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "CMAKE_SOURCE_DIR" "=" "${CMAKE_SOURCE_DIR}")
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "CMAKE_CURRENT_SOURCE_DIR" "=" "${CMAKE_CURRENT_SOURCE_DIR}")
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "CMAKE_CURRENT_LIST_DIR" "=" "${CMAKE_CURRENT_LIST_DIR}")

message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "TOP_PROJECT_SOURCE_DIR" "=" "${TOP_PROJECT_SOURCE_DIR}")

#    Output dirs (like ECM 5.38 does)
#    Redirect output files
set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
#    set (CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
if (WIN32)
    set (CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
    set (${PROJECT_NAME_UPPER}_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin")
else (WIN32)
    set (CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set (${PROJECT_NAME_UPPER}_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
endif (WIN32)

if (WIN32)
    if (WITH_MFC)
        find_package(MFC QUIET)
    endif (WITH_MFC)
endif (WIN32)

set (CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

set ( ${PROJECT_NAME_UPPER}_ARCHIVE_OUTPUT_DIRECTORY    "${CMAKE_CURRENT_BINARY_DIR}/lib")
set ( ${PROJECT_NAME_UPPER}_RUNTIME_OUTPUT_DIRECTORY    "${CMAKE_CURRENT_BINARY_DIR}/bin")
set ( ${PROJECT_NAME_UPPER}_SOURCE_DIR                  "${CMAKE_CURRENT_SOURCE_DIR}")

message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "${PROJECT_NAME_UPPER}_SOURCE_DIR" "=" "${${PROJECT_NAME_UPPER}_SOURCE_DIR}")

message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "CMAKE_INCLUDE_PATH" "=" "${CMAKE_INCLUDE_PATH}")
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "CMAKE_IMPORT_LIBRARY_SUFFIX" "=" "${CMAKE_IMPORT_LIBRARY_SUFFIX}")
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "CMAKE_VERSION" "=" "${CMAKE_VERSION}")
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "CMAKE_ROOT" "=" "${CMAKE_ROOT}")

#    Instruct CMake to run moc/resource/ui automatically when needed.
set (CMAKE_INCLUDE_CURRENT_DIR ON)

if (NOT DEFINED CMAKE_SKIP_BUILD_RPATH)
  set (CMAKE_SKIP_BUILD_RPATH ON)
endif ()
if (NOT DEFINED CMAKE_BUILD_WITH_INSTALL_RPATH)
  set (CMAKE_BUILD_WITH_INSTALL_RPATH ON)
endif ()
if (NOT DEFINED CMAKE_INSTALL_RPATH_USE_LINK_PATH)
  set (CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
endif ()
if (NOT DEFINED CMAKE_MACOSX_RPATH)
  set (CMAKE_MACOSX_RPATH TRUE)
endif ()


#    http://www.cognitive-antics.net/2013/06/17/getting-source-and-build-version-with-cmake/
#    Store the git hash of the current head
if (EXISTS "${PROJECT_SOURCE_DIR}/.git/HEAD")
    file(READ "${PROJECT_SOURCE_DIR}/.git/HEAD" PROJECT_SOURCE_VERSION)
    if ("${PROJECT_SOURCE_VERSION}" MATCHES "^ref:")
        string(REGEX REPLACE "^ref: *([^ \n\r]*).*" "\\1"   ${PROJECT_NAME_UPPER}_GIT_REF "${PROJECT_SOURCE_VERSION}")
        file(READ "${PROJECT_SOURCE_DIR}/.git/${${PROJECT_NAME_UPPER}_GIT_REF}" PROJECT_SOURCE_VERSION)
    endif ()
    string(STRIP "${PROJECT_SOURCE_VERSION}"    PROJECT_SOURCE_VERSION)
endif ()

#    Store the build date
if (WIN32)
    execute_process(COMMAND "cmd" " /c date /t" OUTPUT_VARIABLE DATE)
    string(REGEX REPLACE "[^0-9]*(..).*" "\\1" MONTH "${DATE}")
    set (MONTHS ""
        "Jan" "Feb" "Mar" "Apr" "May" "Jun"
        "Jul" "Aug" "Sep" "Oct" "Nov" "Dec")
    list(GET MONTHS "${MONTH}" MONTH)
    string(REGEX REPLACE "[^/]*/(..)/(....).*" "\\1 ${MONTH} \\2"   ${PROJECT_NAME_UPPER}_BUILD_DATE "${DATE}")
    execute_process(COMMAND "cmd" " /c echo %TIME%" OUTPUT_VARIABLE TIME)
    string(REGEX REPLACE "[^0-9]*(..:..:..).*" "\\1"    ${PROJECT_NAME_UPPER}_BUILD_TIME "${TIME}")
else ()
    execute_process(COMMAND "date" "+%d %b %Y/%H:%M:%S" OUTPUT_VARIABLE DATE_TIME)
    string(REGEX REPLACE "([^/]*)/.*" "\\1" ${PROJECT_NAME_UPPER}_BUILD_DATE "${DATE_TIME}")
    string(REGEX REPLACE "[^/]*/([0-9:]*).*" "\\1"  ${PROJECT_NAME_UPPER}_BUILD_TIME "${DATE_TIME}")
endif ()
#    Version Information ---------------------------------------------------------

set (${PROJECT_NAME_UPPER}_MAJOR 1)
set (${PROJECT_NAME_UPPER}_MINOR 0)
set (${PROJECT_NAME_UPPER}_FEATURE 0)
set (${PROJECT_NAME_UPPER}_PATCH 0)
set (${PROJECT_NAME_UPPER}_SOURCE_VERSION "${${PROJECT_NAME_UPPER}_MAJOR}.${${PROJECT_NAME_UPPER}_MINOR}")
set (${PROJECT_NAME_UPPER}_SOURCE_VERSION "${${PROJECT_NAME_UPPER}_SOURCE_VERSION}.${${PROJECT_NAME_UPPER}_FEATURE}.${${PROJECT_NAME_UPPER}_PATCH}")
set (${PROJECT_NAME_UPPER}_SOURCE_VERSION   ${PROJECT_SOURCE_VERSION})

include (CheckCCompilerFlag)
include (CheckCXXCompilerFlag)
include (CheckCXXSymbolExists)
include (CheckIncludeFiles)
include (CheckLibraryExists)
include (CheckSymbolExists)
include (CMakeParseArguments)
include (CMakePushCheckState)
include (CTest)
include (FeatureSummary)
include (GenerateExportHeader)

set (_shared_output 1)

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

message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module initial" "CMAKE_FIND_LIBRARY_SUFFIXES" "=" "${CMAKE_FIND_LIBRARY_SUFFIXES}")

if (BUILD_SHARED_LIBS)
    set (LIBRARY_PREFIX "${CMAKE_SHARED_LIBRARY_PREFIX}")
    set (LIBRARY_SUFFIX "${CMAKE_SHARED_LIBRARY_SUFFIX}")
    set (CMAKE_FIND_LIBRARY_SUFFIXES    ${CMAKE_SHARED_LIBRARY_SUFFIX})
else ()
    set (LIBRARY_PREFIX "${CMAKE_STATIC_LIBRARY_PREFIX}")
    set (LIBRARY_SUFFIX "${CMAKE_STATIC_LIBRARY_SUFFIX}")
    set (CMAKE_FIND_LIBRARY_SUFFIXES    ${CMAKE_STATIC_LIBRARY_SUFFIX})
endif ()

message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module current" "CMAKE_FIND_LIBRARY_SUFFIXES" "=" "${CMAKE_FIND_LIBRARY_SUFFIXES}")

set (_build_shard_libs 1)

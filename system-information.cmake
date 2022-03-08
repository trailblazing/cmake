# D=tributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
CMakePrintSystemInformation
---------------------------

Print system information.

Th= module serves diagnostic purposes. Just include it in a
project to see various internal CMake variables.
#]=======================================================================]

if (NOT _common_cmake_included)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/common.cmake")
        include (${CMAKE_CURRENT_LIST_DIR}/common.cmake)
    endif()
endif ()

message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_SYSTEM"                              "=" "${CMAKE_SYSTEM} ${CMAKE_SYSTEM_NAME} ${CMAKE_SYSTEM_VERSION} ${CMAKE_SYSTEM_PROCESSOR}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_SYSTEM file"                         "=" "${CMAKE_SYSTEM_INFO_FILE}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_C_COMPILER"                          "=" "${CMAKE_C_COMPILER}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_CXX_COMPILER"                        "=" "${CMAKE_CXX_COMPILER}")

message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS"       "=" "${CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS"     "=" "${CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_DL_LIBS"                             "=" "${CMAKE_DL_LIBS}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_SHARED_LIBRARY_PREFIX"               "=" "${CMAKE_SHARED_LIBRARY_PREFIX}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_SHARED_LIBRARY_SUFFIX"               "=" "${CMAKE_SHARED_LIBRARY_SUFFIX}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_STATIC_LIBRARY_PREFIX"               "=" "${CMAKE_STATIC_LIBRARY_PREFIX}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_STATIC_LIBRARY_SUFFIX"               "=" "${CMAKE_STATIC_LIBRARY_SUFFIX}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_COMPILER_IS_GNUCC"                   "=" "${CMAKE_COMPILER_IS_GNUCC}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_COMPILER_IS_GNUCXX"                  "=" "${CMAKE_COMPILER_IS_GNUCXX}")

#   if (NOT DEFINED lead_mark_location)
#       set (lead_mark_location 57 CACHE STRING "location of lead mark, eg. =" FORCE)
#   endif ()
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_CXX_CREATE_SHARED_LIBRARY"           "=" "${CMAKE_CXX_CREATE_SHARED_LIBRARY}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_CXX_CREATE_SHARED_MODULE"            "=" "${CMAKE_CXX_CREATE_SHARED_MODULE}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_CXX_CREATE_STATIC_LIBRARY"           "=" "${CMAKE_CXX_CREATE_STATIC_LIBRARY}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_CXX_COMPILE_OBJECT"                  "=" "${CMAKE_CXX_COMPILE_OBJECT}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_CXX_LINK_EXECUTABLE"                 "=" "${CMAKE_CXX_LINK_EXECUTABLE}")

message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_C_CREATE_SHARED_LIBRARY"             "=" "${CMAKE_C_CREATE_SHARED_LIBRARY}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_C_CREATE_SHARED_MODULE"              "=" "${CMAKE_C_CREATE_SHARED_MODULE}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_C_CREATE_STATIC_LIBRARY"             "=" "${CMAKE_C_CREATE_STATIC_LIBRARY}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_C_COMPILE_OBJECT"                    "=" "${CMAKE_C_COMPILE_OBJECT}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_C_LINK_EXECUTABLE"                   "=" "${CMAKE_C_LINK_EXECUTABLE}")

message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_SYSTEM_AND_CXX_COMPILER_INFO_FILE"   "=" "${CMAKE_SYSTEM_AND_CXX_COMPILER_INFO_FILE}")
message_format (STATUS "${lead_mark_location}" "system information" "CMAKE_SYSTEM_AND_C_COMPILER_INFO_FILE"     "=" "${CMAKE_SYSTEM_AND_C_COMPILER_INFO_FILE}")

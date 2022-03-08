# https://github.com/ldc-developers/ldc/blob/master/cmake/Modules/FindLLVM.cmake

# - Find LLVM headers and libraries.
# This module locates LLVM and adapts the llvm-config output for use with
# CMake.
#
# A given list of COMPONENTS is passed to llvm-config.
#
# The following variables are defined:
#  LLVM_FOUND          - true if LLVM was found
#  LLVM_CXXFLAGS       - C++ compiler flags for files that include LLVM headers.
#  LLVM_ENABLE_ASSERTIONS - Whether LLVM was built with enabled assertions (ON/OFF).
#  LLVM_INCLUDE_DIRS   - Directory containing LLVM include files.
#  LLVM_IS_SHARED      - Whether LLVM is going to be linked dynamically (ON) or statically (OFF).
#  LLVM_LDFLAGS        - Linker flags to add when linking against LLVM
#                        (includes -LLLVM_LIBRARY_DIRS).
#  LLVM_LIBRARIES      - Full paths to the library files to link against.
#  LLVM_LIBRARY_DIRS   - Directory containing LLVM libraries.
#  LLVM_NATIVE_ARCH    - Backend corresponding to LLVM_HOST_TARGET, e.g.,
#                        X86 for x86_64 and i686 hosts.
#  LLVM_INSTALL_PREFIX - The root directory of the LLVM installation.
#                        llvm-config is searched for in ${LLVM_INSTALL_PREFIX}/bin.
#  LLVM_TARGETS_TO_BUILD - List of built LLVM targets.
#  LLVM_VERSION_MAJOR  - Major version of LLVM.
#  LLVM_VERSION_MINOR  - Minor version of LLVM.
#  LLVM_VERSION_STRING - Full LLVM version string (e.g. 6.0.0svn).
#  LLVM_VERSION_BASE_STRING - Base LLVM version string without git/svn suffix (e.g. 6.0.0).
#
# Note: The variable names were chosen in conformance with the offical CMake
# guidelines, see ${CMAKE_ROOT}/Modules/readme.txt.

# We prefer to user-specified LLVM_INSTALL_PREFIX to take precedence over the
# system default locations such as /usr/local/bin.
# message("-- LLVM_INSTALL_PREFIX from command line or cache = ${LLVM_INSTALL_PREFIX}")
if (NOT DEFINED LLVM_INSTALL_PREFIX)
    set(LLVM_INSTALL_PREFIX $ENV{LLVM_INSTALL_PREFIX})
    if (DEFINED LLVM_INSTALL_PREFIX)
        message("-- LLVM_INSTALL_PREFIX from cacheenvironment = ${LLVM_INSTALL_PREFIX}")
    endif ()
else()
    message("-- LLVM_INSTALL_PREFIX from cache = ${LLVM_INSTALL_PREFIX}")
endif ()

if (NOT DEFINED LLVM_CONFIG_EXECUTABLE)
    set(LLVM_CONFIG_EXECUTABLE $ENV{LLVM_CONFIG_EXECUTABLE})
    if (NOT DEFINED LLVM_CONFIG_EXECUTABLE)
        find_program(LLVM_CONFIG_EXECUTABLE "llvm-config")
    endif ()
    if (NOT DEFINED LLVM_CONFIG_EXECUTABLE)
        # Executing find_program()
        # multiples times is the approach recommended in the docs.
        set(llvm_config_names llvm-config)
        # Try suffixed versions to pick up the newest LLVM install available on Debian
        # derivatives.
        foreach(major RANGE 99 3)
            list(APPEND llvm_config_names "llvm-config${major}" "llvm-config-${major}")
            foreach(minor RANGE 9 0)
                list(APPEND llvm_config_names "llvm-config${major}${minor}" "llvm-config-${major}.${minor}" "llvm-config-mp-${major}.${minor}")
            endforeach ()
        endforeach ()
        if(APPLE)
            execute_process(COMMAND brew --prefix llvm OUTPUT_VARIABLE BREW_LLVM_PATH RESULT_VARIABLE BREW_LLVM_RESULT)
            if (NOT ${BREW_LLVM_RESULT} EQUAL 0)
                set(BREW_LLVM_PATH "/usr/local/opt/llvm")
            endif ()
            string(STRIP ${BREW_LLVM_PATH} BREW_LLVM_PATH)
            find_program(LLVM_CONFIG_EXECUTABLE NAMES llvm-config PATHS "${BREW_LLVM_PATH}/bin")
        else()
            find_program(LLVM_CONFIG_EXECUTABLE
                NAMES ${llvm_config_names}
                PATHS ${LLVM_INSTALL_PREFIX}/bin NO_DEFAULT_PATH
                DOC "Path to llvm-config tool.")
        endif()
    endif()
    if (DEFINED LLVM_CONFIG_EXECUTABLE)
        message(STATUS "llvm-config executable found on ${CMAKE_SYSTEM_NAME}: ${LLVM_CONFIG_EXECUTABLE}")
    else()
        message(FATAL_ERROR "Could NOT find llvm-config executable and LLVM_INSTALL_PREFIX is not set ")
    endif()
else()
    message("-- LLVM_CONFIG_EXECUTABLE from cache = ${LLVM_CONFIG_EXECUTABLE}")
endif ()

# Prints a warning/failure message depending on the required/quiet flags. Copied
# from FindPackageHandleStandardArgs.cmake because it doesn't seem to be exposed.
macro(_LLVM_FAIL _msg)
  if(LLVM_FIND_REQUIRED)
    message(FATAL_ERROR "${_msg}")
  else()
    if(NOT LLVM_FIND_QUIETLY)
      message(WARNING "${_msg}")
    endif()
  endif()
endmacro()

if(NOT LLVM_FIND_VERSION)
    set (LLVM_FIND_VERSION 12.0.0)
endif()

if(NOT LLVM_CONFIG_EXECUTABLE)
    if(NOT LLVM_FIND_QUIETLY)
        _LLVM_FAIL("No LLVM installation (>= ${LLVM_FIND_VERSION}) found. Try manually setting the 'LLVM_INSTALL_PREFIX' or 'LLVM_CONFIG_EXECUTABLE' variables.")
    endif()
else()
    macro(llvm_set var flag)
       if(LLVM_FIND_QUIETLY)
            set(_quiet_arg ERROR_QUIET)
        endif()
        set(result_code)
        execute_process(
            COMMAND ${LLVM_CONFIG_EXECUTABLE} --${flag}
            RESULT_VARIABLE result_code
            OUTPUT_VARIABLE LLVM_${var}
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ${_quiet_arg}
        )
        if(result_code)
            _LLVM_FAIL("Failed to execute llvm-config ('${LLVM_CONFIG_EXECUTABLE}', result code: '${result_code})'")
        else()
            if(${ARGV2})
                file(TO_CMAKE_PATH "${LLVM_${var}}" LLVM_${var})
                message("-- TO_CMAKE_PATH LLVM_${var} from llvm-config = ${LLVM_${var}}")
            endif()
        endif()
    endmacro()
    macro(llvm_set_libs var flag components)
       if(LLVM_FIND_QUIETLY)
            set(_quiet_arg ERROR_QUIET)
        endif()
        set(result_code)
        execute_process(
            COMMAND ${LLVM_CONFIG_EXECUTABLE} --${flag} ${components}
            RESULT_VARIABLE result_code
            OUTPUT_VARIABLE tmplibs
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ${_quiet_arg}
        )
        if(result_code)
            _LLVM_FAIL("Failed to execute llvm-config ('${LLVM_CONFIG_EXECUTABLE}', result code: '${result_code})'")
        else()
            file(TO_CMAKE_PATH "${tmplibs}" tmplibs)
            string(REGEX MATCHALL "${pattern}[^ ]+" LLVM_${var} ${tmplibs})
            message("-- TO_CMAKE_PATH LLVM_${var} from llvm-config = ${LLVM_${var}}")
        endif()
    endmacro()

    llvm_set(INSTALL_PREFIX prefix)

    if (NOT DEFINED LLVM_INSTALL_PREFIX)
        message(FATAL_ERROR "Could NOT find llvm-config executable and LLVM_INSTALL_PREFIX is not set ")
    else()
        message("-- LLVM_INSTALL_PREFIX from cache = ${LLVM_INSTALL_PREFIX}")
    endif ()

    if ("${LLVM_INSTALL_PREFIX}" STREQUAL "/")
        exec_process(COMMAND "realpath ${LLVM_INSTALL_PREFIX}" OUTPUT_VARIABLE _llvm_install_prefix)
        if ("${_llvm_install_prefix}" STREQUAL "/")
            message_format (FATAL_ERROR "${lead_mark_location}" "compiler option" "LLVM_INSTALL_PREFIX NOT DEFINED" "" "")
        else()
            set (LLVM_INSTALL_PREFIX "${_llvm_install_prefix}" CACHE STRING "refresh vale" FORCE )
            message_format (STATUS "${lead_mark_location}" "compiler option" "LLVM_INSTALL_PREFIX" "=" "${LLVM_INSTALL_PREFIX}")
        endif ()
    endif ()

    llvm_set(CMAKE_DIR cmakedir)
    llvm_set(VERSION_STRING version)
    llvm_set(CXXFLAGS cxxflags)
    llvm_set(INCLUDE_DIRS includedir true)
    llvm_set(ROOT_DIR prefix true)
    llvm_set(ENABLE_ASSERTIONS assertion-mode)

    # The LLVM version string _may_ contain a git/svn suffix, so match only the x.y.z part
    string(REGEX MATCH "^[0-9]+[.][0-9]+[.][0-9]+" LLVM_VERSION_BASE_STRING "${LLVM_VERSION_STRING}")

    llvm_set(SHARED_MODE shared-mode)
    if(LLVM_SHARED_MODE STREQUAL "shared")
        set(LLVM_IS_SHARED ON)
    else()
        set(LLVM_IS_SHARED OFF)
    endif()

    llvm_set(LDFLAGS ldflags)
    llvm_set(SYSTEM_LIBS system-libs)
    string(REPLACE "\n" " " LLVM_LDFLAGS "${LLVM_LDFLAGS} ${LLVM_SYSTEM_LIBS}")
    if(APPLE) # unclear why/how this happens
        string(REPLACE "-llibxml2.tbd" "-lxml2" LLVM_LDFLAGS ${LLVM_LDFLAGS})
    endif()

    llvm_set(LIBRARY_DIRS libdir true)
    llvm_set_libs(LIBRARIES libs "${LLVM_FIND_COMPONENTS}")
    # LLVM bug: llvm-config --libs tablegen returns -lLLVM-3.8.0
    # but code for it is not in shared library
    if("${LLVM_FIND_COMPONENTS}" MATCHES "tablegen")
        if (NOT "${LLVM_LIBRARIES}" MATCHES "LLVMTableGen")
            set(LLVM_LIBRARIES "${LLVM_LIBRARIES};-lLLVMTableGen")
        endif()
    endif()

    llvm_set(CMAKEDIR cmakedir)
    llvm_set(TARGETS_TO_BUILD targets-built)
    string(REGEX MATCHALL "${pattern}[^ ]+" LLVM_TARGETS_TO_BUILD ${LLVM_TARGETS_TO_BUILD})

    # Parse LLVM_NATIVE_ARCH manually from LLVMConfig.cmake; including it leads to issues like
    # https://github.com/ldc-developers/ldc/issues/3079.
    file(STRINGS "${LLVM_CMAKEDIR}/LLVMConfig.cmake" LLVM_NATIVE_ARCH LIMIT_COUNT 1 REGEX "^set\\(LLVM_NATIVE_ARCH (.+)\\)$")
    string(REGEX MATCH "set\\(LLVM_NATIVE_ARCH (.+)\\)" LLVM_NATIVE_ARCH "${LLVM_NATIVE_ARCH}")
    set(LLVM_NATIVE_ARCH ${CMAKE_MATCH_1})
    message(STATUS "LLVM_NATIVE_ARCH: ${LLVM_NATIVE_ARCH}")

    # On CMake builds of LLVM, the output of llvm-config --cxxflags does not
    # include -fno-rtti, leading to linker errors. Be sure to add it.
    if(NOT MSVC AND (CMAKE_COMPILER_IS_GNUCXX OR (${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")))
        if(NOT ${LLVM_CXXFLAGS} MATCHES "-fno-rtti")
            set(LLVM_CXXFLAGS "${LLVM_CXXFLAGS} -fno-rtti")
        endif()
    endif()

    # Remove some clang-specific flags for gcc.
    if(CMAKE_COMPILER_IS_GNUCXX)
        string(REPLACE "-Wcovered-switch-default " "" LLVM_CXXFLAGS ${LLVM_CXXFLAGS})
        string(REPLACE "-Wstring-conversion " "" LLVM_CXXFLAGS ${LLVM_CXXFLAGS})
        string(REPLACE "-fcolor-diagnostics " "" LLVM_CXXFLAGS ${LLVM_CXXFLAGS})
        # this requires more recent gcc versions (not supported by 4.9)
        string(REPLACE "-Werror=unguarded-availability-new " "" LLVM_CXXFLAGS ${LLVM_CXXFLAGS})
    endif()

    # Remove gcc-specific flags for clang.
    if(${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
        string(REPLACE "-Wno-maybe-uninitialized " "" LLVM_CXXFLAGS ${LLVM_CXXFLAGS})
    endif()

    string(REGEX REPLACE "([0-9]+).*" "\\1" LLVM_VERSION_MAJOR "${LLVM_VERSION_STRING}" )
    # string(REGEX REPLACE "([0-9]+).([0-9]+).([0-9]+).*[A-Za-z]*" "\\1\\2\\3" LLVM_VERSION_NUMBER "${LLVM_VERSION_STRING}" )
    string(REGEX REPLACE "([0-9]+)\\.([0-9]+)\\.([0-9]+).*[A-Za-z]*" "\\1.\\2.\\3" LLVM_VERSION_NUMBER "${LLVM_VERSION_STRING}" )
    if (LLVM_VERSION_STRING MATCHES "([0-9]+)\\.([0-9]+)\\.([0-9]+).*")
        set(LLVM_VERSION_PREFIX "${CMAKE_MATCH_1}.${CMAKE_MATCH_2}.${CMAKE_MATCH_3}" CACHE INTERNAL "" FORCE)
    endif()
    string(REGEX REPLACE "[0-9]+\\.([0-9]+).*[A-Za-z]*" "\\1" LLVM_VERSION_MINOR "${LLVM_VERSION_STRING}" )
    message("-- CMAKE_CURRENT_LIST_DIR = ${CMAKE_CURRENT_LIST_DIR}")
    message("-- CMAKE_CURRENT_SOURCE_DIR = ${CMAKE_CURRENT_SOURCE_DIR}")
    message("-- LLVM_INSTALL_PREFIX from llvm-config = ${LLVM_INSTALL_PREFIX}")
    message("-- LLVM_CMAKE_DIR from llvm-config = ${LLVM_CMAKE_DIR}")

    list (APPEND CMAKE_PREFIX_PATH "${LLVM_CMAKE_DIR}")
    list (APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")

    message("-- LLVM_VERSION_STRING = ${LLVM_VERSION_STRING}")
    message("-- LLVM_VERSION_MAJOR = ${LLVM_VERSION_MAJOR}")

    message("-- LLVM_VERSION_NUMBER = ${LLVM_VERSION_NUMBER}")
    message("-- LLVM_VERSION_PREFIX = ${LLVM_VERSION_PREFIX}")
    message("-- LLVM_VERSION_BASE_STRING = ${LLVM_VERSION_BASE_STRING}")

    message("-- LLVM_VERSION_MINOR = ${LLVM_VERSION_MINOR}")
    if (${LLVM_VERSION_STRING} VERSION_LESS ${LLVM_FIND_VERSION})
        # if (${LLVM_VERSION_NUMBER} VERSION_LESS ${LLVM_FIND_VERSION})
        _LLVM_FAIL("Unsupported LLVM version ${LLVM_VERSION_STRING} found (${LLVM_CONFIG_EXECUTABLE}). At least version ${LLVM_FIND_VERSION} is required. You can also set variables 'LLVM_INSTALL_PREFIX' or 'LLVM_CONFIG_EXECUTABLE' to use a different LLVM installation.")
    endif()
endif()

# Use the default CMake facilities for handling QUIET/REQUIRED.
include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(LLVM
    REQUIRED_VARS LLVM_INSTALL_PREFIX
    VERSION_VAR LLVM_VERSION_STRING)

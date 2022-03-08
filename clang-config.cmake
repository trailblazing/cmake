# https://github.com/Andersbakken/rtags/blob/master/cmake/FindLibClang.cmake
#
# FindLibClang
#
# This module searches libclang and llvm-config, the llvm-config tool is used to
# get information about the installed llvm/clang package to compile LLVM based
# programs.
#
# It defines the following variables
#
# ``LLVM_CONFIG_EXECUTABLE``
#   the llvm-config tool to get various information.
# ``LIBCLANG_LIBRARIES``
#   the clang libraries to link against to use Clang/LLVM.
# ``LIBCLANG_LIBDIR``
#   the directory where the clang libraries are located.
# ``LIBCLANG_FOUND``
#   true if libclang was found
# ``LIBCLANG_VERSION_STRING``
#   version number as a string
# ``LIBCLANG_CXXFLAGS``
#   the compiler flags for files that include LLVM headers
#
#=============================================================================
# Copyright (C) 2011, 2012, 2013 Jan Erik Hanssen and Anders Bakken
# Copyright (C) 2015 Christian Schwarzgruber <c.schwarzgruber.cs@gmail.com>
#
# This file is part of RTags (https://github.com/Andersbakken/rtags).
#
# RTags is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# RTags is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with RTags.  If not, see <https://www.gnu.org/licenses/>.

if ((NOT DEFINED LLVM_INSTALL_PREFIX) OR (NOT DEFINED LLVM_CONFIG_EXECUTABLE))
    if (NOT DEFINED LLVM_INSTALL_PREFIX)
        set(LLVM_INSTALL_PREFIX $ENV{LLVM_INSTALL_PREFIX})
        if (DEFINED LLVM_INSTALL_PREFIX)
            message("-- LLVM_INSTALL_PREFIX from environment = ${LLVM_INSTALL_PREFIX}")
        endif ()
    endif ()
    if (NOT DEFINED LLVM_CONFIG_EXECUTABLE)
        set(LLVM_CONFIG_EXECUTABLE $ENV{LLVM_CONFIG_EXECUTABLE})
        if (DEFINED LLVM_CONFIG_EXECUTABLE)
            message("-- LLVM_CONFIG_EXECUTABLE from environment = ${LLVM_CONFIG_EXECUTABLE}")
        endif ()
    endif ()
    if ((NOT DEFINED LLVM_INSTALL_PREFIX) OR (NOT DEFINED LLVM_CONFIG_EXECUTABLE))
        include (llvm-config)
        if (DEFINED LLVM_INSTALL_PREFIX)
            message("-- LLVM_INSTALL_PREFIX from llvm-config.cmake = ${LLVM_INSTALL_PREFIX}")
        endif ()
        if (DEFINED LLVM_CONFIG_EXECUTABLE)
            message("-- LLVM_CONFIG_EXECUTABLE from llvm-config.cmake = ${LLVM_CONFIG_EXECUTABLE}")
        endif ()
    endif ()
else()
    message("-- LLVM_INSTALL_PREFIX from cache = ${LLVM_INSTALL_PREFIX}")
    message("-- LLVM_CONFIG_EXECUTABLE from cache = ${LLVM_CONFIG_EXECUTABLE}")
endif ()

# https://gitlab.com/h2t/doxygen/-/blob/master/cmake/FindLibClang.cmake
if (NOT CLANG_INSTALL_PREFIX)
    set(CLANG_INSTALL_PREFIX $ENV{CLANG_INSTALL_PREFIX})
    if (NOT CLANG_INSTALL_PREFIX)
        set(CLANG_INSTALL_PREFIX ${LLVM_INSTALL_PREFIX})
        message("-- CLANG_INSTALL_PREFIX from LLVM_INSTALL_PREFIX = ${CLANG_INSTALL_PREFIX}")
    else ()
        message("-- CLANG_INSTALL_PREFIX from environment = ${CLANG_INSTALL_PREFIX}")
    endif ()
else ()
    message("-- CLANG_INSTALL_PREFIX from cache = ${CLANG_INSTALL_PREFIX}")
endif ()

if ("${CLANG_INSTALL_PREFIX}" STREQUAL "/")
    exec_process(COMMAND "realpath ${CLANG_INSTALL_PREFIX}" OUTPUT_VARIABLE _clang_install_prefix)
    if ("${_clang_install_prefix}" STREQUAL "/")
        message_format (FATAL_ERROR "${lead_mark_location}" "compiler option" "CLANG_INSTALL_PREFIX NOT DEFINED" "" "")
    else()
        set (CLANG_INSTALL_PREFIX "${_clang_install_prefix}" CACHE STRING "refresh vale" FORCE )
        message_format (STATUS "${lead_mark_location}" "compiler option" "CLANG_INSTALL_PREFIX" "=" "${CLANG_INSTALL_PREFIX}")
    endif ()
endif ()

set(CLANG_CMAKE_DIR "${CLANG_INSTALL_PREFIX}/lib/cmake/clang")
list (APPEND CMAKE_PREFIX_PATH "${CLANG_CMAKE_DIR}")
list (APPEND CMAKE_MODULE_PATH "${CLANG_CMAKE_DIR}")
message_format (STATUS "${lead_mark_location}" "compiler option" "CLANG_CMAKE_DIR" "=" "${CLANG_CMAKE_DIR}")

if (LLVM_CONFIG_EXECUTABLE)
    message(STATUS "llvm-config found at: ${LLVM_CONFIG_EXECUTABLE}")
else ()
    message(FATAL_ERROR "Could NOT find llvm-config executable.")
endif ()

if (NOT EXISTS ${CLANG_INCLUDEDIR})
    execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --includedir OUTPUT_VARIABLE CLANG_INCLUDEDIR OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (NOT EXISTS ${CLANG_INCLUDEDIR})
        message(FATAL_ERROR "Could NOT find clang includedir. You can fix this by setting CLANG_INCLUDEDIR in your shell or as a cmake variable.")
    endif ()
endif ()

if (NOT EXISTS ${CLANG_LIBDIR})
    execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --libdir OUTPUT_VARIABLE CLANG_LIBDIR OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (NOT EXISTS ${CLANG_LIBDIR})
        message(FATAL_ERROR "Could NOT find clang libdir. You can fix this by setting CLANG_LIBDIR in your shell or as a cmake variable.")
    endif ()
endif ()

if (NOT CLANG_LIBS)
    find_library(CLANG_LIB_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT NAMES clang libclang ${CLANG_INSTALL_PREFIX}/lib ${CLANG_LIBDIR} NO_DEFAULT_PATH)
    if (NOT EXISTS ${CLANG_CLANG_LIB_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT})
        find_library(CLANG_LIBS NAMES clang libclang)
        if (NOT EXISTS ${CLANG_LIBS})
            set (CLANG_LIBS "-L${CLANG_LIBDIR}" "-lclang" "-Wl,-rpath,${CLANG_LIBDIR}")
        endif ()
    else ()
        set(CLANG_LIBS "${CLANG_LIB_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT}")
    endif ()
endif ()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Clang DEFAULT_MSG CLANG_LIBS CLANG_LIBDIR CLANG_INCLUDEDIR)
mark_as_advanced(CLANG_INCLUDEDIR CLANG_LIBDIR)

execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --version OUTPUT_VARIABLE CLANG_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
message("-- Using Clang ${CLANG_VERSION} from ${CLANG_LIBDIR} with LIBS ${CLANG_LIBS} and CXXFLAGS ${CLANG_CXXFLAGS}")

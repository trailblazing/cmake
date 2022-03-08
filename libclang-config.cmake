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

if (NOT LIBCLANG_CXXFLAGS)
    execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --cxxflags OUTPUT_VARIABLE LIBCLANG_CXXFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (NOT LIBCLANG_CXXFLAGS)
        find_path(LIBCLANG_CXXFLAGS_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT clang-c/Index.h HINTS ${LLVM_INSTALL_PREFIX}/include NO_DEFAULT_PATH)
        if (NOT EXISTS ${LIBCLANG_CXXFLAGS_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT})
            find_path(LIBCLANG_CXXFLAGS clang-c/Index.h)
            if (NOT EXISTS ${LIBCLANG_CXXFLAGS})
                message(FATAL_ERROR "Could NOT find clang include path. You can fix this by setting LIBCLANG_CXXFLAGS in your shell or as a cmake variable.")
            endif ()
        else ()
            set(LIBCLANG_CXXFLAGS ${LIBCLANG_CXXFLAGS_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT})
        endif ()
        set(LIBCLANG_CXXFLAGS "-I${LIBCLANG_CXXFLAGS}")
    endif ()
    string(REGEX MATCHALL "-(D__?[a-zA-Z_]*|I([^\" ]+|\"[^\"]+\"))" LIBCLANG_CXXFLAGS "${LIBCLANG_CXXFLAGS}")
    string(REGEX REPLACE ";" " " LIBCLANG_CXXFLAGS "${LIBCLANG_CXXFLAGS}")
    set(LIBCLANG_CXXFLAGS ${LIBCLANG_CXXFLAGS} CACHE STRING "The LLVM C++ compiler flags needed to compile LLVM based applications.")
    unset(LIBCLANG_CXXFLAGS_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT CACHE)
endif ()

if (NOT EXISTS ${LIBCLANG_LIBDIR})
    execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --libdir OUTPUT_VARIABLE LIBCLANG_LIBDIR OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (NOT EXISTS ${LIBCLANG_LIBDIR})
        message(FATAL_ERROR "Could NOT find clang libdir. You can fix this by setting LIBCLANG_LIBDIR in your shell or as a cmake variable.")
    endif ()
    set(LIBCLANG_LIBDIR ${LIBCLANG_LIBDIR} CACHE STRING "Path to the clang library.")
endif ()

if (NOT LIBCLANG_LIBRARIES)
    # find_library(LibClang_LIBRARY NAMES clang)
    find_library(LIBCLANG_LIB_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT NAMES clang libclang HINTS ${LIBCLANG_LIBDIR} ${LLVM_INSTALL_PREFIX}/lib NO_DEFAULT_PATH)
    if (LIBCLANG_LIB_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT)
        set(LIBCLANG_LIBRARIES "${LIBCLANG_LIB_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT}")
    else ()
        find_library(LIBCLANG_LIBRARIES NAMES clang libclang)
        if (NOT EXISTS ${LIBCLANG_LIBRARIES})
            set (LIBCLANG_LIBRARIES "-L${LIBCLANG_LIBDIR}" "-lclang" "-Wl,-rpath,${LIBCLANG_LIBDIR}")
        endif ()
    endif ()
    unset(LIBCLANG_LIB_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT CACHE)
endif ()

if (NOT LIBCLANG_SYSTEM_LIBS)
    execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --system-libs OUTPUT_VARIABLE LIBCLANG_SYSTEM_LIBS OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (LIBCLANG_SYSTEM_LIBS)
        set (LIBCLANG_LIBRARIES ${LIBCLANG_LIBRARIES} ${LIBCLANG_SYSTEM_LIBS})
    endif ()
endif ()
set(LibClang_LIBRARY ${LIBCLANG_LIBRARIES} CACHE FILEPATH "Path to the libclang library")
set(LibClang_LIBRARIES ${LibClang_LIBRARY})

if (LLVM_CONFIG_EXECUTABLE)
    execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --version OUTPUT_VARIABLE LIBCLANG_VERSION_STRING OUTPUT_STRIP_TRAILING_WHITESPACE)
else ()
    set(LIBCLANG_VERSION_STRING "Unknown")
endif ()
message("-- Using Clang version ${LIBCLANG_VERSION_STRING} from ${LIBCLANG_LIBDIR} with CXXFLAGS ${LIBCLANG_CXXFLAGS}")


# https://unix.stackexchange.com/questions/104538/trouble-embedding-clang-in-a-standalone-application

execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --cxxflags OUTPUT_VARIABLE LibClang_DEFINITIONS)
remove_new_line(LibClang_DEFINITIONS)
# set(LibClang_DEFINITIONS ${LibClang_DEFINITIONS} "-fno-rtti")

execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --includedir OUTPUT_VARIABLE LibClang_INCLUDE_DIR)
remove_new_line(LibClang_INCLUDE_DIR)
set(LibClang_INCLUDE_DIRS ${LibClang_INCLUDE_DIR})

execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --prefix OUTPUT_VARIABLE CLANG_INSTALL_PREFIX)
remove_new_line(CLANG_INSTALL_PREFIX)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibClang DEFAULT_MSG LibClang_LIBRARY LibClang_INCLUDE_DIR LIBCLANG_CXXFLAGS LIBCLANG_LIBDIR)
# Handly the QUIETLY and REQUIRED arguments and set LIBCLANG_FOUND to TRUE if all listed variables are TRUE
mark_as_advanced(LIBCLANG_CXXFLAGS LibClang_INCLUDE_DIR LibClang_LIBRARY LLVM_CONFIG_EXECUTABLE LIBCLANG_LIBDIR)

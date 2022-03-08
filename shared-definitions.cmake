# Global projects source code shared definitions. will introduce heavy libraries

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

add_definitions (-DUSE_SYSTRAYICON)
add_definitions (-DUSE_SIGNAL_CLOSE)
add_definitions (-DUSE_STRINGLIST_MODEL)


#    https://github.com/woboq/verdigris
remove_definitions (-DQ_MOC_RUN)
add_definitions (-DUSE_VERDIGRIS_TO_REMOVE_MOC)

add_definitions (-DUSE_QSTRING)
add_definitions (-DPOINTER_DELEGATE_SIGNAL_SLOT)
add_definitions (-DUSE_NAMEDTYPE)       # add_definitions (-DUSE_BOOST_STRONG_TYPEDEF_EXTENSION)
add_definitions (-DUSE_METAL_TMPL)
add_definitions (-DUSE_BOOST_SIGNALS2)  # add_definitions (-DUSE_SIGSLOT)    # add_definitions (-DUSE_SIGC)   # add_definitions (-DUSE_METAL_TMPL)
add_definitions (-DUSE_DOCKER_RESIZE_EVENT)

add_definitions (-DUSE_FEATHERPAD)      # add_definitions (-DUSE_WYEDIT)
add_definitions (-DUSE_BLOG)

if (DONOT_BUILD_SHARED_LIBS)
    option (BUILD_SHARED_LIBS "Indicate that the dependencies of this project are not prefering shared libraries" OFF)
else ()
    option (BUILD_SHARED_LIBS "Indicate that the dependencies of this project are prefering shared libraries" ON)
endif ()
unset (DONOT_BUILD_STATIC_LIBS CACHE)

if (DONOT_USE_PKG_CONFIG)
    option (USE_PKG_CONFIG  "using PkgConfig"    OFF)
else ()
    option (USE_PKG_CONFIG  "using PkgConfig"    ON)
endif ()
unset (DONOT_USE_PKG_CONFIG CACHE)

# Packager can specify not to use QPlainTextEdit, even if Qt 4.4.0 is present
# Note, the author has found that it does not scroll in between going below the
# bottom of the widget and pressing Enter.

if (NOT USE_PTE)
    set (DONT_USE_PTE TRUE)
endif ()

if (DONT_USE_PTE)
    add_definitions (-DDONT_USE_PTE)
endif ()

if (DONT_USE_DBUS OR WIN32) # Because you don't get D-Bus on Windows
    if (NOT USE_DBUS)         # But let's let the user specify it, in case someone ports it
        set (USE_DBUS FALSE)
    endif ()
else ()
    if (NOT APPLE)        # This doesn't preclude the user from specifying D-Bus
        set (USE_DBUS TRUE)    # on the command line.
    endif ()
endif ()

if (DONT_USE_STI)
    set (USE_STI FALSE)
    set (USE_DBUS FALSE)
else ()
    set (USE_STI TRUE)
endif ()

set (_shared_definitions 1)

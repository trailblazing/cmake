
if (NOT _common_cmake_included)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/common.cmake")
        include (${CMAKE_CURRENT_LIST_DIR}/common.cmake)
    endif()
endif ()

# message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "initial CMAKE_CURRENT_LIST_DIR" = "${CMAKE_CURRENT_LIST_DIR}")
if (COMMAND cmake_policy)
    cmake_policy(SET CMP0057 NEW)
endif ()

#https://lists.freedesktop.org/archives/gstreamer-commits/2013-June/072149.html
#   qmake -query
#   QT_SYSROOT:
#   QT_INSTALL_PREFIX:/usr
#   QT_INSTALL_ARCHDATA:/usr/lib/qt5
#   QT_INSTALL_DATA:/usr/share/qt5
#   QT_INSTALL_DOCS:/usr/share/doc/qt5
#   QT_INSTALL_HEADERS:/usr/include/qt5
#   QT_INSTALL_LIBS:/usr/lib
#   QT_INSTALL_LIBEXECS:/usr/lib/qt5/libexec
#   QT_INSTALL_BINS:/usr/lib/qt5/bin
#   QT_INSTALL_TESTS:/usr/tests
#   QT_INSTALL_PLUGINS:/usr/lib/qt5/plugins
#   QT_INSTALL_IMPORTS:/usr/lib/qt5/imports
#   QT_INSTALL_QML:/usr/lib/qt5/qml
#   QT_INSTALL_TRANSLATIONS:/usr/share/qt5/translations
#   QT_INSTALL_CONFIGURATION:/etc/xdg
#   QT_INSTALL_EXAMPLES:/usr/share/qt5/examples
#   QT_INSTALL_DEMOS:/usr/share/qt5/examples
#   QT_HOST_PREFIX:/usr
#   QT_HOST_DATA:/usr/lib/qt5
#   QT_HOST_BINS:/usr/lib/qt5/bin
#   QT_HOST_LIBS:/usr/lib
#   QMAKE_SPEC:linux-g++
#   QMAKE_XSPEC:linux-g++
#   QMAKE_VERSION:3.1
#   QT_VERSION:5.15.2
function (_qt5_query_qmake VAR)
    if (NOT DEFINED Qt5Core_QMAKE_EXECUTABLE)
        find_package (Qt5Core QUIET)
    endif ()
    #    get_target_property(_QMAKE ${QT_QMAKE_EXECUTABLE} IMPORTED_LOCATION)   #
    get_target_property (_QMAKE ${Qt5Core_QMAKE_EXECUTABLE} IMPORTED_LOCATION)
    execute_process (COMMAND "${_QMAKE}" -query ${VAR}
        RESULT_VARIABLE return_code # 0
        OUTPUT_VARIABLE output      # /usr/lib/qt5/imports
        OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_STRIP_TRAILING_WHITESPACE)
    #   message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} _qt5_query_qmake" "_QMAKE" = "${_QMAKE}")           # _QMAKE                = /usr/lib/qt5/bin/qmake
    #   message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} _qt5_query_qmake" "VAR" = "${VAR}")                 # VAR                   = QT_INSTALL_IMPORTS
    #   message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} _qt5_query_qmake" "return_code" = "${return_code}") # return_code           = 0
    #   message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} _qt5_query_qmake" "output" = "${output}")           # output                = /usr/lib/qt5/imports
    if (NOT return_code)
        file (TO_CMAKE_PATH "${output}" output )
        set (${VAR}     ${output})  # local setting
        set (${VAR}     ${output} PARENT_SCOPE)
    endif ()
    #   message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} _qt5_query_qmake" "${VAR}" = "${${VAR}}")
endfunction ()


# PROJECT_QT5_MODULES:      write parameter
# PROJECT_QT5_MODULES_NAME: write parameter
# module_list:              read parameter
macro(find_qt5_modules lead_mark_location MODULES_INCLUDE_DIRS CMAKE_MODULE_PATH PROJECT_QT5_MODULES PROJECT_QT5_MODULES_NAME module_list)
    list(REMOVE_DUPLICATES "${module_list}")

    #foreach(item Core Gui Widgets Network PrintSupport WebEngineWidgets Xml )  # ${${PROJECT_NAME_UPPER}_MODULES} )  # Core Sql Widgets Quick Multimedia Qml)
    #    message(STATUS "${PROJECT_NAME} module Qt5${module}_FOUND = ${Qt5${module}_FOUND}")
    #    if(${Qt5${module}_FOUND})
    #        string(TOUPPER ${module} item)
    #        message(STATUS "${PROJECT_NAME} module: ${Qt5${item}_LIBRARY} found!")
    #    endif()
    #endforeach()
    add_definitions(-D"QT5_STRICT_PLUGIN_GLOB")

    foreach(module ${module_list} )
        #    foreach(c ${${PROJECT_NAME_UPPER}_MODULES} )  # Core Sql Widgets Quick Multimedia Qml)
        if(NOT ${module} STREQUAL "")                                       # Core  or # Qt5::Core
            #    message(STATUS "${PROJECT_NAME} module name: ${module}")
            string(FIND "${module}" "Qt5::" index)
            if(NOT ${index} EQUAL -1)                                       # Qt5::Core
                string(LENGTH "Qt5::" head_length)
                string(LENGTH "${module}" full_length)
                math(EXPR begin_point   "${head_length}"                    OUTPUT_FORMAT DECIMAL)
                math(EXPR length        "${full_length} - ${head_length}"   OUTPUT_FORMAT DECIMAL)
                string(SUBSTRING ${module} ${begin_point} ${length} sub)    # Core
                set(module_colon_name ${module})                            # Qt5::Core
            else()                                                          # Core
                set(sub ${module})                                          # Core
                string(CONCAT module_colon_name "Qt5::" ${sub})             # Qt5::Core
            endif()

            string(CONCAT module_name "Qt5" ${sub} )                        # Qt5Core
            string(CONCAT module_include_dirs "Qt5" ${sub} "_INCLUDE_DIRS") # Qt5Core_DIR
            string(CONCAT module_dir "Qt5" ${sub} "_DIR")                   # Qt5Core_DIR
            string(CONCAT lib_found ${module_name} "_FOUND")                # Qt5Core_FOUND
            string(CONCAT lib_name ${module_name} "_LIBRARY")               # Qt5Core_LIBRARY

            string(TOUPPER ${sub} item)                                       # CORE

            find_package(${module_name} QUIET)
            if (NOT ${lib_found}) # if (NOT TARGET ${module_name} )
                #   if(NOT TARGET ${lib_name})
                #   endif()
                message(FATAL_ERROR "${PROJECT_NAME} module: ${lib_found} \t= ${${lib_found}}")
            else()
                list(APPEND ${MODULES_INCLUDE_DIRS} "${${module_include_dirs}}" )
                #    set(${MODULES_INCLUDE_DIRS} "${${MODULES_INCLUDE_DIRS}}" PARENT_SCOPE)
                list(APPEND ${CMAKE_MODULE_PATH} "${${module_dir}}" )
                #    set(${CMAKE_MODULE_PATH} "${${CMAKE_MODULE_PATH}}"  PARENT_SCOPE)

                #    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} check value" "${lib_name}" "=" "${${lib_name}}")    # empty
                #    list(APPEND ${PROJECT_QT5_MODULES} "${${lib_name}}")

                #    message(STATUS "${PROJECT_NAME} module: ${lib_found} \t= ${${lib_found}}")
                #   endif (NOT ${lib_found})
                list (APPEND ${PROJECT_QT5_MODULES_NAME} "${module_colon_name}")
                #   if(${lib_found})    # if (TARGET ${module_name} )
                get_target_property(${lib_name} ${module_colon_name} IMPORTED_LOCATION_RELEASE)
                #    message(STATUS "${PROJECT_NAME} module: ${lib_name} \t= ${${lib_name}}")
                if(${${lib_found}})
                    if(NOT ${${lib_name}} STREQUAL "")
                        #    message(STATUS "${PROJECT_NAME} module: ${module_colon_name}, ${tab_display0} = ${${lib_name}} ")
                        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} initial" "${module_colon_name}" "=" "${${lib_name}}")

                        #   list(APPEND ${PROJECT_QT5_MODULES} "${${lib_name}}")
                        list(APPEND ${PROJECT_QT5_MODULES} "${${lib_name}}")
                    else()
                        message(SEND_ERROR "${PROJECT_NAME} module: ${module_colon_name} path not foound, \tand module path: ${lib_name} \t= ${${lib_name}} ")
                    endif()
                else()
                    message(SEND_ERROR "${PROJECT_NAME} module: ${module_colon_name} not found, \tand module path: ${lib_name} \t= ${${lib_name}} ")
                endif()
            endif(NOT ${lib_found}) # endif(TARGET ${module_name})
        endif()
    endforeach()

    list(REMOVE_DUPLICATES ${CMAKE_MODULE_PATH})
    #   set(${CMAKE_MODULE_PATH} "${${CMAKE_MODULE_PATH}}"  PARENT_SCOPE)
    list(REMOVE_DUPLICATES ${MODULES_INCLUDE_DIRS})
    #   set(${MODULES_INCLUDE_DIRS} "${${MODULES_INCLUDE_DIRS}}" PARENT_SCOPE)
    list(REMOVE_DUPLICATES ${PROJECT_QT5_MODULES})
    #   set(${PROJECT_QT5_MODULES} "${${PROJECT_QT5_MODULES}}" PARENT_SCOPE)
    list(REMOVE_DUPLICATES ${PROJECT_QT5_MODULES_NAME})
    #   set(${PROJECT_QT5_MODULES_NAME} "${${PROJECT_QT5_MODULES_NAME}}" PARENT_SCOPE)


endmacro()



# PROJECT_QT5_MODULES:      write parameter
# PROJECT_QT5_MODULES_NAME: write parameter
# module_list:              read parameter
macro(find_qt5_packages lead_mark_location MODULES_INCLUDE_DIRS CMAKE_MODULE_PATH PROJECT_QT5_MODULES PROJECT_QT5_MODULES_NAME module_list)
    list(REMOVE_DUPLICATES "${module_list}")

    #   message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} initial" "module_list" "=" "${module_list}")
    include (FindPkgConfig)
    find_package (PkgConfig REQUIRED QUIET)

    #foreach(item Core Gui Widgets Network PrintSupport WebEngineWidgets Xml )  # ${${PROJECT_NAME_UPPER}_MODULES} )  # Core Sql Widgets Quick Multimedia Qml)
    #    message(STATUS "${PROJECT_NAME} module Qt5${module}_FOUND = ${Qt5${module}_FOUND}")
    #    if(${Qt5${module}_FOUND})
    #        string(TOUPPER ${module} item)
    #        message(STATUS "${PROJECT_NAME} module: ${Qt5${item}_LIBRARY} found!")
    #    endif()
    #endforeach()

    add_definitions(-D"QT5_STRICT_PLUGIN_GLOB")

    foreach(module ${module_list} )
        #    foreach(c ${${PROJECT_NAME_UPPER}_MODULES} )  # Core Sql Widgets Quick Multimedia Qml)
        if(NOT ${module} STREQUAL "")                                       # Core  or # Qt5::Core
            #    message(STATUS "${PROJECT_NAME} module name: ${module}")
            string(FIND "${module}" "Qt5::" index)
            string (FIND ${module} "Qt5" qt5_index)
            if(NOT ${index} EQUAL -1)                                       # Qt5::Core
                string(LENGTH "Qt5::" head_length)
                string(LENGTH "${module}" full_length)
                math(EXPR begin_point   "${head_length}"                    OUTPUT_FORMAT DECIMAL)
                math(EXPR length        "${full_length} - ${head_length}"   OUTPUT_FORMAT DECIMAL)
                string(SUBSTRING ${module} ${begin_point} ${length} sub)    # Core
                #   set(module_colon_name ${module})                            # Qt5::Core
            elseif (NOT "${qt5_index}" EQUAL -1)                            # Qt5Core
                string(LENGTH "Qt5" head_length)
                string(LENGTH "${module}" full_length)
                math(EXPR begin_point   "${head_length}"                    OUTPUT_FORMAT DECIMAL)
                math(EXPR length        "${full_length} - ${head_length}"   OUTPUT_FORMAT DECIMAL)
                string(SUBSTRING ${module} ${begin_point} ${length} sub)# Core
            else ()
                set(sub ${module})                                          # Core
            endif()
            string(CONCAT module_colon_name "Qt5::" ${sub})             # Qt5::Core

            string(CONCAT module_name "Qt5" ${sub} )                        # Qt5Core
            string(CONCAT module_include_dirs ${module_name} "_INCLUDE_DIRS") # Qt5Core_DIR
            string(CONCAT module_dir ${module_name} "_DIR")                   # Qt5Core_DIR
            string(CONCAT lib_found ${module_name} "_FOUND")                # Qt5Core_FOUND
            string(CONCAT lib_name ${module_name} "_LIBRARY")               # Qt5Core_LIBRARY
            string(CONCAT libraries_names ${module_name} "_LIBRARIES")               # Qt5Core_LIBRARY

            string(TOUPPER ${sub} item)                                     # CORE

            pkg_check_modules(${module_name} REQUIRED ${module_name})
            #   find_package(${module_name} QUIET)

            if(NOT ${${lib_found}}) #   if (NOT ${lib_found} EQUAL 1) # if (NOT TARGET ${module_name} )
                #   if(NOT TARGET lib_name)
                #       #   find_package(${module_name} QUIET)
                #   endif()
                #   if(NOT ${lib_found} EQUAL 1)
                    message(FATAL_ERROR "${PROJECT_NAME} module: ${lib_found} \t= ${${lib_found}}")
            endif()

            list(APPEND ${MODULES_INCLUDE_DIRS} "${${module_include_dirs}}" )
            #    set(${MODULES_INCLUDE_DIRS} "${${MODULES_INCLUDE_DIRS}}" PARENT_SCOPE)
            list(APPEND ${CMAKE_MODULE_PATH} "${${module_dir}}" )
            #    set(${CMAKE_MODULE_PATH} "${${CMAKE_MODULE_PATH}}"  PARENT_SCOPE)

            #    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} check value" "${lib_name}" "=" "${${lib_name}}")    # empty
            #    list(APPEND ${PROJECT_QT5_MODULES} "${${lib_name}}")

            #    message(STATUS "${PROJECT_NAME} module: ${lib_found} \t= ${${lib_found}}")

            list (APPEND ${PROJECT_QT5_MODULES_NAME} "${module_name}")

            #   #   if(${lib_found} EQUAL 1)    # if (TARGET ${module_name} )
            #   get_target_property(${lib_name} ${module_colon_name} IMPORTED_LOCATION_RELEASE)
            #   #   get_target_property(${lib_name} ${module_colon_name} IMPORTED_LOCATION)
            #   #   if(${${lib_found}})
            #   if(NOT ${lib_name} STREQUAL "")
            #       message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} initial" "${module_colon_name}" "=" "${${lib_name}}")

            #       #   list(APPEND ${PROJECT_QT5_MODULES} "${${lib_name}}")
            #       #   list(APPEND ${PROJECT_QT5_MODULES} "${lib_name}")
            #   else()
            #       #   get_target_property(${lib_name} ${module_colon_name} IMPORTED_LOCATION)
            #       get_target_property(${module_name}_LIBRARIES ${module_colon_name} IMPORTED_LOCATION)
            #       if("${${module_name}_LIBRARIES}" STREQUAL "")
            #               message_format(SEND_ERROR "${lead_mark_location}" "${PROJECT_NAME} module" "${module_colon_name} path not foound" "=" "${lib_name} \t= ${${lib_name}} ")
            #       else ()
            #           foreach (element ${${module_name}_LIBRARIES})
            #               message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} initial" "${module_colon_name}" "=" "${element}")
            #           endforeach ()
            #       endif()
            #   endif()
            #   #   else()
            #   #       message(SEND_ERROR "${lead_mark_location}"  "${PROJECT_NAME} module" "${module_colon_name} not found" "=" "${lib_name} \t= ${${lib_name}} ")
            #   #   endif()
            #   #   endif(${lib_found} EQUAL 1) # endif(TARGET ${module_name})

            foreach (lib_index ${libraries_names})
                list(APPEND ${PROJECT_QT5_MODULES} "${lib_index}")
            endforeach ()


        endif()
    endforeach()

    list(REMOVE_DUPLICATES ${CMAKE_MODULE_PATH})
    #   set(${CMAKE_MODULE_PATH} "${${CMAKE_MODULE_PATH}}"  PARENT_SCOPE)
    list(REMOVE_DUPLICATES ${MODULES_INCLUDE_DIRS})
    #   set(${MODULES_INCLUDE_DIRS} "${${MODULES_INCLUDE_DIRS}}" PARENT_SCOPE)
    list(REMOVE_DUPLICATES ${PROJECT_QT5_MODULES})
    #   set(${PROJECT_QT5_MODULES} "${${PROJECT_QT5_MODULES}}" PARENT_SCOPE)
    list(REMOVE_DUPLICATES ${PROJECT_QT5_MODULES_NAME})
    #   set(${PROJECT_QT5_MODULES_NAME} "${${PROJECT_QT5_MODULES_NAME}}" PARENT_SCOPE)


endmacro()


string (FIND "${CMAKE_BUILD_TYPE}" "Deb" debug_index)
if (("${CMAKE_BUILD_TYPE}" STREQUAL "Debug") OR (NOT ${debug_index} EQUAL -1))  # OR ("${CMAKE_BUILD_TYPE}" MATCHES "^Deb") OR ("${CMAKE_BUILD_TYPE}" MATCHES ";Deb") OR ("${CMAKE_BUILD_TYPE}" MATCHES "Deb"))
    set (QT_DEBUG ON)
    option (QT_DEBUG ON)
    add_definitions (-DQT_DEBUG)
    set (CMAKE_VERBOSE_MAKEFILE ON)
    add_definitions (-g -O1)
else ()
    unset (QT_DEBUG)
    option (QT_DEBUG OFF)
    remove_definitions (-DQT_DEBUG)
    add_definitions (-DNO_DEBUG_OUTPUT)
    set ( CMAKE_SKIP_RPATH ON)
endif ()

# Default qt installation using default CMAKE_PREFIX_PATH   = /usr/lib/cmake
# and you dont need to set it.
# Ohterwise, append self-defined path to CMAKE_PREFIX_PATH
# For example, "/opt/qt/5.15.0" is your current prefered qt installation, then
# set (QT5DIR  "/opt/qt/5.15.0/gcc_64")                                 # corresponds to the default value "/usr"
# list (APPEND CMAKE_PREFIX_PATH    "/op/qt/5.15.0/gcc_64/lib/cmake")   # corresponds to the default value "/usr/lib/cmake"
# To avoid hard coding, it should be a shell command:
# cmake /path/to/source -D"QT5DIR=/op/qt/5.15.0/gcc_64" # or the following,
# cmake /path/to/source -D"QTDIR=/op/qt/5.15.0/gcc_64"

if (DEFINED QTDIR)
    check_definition(DONOT_HAS_QTDIR "${QTDIR}/lib/cmake" ${CMAKE_SOURCE_DIR})
    if (DONOT_HAS_QTDIR)
        list (APPEND CMAKE_PREFIX_PATH    "${QTDIR}/lib/cmake")
    endif ()
endif ()

if (DEFINED QT5DIR)
    check_definition(DONOT_HAS_QT5DIR "${QTDIR}/lib/cmake" ${CMAKE_SOURCE_DIR})
    if (DONOT_HAS_QT5DIR)
        list (APPEND CMAKE_PREFIX_PATH    "${QT5DIR}/lib/cmake")
    endif ()
endif ()

if ((NOT DEFINED ) AND (NOT DEFINED ))
endif ()

list(APPEND CMAKE_PREFIX_PATH "${CMAKE_ROOT}/Modules")

if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
    list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
endif ()

if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")
    list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")
endif ()

if ((NOT "${QT5DIR}" IN_LIST "${CMAKE_PREFIX_PATH}") AND (NOT "${QT5DIR}/lib/cmake" IN_LIST "${CMAKE_PREFIX_PATH}"))
    list (APPEND CMAKE_PREFIX_PATH "${QT5DIR}/lib/cmake")
endif ()



message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "QT_SEARCH_PATH" = "${QT_SEARCH_PATH}")
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "CMAKE_FRAMEWORK_PATH" = "${CMAKE_FRAMEWORK_PATH}")

list (REMOVE_DUPLICATES CMAKE_PREFIX_PATH)
list (APPEND CMAKE_MODULE_PATH "${CMAKE_PREFIX_PATH}")

message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "initial CMAKE_INSTALL_PREFIX" = "${CMAKE_INSTALL_PREFIX}")   # /usr/local

if (DEFINED QTDIR)
    set (prefix_dir "${QTDIR}" CACHE STRING "set qt install prefix" FORCE)
endif ()
if (DEFINED QT5DIR)
    set (prefix_dir "${QT5DIR}" CACHE STRING "set qt install prefix" FORCE)
endif ()

if (USE_PKG_CONFIG)
    include (FindPkgConfig)
    find_package (PkgConfig REQUIRED QUIET)

    pkg_check_modules(Qt5Core REQUIRED Qt5Core)
    pkg_check_modules(Qt5Widgets REQUIRED Qt5Widgets)
    # pkg_check_modules(Qt5LinguistTools REQUIRED Qt5LinguistTools)
    list (REMOVE_DUPLICATES Qt5Core_INCLUDE_DIRS)
    foreach (dir ${Qt5Core_INCLUDE_DIRS})
        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "Qt5Core_INCLUDE_DIRS" = "${dir}")
        if (NOT DEFINED prefix_dir)
            string (FIND "${dir}" "/include" qt5_install_prefix_index)
            if (NOT ${qt5_install_prefix_index} EQUAL -1)
                if ("${qt5_install_prefix_index}" EQUAL 0)
                    execute_process(COMMAND "realpath" ARGS "${dir}" OUTPUT_VARIABLE QT5CORE_DIR)
                    remove_new_line(QT5CORE_DIR)
                    string (FIND "${QT5CORE_DIR}" "/include" qt5_install_prefix_index)
                endif ()
                string(SUBSTRING "${dir}" 0  ${qt5_install_prefix_index} prefix_dir )
                #   set (_qt5_install_prefix ${prefix_dir} CACHE STRING FORCE)
            endif ()
        endif ()
    endforeach ()
    list (REMOVE_DUPLICATES Qt5Widgets_INCLUDE_DIRS)
    foreach (dir ${Qt5Widgets_INCLUDE_DIRS})
        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "Qt5Widgets_INCLUDE_DIRS" = "${dir}")
    endforeach ()
    # else ()
    #     if (NOT DEFINED prefix_dir)
    #     endif ()
endif ()


if (NOT EXISTS "${prefix_dir}")

    foreach(module_dir ${CMAKE_MODULE_PATH})
        # message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "CMAKE_MODULE_PATH" = "${module_dir}")

        if (NOT Qt5Core_FOUND)
            if(EXISTS "${module_dir}/Qt5Core/Qt5CoreConfigExtras.cmake")
                include(${module_dir}/Qt5Core/Qt5CoreConfigExtras.cmake)
            endif ()
            if (APPLE)
                if(EXISTS "${module_dir}/Qt5Core/Qt5CoreMacros.cmake")
                    include(${module_dir}/Qt5Core/Qt5CoreMacros.cmake)
                endif ()
            else ()
                if(EXISTS "${module_dir}/Qt5Core/Qt5CoreMacros.cmake")
                    include(${module_dir}/Qt5Core/Qt5CoreConfig.cmake)
                endif ()
            endif ()
            find_package (Qt5Core QUIET)
        else ()
            break()
        endif ()
    endforeach()

    if (NOT Qt5Core_FOUND)
        message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} root" "" = "Deducted _qt5_install_prefix doesn't exit. Try to enable USE_PKG_CONFIG or input QT5DIR/QT5DIR/CMAKE_PREFIX_PATH for qt manually")
    else ()
        string (FIND "${Qt5Core_DIR}" "/lib" qt5_install_prefix_index)
        if (NOT ${qt5_install_prefix_index} EQUAL -1)
            if ("${qt5_install_prefix_index}" EQUAL 0)
                execute_process(COMMAND "realpath" ARGS "${Qt5Core_DIR}" OUTPUT_VARIABLE QT5CORE_DIR)
                remove_new_line(QT5CORE_DIR)
                string (FIND "${QT5CORE_DIR}" "/lib" qt5_install_prefix_index)
            endif ()
            string(SUBSTRING "${Qt5Core_DIR}" 0  ${qt5_install_prefix_index} prefix_dir )
            set (_qt5_install_prefix "${prefix_dir}" CACHE STRING "set qt install prefix" FORCE)
        endif ()
    endif ()

else ()
    set (_qt5_install_prefix "${prefix_dir}" CACHE STRING "set qt install prefix" FORCE)
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "_qt5_install_prefix" = "${_qt5_install_prefix}")
endif ()

if (DEFINED QT_INSTALL_PREFIX)
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "initial QT_INSTALL_PREFIX" = "${QT_INSTALL_PREFIX}")     # /usr empty when pkgconfig
endif ()

if (DEFINED _qt5_install_prefix)
    set (CMAKE_INCLUDE_CURRENT_DIR ON )
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "PROJECT_QT_VERSION" = "${Qt5Core_VERSION}")
    if (NOT DEFINED Qt5_DIR)
        set (Qt5_DIR "${_qt5_install_prefix}/lib/cmake/Qt5" CACHE STRING "set qt config  prefix" FORCE)
        # string (FIND "${Qt5Core_DIR}" "Core" qt5_dir_index)
        # if (NOT ${qt5_dir_index} EQUAL -1)
        #     if ("${qt5_dir_index}" EQUAL 0)
        #         execute_process(COMMAND "realpath" ARGS "${Qt5Core_DIR}" OUTPUT_VARIABLE QT5CORE_DIR)
        #         set (Qt5Core_DIR ${QT5CORE_DIR} "refresh vale" CACHE STRING FORCE )
        #         string (FIND "${QT5CORE_DIR}" "Core" qt5_dir_index)
        #     endif ()
        #     string(SUBSTRING "${Qt5Core_DIR}" 0  ${qt5_dir_index} might_qt5_dir )
        #     if (NOT EXISTS "${might_qt5_dir}")
        #         message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} root" "Qt5_DIR" = "${Qt5_DIR}")
        #     else ()
        #         set (Qt5_DIR "${might_qt5_dir}")
        #         message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "Qt5_DIR" = "${Qt5_DIR}")
        #     endif ()
        # endif ()
    endif ()
    if (NOT DEFINED QT5DIR)
        set (QTDIR  "${_qt5_install_prefix}" CACHE STRING "set qt install prefix" FORCE)
        set (QT5DIR "${_qt5_install_prefix}" CACHE STRING "set qt install prefix" FORCE)
        # string (FIND "${Qt5Core_DIR}" "/lib" qt5dir_index)
        # if (NOT ${qt5dir_index} EQUAL -1)
        #     if ("${qt5dir_index}" EQUAL 0)
        #         execute_process(COMMAND "realpath" ARGS "${Qt5Core_DIR}" OUTPUT_VARIABLE QT5CORE_DIR)
        #         set (Qt5Core_DIR ${QT5CORE_DIR} "refresh vale" CACHE STRING FORCE )
        #         string (FIND "${QT5CORE_DIR}" "/lib" qt5dir_index)
        #     endif ()
        #     string(SUBSTRING "${Qt5Core_DIR}" 0  ${qt5dir_index} might_qt5dir )
        #     if (NOT EXISTS "${might_qt5dir}")
        #         message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} root" "QT5DIR" = "${QT5DIR}")
        #     else ()
        #         set (QT5DIR "${might_qt5dir}")
        #         message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "QT5DIR" = "${QT5DIR}")
        #     endif ()
        # endif ()
        check_definition(DONOT_HAS_QTDIR "${QTDIR}/lib/cmake" ${CMAKE_SOURCE_DIR})
        if (DONOT_HAS_QTDIR)
            list (APPEND CMAKE_PREFIX_PATH    "${QTDIR}/lib/cmake")
            list (APPEND CMAKE_MODULE_PATH    "${QTDIR}/lib/cmake")
        endif ()
        check_definition(DONOT_HAS_QT5DIR "${QTDIR}/lib/cmake" ${CMAKE_SOURCE_DIR})
        if (DONOT_HAS_QT5DIR)
            list (APPEND CMAKE_PREFIX_PATH    "${QT5DIR}/lib/cmake")
            list (APPEND CMAKE_MODULE_PATH    "${QT5DIR}/lib/cmake")
        endif ()
    endif ()
    if (NOT DEFINED QT_QMAKE_EXECUTABLE)
        # https://svn.osgeo.org/ossim/trunk/ossim_package_support/cmake/CMakeModules/FindQt5.cmake
        find_program(QT_QMAKE_EXECUTABLE_FINDQT
            NAMES
            qmake qmake5 qmake-qt5
            PATHS
            "${QTDIR}/bin"
            "${QT5DIR}/bin"
            "$ENV{QTDIR}/bin"
            "$ENV{QT5DIR}/bin"
            "${QT_SEARCH_PATH}/bin"
            PATH_SUFFIXES
            "${QT5DIR}"
            NO_DEFAULT_PATH
            NO_PACKAGE_ROOT_PATH
            NO_CMAKE_PATH
            NO_CMAKE_ENVIRONMENT_PATH
            NO_SYSTEM_ENVIRONMENT_PATH
            NO_CMAKE_SYSTEM_PATH
            NO_CMAKE_FIND_ROOT_PATH # | ONLY_CMAKE_FIND_ROOT_PATH  # |    CMAKE_FIND_ROOT_PATH_BOTH |
            )
        if (NOT DEFINED QT_QMAKE_EXECUTABLE_FINDQT)
            message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} root" "" ""  "QT_QMAKE_EXECUTABLE_FINDQT NOT DEFINED ")
        else ()
            set (QT_QMAKE_EXECUTABLE ${QT_QMAKE_EXECUTABLE_FINDQT} CACHE PATH "Qt qmake program." FORCE)
            message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "QT_QMAKE_EXECUTABLE" = "${QT_QMAKE_EXECUTABLE}")
        endif ()
    else ()
        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "QT_QMAKE_EXECUTABLE" = "${QT_QMAKE_EXECUTABLE}")
    endif ()

    if (DEFINED Qt5Core_QMAKE_EXECUTABLE)                                                               # Qt5::qmake
        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "Qt5Core_QMAKE_EXECUTABLE" = "${Qt5Core_QMAKE_EXECUTABLE}")    # Qt5::qmake
        get_target_property(QT5_QMAKE_EXECUTABLE Qt5::qmake LOCATION)                                   # /usr/bin/qmake-qt5
        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "QT5_QMAKE_EXECUTABLE" = "${QT5_QMAKE_EXECUTABLE}")  # /usr/lib/qt5/bin/qmake

        add_definitions (-DQT5_STRICT_PLUGIN_GLOB)

        set (cmake_qt_prefix_path "${CMAKE_PREFIX_PATH}")

        # message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module: QT_INCLUDE_DIR" = "${QT_INCLUDE_DIR}")
        # message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module: QT_QTCORE_INCLUDE_DIR" = "${QT_QTCORE_INCLUDE_DIR}")
        # message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module: QT_QTGUI_INCLUDE_DIR" = "${QT_QTGUI_INCLUDE_DIR}")
        # message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module: QT_QTWEBENGINEWIDGETS_INCLUDE_DIR" = "${QT_QTWEBENGINEWIDGETS_INCLUDE_DIR}")
        # message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module: QT_QTNETWORK_INCLUDE_DIR" = "${QT_QTNETWORK_INCLUDE_DIR}")
        # message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module: QT_QTWIDGETS_INCLUDE_DIR" = "${QT_QTWIDGETS_INCLUDE_DIR}")
        # message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module: QT_QTPRINTSUPPORT_INCLUDE_DIR" = "${QT_QTPRINTSUPPORT_INCLUDE_DIR}")
        # message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module: QT_QTCORE_LIBRARY" = "${QT_QTCORE_LIBRARY}")
        # message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module: QT_QMAKE_EXECUTABLE" = "${QT_QMAKE_EXECUTABLE}")    # /usr/bin/qmake-qt5

        _qt5_query_qmake(QT_INSTALL_LIBS)
        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "QT_INSTALL_LIBS" = "${QT_INSTALL_LIBS}")
    endif ()

    if (DEFINED _qt5Core_install_prefix)
        #    if ((NOT DEFINED CMAKE_PREFIX_PATH) OR (NOT "${CMAKE_PREFIX_PATH}" STREQUAL "${_qt5Core_install_prefix}"))
        #        set (CMAKE_PREFIX_PATH "${_qt5Core_install_prefix}" CACHE STRING "CMAKE_PREFIX_PATH install path" FORCE)
        #    endif ()
        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "_qt5Core_install_prefix" = "${_qt5Core_install_prefix}")

        if ((NOT DEFINED QT5DIR) OR (NOT "${QT5DIR}" STREQUAL "${_qt5Core_install_prefix}"))
            set (QT5DIR ${_qt5Core_install_prefix} CACHE STRING "Qt5 install path" FORCE)
            message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "QT5DIR" = "${QT5DIR}")
        endif ()

        if ((NOT DEFINED QTDIR) OR (NOT "${QTDIR}" STREQUAL "${_qt5Core_install_prefix}"))
            set (QTDIR  ${_qt5Core_install_prefix} CACHE STRING "Qt install path"  FORCE)
            message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "QTDIR" = "${QTDIR}")
        endif ()

        if (NOT DEFINED QT_INSTALL_PREFIX)
            execute_process(COMMAND ${QT_QMAKE_EXECUTABLE} -query QT_INSTALL_PREFIX OUTPUT_VARIABLE QT_INSTALL_PREFIX)
            string(FIND "${QT_INSTALL_PREFIX}" "${_qt5Core_install_prefix}" index)
            if ((NOT DEFINED QT_INSTALL_PREFIX) OR (${index} EQUAL -1))
                set (QT_INSTALL_PREFIX "${_qt5Core_install_prefix}" CACHE STRING "QT_INSTALL_PREFIX path" FORCE)
            endif ()
        endif ()

        if (NOT DEFINED QT_INSTALL_PREFIX)
            set (QT_INSTALL_PREFIX ${QT5DIR})
            message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "reset QT_INSTALL_PREFIX" = "${QT_INSTALL_PREFIX}")
        endif ()

        if (NOT DEFINED QT_INSTALL_LIBS)
            execute_process(COMMAND ${QT_QMAKE_EXECUTABLE} ARGS "-query QT_INSTALL_LIBS" OUTPUT_VARIABLE QT_INSTALL_LIBS)
            string(FIND "${QT_INSTALL_LIBS}" "${_qt5Core_install_prefix}" index)
            if ((NOT DEFINED QT_INSTALL_LIBS) OR (${index} EQUAL -1))
                set (QT_INSTALL_LIBS "${_qt5Core_install_prefix}/lib" CACHE STRING "QT_INSTALL_LIBS path" FORCE)
            endif ()
            list (APPEND DEPENDENCIES_LIBRARY_DIRS "${QT_INSTALL_LIBS}")
        endif ()

        _qt5_query_qmake(QT_INSTALL_HEADERS)
        list (APPEND DEPENDENCIES_INCLUDE_DIRS "${QT_INSTALL_HEADERS}")
        _qt5_query_qmake(QT_INSTALL_ARCHDATA)
        list (APPEND DEPENDENCIES_LIBRARY_DIRS "${QT_INSTALL_ARCHDATA}")
        _qt5_query_qmake(QT_INSTALL_PLUGINS)
        list (APPEND DEPENDENCIES_LIBRARY_DIRS "${QT_INSTALL_PLUGINS}")
        list (APPEND DEPENDENCIES_LIBRARY_DIRS "${QT_INSTALL_PLUGINS}/platforms")

        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "QT_INSTALL_PREFIX" = "${QT_INSTALL_PREFIX}")        # /usr
        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "QT_INSTALL_LIBS" = "${QT_INSTALL_LIBS}")            # /usr/lib

    endif ()
endif ()

if ("${QT5DIR}" STREQUAL "")
    message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} root" "QT5DIR" = "${QT5DIR}")
endif ()

if (NOT USE_PKG_CONFIG)
    if (NOT Qt5Core_FOUND)
        if (APPLE)
            include(${QT5DIR}/lib/cmake/Qt5Core/Qt5CoreMacros.cmake)
        else ()
            include(${QT5DIR}/lib/cmake/Qt5Core/Qt5CoreConfig.cmake)
        endif ()
        include(${QT5DIR}/lib/cmake/Qt5Core/Qt5CoreConfigExtras.cmake)
        find_package (Qt5Core QUIET)
    endif ()

    if (NOT Qt5Widgets_FOUND)
        if (APPLE)
            include(${QT5DIR}/lib/cmake/Qt5Widgets/Qt5WidgetsMacros.cmake)
        else ()
            include(${QT5DIR}/lib/cmake/Qt5Widgets/Qt5WidgetsConfig.cmake)
        endif ()
        include(${QT5DIR}/lib/cmake/Qt5Widgets/Qt5WidgetsConfigExtras.cmake)
        find_package (Qt5Widgets REQUIRED)
    endif ()
    #   find_package (Qt5LinguistTools QUIET)
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "Qt5Core_DIR" = "${Qt5Core_DIR}")
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "Qt5Widgets_DIR" = "${Qt5Widgets_DIR}")
    #   message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "Qt5LinguistTools_DIR" = "${Qt5LinguistTools_DIR}")
endif ()

if (NOT Qt5Core_FOUND)
    message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} root" "Qt5Core_FOUND" = "${Qt5Core_FOUND}")
else ()
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "Qt5Core_FOUND" = "${Qt5Core_FOUND}")
endif ()
if (NOT Qt5Widgets_FOUND)
    message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} root" "Qt5Widgets_FOUND" = "${Qt5Widgets_FOUND}")
else ()
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "Qt5Widgets_FOUND" = "${Qt5Widgets_FOUND}")
endif ()

# if (NOT Qt5LinguistTools_FOUND)
#     message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} root" "Qt5LinguistTools_FOUND" = "${Qt5LinguistTools_FOUND}")
# else ()
#     message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "Qt5LinguistTools_FOUND" = "${Qt5LinguistTools_FOUND}")
# endif ()

message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "\${Qt5_DIR}" = "${Qt5_DIR}")       # /usr/lib/cmake/Qt5
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "\${QT5DIR}" = "${QT5DIR}")         # /usr/lib/cmake/Qt5
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "\$ENV{QTDIR}" = "$ENV{QTDIR}")     # /usr/lib/qt5
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "\$ENV{QT5DIR}" = "$ENV{QT5DIR}")
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "\$ENV{Qt5_DIR}" = "$ENV{Qt5_DIR}")

list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)
foreach(module_dir ${CMAKE_MODULE_PATH})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "CMAKE_MODULE_PATH" = "${module_dir}")
endforeach()
foreach (model ${CMAKE_PREFIX_PATH})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "initial CMAKE_PREFIX_PATH" = "${model}")      # /usr/lib/cmake
endforeach ()
foreach (model ${CMAKE_FRAMEWORK_PATH})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "initial CMAKE_FRAMEWORK_PATH" = "${model}")   # /usr/lib/cmake
endforeach ()
foreach (model ${CMAKE_APPBUNDLE_PATH})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "initial CMAKE_APPBUNDLE_PATH" = "${model}")   # /usr/lib/cmake
endforeach ()

if (APPLE)
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "CMAKE_APPBUNDLE_PATH" = "${CMAKE_APPBUNDLE_PATH}")
endif ()


message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "QT_USE_FILE" = "${QT_USE_FILE}")




_qt5_query_qmake(QT_INSTALL_IMPORTS)     # function(_qt5_query_qmake VAR RESULT)

message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "QT_INSTALL_IMPORTS" = "${QT_INSTALL_IMPORTS}")   # /usr/lib/qt5/imports

string (FIND "${QT_INSTALL_IMPORTS}" "${QT5DIR}"  qt5_import_dir_found)
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "qt5_import_dir_found" = "${qt5_import_dir_found}")
if (${qt5_import_dir_found} EQUAL -1)
    set (QT_INSTALL_IMPORTS "${QT5DIR}/lib/qt5/imports" CACHE PATH "Qt qmake program." FORCE)
    if (NOT EXISTS  "${QT_INSTALL_IMPORTS}")
        message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} root" "QT_INSTALL_IMPORTS = \"${QT_INSTALL_IMPORTS}\" does not contain QT5DIR" "=" "\"${QT5DIR}\"")
    else ()
        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "QT_INSTALL_IMPORTS" = "${QT_INSTALL_IMPORTS}")
    endif ()
else ()
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "QT_INSTALL_IMPORTS" = "${QT_INSTALL_IMPORTS}")
endif ()



if (NOT DEFINED Qt5Core_MOC_EXECUTABLE)  # Qt5::moc
    if ((NOT Qt5Core_FOUND) OR (USE_PKG_CONFIG))
        if (APPLE)
            include(${QT5DIR}/lib/cmake/Qt5Core/Qt5CoreMacros.cmake)
        else ()
            include(${QT5DIR}/lib/cmake/Qt5Core/Qt5CoreConfig.cmake)
        endif ()
        include(${QT5DIR}/lib/cmake/Qt5Core/Qt5CoreConfigExtras.cmake)

        find_package(Qt5Core REQUIRED)
    endif ()

    get_target_property(QT5_MOC_EXECUTABLE Qt5::moc LOCATION)    # /usr/bin/moc
    if (NOT "${QT5_MOC_EXECUTABLE}" STREQUAL "${Qt5Core_MOC_EXECUTABLE}")
        # message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "QT5_MOC_EXECUTABLE" "="  "${QT5_MOC_EXECUTABLE}")       # /usr/lib/qt5/bin/moc
        # message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5Core_MOC_EXECUTABLE" "="  "${Qt5Core_MOC_EXECUTABLE}")   # Qt5::moc
        set (Qt5Core_MOC_EXECUTABLE ${QT5_MOC_EXECUTABLE})
    endif ()
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5Core_MOC_EXECUTABLE" "="  "${Qt5Core_MOC_EXECUTABLE}")
    if (NOT DEFINED Qt5Core_MOC_EXECUTABLE)
       message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5Core_MOC_EXECUTABLE" "="  "${Qt5Core_MOC_EXECUTABLE}")
    endif ()
else ()
    get_target_property(QT5_MOC_EXECUTABLE Qt5::moc LOCATION)    # /usr/bin/moc
    if (NOT "${QT5_MOC_EXECUTABLE}" STREQUAL "${Qt5Core_MOC_EXECUTABLE}")
        set (Qt5Core_MOC_EXECUTABLE ${QT5_MOC_EXECUTABLE})
    endif ()
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5Core_MOC_EXECUTABLE" "="  "${Qt5Core_MOC_EXECUTABLE}")
endif ()

if (NOT DEFINED Qt5Core_RCC_EXECUTABLE)
    if ((NOT Qt5Core_FOUND) OR (USE_PKG_CONFIG))
        if (APPLE)
            include(${QT5DIR}/lib/cmake/Qt5Core/Qt5CoreMacros.cmake)
        else ()
            include(${QT5DIR}/lib/cmake/Qt5Core/Qt5CoreConfig.cmake)
        endif ()
        include(${QT5DIR}/lib/cmake/Qt5Core/Qt5CoreConfigExtras.cmake)

        find_package(Qt5Core REQUIRED)
    endif ()

    get_target_property(QT5_RCC_EXECUTABLE Qt5::rcc LOCATION)
    if (NOT "${Qt5Core_RCC_EXECUTABLE}" STREQUAL "${QT5_RCC_EXECUTABLE}")
        set (Qt5Core_RCC_EXECUTABLE  ${QT5_RCC_EXECUTABLE})
    endif ()
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5Core_RCC_EXECUTABLE" "=" "${Qt5Core_RCC_EXECUTABLE}")
    if (NOT DEFINED Qt5Core_RCC_EXECUTABLE)
        message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5Core_RCC_EXECUTABLE" "=" "${Qt5Core_RCC_EXECUTABLE}")
    endif ()
else ()
    get_target_property(QT5_RCC_EXECUTABLE Qt5::rcc LOCATION)
    if (NOT "${Qt5Core_RCC_EXECUTABLE}" STREQUAL "${QT5_RCC_EXECUTABLE}")
        set (Qt5Core_RCC_EXECUTABLE  ${QT5_RCC_EXECUTABLE})
    endif ()
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5Core_RCC_EXECUTABLE" "=" "${Qt5Core_RCC_EXECUTABLE}")
endif ()


if (NOT DEFINED Qt5Widgets_UIC_EXECUTABLE)
    if ((NOT Qt5Widgets_FOUND) OR (USE_PKG_CONFIG))
        if (APPLE)
            include(${QT5DIR}/lib/cmake/Qt5Widgets/Qt5WidgetsMacros.cmake)
        else ()
            include(${QT5DIR}/lib/cmake/Qt5Widgets/Qt5WidgetsConfig.cmake)
        endif ()
        include(${QT5DIR}/lib/cmake/Qt5Widgets/Qt5WidgetsConfigExtras.cmake)

        find_package(Qt5Widgets REQUIRED)
    endif ()

    get_target_property(QT5WIDGETS_UIC_EXECUTABLE Qt5::uic LOCATION)
    if (NOT "${Qt5Widgets_UIC_EXECUTABLE}" STREQUAL "$QT5WIDGETS_UIC_EXECUTABLE}")
        set (Qt5Widgets_UIC_EXECUTABLE  ${QT5WIDGETS_UIC_EXECUTABLE})
    endif ()
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5Widgets_UIC_EXECUTABLE" "=" "${Qt5Widgets_UIC_EXECUTABLE}")
    if (NOT DEFINED Qt5Widgets_UIC_EXECUTABLE)
        message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5Widgets_UIC_EXECUTABLE" "=" "${Qt5Widgets_UIC_EXECUTABLE}")
    endif ()
else ()
    get_target_property(QT5WIDGETS_UIC_EXECUTABLE Qt5::uic LOCATION)
    if (NOT "${Qt5Widgets_UIC_EXECUTABLE}" STREQUAL "$QT5WIDGETS_UIC_EXECUTABLE}")
        set (Qt5Widgets_UIC_EXECUTABLE  ${QT5WIDGETS_UIC_EXECUTABLE})
    endif ()
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5Widgets_UIC_EXECUTABLE" "=" "${Qt5Widgets_UIC_EXECUTABLE}")
endif ()


if (COMMAND cmake_policy)
    if(POLICY CMP0111)
        cmake_policy(SET CMP0111 NEW)
    endif()
endif (COMMAND cmake_policy)


set (CMAKE_AUTOUIC_SEARCH_PATHS ${CMAKE_CURRENT_SOURCE_DIR})


# LinguistTools dependencies
if (NOT DEFINED Qt5_LUPDATE_EXECUTABLE)
    if ((NOT Qt5LinguistTools_FOUND) OR (USE_PKG_CONFIG))
        if (APPLE)
            include(${QT5DIR}/lib/cmake/Qt5LinguistTools/Qt5LinguistToolsMacros.cmake)
        else ()
            include(${QT5DIR}/lib/cmake/Qt5LinguistTools/Qt5LinguistToolsConfig.cmake)
        endif ()

        find_package(Qt5LinguistTools REQUIRED)

    endif ()
    get_target_property(QT_LUPDATE_EXECUTABLE Qt5::lupdate LOCATION)
    set (Qt5_LUPDATE_EXECUTABLE "${QT_LUPDATE_EXECUTABLE}")
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5_LUPDATE_EXECUTABLE" "=" "${Qt5_LUPDATE_EXECUTABLE}")
    if (NOT DEFINED Qt5_LUPDATE_EXECUTABLE)
        message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5_LUPDATE_EXECUTABLE" "=" "${Qt5_LUPDATE_EXECUTABLE}")
    endif ()
else ()
    get_target_property(QT_LUPDATE_EXECUTABLE Qt5::lupdate LOCATION)
    set (Qt5_LUPDATE_EXECUTABLE "${QT_LUPDATE_EXECUTABLE}")
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5_LUPDATE_EXECUTABLE" "=" "${Qt5_LUPDATE_EXECUTABLE}")
endif ()


if (NOT DEFINED Qt5_LRELEASE_EXECUTABLE)
    if ((NOT Qt5LinguistTools_FOUND) OR (USE_PKG_CONFIG))
        if (APPLE)
            include(${QT5DIR}/lib/cmake/Qt5LinguistTools/Qt5LinguistToolsMacros.cmake)
        else ()
            include(${QT5DIR}/lib/cmake/Qt5LinguistTools/Qt5LinguistToolsConfig.cmake)
        endif ()

        find_package(Qt5LinguistTools REQUIRED)
    endif ()
    get_target_property(QT_LRELEASE_EXECUTABLE Qt5::lrelease LOCATION)
    set (Qt5_LRELEASE_EXECUTABLE "${QT_LRELEASE_EXECUTABLE}")
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5_LRELEASE_EXECUTABLE" "=" "${Qt5_LRELEASE_EXECUTABLE}")
    if (NOT DEFINED Qt5_LRELEASE_EXECUTABLE)
        message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5_LRELEASE_EXECUTABLE" "=" "${Qt5_LRELEASE_EXECUTABLE}")
    endif ()
else ()
    get_target_property(QT_LRELEASE_EXECUTABLE Qt5::lrelease LOCATION)
    set (Qt5_LRELEASE_EXECUTABLE "${QT_LRELEASE_EXECUTABLE}")
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Qt5_LRELEASE_EXECUTABLE" "=" "${Qt5_LRELEASE_EXECUTABLE}")
endif ()


if (MSVC )
    if (NOT DEFINED QT_MAIN_LIB_FOR_MSVC)
        message_format (FATAL_ERROR "${lead_mark_location}" "" "" "" "The MSVC main library (/path/to/lib/qtmain.lib) for the project could not be found!")
    else ()
        # set (QT_MAIN_LIB c:/Qt/Qt5.15.0beta2/5.15.0-beta2/msvc2010/lib/qtmain.lib )
        set (QT_MAIN_LIB ${QT_MAIN_LIB_FOR_MSVC} )
    endif ()
endif (MSVC )

# These variables are not defined with Qt5 CMake modules
set (QT_INCLUDE_DIR         "${QT5DIR}/include")
set (QT_BINARY_DIR          "${QT5DIR}/bin")
set (QT_LIBRARY_DIR         "${QT5DIR}/lib")
set (QT_PLUGINS_DIR         "${QT5DIR}/lib/qt5/plugins")
set (QT_TRANSLATIONS_DIR    "${QT5DIR}/lib/qt5/translations")

# if (WIN32)
#     set (QT_QMAKE_EXECUTABLE "${QT5DIR}/bin/qmake.exe")
# else ()
#     set (QT_QMAKE_EXECUTABLE "${QT5DIR}/bin/qmake")
# endif ()

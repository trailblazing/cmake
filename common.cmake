# Shared settings and functions between projects. light weight
# https://stackoverflow.com/questions/30793804/how-do-i-list-the-defined-make-targets-from-the-command-line

#   set_property (GLOBAL PROPERTY GLOBAL_DEPENDS_DEBUG_MODE 1)  # print all targets

set (_common_cmake_included 1)

if (COMMAND cmake_policy)
    cmake_policy(SET CMP0057 NEW)
    cmake_policy(SET CMP0077 NEW)   # For compatibility with older versions of CMake, option is clearing the normal variable 'QT_DEBUG'.
    cmake_policy(SET CMP0111 NEW)
endif ()

#   if (NOT BUILD_SHARED_LIBS)
#       option (BUILD_SHARED_LIBS ON)
#   endif ()

set (CMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH FALSE)

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

include (${CMAKE_CURRENT_LIST_DIR}/colorize.cmake)
#   include (${TOP_PROJECT_SOURCE_DIR}/cmake/colorize.cmake)
#   # https://stackoverflow.com/questions/18968979/how-to-get-colorized-output-with-cmake
#   # https://github.com/nerdvegas/rez/blob/master/src/rezplugins/build_system/cmake_files/Colorize.cmake
#   if(NOT _COLORIZE_INCLUDED)
#
#       #   if(NOT WIN32)
#       if($ENV{SHELL} MATCHES "bash|csh|zsh")
#         string(ASCII 27 Esc)
#         set(ColourReset "${Esc}[m")
#         set(ColourBold  "${Esc}[1m")
#
#
#         set(ColorReset  "${Esc}[m")  # for the Americans
#         set(ColorBold   "${Esc}[1m")
#
#
#         set(Red         "${Esc}[31m")
#         set(Green       "${Esc}[32m")
#         set(Yellow      "${Esc}[33m")
#         set(Blue        "${Esc}[34m")
#         set(Magenta     "${Esc}[35m")
#         set(Cyan        "${Esc}[36m")
#         set(White       "${Esc}[37m")
#         set(BoldRed     "${Esc}[1;31m")
#         set(BoldGreen   "${Esc}[1;32m")
#         set(BoldYellow  "${Esc}[1;33m")
#         set(BoldBlue    "${Esc}[1;34m")
#         set(BoldMagenta "${Esc}[1;35m")
#         set(BoldCyan    "${Esc}[1;36m")
#         set(BoldWhite   "${Esc}[1;37m")
#       endif()
#
#       function(message)
#         list(GET ARGV 0 MessageType)
#         if(MessageType STREQUAL FATAL_ERROR OR MessageType STREQUAL SEND_ERROR)
#           list(REMOVE_AT ARGV 0)
#           _message(${MessageType} "${BoldRed}${ARGV}${ColourReset}")
#         elseif(MessageType STREQUAL WARNING)
#           list(REMOVE_AT ARGV 0)
#           _message(${MessageType} "${BoldYellow}${ARGV}${ColourReset}")
#         elseif(MessageType STREQUAL AUTHOR_WARNING)
#           list(REMOVE_AT ARGV 0)
#           _message(${MessageType} "${BoldCyan}${ARGV}${ColourReset}")
#         elseif(MessageType STREQUAL STATUS)
#           list(REMOVE_AT ARGV 0)
#           _message(${MessageType} "${Green}${ARGV}${ColourReset}")
#         else()
#           _message("${ARGV}")
#         endif()
#       endfunction()
#
#       set(_COLORIZE_INCLUDED 1)
#
#   endif ()


# macro definitions begin _________________________________________________________________
#    add_definitions (-D"QT_NO_VERSION_TAGGING")
#    add_definitions (-DQWEBENGINESETTINGS_PATHS)
#    add_definitions (-DDONT_USE_DBUS)
#    add_definitions (-DUSE_EDITOR_INTERFACE)
#    add_definitions (-DUSE_CLEAR_BUTTON)
#    add_definitions (-DUSE_BUTTON_PIN)

set (CMAKE_EXPORT_COMPILE_COMMANDS ON)
set (CMAKE_VERBOSE_MAKEFILE ON)
set (CMAKE_COLOR_MAKEFILE   ON)
add_definitions (-D"CMAKE_VERBOSE_MAKEFILE=1")
add_definitions (-D"CMAKE_COLOR_MAKEFILE=1")

string (FIND "${CMAKE_BUILD_TYPE}" "Deb" debug_index)
if (("${CMAKE_BUILD_TYPE}" STREQUAL "Debug") OR (NOT ${debug_index} EQUAL -1))  # OR ("${CMAKE_BUILD_TYPE}" MATCHES "^Deb") OR ("${CMAKE_BUILD_TYPE}" MATCHES ";Deb") OR ("${CMAKE_BUILD_TYPE}" MATCHES "Deb"))
    set (CMAKE_VERBOSE_MAKEFILE ON)
    add_definitions (-g -O1)
else ()
    add_definitions (-DNO_DEBUG_OUTPUT)
    set ( CMAKE_SKIP_RPATH ON)
endif ()

# https://github.com/CastXML/CastXML/issues/148
# build system doesn't pick default LLVM libraries #148
# If several LLVM versions provide CMake packages, try to use the latest one.
set(CMAKE_FIND_PACKAGE_SORT_ORDER NATURAL)
set(CMAKE_FIND_PACKAGE_SORT_DIRECTION DEC)

if (NOT DEFINED lead_mark_location)
    set (lead_mark_location 57 CACHE STRING "location of lead mark, eg. =" FORCE)
endif ()
# macro definitions end    _________________________________________________________________

macro (check_definition result define_option scope)
    get_directory_property(DEFINITIONS_LIST DIRECTORY "${scope}" COMPILE_DEFINITIONS)
    list (REMOVE_DUPLICATES DEFINITIONS_LIST)
    if (("${DEFINITIONS_LIST}" MATCHES "^${define_option}") OR ("${DEFINITIONS_LIST}" MATCHES ";${define_option}") OR ("${DEFINITIONS_LIST}" MATCHES "${define_option}"))
        #   set (${result} ON  CACHE BOOL PARENT_SCOPE FORCE)
        set (${result} ON CACHE BOOL "definition foud"  FORCE)
    else ()
        #   set (${result} OFF CACHE BOOL PARENT_SCOPE FORCE)
        set (${result} OFF CACHE BOOL "definition not found"  FORCE)
    endif ()
endmacro()

function (remove_new_line output)
    IF(WIN32)
        STRING(REPLACE "\r\n" "" result "${${output}}")
    ELSE(WIN32)
        STRING(REPLACE "\n" "" result "${${output}}")
    ENDIF(WIN32)
    #   set (${output} ${result} CACHE STRING "return value" PARENT_SCOPE)
    set (${output} ${result} PARENT_SCOPE)
endfunction ()

# format message
function (message_format status lead_mark_location description variable_name lead_mark variable_value)
    if (OUTPUT_USE_NEW_LINE)
        if (WIN32)
            set (new_line "\n\r")
        else ()
            set (new_line "\n")
        endif ()
    else ()
        set (new_line "")
    endif ()
    string (LENGTH "${description}" description_name_length)
    string (LENGTH "${variable_name}" variable_name_length)
    string (LENGTH "${description}:${variable_name}" left_full_length)

    set (sapce_count 0)

    if (OUTPUT_USE_NEW_LINE)
        if (NOT ${left_full_length} LESS_EQUAL ${lead_mark_location})
            set (space_display "")
            foreach(i RANGE ${lead_mark_location})
                set (space_display "${space_display} ")
            endforeach()
            set (output_left_part "${description}:${variable_name}${new_line}   ${space_display}")
        else ()
            set (output_left_part "${description}:${variable_name}")
            #    math (EXPR tab_count0 "(24 - ${module_length} - 1)" OUTPUT_FORMAT DECIMAL)
            math (EXPR sapce_count  "(${lead_mark_location} - ${left_full_length})" OUTPUT_FORMAT DECIMAL)
            #    math (EXPR tab_count1 "(32 - ${module_length} - 6)" OUTPUT_FORMAT DECIMAL)
        endif ()
    else ()
        if (NOT ${left_full_length} LESS_EQUAL ${lead_mark_location})
            math (EXPR extra_count  "(${left_full_length} - ${lead_mark_location})" OUTPUT_FORMAT DECIMAL)
            math (EXPR tab_count    "((${extra_count} / 4) + 1)"                    OUTPUT_FORMAT DECIMAL)
            math (EXPR mode_count   "(${extra_count} % 4)"                          OUTPUT_FORMAT DECIMAL)
            math (EXPR space_count  "((${tab_count} * 4) - ${mode_count})"          OUTPUT_FORMAT DECIMAL)
            set (space_display "")
            foreach(i RANGE ${space_count})
                set (space_display "${space_display} ")
            endforeach()
            set (output_left_part "${description}:${variable_name}${space_display}")
        else ()
            set (output_left_part "${description}:${variable_name}")
            #    math (EXPR tab_count0 "(24 - ${module_length} - 1)" OUTPUT_FORMAT DECIMAL)
            math (EXPR sapce_count  "(${lead_mark_location} - ${left_full_length})" OUTPUT_FORMAT DECIMAL)
            #    math (EXPR tab_count1 "(32 - ${module_length} - 6)" OUTPUT_FORMAT DECIMAL)
        endif ()
    endif ()

    set (space_display "")
    foreach(i RANGE ${sapce_count})
        set (space_display "${space_display} ")
    endforeach()

    #    set (tab_display1 "")
    #    foreach(i RANGE ${tab_count1})
    #        set (tab_display1 "${tab_display1} ")
    #    endforeach()

    #    message(STATUS "${PROJECT_NAME} module: ${module_colon_name}, ${tab_display0} ${lib_name} ${tab_display1}= ${${lib_name}} ")

    if (OUTPUT_USE_NEW_LINE)
        string (LENGTH "${variable_value}" variable_value_length)
        math (EXPR margin_count "(140 - ${lead_mark_location})"                     OUTPUT_FORMAT DECIMAL)
        if (NOT ${variable_value_length} LESS_EQUAL ${margin_count})
            set (output_variable_value "${new_line}    ${variable_value}")
        else ()
            set (output_variable_value "${variable_value}")
        endif ()
    else ()
        set (output_variable_value "${variable_value}")
    endif ()

    message(${status} "${output_left_part}${space_display}${lead_mark} ${output_variable_value}")
endfunction()

function (new_line)
    if (WIN32)
        #   message_format (STATUS "${lead_mark_location}" "\n\r" "" "" "")
        message_format (STATUS "${lead_mark_location}" "\n\r" "" "" "")
    else ()
        #   message_format (STATUS "${lead_mark_location}" "\n" "" "" "")
        message_format (STATUS "${lead_mark_location}" "\n" "" "" "")
    endif ()
endfunction()





# genearats ts and qm file searching recursively SRC_DIR
function(generate_translations CUSTOM_TARGET TS_DIR TS_FILES SRC_DIR)
    set(UPADTE_TS_TARGET_NAME ${CUSTOM_TARGET}_ts)
    set(UPADTE_QM_TARGET_NAME ${CUSTOM_TARGET}_qm)

    add_custom_target(${UPADTE_TS_TARGET_NAME}
        COMMAND ${Qt5_LUPDATE_EXECUTABLE} -recursive ${SRC_DIR} -ts ${TS_FILES}
        WORKING_DIRECTORY ${TS_DIR})

    add_custom_target(${UPADTE_QM_TARGET_NAME}
        COMMAND ${Qt5_LRELEASE_EXECUTABLE} ${TS_FILES}
        WORKING_DIRECTORY ${TS_DIR})

    add_dependencies(${UPADTE_QM_TARGET_NAME} ${UPADTE_TS_TARGET_NAME} )
    add_dependencies(${CUSTOM_TARGET} ${UPADTE_QM_TARGET_NAME})
endfunction()

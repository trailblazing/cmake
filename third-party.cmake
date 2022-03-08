
# add_definitions (-DUSE_BOOST_SIGNALS2)
# add_definitions (-DUSE_SIGSLOT)
# add_definitions (-DUSE_SIGC)
# add_definitions (-DUSE_METAL_TMPL)

# set (DEPENDENCIES_LIBRARIES "" )

# Begin check definitions:__________________________________________________________________________________________________________

message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "CMAKE_FIND_ROOT_PATH" "="  "${CMAKE_FIND_ROOT_PATH}")



if (BUILD_SHARED_LIBS)
    set (CMAKE_FIND_LIBRARY_SUFFIXES    ${CMAKE_SHARED_LIBRARY_SUFFIX} ${CMAKE_FIND_LIBRARY_SUFFIXES})
else ()
    set (CMAKE_FIND_LIBRARY_SUFFIXES    ${CMAKE_STATIC_LIBRARY_SUFFIX} ${CMAKE_FIND_LIBRARY_SUFFIXES})
endif ()


get_directory_property(DEFINITIONS_LIST COMPILE_DEFINITIONS)
list (REMOVE_DUPLICATES DEFINITIONS_LIST)
foreach(flag ${DEFINITIONS_LIST})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" " compile definitions"  "="  "${flag}")
endforeach()

check_definition (DEFINED_USE_VERDIGRIS_TO_REMOVE_MOC "USE_VERDIGRIS_TO_REMOVE_MOC" "${CMAKE_SOURCE_DIR}")
if (DEFINED_USE_VERDIGRIS_TO_REMOVE_MOC)
    list (APPEND DEPENDENCIES_INCLUDE_DIRS "${TOP_PROJECT_SOURCE_DIR}/dependencies/verdigris/src")
endif ()

# OpenGl is default installed
# include (FindPkgConfig)
# find_package (PkgConfig REQUIRED)
# pkg_check_modules(OpenGL_LIB REQUIRED OpenGL)
# message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "OpenGL_LIB_INCLUDE_DIRS" "="  "${OpenGL_LIB_INCLUDE_DIRS}")
# message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "OpenGL_LIB_LIBRARIES" "="  "${OpenGL_LIB_LIBRARIES}")

# #   find_package(OpenGL REQUIRED COMPONENTS OpenGL EGL GLX)
# find_package(OpenGL REQUIRED COMPONENTS OpenGL)
# include_directories(${OPENGL_INCLUDE_DIRS})
# if (OPENGL_gl_LIBRARY)
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "OPENGL_gl_LIBRARY"     "="  "${OPENGL_gl_LIBRARY}")
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "OPENGL_opengl_LIBRARY"     "="  "${OPENGL_opengl_LIBRARY}")
# endif ()
# if(OPENGL_FOUND)
#   message("Found OpenGL in the current environment!")
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "OPENGL_INCLUDE_DIR"    "="  "${OPENGL_INCLUDE_DIR}")
#   message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "OPENGL_INCLUDE_DIRS"   "="  "${OPENGL_INCLUDE_DIRS}")
message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "OPENGL_LIBRARIES"      "="  "${OPENGL_LIBRARIES}")
# else()
#     #   message("Error: No OpenGL found.")
#     message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} module" ""                 "="  "No OpenGL found")
# endif()



#    get_target_property(DEFINITIONS_LIST ${PROJECT_NAME} COMPILE_DEFINITIONS)
check_definition (DEFINED_USE_BOOST_SIGNALS2 "USE_BOOST_SIGNALS2" "${CMAKE_SOURCE_DIR}")
if (DEFINED_USE_BOOST_SIGNALS2)    # if (("${DEFINITIONS_LIST}" MATCHES "^USE_BOOST_SIGNALS2") OR ("${DEFINITIONS_LIST}" MATCHES ";USE_BOOST_SIGNALS2") OR ("${DEFINITIONS_LIST}" MATCHES "USE_BOOST_SIGNALS2"))
    #    message_format (STATUS "${lead_mark_location}" "USE_BOOST_SIGNALS2 defined" )
    if (NOT BUILD_SHARED_LIBS)
        set (Boost_USE_STATIC_LIBS ON)
        set (Boost_USE_STATIC_RUNTIME ON)
    else ()
        set (Boost_USE_STATIC_LIBS OFF)
        set (Boost_USE_STATIC_RUNTIME OFF)
    endif ()
    set (Boost_USE_MULTITHREADED ON)
    find_package(Boost REQUIRED COMPONENTS )    # signals2 won't be found
    if (Boost_FOUND)
        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Boost_INCLUDE_DIRS" "="  "${Boost_INCLUDE_DIRS}")
        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Boost_INCLUDE_DIR"  "="  "${Boost_INCLUDE_DIR}")
        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Boost_LIBRARY_DIRS" "="  "${Boost_LIBRARY_DIRS}")
        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Boost_LIBRARIES"    "="  "${Boost_LIBRARIES}")
        list (APPEND DEPENDENCIES_INCLUDE_DIRS "${Boost_INCLUDE_DIRS}")
        list (APPEND DEPENDENCIES_LIBRARY_DIRS "${Boost_LIBRARY_DIRS}")
        list (APPEND DEPENDENCIES_LIBRARIES    "${Boost_LIBRARIES}")
    else (Boost_FOUND)
        message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} module" " Boost_INCLUDE_DIRS" "="  "${Boost_INCLUDE_DIRS}")
    endif (Boost_FOUND)
    add_definitions (-D_LIBCPP_ENABLE_CXX20_REMOVED_ALLOCATOR_MEMBERS)   # boost::auto_buffer: error: no type named 'size_type' in 'std::__1::allocator<boost::shared_ptr<void>>'
    #    else ()
    #        message_format (STATUS "${lead_mark_location}" "USE_BOOST_SIGNALS2 did not define" )   # You can define your OS here if desired
endif ()


check_definition (DEFINED_USE_SIGC "USE_SIGC" "${CMAKE_SOURCE_DIR}")
if (DEFINED_USE_SIGC)    # if (("${DEFINITIONS_LIST}" MATCHES "^USE_SIGC") OR ("${DEFINITIONS_LIST}" MATCHES ";USE_SIGC") OR ("${DEFINITIONS_LIST}" MATCHES "USE_SIGC"))
    if (USE_SYSTEM_SIGC)
        include(FindPkgConfig)
        pkg_check_modules(SIGC REQUIRED sigc++-3.0)
        #    pkg_check_modules(SIGC REQUIRED sigc++-2.0)
        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} root" "SIGC_INCLUDE_DIRS" "=" "${SIGC_INCLUDE_DIRS}")
    else ()
        list (APPEND DEPENDENCIES_INCLUDE_DIRS "${TOP_PROJECT_SOURCE_DIR}/dependencies/libsigcplusplus")
    endif ()
endif ()

check_definition (DEFINED_USE_SIGSLOT "USE_SIGSLOT" "${CMAKE_SOURCE_DIR}")
if (DEFINED_USE_SIGSLOT)    # if (("${DEFINITIONS_LIST}" MATCHES "^USE_SIGSLOT") OR ("${DEFINITIONS_LIST}" MATCHES ";USE_SIGSLOT") OR ("${DEFINITIONS_LIST}" MATCHES "USE_SIGSLOT"))
    list (APPEND DEPENDENCIES_INCLUDE_DIRS "${TOP_PROJECT_SOURCE_DIR}/dependencies/sigslot/include")
endif ()

check_definition (DEFINED_USE_METAL_TMPL "USE_METAL_TMPL" "${CMAKE_SOURCE_DIR}")
if (DEFINED_USE_METAL_TMPL)    # if (("${DEFINITIONS_LIST}" MATCHES "^USE_METAL_TMPL") OR ("${DEFINITIONS_LIST}" MATCHES ";USE_METAL_TMPL") OR ("${DEFINITIONS_LIST}" MATCHES "USE_METAL_TMPL"))
    list (APPEND DEPENDENCIES_INCLUDE_DIRS "${TOP_PROJECT_SOURCE_DIR}/dependencies/metal/include")
endif ()

check_definition (DEFINED_USE_NAMEDTYPE "USE_NAMEDTYPE" "${CMAKE_SOURCE_DIR}")
if (DEFINED_USE_NAMEDTYPE)    # if (("${DEFINITIONS_LIST}" MATCHES "^USE_NAMEDTYPE") OR ("${DEFINITIONS_LIST}" MATCHES ";USE_NAMEDTYPE") OR ("${DEFINITIONS_LIST}" MATCHES "USE_NAMEDTYPE"))
    list (APPEND DEPENDENCIES_INCLUDE_DIRS "${TOP_PROJECT_SOURCE_DIR}/dependencies/NamedType/include")
endif ()

check_definition (DEFINED_USE_FEATHERPAD "USE_FEATHERPAD" "${CMAKE_SOURCE_DIR}")
if (DEFINED_USE_FEATHERPAD)    # if (("${DEFINITIONS_LIST}" MATCHES "^USE_FEATHERPAD") OR ("${DEFINITIONS_LIST}" MATCHES ";USE_FEATHERPAD") OR ("${DEFINITIONS_LIST}" MATCHES "USE_FEATHERPAD"))
    list (APPEND CMAKE_PREFIX_PATH          "${TOP_PROJECT_SOURCE_DIR}/dependencies/featherpad/FeatherPad/cmake")
    list (APPEND CMAKE_PREFIX_PATH          "${TOP_PROJECT_SOURCE_DIR}/dependencies/featherpad/FeatherPad/cmake/Modules")
    #    list (APPEND CMAKE_MODULE_PATH          "${TOP_PROJECT_SOURCE_DIR}/dependencies/featherpad/cmake")
    #    list (APPEND CMAKE_MODULE_PATH          "${TOP_PROJECT_SOURCE_DIR}/dependencies/featherpad/cmake/Modules")
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_PREFIX_PATH}")
    list (APPEND DEPENDENCIES_INCLUDE_DIRS  "${TOP_PROJECT_SOURCE_DIR}/dependencies/featherpad/FeatherPad")
    #    include_directories(                    "${TOP_PROJECT_SOURCE_DIR}/dependencies/featherpad/FeatherPad")

    #    for spell checking (see FindHUNSPELL.cmake)
    set (HUNSPELL_MINIMUM_VERSION "1.6")
    include(${TOP_PROJECT_SOURCE_DIR}/dependencies/featherpad/cmake/Modules/FindHUNSPELL.cmake)
    find_package (HUNSPELL "${HUNSPELL_MINIMUM_VERSION}" REQUIRED)
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" " HUNSPELL_INCLUDE_DIRS" "="  "${HUNSPELL_INCLUDE_DIRS}" )
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" " HUNSPELL_LIBRARIES" "="  "${HUNSPELL_LIBRARIES}" )
    list (APPEND DEPENDENCIES_INCLUDE_DIRS "${HUNSPELL_INCLUDE_DIRS}")
    list (APPEND DEPENDENCIES_LIBRARIES "${HUNSPELL_LIBRARIES}")    # link_libraries(${HUNSPELL_LIBRARIES})

    #    include (FindPkgConfig)
    #    find_package (PkgConfig REQUIRED)
    #    pkg_check_modules(HUNSPELL_LIB REQUIRED hunspell)
    #    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" " HUNSPELL_LIB_INCLUDE_DIRS" "="  "${HUNSPELL_LIB_INCLUDE_DIRS}")
    #    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" " HUNSPELL_LIB_LIBRARIES" "="  "${HUNSPELL_LIB_LIBRARIES}")
    #    list (APPEND DEPENDENCIES_INCLUDE_DIRS "${HUNSPELL_LIB_INCLUDE_DIRS}")
    #    list (APPEND DEPENDENCIES_LIBRARIES "${HUNSPELL_LIB_LIBRARIES}")    # link_libraries(${HUNSPELL_LIBRARIES})
endif ()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_PREFIX_PATH}")

# End check definitions:__________________________________________________________________________________________________________

#    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "${PROJECT_NAME_UPPER}_UI_LIST     " "="  "${${PROJECT_NAME_UPPER}_UI_LIST}")
foreach(ui ${${PROJECT_NAME_UPPER}_UI_LIST})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} ${PROJECT_NAME_UPPER}_UI_LIST" "ui" "="  "${ui}")
endforeach()
#    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "${PROJECT_NAME_UPPER}_RSC_LIST     " "="  "${${PROJECT_NAME_UPPER}_RSC_LIST}")
foreach(rsc ${${PROJECT_NAME_UPPER}_RSC_LIST})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} ${PROJECT_NAME_UPPER}_RSC_LIST" "rsc" "="  "${rsc}")
endforeach()

list (REMOVE_DUPLICATES CMAKE_MODULE_PATH)
foreach(module_dir ${CMAKE_MODULE_PATH})
    #    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" " CMAKE_MODULE_PATH     " "="  "${CMAKE_MODULE_PATH}")
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} CMAKE_MODULE_PATH" "module_dir" "="  "${module_dir}")
endforeach()

#    foreach(include_dir ${MODULES_INCLUDE_DIRS})
#        #    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" " MODULES_INCLUDE_DIRS" "="  "${MODULES_INCLUDE_DIRS}")
#        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} MODULES_INCLUDE_DIRS: include_dir" "="  "${include_dir}")
#    endforeach()

# list (APPEND MODULES_INCLUDE_DIRS  "${DEPENDENCIES_INCLUDE_DIRS}")
list (APPEND DEPENDENCIES_INCLUDE_DIRS "${MODULES_INCLUDE_DIRS}")
list (REMOVE_DUPLICATES DEPENDENCIES_INCLUDE_DIRS)

set (DEPENDENCIES_INCLUDE_DIRS_STRING "")
foreach(dir ${DEPENDENCIES_INCLUDE_DIRS})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "DEPENDENCIES_INCLUDE_DIRS" "="  "${dir}")
    set (DEPENDENCIES_INCLUDE_DIRS_STRING "${DEPENDENCIES_INCLUDE_DIRS_STRING} ${dir}")
endforeach()

#    include_directories (${DEPENDENCIES_INCLUDE_DIRS})    # for dependencies

#    foreach(link_module ${PROJECT_QT5_MODULES})
#        message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} PROJECT_QT5_MODULES: link_module                      " "="  "${link_module}")
#    endforeach()

list (REMOVE_DUPLICATES DEPENDENCIES_LIBRARY_DIRS)

set (DEPENDENCIES_LIBRARY_DIRS_STRING "")
foreach(dir ${DEPENDENCIES_LIBRARY_DIRS})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "DEPENDENCIES_LIBRARY_DIRS" "="  "${dir}")
    set (DEPENDENCIES_LIBRARY_DIRS_STRING "${DEPENDENCIES_LIBRARY_DIRS_STRING} ${dir}")
endforeach()

foreach(link_module_name ${PROJECT_QT5_MODULES_NAME})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} PROJECT_QT5_MODULES_NAME" "link_module_name" "="  "${link_module_name}")
endforeach()
set (DEPENDENCIES_LIBRARIES_STRING "")
list (APPEND DEPENDENCIES_LIBRARIES "${PROJECT_QT5_MODULES_NAME}")
foreach(dep_lib ${DEPENDENCIES_LIBRARIES})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "DEPENDENCIES_LIBRARIES" "="  "${dep_lib}" )
    set (DEPENDENCIES_LIBRARIES_STRING "${DEPENDENCIES_LIBRARIES_STRING} ${def_lib}")
endforeach()


foreach(dep_dir ${CMAKE_PREFIX_PATH})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "CMAKE_PREFIX_PATH" "="  "${dep_dir}" )
endforeach()
foreach(dep_lib ${CMAKE_LIBRARY_PATH})
    message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "CMAKE_LIBRARY_PATH" "="  "${dep_lib}" )
endforeach()




macro (pkg_config package_name)
        include (FindPkgConfig)
        find_package (PkgConfig REQUIRED)

        pkg_check_modules(${package_name} REQUIRED ${package_name})   #   pkg_check_modules(${package_name} REQUIRED ${package_name})
        #   list (APPEND ${PROJECT_NAME_UPPER}_MODULES "UiTools")  # QtUiTools/QUiLoader


        #   message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "${package_name}_INCLUDE_DIRS"     "="  "${${package_name}_INCLUDE_DIRS}")
        list (REMOVE_DUPLICATES ${package_name}_INCLUDE_DIRS)
        foreach (dir ${${package_name}_INCLUDE_DIRS})
            message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "${package_name}_INCLUDE_DIRS"     "="  "${dir}")
            list (APPEND DEPENDENCIES_INCLUDE_DIRS "${dir}")
        endforeach ()
        #   message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "${package_name}_LIBRARIES"     "="  "${${package_name}_LIBRARIES}")
        foreach (lib ${${package_name}_LIBRARIES})
            message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "${package_name}_LIBRARIES"     "="  "${lib}")
            list (APPEND DEPENDENCIES_LIBRARIES "${lib}")
        endforeach ()

endmacro ()

macro (dependency_define target_name package_name)
    if (NOT TARGET ${package_name}_LIBRARY_PORT)
        add_library( ${package_name}_LIBRARY_PORT STATIC IMPORTED)
        set_target_properties(${package_name}_LIBRARY_PORT PROPERTIES
            IMPORTED_LOCATION ${${package_name}_LIBRARY}   #    IMPORTED_LOCATION /usr/lib/${PROGNAME}.a
            ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
            LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
            )
        if (NOT TARGET ${package_name}_LIBRARY_PORT)
            message_format (FATAL_ERROR "${lead_mark_location}" "${PROJECT_NAME} module" "${package_name}_LIBRARY_PORT" "=" "${${package_name}_LIBRARY_PORT}")
        else ()
            get_target_property(QUERIED_LIBRARY ${package_name} LOCATION)
            message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "Before set, ${package_name}_LIBRARY" "=" "${${package_name}_LIBRARY}")
            set (${package_name}_LIBRARY ${QUERIED_LIBRARY})
            message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "After set, ${package_name}_LIBRARY" "=" "${${package_name}_LIBRARY}")
            message_format (STATUS "${lead_mark_location}" "${PROJECT_NAME} module" "${package_name}_LIBRARY_PORT" "=" "${${package_name}_LIBRARY_PORT}")
        endif ()
    endif ()
    add_dependencies(${target_name} ${package_name}_LIBRARY_PORT)
endmacro ()

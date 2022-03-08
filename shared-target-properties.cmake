

function (set_link_properties target_name)
    set (CMAKE_CXX_LINKER_PREFERENCE_PROPAGATES OFF)
    set_target_properties( ${target_name} PROPERTIES INSTALL_RPATH_USE_LINK_PATH TRUE )
    set_target_properties( ${target_name} PROPERTIES LINKER_LANGUAGE CXX)
endfunction ()

function (set_target_properties_package target_name imported_link_interface_libraries)
    set_target_properties( ${target_name}
        PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
    )

    set_target_properties( ${target_name} PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY "${${PROJECT_NAME_UPPER}_ARCHIVE_OUTPUT_DIRECTORY}")

    set_target_properties( ${target_name} PROPERTIES
        IMPORTED_LINK_INTERFACE_LIBRARIES "${imported_link_interface_libraries}"
        IMPORTED_LOCATION "${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/${LIBRARY_PREFIX}${PROJECT_NAME}${LIBRARY_SUFFIX}"
    )
endfunction ()

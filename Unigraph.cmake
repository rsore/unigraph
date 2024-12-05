if (CMAKE_VERSION VERSION_LESS "3.23")
    message(FATAL_ERROR "The module 'Unigraph' requires at least CMake 3.23. "
            "Please update your CMake version.")
endif ()

include(CMakeParseArguments)

set(UNIGRAPH_CURRENT_UNIT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

set(_UNIGRAPH_UNIT_LIST_DELIMITER "|")
set(_UNIGRAPH_UNIT_PROPERTY_LIST_DELIMITER "*")

set_property(GLOBAL PROPERTY UNIGRAPH_UNITS_LIST)

function(_unigraph_pack_unit_struct
        unit_name
        unit_dir
        target_name
        target_type
        target_sources
        target_headers
        target_dependencies
        out_str)

    if (NOT target_sources STREQUAL "")
        string(REPLACE ";" "${_UNIGRAPH_UNIT_PROPERTY_LIST_DELIMITER}" target_sources_packed "${target_sources}")
    else ()
        set(target_sources_packed "")
    endif ()

    if (NOT target_headers STREQUAL "")
        string(REPLACE ";" "${_UNIGRAPH_UNIT_PROPERTY_LIST_DELIMITER}" target_headers_packed "${target_headers}")
    else ()
        set(target_headers_packed "")
    endif ()

    if (NOT target_dependencies STREQUAL "")
        string(REPLACE ";" "${_UNIGRAPH_UNIT_PROPERTY_LIST_DELIMITER}" target_dependencies_packed "${target_dependencies}")
    else ()
        set(target_dependencies_packed "")
    endif ()

    set(${out_str} "${unit_name}${_UNIGRAPH_UNIT_LIST_DELIMITER}${unit_dir}${_UNIGRAPH_UNIT_LIST_DELIMITER}${target_name}${_UNIGRAPH_UNIT_LIST_DELIMITER}${target_type}${_UNIGRAPH_UNIT_LIST_DELIMITER}${target_sources_packed}${_UNIGRAPH_UNIT_LIST_DELIMITER}${target_headers_packed}${_UNIGRAPH_UNIT_LIST_DELIMITER}${target_dependencies_packed}" PARENT_SCOPE)
endfunction(_unigraph_pack_unit_struct)

function(_unigraph_unpack_unit_struct packed_str
        out_unit_name
        out_unit_dir
        out_target_name
        out_target_type
        out_target_sources
        out_target_headers
        out_target_dependencies)
    string(REPLACE "${_UNIGRAPH_UNIT_LIST_DELIMITER}" ";" unit_list "${packed_str}")

    list(LENGTH unit_list num_elements)
    if (num_elements LESS 7)
        message(FATAL_ERROR "Malformed packed string: '${packed_str}'")
    endif ()

    list(GET unit_list 0 unit_name)
    list(GET unit_list 1 unit_dir)
    list(GET unit_list 2 target_name)
    list(GET unit_list 3 target_type)
    list(GET unit_list 4 sources_packed)
    list(GET unit_list 5 headers_packed)
    list(GET unit_list 6 dependencies_packed)

    if (NOT sources_packed STREQUAL "")
        string(REPLACE "${_UNIGRAPH_UNIT_PROPERTY_LIST_DELIMITER}" ";" target_sources "${sources_packed}")
    else ()
        set(target_sources "")
    endif ()

    if (NOT headers_packed STREQUAL "")
        string(REPLACE "${_UNIGRAPH_UNIT_PROPERTY_LIST_DELIMITER}" ";" target_headers "${headers_packed}")
    else ()
        set(target_headers "")
    endif ()

    if (NOT dependencies_packed STREQUAL "")
        string(REPLACE "${_UNIGRAPH_UNIT_PROPERTY_LIST_DELIMITER}" ";" target_dependencies "${dependencies_packed}")
    else ()
        set(target_dependencies "")
    endif ()

    set(${out_unit_name} "${unit_name}" PARENT_SCOPE)
    set(${out_unit_dir} "${unit_dir}" PARENT_SCOPE)
    set(${out_target_name} "${target_name}" PARENT_SCOPE)
    set(${out_target_type} "${target_type}" PARENT_SCOPE)
    set(${out_target_sources} "${target_sources}" PARENT_SCOPE)
    set(${out_target_headers} "${target_headers}" PARENT_SCOPE)
    set(${out_target_dependencies} "${target_dependencies}" PARENT_SCOPE)
endfunction(_unigraph_unpack_unit_struct)

function(unigraph_unit unit_name)
    cmake_parse_arguments(
            PARSED_ARGS
            ""
            "TYPE"
            "SOURCES;HEADERS;DEPEND;NAME"
            ${ARGN}
    )

    if (PARSED_ARGS_NAME)
        set(target_name "${PARSED_ARGS_NAME}")
    else ()
        set(target_name "${PROJECT_NAME}_${unit_name}")
    endif ()

    if (PARSED_ARGS_SOURCES)
        list(TRANSFORM PARSED_ARGS_SOURCES PREPEND "${UNIGRAPH_CURRENT_UNIT_DIRECTORY}/")
    endif ()

    if (PARSED_ARGS_HEADERS)
        list(TRANSFORM PARSED_ARGS_HEADERS PREPEND "${UNIGRAPH_CURRENT_UNIT_DIRECTORY}/")
    endif ()

    set(valid_target_types "Executable" "StaticLibrary" "SharedLibrary" "Interface")
    set(target_type "StaticLibrary")
    if (NOT PARSED_ARGS_SOURCES)
        set(target_type "Interface")
    endif ()

    if (PARSED_ARGS_TYPE)
        set(user_defined_target_type "${PARSED_ARGS_TYPE}")
        list(FIND valid_target_types "${user_defined_target_type}" index)
        if (index EQUAL -1)
            message(WARNING "Target type '${user_defined_target_type}' is ill-formed, "
                    "must be one of '${valid_target_types}', inferring '${target_type}'")
        else ()
            set(target_type "${user_defined_target_type}")
        endif ()
    endif ()

    _unigraph_pack_unit_struct(
            ${unit_name}
            ${UNIGRAPH_CURRENT_UNIT_DIRECTORY}
            ${target_name}
            ${target_type}
            "${PARSED_ARGS_SOURCES}"
            "${PARSED_ARGS_HEADERS}"
            "${PARSED_ARGS_DEPEND}"
            unit
    )

    get_property(unit_list GLOBAL PROPERTY UNIGRAPH_UNITS_LIST)
    list(APPEND unit_list "${unit}")
    set_property(GLOBAL PROPERTY UNIGRAPH_UNITS_LIST ${unit_list})
endfunction(unigraph_unit)

function(_unigraph_resolve_target_name in_unit_name out_target_name)
    get_property(unit_list GLOBAL PROPERTY UNIGRAPH_UNITS_LIST)
    foreach (unit IN LISTS unit_list)
        _unigraph_unpack_unit_struct(${unit}
                unit_name
                unit_dir
                target_name
                target_type
                target_sources
                target_headers
                target_dependencies)
        if (in_unit_name STREQUAL unit_name)
            set(${out_target_name} ${target_name} PARENT_SCOPE)
            return()
        endif ()
    endforeach ()
    set(${out_target_name} ${in_unit_name} PARENT_SCOPE)
endfunction(_unigraph_resolve_target_name)

function(_unigraph_make_unit_targets)
    get_property(unit_list GLOBAL PROPERTY UNIGRAPH_UNITS_LIST)
    foreach (unit IN LISTS unit_list)
        _unigraph_unpack_unit_struct(${unit}
                unit_name
                unit_dir
                target_name
                target_type
                target_sources
                target_headers
                target_dependencies)

        message(STATUS "Creating target '${target_name}' of type '${target_type}'")
        if (target_type STREQUAL "Executable")
            add_executable(${target_name})
            set(header_visibility PRIVATE)
        elseif (target_type STREQUAL "StaticLibrary")
            add_library(${target_name} STATIC)
            set(header_visibility PUBLIC)
        elseif (target_type STREQUAL "SharedLibrary")
            add_library(${target_name} SHARED)
            set(header_visibility PUBLIC)
        elseif (target_type STREQUAL "Interface")
            add_library(${target_name} INTERFACE)
            set(header_visibility INTERFACE)
        endif ()

        target_sources(${target_name}
                PRIVATE
                ${target_sources}
        )

        target_sources(${target_name}
                ${header_visibility}
                FILE_SET unigraph_${target_name}_headers
                TYPE HEADERS
                BASE_DIRS ${unit_dir}
                FILES ${target_headers}
        )

        set_target_properties(${target_name} PROPERTIES LINKER_LANGUAGE CXX)

        if (target_type STREQUAL "Interface")
            set(link_visibility INTERFACE)
        else ()
            set(link_visibility PUBLIC)
        endif ()
        foreach (dependency IN LISTS target_dependencies)
            _unigraph_resolve_target_name(${dependency} resolved_dependency)
            target_link_libraries(${target_name} ${link_visibility} ${resolved_dependency})
        endforeach ()
    endforeach ()
endfunction(_unigraph_make_unit_targets)

# Recursively search for all unit.cmake files, and process them
file(GLOB_RECURSE UNIGRAPH_UNIT_CMAKE_FILES "${CMAKE_CURRENT_LIST_DIR}/**/unit.cmake")
foreach (file IN LISTS UNIGRAPH_UNIT_CMAKE_FILES)
    message(STATUS "Found unit.cmake: ${file}")
    get_filename_component(UNIGRAPH_CURRENT_UNIT_DIRECTORY ${file} DIRECTORY)
    include(${file})
endforeach ()
_unigraph_make_unit_targets()
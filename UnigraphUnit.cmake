include(CMakeParseArguments)

set(_UNIGRAPH_CURRENT_UNIT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}) # Used during unit.cmake parsing

set(_UNIGRAPH_UNIT_LIST_DELIMITER "|")
set(_UNIGRAPH_UNIT_PROPERTY_LIST_DELIMITER "*")

set_property(GLOBAL PROPERTY _UNIGRAPH_UNITS_LIST)

if (NOT UNIGRAPH_TARGET_NAME_PREFIX)
    set(UNIGRAPH_TARGET_NAME_PREFIX "${PROJECT_NAME}")
endif ()

function(_unigraph_make_unit_target name type base_dir sources headers include_dirs dependencies nolink_dependencies)
    _unigraph_message(STATUS "Creating target '${name}' of type '${type}'")
    if (type STREQUAL "Executable")
        add_executable(${target_name})
        set(property_visibility PRIVATE)
    elseif (type STREQUAL "StaticLibrary")
        add_library(${target_name} STATIC)
        set(property_visibility PUBLIC)
    elseif (type STREQUAL "SharedLibrary")
        add_library(${target_name} SHARED)
        set(property_visibility PUBLIC)
    elseif (type STREQUAL "Interface")
        add_library(${target_name} INTERFACE)
        set(property_visibility INTERFACE)
    endif ()

    target_sources(${name}
        PRIVATE
        ${target_sources}
        ${target_headers}
    )
    target_include_directories(${name} ${property_visibility} ${include_dirs})
    set_target_properties(${name} PROPERTIES LINKER_LANGUAGE CXX)

    foreach (dependency IN LISTS dependencies)
        _unigraph_resolve_target_name(${dependency} resolved_dependency)
        target_link_libraries(${name} ${property_visibility} ${resolved_dependency})
    endforeach ()

    foreach (nolink_dependency IN LISTS nolink_dependencies)
        add_dependencies(${name} ${nolink_dependency})
    endforeach ()
endfunction(_unigraph_make_unit_target)

# Utility function to iterate over all user-defined units, and create their cmake targets,
# resolving dependencies for linkage.
function(_unigraph_make_unit_targets)
    set(all_test_sources)
    set(all_test_dependencies)

    get_property(unit_list GLOBAL PROPERTY _UNIGRAPH_UNITS_LIST)
    foreach (unit IN LISTS unit_list)
        _unigraph_dict_from_list_compatible(unit)
        _unigraph_get_value_from_dict(STRING unit "target_name" target_name)
        _unigraph_get_value_from_dict(STRING unit "type" target_type)
        _unigraph_get_value_from_dict(STRING unit "directory" unit_dir)
        _unigraph_get_value_from_dict(LIST unit "sources" target_sources)
        _unigraph_get_value_from_dict(LIST unit "headers" target_headers)
        _unigraph_get_value_from_dict(LIST unit "include_dirs" target_include_dirs)
        _unigraph_get_value_from_dict(LIST unit "dependencies" target_dependencies)
        _unigraph_get_value_from_dict(LIST unit "nolink_dependencies" target_nolink_dependencies)
        _unigraph_get_value_from_dict(LIST unit "test_sources" target_test_sources)

        list(FILTER target_sources EXCLUDE REGEX "^\"\"$")
        list(FILTER target_headers EXCLUDE REGEX "^\"\"$")
        list(FILTER target_include_dirs EXCLUDE REGEX "^\"\"$")
        list(FILTER target_dependencies EXCLUDE REGEX "^\"\"$")
        list(FILTER target_nolink_dependencies EXCLUDE REGEX "^\"\"$")
        list(FILTER target_test_sources EXCLUDE REGEX "^\"\"$")

        _unigraph_make_unit_target("${target_name}" "${target_type}" "${unit_dir}" "${target_sources}" "${target_headers}" "${target_include_dirs}" "${target_dependencies}" "${target_nolink_dependencies}")

        if (target_test_sources)
            _unigraph_create_test_target("${target_name}_Test" "${target_test_sources}" "${target_name}")
            list(APPEND all_test_sources ${target_test_sources})
            list(APPEND all_test_dependencies ${target_name})
        endif ()
    endforeach ()

    if (all_test_sources)
        _unigraph_create_test_target("${PROJECT_NAME}_All_Tests" "${all_test_sources}" "${all_test_dependencies}")
    endif ()
endfunction(_unigraph_make_unit_targets)

function(_unigraph_resolve_target_name in_unit_name out_target_name)
    get_property(unit_list GLOBAL PROPERTY _UNIGRAPH_UNITS_LIST)
    foreach (unit IN LISTS unit_list)
        _unigraph_dict_from_list_compatible(unit)
        _unigraph_get_value_from_dict(STRING unit "name" unit_name)
        _unigraph_get_value_from_dict(STRING unit "target_name" target_name)
        if (in_unit_name STREQUAL unit_name)
            set(${out_target_name} ${target_name} PARENT_SCOPE)
            return()
        endif ()
    endforeach ()
    set(${out_target_name} ${in_unit_name} PARENT_SCOPE)
endfunction(_unigraph_resolve_target_name)

# User-facing function to define a unit
function(unigraph_unit unit_name)
    cmake_parse_arguments(
        PARSED_ARGS
        ""
        "TYPE"
        "SOURCES;HEADERS;DEPEND;NAME;INCLUDE_DIRS;TEST_SOURCES;NOLINK_DEPEND"
        ${ARGN}
    )

    if (PARSED_ARGS_NAME)
        set(target_name "${PARSED_ARGS_NAME}")
    else ()
        set(target_name "${UNIGRAPH_TARGET_NAME_PREFIX}_${unit_name}")
    endif ()

    if (PARSED_ARGS_SOURCES)
        list(TRANSFORM PARSED_ARGS_SOURCES PREPEND "${_UNIGRAPH_CURRENT_UNIT_DIRECTORY}/")
    endif ()

    if (PARSED_ARGS_HEADERS)
        list(TRANSFORM PARSED_ARGS_HEADERS PREPEND "${_UNIGRAPH_CURRENT_UNIT_DIRECTORY}/")
    endif ()

    if (PARSED_ARGS_INCLUDE_DIRS)
        set(include_dirs)
        foreach (include_dir IN LISTS PARSED_ARGS_INCLUDE_DIRS)
            cmake_path(IS_ABSOLUTE include_dir is_absolute)
            if (is_absolute)
                list(APPEND include_dirs "${include_dir}")
            else ()
                list(APPEND include_dirs "${_UNIGRAPH_CURRENT_UNIT_DIRECTORY}/${include_dir}")
            endif ()
        endforeach ()
    else ()
        set(include_dirs "${_UNIGRAPH_CURRENT_UNIT_DIRECTORY}")
    endif()

    set(valid_target_types "Executable" "StaticLibrary" "SharedLibrary" "Interface")
    set(target_type "StaticLibrary")
    if (NOT PARSED_ARGS_SOURCES)
        set(target_type "Interface")
    endif ()

    if (PARSED_ARGS_TYPE)
        set(user_defined_target_type "${PARSED_ARGS_TYPE}")
        list(FIND valid_target_types "${user_defined_target_type}" index)
        if (index EQUAL -1)
            _unigraph_message(WARNING "Target type '${user_defined_target_type}' is ill-formed, "
                "must be one of '${valid_target_types}', inferring '${target_type}'")
        else ()
            set(target_type "${user_defined_target_type}")
        endif ()
    endif ()

    if (PARSED_ARGS_TEST_SOURCES)
        if (target_type STREQUAL "Executable")
            _unigraph_message(FATAL_ERROR "Executable units cannot have TEST_SOURCES")
        endif ()
        get_property(test_framework_target_with_main GLOBAL PROPERTY UNIGRAPH_ACTIVE_TEST_FRAMEWORK_TARGET_WITH_MAIN)
        if (test_framework_target_with_main STREQUAL "")
            _unigraph_message(FATAL_ERROR "TEST_SOURCES defined, but not test framework has been configured. Set variable UNIGRAPH_TEST_FRAMEWORK to one of '${UNIGRAPH_VALID_TEST_FRAMEWORKS}' before including Unigraph")
        endif ()
        list(TRANSFORM PARSED_ARGS_TEST_SOURCES PREPEND "${_UNIGRAPH_CURRENT_UNIT_DIRECTORY}/")
    endif ()

    set(unit)
    _unigraph_set_value_to_dict(STRING unit "name" "${unit_name}")
    _unigraph_set_value_to_dict(STRING unit "type" "${target_type}")
    _unigraph_set_value_to_dict(STRING unit "target_name" "${target_name}")
    _unigraph_set_value_to_dict(STRING unit "directory" "${_UNIGRAPH_CURRENT_UNIT_DIRECTORY}")
    _unigraph_set_value_to_dict(LIST unit "include_dirs" "${include_dirs}")
    _unigraph_set_value_to_dict(LIST unit "headers" "${PARSED_ARGS_HEADERS}")
    _unigraph_set_value_to_dict(LIST unit "sources" "${PARSED_ARGS_SOURCES}")
    _unigraph_set_value_to_dict(LIST unit "test_sources" "${PARSED_ARGS_TEST_SOURCES}")
    _unigraph_set_value_to_dict(LIST unit "dependencies" "${PARSED_ARGS_DEPEND}")
    _unigraph_set_value_to_dict(LIST unit "nolink_dependencies" "${PARSED_ARGS_NOLINK_DEPEND}")

    get_property(unit_list GLOBAL PROPERTY _UNIGRAPH_UNITS_LIST)
    _unigraph_dict_to_list_compatible(unit)
    list(APPEND unit_list "${unit}")
    set_property(GLOBAL PROPERTY _UNIGRAPH_UNITS_LIST ${unit_list})
endfunction(unigraph_unit)

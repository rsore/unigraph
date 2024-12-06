include(CMakeParseArguments)

set(_UNIGRAPH_CURRENT_UNIT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}) # Used during unit.cmake parsing

set(_UNIGRAPH_UNIT_LIST_DELIMITER "|")
set(_UNIGRAPH_UNIT_PROPERTY_LIST_DELIMITER "*")

set_property(GLOBAL PROPERTY _UNIGRAPH_UNITS_LIST)

if (NOT UNIGRAPH_TARGET_NAME_PREFIX)
    set(UNIGRAPH_TARGET_NAME_PREFIX "${PROJECT_NAME}")
endif ()

# Utility function to convert a set of unit data to a stringified "struct)
# We need to use different delimiters for internal lists, to maintain parsability
function(_unigraph_pack_unit_struct
        unit_name
        unit_dir
        target_name
        target_type
        target_sources
        target_headers
        target_dependencies
        target_test_sources
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

    if (NOT target_test_sources STREQUAL "")
        string(REPLACE ";" "${_UNIGRAPH_UNIT_PROPERTY_LIST_DELIMITER}" target_test_sources_packed "${target_test_sources}")
    else ()
        set(target_test_sources_packed "")
    endif ()

    string(CONCAT packed_str
            "${unit_name}${_UNIGRAPH_UNIT_LIST_DELIMITER}"
            "${unit_dir}${_UNIGRAPH_UNIT_LIST_DELIMITER}"
            "${target_name}${_UNIGRAPH_UNIT_LIST_DELIMITER}"
            "${target_type}${_UNIGRAPH_UNIT_LIST_DELIMITER}"
            "${target_sources_packed}${_UNIGRAPH_UNIT_LIST_DELIMITER}"
            "${target_headers_packed}${_UNIGRAPH_UNIT_LIST_DELIMITER}"
            "${target_dependencies_packed}${_UNIGRAPH_UNIT_LIST_DELIMITER}"
            "${target_test_sources_packed}")
    set(${out_str} ${packed_str} PARENT_SCOPE)
endfunction(_unigraph_pack_unit_struct)

# Utility function to take a stringified unit and extract the different fields
function(_unigraph_unpack_unit_struct
        packed_str
        out_unit_name
        out_unit_dir
        out_target_name
        out_target_type
        out_target_sources
        out_target_headers
        out_target_dependencies
        out_target_test_sources)
    string(REPLACE "${_UNIGRAPH_UNIT_LIST_DELIMITER}" ";" unit_list "${packed_str}")

    list(LENGTH unit_list num_elements)
    if (num_elements LESS 7)
        _unigraph_message(FATAL_ERROR "Malformed packed string: '${packed_str}'")
    endif ()

    list(GET unit_list 0 unit_name)
    list(GET unit_list 1 unit_dir)
    list(GET unit_list 2 target_name)
    list(GET unit_list 3 target_type)
    list(GET unit_list 4 sources_packed)
    list(GET unit_list 5 headers_packed)
    list(GET unit_list 6 dependencies_packed)
    list(GET unit_list 7 test_sources_packed)

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

    if (NOT test_sources_packed STREQUAL "")
        string(REPLACE "${_UNIGRAPH_UNIT_PROPERTY_LIST_DELIMITER}" ";" target_test_sources "${test_sources_packed}")
    else ()
        set(target_test_sources "")
    endif ()

    set(${out_unit_name} "${unit_name}" PARENT_SCOPE)
    set(${out_unit_dir} "${unit_dir}" PARENT_SCOPE)
    set(${out_target_name} "${target_name}" PARENT_SCOPE)
    set(${out_target_type} "${target_type}" PARENT_SCOPE)
    set(${out_target_sources} "${target_sources}" PARENT_SCOPE)
    set(${out_target_headers} "${target_headers}" PARENT_SCOPE)
    set(${out_target_dependencies} "${target_dependencies}" PARENT_SCOPE)
    set(${out_target_test_sources} "${target_test_sources}" PARENT_SCOPE)
endfunction(_unigraph_unpack_unit_struct)

# Utility function to iterate over all user-defined units, and create their cmake targets,
# resolving dependencies for linkage.
function(_unigraph_make_unit_targets)
    set(all_test_sources "")
    set(all_test_dependencies "")

    get_property(unit_list GLOBAL PROPERTY _UNIGRAPH_UNITS_LIST)
    foreach (unit IN LISTS unit_list)
        _unigraph_unpack_unit_struct(${unit}
                unit_name
                unit_dir
                target_name
                target_type
                target_sources
                target_headers
                target_dependencies
                target_test_sources)

        _unigraph_message(STATUS "Creating target '${target_name}' of type '${target_type}'")
        if (target_type STREQUAL "Executable")
            add_executable(${target_name})
            set(property_visibility PRIVATE)
        elseif (target_type STREQUAL "StaticLibrary")
            add_library(${target_name} STATIC)
            set(property_visibility PUBLIC)
        elseif (target_type STREQUAL "SharedLibrary")
            add_library(${target_name} SHARED)
            set(property_visibility PUBLIC)
        elseif (target_type STREQUAL "Interface")
            add_library(${target_name} INTERFACE)
            set(property_visibility INTERFACE)
        endif ()

        target_sources(${target_name}
                PRIVATE
                ${target_sources}
        )

        target_sources(${target_name}
                ${property_visibility}
                FILE_SET unigraph_${target_name}_headers
                TYPE HEADERS
                BASE_DIRS ${unit_dir}
                FILES ${target_headers}
        )

        set_target_properties(${target_name} PROPERTIES LINKER_LANGUAGE CXX)

        foreach (dependency IN LISTS target_dependencies)
            _unigraph_resolve_target_name(${dependency} resolved_dependency)
            target_link_libraries(${target_name} ${property_visibility} ${resolved_dependency})
        endforeach ()

        # If there are tests sources defined for the unit, create a unit test target
        if (target_test_sources)
            set(test_target "${target_name}_Test")
            _unigraph_message(STATUS "Creating test target '${test_target}' of type 'Executable'")
            get_property(test_framework_target_with_main GLOBAL PROPERTY UNIGRAPH_ACTIVE_TEST_FRAMEWORK_TARGET_WITH_MAIN)
            add_executable(${test_target} ${target_test_sources})
            target_link_libraries(${test_target} PRIVATE ${target_name} ${test_framework_target_with_main})

            list(APPEND all_test_sources ${target_test_sources})
            list(APPEND all_test_dependencies ${target_name})
        endif ()
    endforeach ()

    # If there are any test sources in the entire project, collect them in one amalgamated test target
    if (all_test_sources)
        set(all_tests_target "${PROJECT_NAME}_All_Tests")
        _unigraph_message(STATUS "Creating test target '${all_tests_target}' of type 'Executable'")
        add_executable(${all_tests_target} ${all_test_sources})
        foreach (dependency IN LISTS all_test_dependencies)
            target_link_libraries(${all_tests_target} PRIVATE ${dependency})
        endforeach ()
        get_property(test_framework_target_with_main GLOBAL PROPERTY UNIGRAPH_ACTIVE_TEST_FRAMEWORK_TARGET_WITH_MAIN)
        target_link_libraries(${all_tests_target} PRIVATE ${test_framework_target_with_main})
    endif ()
endfunction(_unigraph_make_unit_targets)

function(_unigraph_resolve_target_name in_unit_name out_target_name)
    get_property(unit_list GLOBAL PROPERTY _UNIGRAPH_UNITS_LIST)
    foreach (unit IN LISTS unit_list)
        _unigraph_unpack_unit_struct(${unit}
                unit_name
                unit_dir
                target_name
                target_type
                target_sources
                target_headers
                target_dependencies
                target_test_sources)
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
            "SOURCES;HEADERS;DEPEND;NAME;TEST_SOURCES"
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

    _unigraph_pack_unit_struct(
            ${unit_name}
            ${_UNIGRAPH_CURRENT_UNIT_DIRECTORY}
            ${target_name}
            ${target_type}
            "${PARSED_ARGS_SOURCES}"
            "${PARSED_ARGS_HEADERS}"
            "${PARSED_ARGS_DEPEND}"
            "${PARSED_ARGS_TEST_SOURCES}"
            unit
    )

    get_property(unit_list GLOBAL PROPERTY _UNIGRAPH_UNITS_LIST)
    list(APPEND unit_list "${unit}")
    set_property(GLOBAL PROPERTY _UNIGRAPH_UNITS_LIST ${unit_list})
endfunction(unigraph_unit)

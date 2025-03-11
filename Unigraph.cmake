# Unigraph
#
# CMake module for declarative target creation and dependency management.
# It allows users to define targets with dependencies, headers, and sources
# in a simple, declarative style, and automatically resolves and builds them.
#
# Configuration options:
#  - UNIGRAPH_TARGET_NAME_PREFIX: String used as prefix in automatic target names.
#                                 If not specified, ${PROJECT_NAME} is used
#  - UNIGRAPH_TEST_FRAMEWORK: Test framework to link with for auto-generated test targets
#                             when a unit defines TEST_SOURCES
#
# User-facing function:
#  - unigraph_unit: Defines a new unit with a set of sources, headers, and dependencies.
#                   Expected to be used inside unit.cmake files

macro(_unigraph_message level message)
    message(${level} "[ Unigraph - ${PROJECT_NAME} ] ${message}")
endmacro()

if (CMAKE_VERSION VERSION_LESS "3.24")
    _unigraph_message(FATAL_ERROR "The module 'Unigraph' requires at least CMake 3.23. Please update your CMake version.")
endif ()

include(UnigraphUtil)
include(UnigraphDictionary)
include(UnigraphTestFramework)
include(UnigraphUnit)
include(UnigraphReport)
include(UnigraphViz)

if (NOT DEFINED UNIGRAPH_GENERATE_REPORT)
    set(UNIGRAPH_GENERATE_REPORT ON)
endif ()

if (NOT DEFINED UNIGRAPH_GENERATE_DEPENDENCY_GRAPH_DOT_FILE)
    set(UNIGRAPH_GENERATE_DEPENDENCY_GRAPH_DOT_FILE ON)
endif ()

function(unigraph_init)
    cmake_parse_arguments(
        arg
        ""
        "TEST_FRAMEWORK;GENERATE_REPORT;GENERATE_DEPENDENCY_GRAPH"
        "UNITS"
        ${ARGN}
    )

    list(LENGTH arg_UNITS unit_count)
    math(EXPR unit_count_mod_two "${unit_count} % 2")
    if (NOT ${unit_count_mod_two} STREQUAL "0")
        _unigraph_message(FATAL_ERROR "In function 'unigraph_init': Keyword 'UNITS' must have an even number of arguments (name/path pairs).")
    endif ()

    if (arg_TEST_FRAMEWORK)
        _unigraph_initialize_test_framework("${arg_TEST_FRAMEWORK}")
    endif ()

    math(EXPR unit_count_minus_one "${unit_count} - 1")
    foreach(i RANGE 0 ${unit_count_minus_one} 2)
        math(EXPR i_plus_one "${i} + 1")
        list(GET arg_UNITS ${i} unit_name)
        list(GET arg_UNITS ${i_plus_one} unit_path)

        set (unit_file "${CMAKE_CURRENT_SOURCE_DIR}/${unit_path}/unit.cmake")
        if (NOT EXISTS "${unit_file}")
            _unigraph_message(FATAL_ERROR "Expected to find unit file \"${unit_file}\", but it does not exist")
        endif ()

        _unigraph_message(STATUS "Processing unit \"${unit_name}\" in file \"${unit_file}\"...")

        # Used by Unigraph while parsing units
        get_filename_component(_UNIGRAPH_CURRENT_UNIT_DIRECTORY "${unit_file}" DIRECTORY)
        set(_UNIGRAPH_CURRENT_UNIT_NAME "${unit_name}")

        include("${unit_file}")
    endforeach()
    _unigraph_make_unit_targets()

    if ("${arg_GENERATE_REPORT}" STREQUAL "ON")
        _unigraph_generate_report()
    endif ()

    if ("${arg_GENERATE_DEPENDENCY_GRAPH}" STREQUAL "ON")
        _unigraph_generate_dependency_graph_dot_file()
    endif ()
endfunction(unigraph_init)
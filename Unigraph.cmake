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
        "GENERATE_REPORT;GENERATE_DEPENDENCY_GRAPH"
        "TEST_FRAMEWORK"
        "UNITS"
        ${ARGN}
    )

    if (arg_TEST_FRAMEWORK)
        _unigraph_initialize_test_framework("${arg_TEST_FRAMEWORK}")
    endif ()

    foreach (unit_path IN LISTS arg_UNITS)
        set (unit_file "${CMAKE_CURRENT_SOURCE_DIR}/${unit_path}/unit.cmake")
        if (NOT EXISTS "${unit_file}")
            _unigraph_message(FATAL_ERROR "Expected to find unit file \"${unit_file}\", but it does not exist")
        endif ()

        _unigraph_message(STATUS "Processing unit file \"${unit_file}\"...")
        get_filename_component(_UNIGRAPH_CURRENT_UNIT_DIRECTORY "${unit_file}" DIRECTORY) # Used by Unigraph while parsing units
        include("${unit_file}")
    endforeach ()
    _unigraph_make_unit_targets()

    if (arg_GENERATE_REPORT)
        _unigraph_generate_report()
    endif ()

    if (arg_GENERATE_DEPENDENCY_GRAPH)
        _unigraph_generate_dependency_graph_dot_file()
    endif ()
endfunction(unigraph_init)
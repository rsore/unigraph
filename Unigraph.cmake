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

if (CMAKE_VERSION VERSION_LESS "3.23")
    message(FATAL_ERROR "The module 'Unigraph' requires at least CMake 3.23. "
            "Please update your CMake version.")
endif ()

macro(_unigraph_message level message)
    message(${level} "[ Unigraph ] ${message}")
endmacro()

include(UnigraphUtil)
include(UnigraphUnit)
include(UnigraphTestFramework)
include(UnigraphReport)
include(UnigraphViz)

if (NOT DEFINED UNIGRAPH_GENERATE_REPORT)
    set(UNIGRAPH_GENERATE_REPORT ON)
endif ()

if (NOT DEFINED UNIGRAPH_GENERATE_DEPENDENCY_GRAPH_DOT_FILE)
    set(UNIGRAPH_GENERATE_DEPENDENCY_GRAPH_DOT_FILE ON)
endif ()

if (UNIGRAPH_TEST_FRAMEWORK)
    _unigraph_initialize_test_framework("${UNIGRAPH_TEST_FRAMEWORK}")
endif ()

file(GLOB_RECURSE _UNIGRAPH_UNIT_CMAKE_FILES "${CMAKE_CURRENT_LIST_DIR}/**/unit.cmake")
foreach (file IN LISTS _UNIGRAPH_UNIT_CMAKE_FILES)
    _unigraph_message(STATUS "Found unit.cmake: ${file}")
    get_filename_component(_UNIGRAPH_CURRENT_UNIT_DIRECTORY ${file} DIRECTORY)
    include(${file})
endforeach ()
_unigraph_make_unit_targets()

if (UNIGRAPH_GENERATE_REPORT)
    _unigraph_generate_report()
endif ()

if (UNIGRAPH_GENERATE_DEPENDENCY_GRAPH_DOT_FILE)
    _unigraph_generate_dependency_graph_dot_file()
endif()
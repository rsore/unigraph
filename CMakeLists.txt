cmake_minimum_required(VERSION 3.24)
project(Unigraph)

option(UNIGRAPH_BUILD_EXAMPLE "Build the example project" ON)

option(UNIGRAPH_BUILD_EXAMPLES "Build Unigraph example projects" OFF)
if (PROJECT_IS_TOP_LEVEL)
    set(UNIGRAPH_BUILD_EXAMPLES ON CACHE BOOL "" FORCE)
endif ()

if (UNIGRAPH_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif ()

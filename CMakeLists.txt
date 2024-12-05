cmake_minimum_required(VERSION 3.23)
project(Unigraph)

option(UNIGRAPH_BUILD_EXAMPLE "Build the example project" ON)

if (UNIGRAPH_BUILD_EXAMPLE)
    add_subdirectory(examples)
endif ()

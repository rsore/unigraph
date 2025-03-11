cmake_minimum_required(VERSION 3.24)

project(GTestTestApp VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../..")
include(Unigraph)

unigraph_init(
    GENERATE_REPORT           ON
    GENERATE_DEPENDENCY_GRAPH ON
    TEST_FRAMEWORK            GoogleTest

    UNITS
      HelloGTest hello_gtest/
)
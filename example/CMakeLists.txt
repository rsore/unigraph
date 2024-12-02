cmake_minimum_required(VERSION 3.20)

project(UnigraphExample)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/..")
include(Unigraph)

add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/core)
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/example_app)
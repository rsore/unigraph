include(FetchContent)

set(UNIGRAPH_VALID_TEST_FRAMEWORKS "Catch2" "GoogleTest")
set_property(GLOBAL PROPERTY _UNIGRAPH_ACTIVE_TEST_FRAMEWORK_TARGET_WITH_MAIN "")

function(_unigraph_initialize_google_test)
    FetchContent_Declare(googletest
        URL https://github.com/google/googletest/archive/b514bdc898e2951020cbdca1304b75f5950d1f59.zip
    )
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)

    add_library(unigraph_gtest_gmock_bundle INTERFACE)
    target_link_libraries(unigraph_gtest_gmock_bundle INTERFACE GTest::gtest_main GTest::gmock)

    set_property(GLOBAL PROPERTY _UNIGRAPH_ACTIVE_TEST_FRAMEWORK_TARGET_WITH_MAIN "unigraph_gtest_gmock_bundle")
endfunction()

function(_unigraph_initialize_catch2)
    FetchContent_Declare(Catch2
        URL https://github.com/catchorg/Catch2/archive/refs/tags/v3.7.1.zip
    )
    FetchContent_MakeAvailable(Catch2)
    set_property(GLOBAL PROPERTY _UNIGRAPH_ACTIVE_TEST_FRAMEWORK_TARGET_WITH_MAIN "Catch2::Catch2WithMain")
endfunction()

function(_unigraph_initialize_test_framework framework)
    list(FIND UNIGRAPH_VALID_TEST_FRAMEWORKS "${framework}" index)
    if (index EQUAL -1)
        _unigraph_message(FATAL_ERROR "Test framework '${framework}' is not supported. Supported frameworks are: ${UNIGRAPH_VALID_TEST_FRAMEWORKS}")
    endif ()

    if (framework STREQUAL "GoogleTest")
        _unigraph_initialize_google_test()
    elseif (framework STREQUAL "Catch2")
        _unigraph_initialize_catch2()
    endif ()
    _unigraph_message(STATUS "Using test framework '${framework}'")
endfunction(_unigraph_initialize_test_framework)

function(_unigraph_create_test_target name sources_list dependency_list)
    _unigraph_message(STATUS "Creating test target '${name}' of type 'Executable'")
    get_property(test_framework_target_with_main GLOBAL PROPERTY _UNIGRAPH_ACTIVE_TEST_FRAMEWORK_TARGET_WITH_MAIN)
    add_executable(${name} ${sources_list})
    target_link_libraries(${name} PRIVATE ${dependency_list} ${test_framework_target_with_main})
endfunction(_unigraph_create_test_target)
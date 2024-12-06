include(FetchContent)

set(UNIGRAPH_VALID_TEST_FRAMEWORKS "Catch2" "GoogleTest")
set_property(GLOBAL PROPERTY _UNIGRAPH_ACTIVE_TEST_FRAMEWORK_TARGET_WITH_MAIN "")

function(_unigraph_initialize_google_test)
    _unigraph_message(FATAL_ERROR "Support for GoogleTest not yet implemented")
endfunction()

function(_unigraph_initialize_catch2)
    FetchContent_Declare(
            Catch2
            GIT_REPOSITORY https://github.com/catchorg/Catch2.git
            GIT_TAG v3.7.1
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

function(_unigraph_create_test_target name sources_list link_list)
    _unigraph_message(STATUS "Creating test target '${name}' of type 'Executable'")
    get_property(test_framework_target_with_main GLOBAL PROPERTY _UNIGRAPH_ACTIVE_TEST_FRAMEWORK_TARGET_WITH_MAIN)
    add_executable(${name} ${sources_list})
    target_link_libraries(${name} PRIVATE ${link_list} ${test_framework_target_with_main})
endfunction(_unigraph_create_test_target)
include(CMakeParseArguments)

function(unigraph_unit unit_name)
    cmake_parse_arguments(
            PARSED_ARGS
            ""
            "TYPE"
            "SOURCES;HEADERS;DEPEND"
            ${ARGN}
    )

    if (NOT PARSED_ARGS_SOURCES AND NOT PARSED_ARGS_HEADERS)
        message(FATAL_ERROR "You must provide at least one source or header file")
    endif ()

    set(target_name "${unit_name}")

    set(valid_target_types "Executable" "StaticLibrary" "SharedLibrary" "Interface")
    set(target_type "StaticLibrary")
    if (PARSED_ARGS_TYPE)
        set(user_defined_target_type "${PARSED_ARGS_TYPE}")
        list(FIND valid_target_types "${user_defined_target_type}" index)
        if (index EQUAL -1)
            message(WARNING "Target type '${user_defined_target_type}' is not valid, must be one of ${valid_target_types}, falling back to ${target_type}")
        else ()
            set(target_type "${user_defined_target_type}")
        endif ()
    endif ()

    if (target_type STREQUAL "Executable")
        add_executable(${target_name}
                ${PARSED_ARGS_SOURCES}
                ${PARSED_ARGS_HEADERS}
        )
    elseif (target_type STREQUAL "StaticLibrary")
        add_library(${target_name} STATIC
                ${PARSED_ARGS_SOURCES}
                ${PARSED_ARGS_HEADERS}
        )
    elseif (target_type STREQUAL "SharedLibrary")
        add_library(${target_name} SHARED
                ${PARSED_ARGS_SOURCES}
                ${PARSED_ARGS_HEADERS}
        )
    elseif (target_type STREQUAL "Interface")
        if (PARSED_ARGS_SOURCES)
            message(FATAL_ERROR "Interface units cannot have source files, only header files")
        endif ()
        add_library(${target_name} INTERFACE
                ${PARSED_ARGS_HEADERS}
        )
    endif ()

    target_include_directories(${target_name} PUBLIC ${CMAKE_CURRENT_LIST_DIR})
    set_target_properties(${target_name} PROPERTIES LINKER_LANGUAGE CXX)

    if (PARSED_ARGS_DEPEND)
        target_link_libraries(${target_name} PUBLIC
                ${PARSED_ARGS_DEPEND}
        )
    endif ()
endfunction(unigraph_unit)
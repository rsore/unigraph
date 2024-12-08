function(_unigraph_json_append_string in_json key indent_key indent_depth value last_key_flag out_json)
    set(output "${in_json}")
    _unigraph_append_indent("${output}" "${indent_key}" ${indent_depth} output)

    string(APPEND output "\"${key}\": \"${value}\"")

    if (NOT last_key_flag)
        string(APPEND output ",")
    endif ()
    string(APPEND output "\n")

    set(${out_json} "${output}" PARENT_SCOPE)
endfunction(_unigraph_json_append_string)

function(_unigraph_json_append_list in_json key indent_key indent_depth list_content_var last_key_flag out_json)
    set(output "${in_json}")
    _unigraph_append_indent("${output}" "${indent_key}" ${indent_depth} output)

    list(LENGTH ${list_content_var} list_length)
    if (list_length EQUAL 0)
        string(APPEND output "\"${key}\": []")
    else ()
        string(APPEND output "\"${key}\": [\n")
        math(EXPR indent_depth "${indent_depth} + 1")

        list(LENGTH ${list_content_var} list_length)
        set(i 0)
        foreach (item IN LISTS ${list_content_var})
            math(EXPR i "${i} + 1")
            if (i EQUAL list_length)
                set(last_item YES)
            else ()
                set(last_item NO)
            endif ()

            _unigraph_append_indent("${output}" "${indent_key}" ${indent_depth} output)

            string(APPEND output "\"${item}\"")
            if (NOT last_item)
                string(APPEND output ",")
            endif ()
            string(APPEND output "\n")
        endforeach ()
        math(EXPR indent_depth "${indent_depth} - 1")

        _unigraph_append_indent("${output}" "${indent_key}" ${indent_depth} output)
        string(APPEND output "]")
    endif ()

    if (NOT last_key_flag)
        string(APPEND output ",")
    endif ()
    string(APPEND output "\n")

    set(${out_json} "${output}" PARENT_SCOPE)
endfunction(_unigraph_json_append_list)

function(_unigraph_generate_report)
    set(report_path "${CMAKE_BINARY_DIR}/unigraph_${PROJECT_NAME}_report.json")
    _unigraph_message(STATUS "Generating unigraph report '${report_path}'")

    set(indent "    ")
    set(json_content "{\n")

    if (UNIGRAPH_TEST_FRAMEWORK)
        set(test_framework "${UNIGRAPH_TEST_FRAMEWORK}")
    else ()
        set(test_framework "None")
    endif ()

    string(TIMESTAMP report_time "%Y-%m-%dT%H:%M:%SZ")
    _unigraph_json_append_string(${json_content} "generated" "${indent}" 1 "${report_time}" NO json_content)
    string(APPEND json_content "${indent}\"cpp\": {\n")
    _unigraph_json_append_string(${json_content} "standard" "${indent}" 2 "${CMAKE_CXX_STANDARD}" NO json_content)
    string(APPEND json_content "${indent}${indent}\"compiler\": {\n")
    _unigraph_json_append_string(${json_content} "path" "${indent}" 3 "${CMAKE_CXX_COMPILER}" NO json_content)
    _unigraph_json_append_string(${json_content} "version" "${indent}" 3 "${CMAKE_CXX_COMPILER_VERSION}" YES json_content)
    string(APPEND json_content "${indent}${indent}}\n")
    string(APPEND json_content "${indent}},\n")

    string(APPEND json_content "${indent}\"host_system\": {\n")
    _unigraph_json_append_string(${json_content} "name" "${indent}" 2 "${CMAKE_HOST_SYSTEM_NAME}" NO json_content)
    _unigraph_json_append_string(${json_content} "version" "${indent}" 2 "${CMAKE_HOST_SYSTEM_VERSION}" NO json_content)
    _unigraph_json_append_string(${json_content} "processor" "${indent}" 2 "${CMAKE_HOST_SYSTEM_PROCESSOR}" YES json_content)
    string(APPEND json_content "${indent}},\n")

    string(APPEND json_content "${indent}\"target_system\": {\n")
    _unigraph_json_append_string(${json_content} "name" "${indent}" 2 "${CMAKE_SYSTEM_NAME}" NO json_content)
    _unigraph_json_append_string(${json_content} "version" "${indent}" 2 "${CMAKE_SYSTEM_VERSION}" NO json_content)
    _unigraph_json_append_string(${json_content} "processor" "${indent}" 2 "${CMAKE_SYSTEM_PROCESSOR}" YES json_content)
    string(APPEND json_content "${indent}},\n")

    string(APPEND json_content "${indent}\"project\": {\n")
    _unigraph_json_append_string(${json_content} "name" "${indent}" 2 "${PROJECT_NAME}" NO json_content)
    _unigraph_json_append_string(${json_content} "version" "${indent}" 2 "${PROJECT_VERSION}" NO json_content)
    _unigraph_json_append_string(${json_content} "test_framework" "${indent}" 2 "${test_framework}" NO json_content)

    _unigraph_append_indent("${json_content}" "${indent}" 2 json_content)
    string(APPEND json_content "\"units\": [\n")

    get_property(unit_list GLOBAL PROPERTY _UNIGRAPH_UNITS_LIST)
    list(LENGTH unit_list unit_list_length)
    set(i 0)
    foreach (unit IN LISTS unit_list)
        math(EXPR i "${i} + 1")
        if (i EQUAL unit_list_length)
            set(last_unit YES)
        else ()
            set(last_unit NO)
        endif ()

        _unigraph_unpack_unit_struct(${unit}
            unit_name
            unit_dir
            target_name
            target_type
            target_sources
            target_headers
            target_include_dirs
            target_dependencies
            target_test_sources)

        _unigraph_append_indent("${json_content}" "${indent}" 3 json_content)
        string(APPEND json_content "{\n")

        _unigraph_json_append_string(${json_content} "name" "${indent}" 4 "${unit_name}" NO json_content)
        _unigraph_json_append_string(${json_content} "target" "${indent}" 4 "${target_name}" NO json_content)
        _unigraph_json_append_string(${json_content} "type" "${indent}" 4 "${target_type}" NO json_content)
        _unigraph_json_append_string(${json_content} "directory" "${indent}" 4 "${unit_dir}" NO json_content)
        _unigraph_json_append_list(${json_content} "dependencies" "${indent}" 4 target_dependencies NO json_content)
        _unigraph_json_append_list(${json_content} "headers" "${indent}" 4 target_headers NO json_content)
        _unigraph_json_append_list(${json_content} "sources" "${indent}" 4 target_sources NO json_content)
        message("Unit: ${unit_name}, include_dirs: ( ${target_include_dirs} )")
        _unigraph_json_append_list(${json_content} "include_dirs" "${indent}" 4 target_include_dirs NO json_content)
        _unigraph_json_append_list(${json_content} "test_sources" "${indent}" 4 target_test_sources YES json_content)

        _unigraph_append_indent("${json_content}" "${indent}" 3 json_content)
        string(APPEND json_content "}")
        if (NOT last_unit)
            string(APPEND json_content ",")
        endif ()
        string(APPEND json_content "\n")
    endforeach ()
    _unigraph_append_indent("${json_content}" "${indent}" 2 json_content)
    string(APPEND json_content "]\n")

    _unigraph_append_indent("${json_content}" "${indent}" 1 json_content)
    string(APPEND json_content "}\n")

    string(APPEND json_content "}\n")

    file(WRITE "${report_path}" "${json_content}")
endfunction(_unigraph_generate_report)
function(_unigraph_append_indent in_str indent_key indent_depth out_str)
    set(output "${in_str}")
    foreach (i RANGE 1 ${indent_depth})
        string(APPEND output "${indent_key}")
    endforeach ()
    set(${out_str} "${output}" PARENT_SCOPE)
endfunction(_unigraph_append_indent)

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

function(_unigraph_list_of_absolute_paths_to_list_of_relative_paths in_list directory out_list)
    set(output)
    foreach (abs_path IN LISTS in_list)
        file(RELATIVE_PATH rel_path "${directory}" "${abs_path}")
        list(APPEND output "${rel_path}")
    endforeach ()
    set(${out_list} "${output}" PARENT_SCOPE)
endfunction(_unigraph_list_of_absolute_paths_to_list_of_relative_paths)

function(_unigraph_generate_report)
    set(report_path "${CMAKE_BINARY_DIR}/unigraph_report.json")
    _unigraph_message(STATUS "Generating unigraph report '${report_path}'")

    set(indent "  ")
    set(json_content "{\n")

    if (UNIGRAPH_TEST_FRAMEWORK)
        set(test_framework "${UNIGRAPH_TEST_FRAMEWORK}")
    else ()
        set(test_framework "None")
    endif ()
    _unigraph_json_append_string(${json_content} "test_framework" "${indent}" 1 "${test_framework}" NO json_content)

    _unigraph_append_indent("${json_content}" "${indent}" 1 json_content)
    string(APPEND json_content "\"units\": [\n")

    get_property(unit_list GLOBAL PROPERTY UNIGRAPH_UNITS_LIST)
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
                target_dependencies
                target_test_sources)

        file(RELATIVE_PATH unit_dir_rel "${PROJECT_SOURCE_DIR}" "${unit_dir}")

        _unigraph_list_of_absolute_paths_to_list_of_relative_paths("${target_headers}" "${unit_dir}" target_headers)
        _unigraph_list_of_absolute_paths_to_list_of_relative_paths("${target_sources}" "${unit_dir}" target_sources)
        _unigraph_list_of_absolute_paths_to_list_of_relative_paths("${target_test_sources}" "${unit_dir}" target_test_sources)

        string(APPEND json_content "${indent}${indent}{\n")

        _unigraph_json_append_string(${json_content} "name" "${indent}" 3 "${unit_name}" NO json_content)
        _unigraph_json_append_string(${json_content} "target" "${indent}" 3 "${target_name}" NO json_content)
        _unigraph_json_append_string(${json_content} "type" "${indent}" 3 "${target_type}" NO json_content)
        _unigraph_json_append_string(${json_content} "directory" "${indent}" 3 "${unit_dir_rel}" NO json_content)
        _unigraph_json_append_list(${json_content} "dependencies" "${indent}" 3 target_dependencies NO json_content)
        _unigraph_json_append_list(${json_content} "headers" "${indent}" 3 target_headers NO json_content)
        _unigraph_json_append_list(${json_content} "sources" "${indent}" 3 target_sources NO json_content)
        _unigraph_json_append_list(${json_content} "test_sources" "${indent}" 3 target_test_sources YES json_content)

        _unigraph_append_indent("${json_content}" "${indent}" 2 json_content)
        string(APPEND json_content "}")
        if (NOT last_unit)
            string(APPEND json_content ",")
        endif ()
        string(APPEND json_content "\n")
    endforeach ()

    _unigraph_append_indent("${json_content}" "${indent}" 1 json_content)
    string(APPEND json_content "]\n}\n")

    file(WRITE "${report_path}" "${json_content}")
endfunction(_unigraph_generate_report)
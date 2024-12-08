function(_unigraph_append_line_to_dot in_str line indent_key indent_depth out_str)
    set(output "${in_str}")
    _unigraph_append_indent("${output}" "${indent_key}" ${indent_depth} output)
    string(APPEND output "${line}\n")
    set(${out_str} "${output}" PARENT_SCOPE)
endfunction(_unigraph_append_line_to_dot)

function(_unigraph_append_legend_block_to_dot in_str block_name label color indent_key indent_depth out_str)
    set(output "${in_str}")
    _unigraph_append_line_to_dot("${output}" "${block_name} [label=\"${label}\",color=${color}]" "${indent_key}" ${indent_depth} output)
    _unigraph_append_line_to_dot("${output}" "{" "${indent_key}" ${indent_depth} output)
    math(EXPR indent_depth "${indent_depth} + 1")
    _unigraph_append_line_to_dot("${output}" "rank=same;" "${indent_key}" ${indent_depth} output)
    math(EXPR indent_depth "${indent_depth} - 1")
    _unigraph_append_line_to_dot("${output}" "}" "${indent_key}" ${indent_depth} output)
    set(${out_str} "${output}" PARENT_SCOPE)
endfunction(_unigraph_append_legend_block_to_dot)

function(_unigraph_generate_dependency_graph_dot_file)
    set(viz_path "${CMAKE_BINARY_DIR}/unigraph_${PROJECT_NAME}_dependency_graph.dot")
    _unigraph_message(STATUS "Generating unigraph dependency graph '${viz_path}'")

    set(indent "    ")
    set(graph_content "digraph ${PROJECT_NAME} {\n")

    set(executable_color "blue")
    set(static_library_color "green")
    set(shared_library_color "magenta4")
    set(interface_color "gray16")
    set(executable_attributes "[color=${executable_color}]")
    set(static_library_attributes "[color=${static_library_color}]")
    set(shared_library_attributes "[color=${shared_library_color}]")
    set(interface_attributes "[color=${interface_color},style=dashed]")

    _unigraph_append_line_to_dot("${graph_content}" "subgraph cluster_legend {" "${indent}" 1 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "label=\"Legend\";" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "style=\"solid\";" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "fontsize=10;" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "ranksep=0.01;" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "labelloc=b;" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "node [shape=rectangle,style=filled,fontcolor=white,labelloc=c];" "${indent}" 2 graph_content)
    _unigraph_append_legend_block_to_dot("${graph_content}" "ExecutableBlock" "Executable" "${executable_color}" "${indent}" 2 graph_content)
    _unigraph_append_legend_block_to_dot("${graph_content}" "StaticLibBlock" "StaticLibrary" "${static_library_color}" "${indent}" 2 graph_content)
    _unigraph_append_legend_block_to_dot("${graph_content}" "SharedLibBlock" "SharedLibrary" "${shared_library_color}" "${indent}" 2 graph_content)
    _unigraph_append_legend_block_to_dot("${graph_content}" "InterfaceBlock" "Interface" "${interface_color}" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "ExecutableBlock -> StaticLibBlock -> SharedLibBlock -> InterfaceBlock [style=invis];" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "}" "${indent}" 1 graph_content)

    _unigraph_append_line_to_dot("${graph_content}" "node [penwidth=2];" "${indent}" 1 graph_content)
    get_property(unit_list GLOBAL PROPERTY _UNIGRAPH_UNITS_LIST)
    foreach (unit IN LISTS unit_list)
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
        if (target_type STREQUAL "Executable")
            set(label_properties "${executable_attributes}")
        elseif (target_type STREQUAL "StaticLibrary")
            set(label_properties "${static_library_attributes}")
        elseif (target_type STREQUAL "SharedLibrary")
            set(label_properties "${shared_library_attributes}")
        elseif (target_type STREQUAL "Interface")
            set(label_properties "${interface_attributes}")
        endif ()

        _unigraph_append_line_to_dot("${graph_content}" "${unit_name} ${label_properties};" "${indent}" 1 graph_content)
    endforeach ()

    foreach (unit IN LISTS unit_list)
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

        foreach (dependency IN LISTS target_dependencies)
            _unigraph_append_line_to_dot("${graph_content}" "${unit_name} -> ${dependency};" "${indent}" 1 graph_content)
        endforeach ()
    endforeach ()

    string(APPEND graph_content "}")

    file(WRITE "${viz_path}" "${graph_content}")
endfunction(_unigraph_generate_dependency_graph_dot_file)
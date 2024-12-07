function(_unigraph_append_line_to_dot in_str line indent_key indent_depth out_str)
    set(output "${in_str}")
    _unigraph_append_indent("${output}" "${indent_key}" ${indent_depth} output)
    string(APPEND output "${line}\n")
    set(${out_str} "${output}" PARENT_SCOPE)
endfunction(_unigraph_append_line_to_dot)

function(_unigraph_generate_dependency_graph_dot_file)
    set(viz_path "${CMAKE_BINARY_DIR}/unigraph_dependency_graph.dot")
    _unigraph_message(STATUS "Generating unigraph dependency graph '${viz_path}'")

    set(indent "    ")
    set(graph_content "digraph ${PROJECT_NAME} {\n")

    set(executable_attributes "[color=blue]")
    set(library_attributes "[color=green]")
    set(interface_attributes "[color=gray,style=dashed]")

    _unigraph_append_line_to_dot("${graph_content}" "subgraph cluster_legend {" "${indent}" 1 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "label=\"Legend\";" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "style=\"solid\";" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "fontsize=10;" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "ranksep=0.05;" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "nodesep=0.01;" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "labelloc=b;" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "Executable ${executable_attributes};" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "Library ${library_attributes};" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "Interface ${interface_attributes};" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "Executable -> Library -> Interface [style=\"invis\"];" "${indent}" 2 graph_content)
    _unigraph_append_line_to_dot("${graph_content}" "}" "${indent}" 1 graph_content)

    get_property(unit_list GLOBAL PROPERTY _UNIGRAPH_UNITS_LIST)
    foreach (unit IN LISTS unit_list)
        _unigraph_unpack_unit_struct(${unit}
                unit_name
                unit_dir
                target_name
                target_type
                target_sources
                target_headers
                target_dependencies
                target_test_sources)
        if (target_type STREQUAL "Executable")
            set(label_properties "${executable_attributes}")
        elseif (target_type STREQUAL "Interface")
            set(label_properties "${interface_attributes}")
        else ()
            set(label_properties "${library_attributes}")
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
                target_dependencies
                target_test_sources)

        foreach (dependency IN LISTS target_dependencies)
            _unigraph_append_line_to_dot("${graph_content}" "${unit_name} -> ${dependency};" "${indent}" 1 graph_content)
        endforeach ()
    endforeach ()

    string(APPEND graph_content "}")

    file(WRITE "${viz_path}" "${graph_content}")
endfunction(_unigraph_generate_dependency_graph_dot_file)
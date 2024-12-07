function(_unigraph_generate_dependency_graph_dot_file)
    set(viz_path "${CMAKE_BINARY_DIR}/unigraph_dependency_graph.dot")
    _unigraph_message(STATUS "Generating unigraph dependency graph '${viz_path}'")

    set(indent "    ")
    set(graph_content "digraph ${PROJECT_NAME} {\n")

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

        foreach (dependency IN LISTS target_dependencies)
            _unigraph_append_indent("${graph_content}" "${indent}" 1 graph_content)
            string(APPEND graph_content "${unit_name} -> ${dependency};\n")
        endforeach ()
    endforeach ()

    string(APPEND graph_content "}")

    file(WRITE "${viz_path}" "${graph_content}")
endfunction(_unigraph_generate_dependency_graph_dot_file)
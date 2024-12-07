function(_unigraph_append_indent in_str indent_key indent_depth out_str)
    set(output "${in_str}")
    foreach (i RANGE 1 ${indent_depth})
        string(APPEND output "${indent_key}")
    endforeach ()
    set(${out_str} "${output}" PARENT_SCOPE)
endfunction(_unigraph_append_indent)

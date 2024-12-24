# This dictionary implementation is realized through the use of a list type.
# It can store key/value pairs, where the keys are strings, and values may
# be either strings or lists.
# When storing a list, it must be "flat", meaning you cannot store nested
# dictionaries. This is due to the fact that since the dictionary itself
# is a list, it uses ';' to delimit each element. If you store a list as a
# value, retrieving values from the dictionary will not work.
# This also means that this dictionary implementation itself must account
# for this, so internally, lists are stored with a custom delimiter.
# You generally don't need to worry about this, as long as you stick
# to using the set and get functions. But be wary that the default
# internal delimiter for lists is '?'. This means that if you need to store
# values that include '?', then you must set the option UNIGRAPH_DICT_LIST_DELIMITER
# to a character you can guarantee will not be present in any of your
# values.

if (NOT DEFINED UNIGRAPH_DICT_LIST_DELIMITER)
    set(UNIGRAPH_DICT_LIST_DELIMITER "?")
else ()
    string(LENGTH "${UNIGRAPH_DICT_LIST_DELIMITER}" delimiter_length)
    if (NOT ${delimiter_length} EQUAL 1)
        message(FATAL_ERROR "UNIGRAPH_DICT_LIST_DELIMITER set to \"${UNIGRAPH_DICT_LIST_DELIMITER}\", but length but be 1")
    endif ()
    if ("${UNIGRAPH_DICT_LIST_DELIMITER}" STREQUAL ";")
        message(FATAL_ERROR "UNIGRAPH_DICT_LIST_DELIMITER set to \";\", but \";\" is not a valid delimiter")
    endif ()
endif ()

if (NOT DEFINED UNIGRAPH_DICT_ELEMENT_DELIMITER)
    set(UNIGRAPH_DICT_ELEMENT_DELIMITER "*")
else ()
    string(LENGTH "${UNIGRAPH_DICT_ELEMENT_DELIMITER}" delimiter_length)
    if (NOT ${delimiter_length} EQUAL 1)
        message(FATAL_ERROR "UNIGRAPH_DICT_ELEMENT_DELIMITER set to \"${UNIGRAPH_DICT_ELEMENT_DELIMITER}\", but length but be 1")
    endif ()
    if ("${UNIGRAPH_DICT_ELEMENT_DELIMITER}" STREQUAL ";")
        message(FATAL_ERROR "UNIGRAPH_DICT_ELEMENT_DELIMITER set to \";\", but \";\" is not a valid delimiter")
    endif ()
endif ()

if (NOT DEFINED UNIGRAPH_DICT_KEY_PREFIX)
    set(UNIGRAPH_DICT_KEY_PREFIX "UNIGRAPH_DICT_KEY_")
endif ()

function(_unigraph_set_value_to_dict type dict key value)
    set(valid_types "STRING" "LIST")
    if (NOT "${type}" IN_LIST valid_types)
        message(FATAL_ERROR "Expected type to be \"STRING\" or \"LIST\", but got \"${type}\"")
    endif ()

    if (NOT DEFINED value OR value STREQUAL "")
        set(value "\"\"")
    endif ()

    if (type STREQUAL "LIST")
        string(REPLACE ";" "${UNIGRAPH_DICT_LIST_DELIMITER}" value "${value}")
    endif ()

    string(PREPEND key "${UNIGRAPH_DICT_KEY_PREFIX}")

    list(FIND ${dict} ${key} index)
    if (index GREATER_EQUAL 0)
        math(EXPR value_index "${index} + 1")
        list(REMOVE_AT ${dict} ${value_index})
        list(INSERT ${dict} ${value_index} "${value}")
    else ()
        list(APPEND ${dict} ${key} ${value})
    endif ()

    set(${dict} ${${dict}} PARENT_SCOPE)
endfunction(_unigraph_set_value_to_dict)

function(_unigraph_get_value_from_dict type dict key out_var)
    set(valid_types "STRING" "LIST")
    if (NOT "${type}" IN_LIST valid_types)
        message(FATAL_ERROR "Expected type to be \"STRING\" or \"LIST\", but got \"${type}\"")
    endif ()

    string(PREPEND key "${UNIGRAPH_DICT_KEY_PREFIX}")

    list(FIND ${dict} ${key} index)
    if (index LESS_EQUAL -1)
        message(FATAL_ERROR "Key '${key}' not found in dictionary.")
    endif ()

    math(EXPR value_index "${index} + 1")
    list(GET ${dict} ${value_index} value)

    if (type STREQUAL "LIST")
        string(REPLACE "${UNIGRAPH_DICT_LIST_DELIMITER}" ";" value "${value}")
    endif ()

    set(${out_var} "${value}" PARENT_SCOPE)
endfunction(_unigraph_get_value_from_dict)

function(_unigraph_dict_to_list_compatible dict)
    string(REPLACE ";" "${UNIGRAPH_DICT_ELEMENT_DELIMITER}" ${dict} "${${dict}}")
    set(${dict} "${${dict}}" PARENT_SCOPE)
endfunction()

function(_unigraph_dict_from_list_compatible dict)
    string(REPLACE "${UNIGRAPH_DICT_ELEMENT_DELIMITER}" ";" ${dict} "${${dict}}")
    set(${dict} "${${dict}}" PARENT_SCOPE)
endfunction()
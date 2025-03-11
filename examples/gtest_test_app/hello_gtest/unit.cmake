unigraph_unit(
    HEADERS hello_gtest.hpp
    SOURCES hello_gtest.cpp
    TEST_SOURCES hello_gtest_test.cpp
    DEFINITIONS
      UNIT_SPECIFIC_DEFINITION="foo"
)
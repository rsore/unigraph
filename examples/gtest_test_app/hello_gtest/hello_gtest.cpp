#include <hello_gtest.hpp>
#include <string>

#ifndef UNIT_SPECIFIC_DEFINITION
static_assert(false);
#endif

std::string
hello_gtest()
{
    return "Hello GTest";
}

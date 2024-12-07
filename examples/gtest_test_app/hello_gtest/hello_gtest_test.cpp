#include <gtest/gtest.h>
#include <hello_gtest.hpp>

TEST(HelloTest, BasicAssertions)
{
    EXPECT_STREQ(hello_gtest().c_str(), "Hello GTest");
}

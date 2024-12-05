#include <catch2/catch_approx.hpp>
#include <catch2/catch_test_macros.hpp>
#include <cmath>
#include <statistics.hpp>

using namespace Statistics;

using Catch::Approx;

TEST_CASE("Mean is computed correctly", "[mean]")
{
    std::vector<float> data = {1.0f, 2.0f, 3.0f, 4.0f, 5.0f};
    REQUIRE(mean(data).has_value());
    REQUIRE(mean(data).value() == Approx(3.0f));
}

TEST_CASE("Variance is computed correctly", "[variance]")
{
    std::vector<float> data = {1.0f, 2.0f, 3.0f, 4.0f, 5.0f};
    REQUIRE(variance(data).has_value());
    REQUIRE(variance(data).value() == Approx(2.0f));
}

TEST_CASE("Standard deviation is computed correctly", "[standard_deviation]")
{
    std::vector<float> data = {1.0f, 2.0f, 3.0f, 4.0f, 5.0f};
    REQUIRE(standard_deviation(data).has_value());
    REQUIRE(standard_deviation(data).value() == Approx(std::sqrt(2.0f)));
}

TEST_CASE("Covariance is computed correctly", "[covariance]")
{
    std::vector<float> data1 = {1.0f, 2.0f, 3.0f};
    std::vector<float> data2 = {4.0f, 5.0f, 6.0f};
    REQUIRE(covariance(data1, data2).has_value());
    REQUIRE(covariance(data1, data2).value() == Approx(0.6666667f));
}

TEST_CASE("Empty data returns no result", "[statistics]")
{
    std::vector<float> empty;
    REQUIRE_FALSE(mean(empty).has_value());
    REQUIRE_FALSE(variance(empty).has_value());
    REQUIRE_FALSE(standard_deviation(empty).has_value());
}

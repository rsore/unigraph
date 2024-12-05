#include <catch2/catch_approx.hpp>
#include <catch2/catch_test_macros.hpp>
#include <circle.hpp>
#include <constants.hpp>

using namespace Geometry;

using Catch::Approx;

TEST_CASE("Circle area and circumference calculations")
{
    Circle circle(5.0f);

    REQUIRE(circle.area() == Approx(Constants::pi * 25.0f).epsilon(0.0001f));
    REQUIRE(circle.circumference() == Approx(2 * Constants::pi * 5.0f).epsilon(0.0001f));
}

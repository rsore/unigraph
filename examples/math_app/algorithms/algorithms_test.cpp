#include <algorithms.hpp>
#include <catch2/catch_approx.hpp>
#include <catch2/catch_test_macros.hpp>

using namespace Algorithms;
using namespace MathTypes;

using Catch::Approx;

TEST_CASE("Dot product of Vector2 is correct", "[dot_product]")
{
    Vector2 a(1.0f, 2.0f);
    Vector2 b(3.0f, 4.0f);
    REQUIRE(dot_product(a, b) == Approx(11.0f));
}

TEST_CASE("Cross product of Vector2 is correct", "[cross_product]")
{
    Vector2 a(1.0f, 2.0f);
    Vector2 b(3.0f, 4.0f);
    REQUIRE(cross_product(a, b) == Approx(-2.0f));
}

TEST_CASE("Dot product of Vector3 is correct", "[dot_product]")
{
    Vector3 a(1.0f, 2.0f, 3.0f);
    Vector3 b(4.0f, 5.0f, 6.0f);
    REQUIRE(dot_product(a, b) == Approx(32.0f));
}

TEST_CASE("Centroid of Vector2 points is computed correctly", "[centroid]")
{
    std::vector<Vector2> points = {{1.0f, 1.0f}, {2.0f, 3.0f}, {4.0f, 5.0f}};
    Vector2              result = centroid(points);
    REQUIRE(result.x == Approx(7.0f / 3.0f));
    REQUIRE(result.y == Approx(3.0f));
}

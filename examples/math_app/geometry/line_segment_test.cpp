#include <catch2/catch_approx.hpp>
#include <catch2/catch_test_macros.hpp>
#include <line_segment.hpp>

using namespace Geometry;
using namespace MathTypes;

using Catch::Approx;

TEST_CASE("Length of a line segment is correct", "[length]")
{
    LineSegment segment({0, 0}, {3, 4});
    REQUIRE(length(segment) == Approx(5.0f));
}

TEST_CASE("Intersection of line segments is detected correctly", "[intersect]")
{
    LineSegment a({0, 0}, {4, 4});
    LineSegment b({0, 4}, {4, 0});

    auto intersection = intersect(a, b);
    REQUIRE(intersection.has_value());
    REQUIRE(intersection->x == Approx(2.0f));
    REQUIRE(intersection->y == Approx(2.0f));
}

TEST_CASE("Parallel lines do not intersect", "[intersect]")
{
    LineSegment a({0, 0}, {4, 4});
    LineSegment b({0, 1}, {4, 5});

    auto intersection = intersect(a, b);
    REQUIRE_FALSE(intersection.has_value());
}

TEST_CASE("Collinear but disjoint lines do not intersect", "[intersect]")
{
    LineSegment a({0, 0}, {2, 2});
    LineSegment b({3, 3}, {5, 5});

    auto intersection = intersect(a, b);
    REQUIRE_FALSE(intersection.has_value());
}

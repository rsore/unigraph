#include <catch2/catch_approx.hpp>
#include <catch2/catch_test_macros.hpp>
#include <math_types.hpp>

#include <cmath>

using namespace MathTypes;

using Catch::Approx;

TEST_CASE("Vector2 length is computed correctly", "[Vector2]")
{
    Vector2 vec(3.0f, 4.0f);
    REQUIRE(vec.length() == Catch::Approx(5.0f));
}

TEST_CASE("Vector2 normalization works", "[Vector2]")
{
    Vector2 vec(3.0f, 4.0f);
    auto    normalized = vec.normalize();
    REQUIRE(normalized.length() == Approx(1.0f));
    REQUIRE(normalized.x == Approx(3.0f / 5.0f));
    REQUIRE(normalized.y == Approx(4.0f / 5.0f));
}

TEST_CASE("Vector3 length is computed correctly", "[Vector3]")
{
    Vector3 vec(1.0f, 2.0f, 2.0f);
    REQUIRE(vec.length() == Approx(3.0f));
}

TEST_CASE("Vector3 normalization works", "[Vector3]")
{
    Vector3 vec(1.0f, 2.0f, 2.0f);
    auto    normalized = vec.normalize();
    REQUIRE(normalized.length() == Approx(1.0f));
    REQUIRE(normalized.x == Approx(1.0f / 3.0f));
    REQUIRE(normalized.y == Approx(2.0f / 3.0f));
    REQUIRE(normalized.z == Approx(2.0f / 3.0f));
}

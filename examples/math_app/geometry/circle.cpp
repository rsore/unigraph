#include <circle.hpp>
#include <constants.hpp>

Geometry::Circle::Circle(float radius)
    : radius(radius)
{
}

float
Geometry::Circle::area() const
{
    return Constants::pi * radius * radius;
}

float
Geometry::Circle::circumference() const
{
    return 2 * Constants::pi * radius;
}

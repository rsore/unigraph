#include <math_types.hpp>

#include <cmath>

MathTypes::Vector2::Vector2(float x, float y)
    : x(x)
    , y(y)
{
}

float
MathTypes::Vector2::length() const
{
    return std::sqrt(x * x + y * y);
}

MathTypes::Vector2
MathTypes::Vector2::normalize() const
{
    float len = length();
    if (len == 0)
    {
        return {0, 0};
    }
    return {x / len, y / len};
}

std::ostream &
operator<<(std::ostream &os, const MathTypes::Vector2 &vec)
{
    os << "(" << vec.x << ", " << vec.y << ")";
    return os;
}

MathTypes::Vector3::Vector3(float x, float y, float z)
    : x(x)
    , y(y)
    , z(z)
{
}

float
MathTypes::Vector3::length() const
{
    return std::sqrt(x * x + y * y + z * z);
}

MathTypes::Vector3
MathTypes::Vector3::normalize() const
{
    float len = length();
    if (len == 0)
    {
        return {0, 0, 0};
    }
    return {x / len, y / len, z / len};
}

std::ostream &
operator<<(std::ostream &os, const MathTypes::Vector3 &vec)
{
    os << "(" << vec.x << ", " << vec.y << ", " << vec.z << ")";
    return os;
}

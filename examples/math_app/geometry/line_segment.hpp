#ifndef MATHAPP_GEOMETRY_HPP
#define MATHAPP_GEOMETRY_HPP

#include <math_types.hpp>
#include <optional>
#include <vector>

namespace Geometry
{
    struct LineSegment
    {
        MathTypes::Vector2 start;
        MathTypes::Vector2 end;

        LineSegment(const MathTypes::Vector2 &start, const MathTypes::Vector2 &end);
    };

    float length(const LineSegment &segment);

    std::optional<MathTypes::Vector2> intersect(const LineSegment &a, const LineSegment &b);
} // namespace Geometry

#endif // MATHAPP_GEOMETRY_HPP

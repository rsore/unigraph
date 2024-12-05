#include <algorithms.hpp>
#include <line_segment.hpp>

#include <cmath>

Geometry::LineSegment::LineSegment(const MathTypes::Vector2 &start, const MathTypes::Vector2 &end)
    : start(start)
    , end(end)
{
}

float
Geometry::length(const Geometry::LineSegment &segment)
{
    float dx = segment.end.x - segment.start.x;
    float dy = segment.end.y - segment.start.y;
    return std::sqrt(dx * dx + dy * dy);
}

std::optional<MathTypes::Vector2>
Geometry::intersect(const Geometry::LineSegment &a, const Geometry::LineSegment &b)
{
    MathTypes::Vector2 r = {a.end.x - a.start.x, a.end.y - a.start.y};
    MathTypes::Vector2 s = {b.end.x - b.start.x, b.end.y - b.start.y};

    float cross_rs = Algorithms::cross_product(r, s);
    if (cross_rs == 0.0f)
    {
        return std::nullopt;
    }

    MathTypes::Vector2 qp = {b.start.x - a.start.x, b.start.y - a.start.y};
    float              t  = Algorithms::cross_product(qp, s) / cross_rs;
    float              u  = Algorithms::cross_product(qp, r) / cross_rs;

    if (t >= 0.0f && t <= 1.0f && u >= 0.0f && u <= 1.0f)
    {
        return MathTypes::Vector2{a.start.x + t * r.x, a.start.y + t * r.y};
    }

    return std::nullopt;
}

#include <algorithms.hpp>

float
Algorithms::dot_product(const MathTypes::Vector2 &a, const MathTypes::Vector2 &b)
{
    return a.x * b.x + a.y * b.y;
}

float
Algorithms::cross_product(const MathTypes::Vector2 &a, const MathTypes::Vector2 &b)
{
    return a.x * b.y - a.y * b.x;
}

float
Algorithms::dot_product(const MathTypes::Vector3 &a, const MathTypes::Vector3 &b)
{
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

MathTypes::Vector2
Algorithms::centroid(const std::vector<MathTypes::Vector2> &points)
{
    if (points.empty())
        return {0, 0};

    float x_sum = 0.0f;
    float y_sum = 0.0f;

    for (const auto &point : points)
    {
        x_sum += point.x;
        y_sum += point.y;
    }

    return {x_sum / static_cast<float>(points.size()), y_sum / static_cast<float>(points.size())};
}

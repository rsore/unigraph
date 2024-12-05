#ifndef MATHAPP_ALGORITHMS_HPP
#define MATHAPP_ALGORITHMS_HPP

#include <math_types.hpp>

#include <vector>

namespace Algorithms
{
    float              dot_product(const MathTypes::Vector2 &a, const MathTypes::Vector2 &b);
    float              cross_product(const MathTypes::Vector2 &a, const MathTypes::Vector2 &b);
    float              dot_product(const MathTypes::Vector3 &a, const MathTypes::Vector3 &b);
    MathTypes::Vector2 centroid(const std::vector<MathTypes::Vector2> &points);
} // namespace Algorithms

#endif // MATHAPP_ALGORITHMS_HPP

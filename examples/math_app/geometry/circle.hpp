#ifndef MATHAPP_CIRCLE_HPP
#define MATHAPP_CIRCLE_HPP

namespace Geometry
{
    struct Circle
    {
        explicit Circle(float radius);

        [[nodiscard]] float area() const;
        [[nodiscard]] float circumference() const;

        float radius;
    };
} // namespace Geometry

#endif // MATHAPP_CIRCLE_HPP

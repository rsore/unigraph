#ifndef MATHAPP_MATH_TYPES_HPP
#define MATHAPP_MATH_TYPES_HPP

#include <ostream>

namespace MathTypes
{
    struct Vector2
    {
        float x{};
        float y{};

        Vector2() = default;
        Vector2(float x, float y);

        [[nodiscard]] float   length() const;
        [[nodiscard]] Vector2 normalize() const;

        friend std::ostream &operator<<(std::ostream &os, const Vector2 &vec);
    };

    struct Vector3
    {
        float x{};
        float y{};
        float z{};

        Vector3() = default;
        Vector3(float x, float y, float z);

        [[nodiscard]] float   length() const;
        [[nodiscard]] Vector3 normalize() const;

        friend std::ostream &operator<<(std::ostream &os, const Vector3 &vec);
    };
} // namespace MathTypes


#endif // MATHAPP_MATH_TYPES_HPP

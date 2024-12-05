#include <algorithms.hpp>
#include <circle.hpp>
#include <iostream>
#include <math_types.hpp>
#include <statistics.hpp>

int
main()
{
    // Demonstrate usage of MathTypes
    MathTypes::Vector2 v1(1.0f, 2.0f);
    MathTypes::Vector2 v2(3.0f, 4.0f);

    std::cout << "Vector1: (" << v1.x << ", " << v1.y << ")\n";
    std::cout << "Vector2: (" << v2.x << ", " << v2.y << ")\n";

    // Demonstrate usage of MathAlgorithms
    auto dot_product = Algorithms::dot_product(v1, v2);
    std::cout << "Dot product: " << dot_product << "\n";

    // Demonstrate usage of Geometry (Area of circle)
    Geometry::Circle circle(5.0f);
    std::cout << "Area of Circle with radius 5: " << circle.area() << "\n";

    // Demonstrate usage of Statistics (Mean, Covariance)
    std::vector<float> data1 = {1.0f, 2.0f, 3.0f};
    std::vector<float> data2 = {4.0f, 5.0f, 6.0f};

    auto mean_data1 = Statistics::mean(data1);
    auto mean_data2 = Statistics::mean(data2);

    if (mean_data1 && mean_data2)
    {
        std::cout << "Mean of Data1: " << mean_data1.value() << "\n";
        std::cout << "Mean of Data2: " << mean_data2.value() << "\n";
    }

    auto covariance_result = Statistics::covariance(data1, data2);
    if (covariance_result.has_value())
    {
        std::cout << "Covariance: " << covariance_result.value() << "\n";
    }

    return 0;
}

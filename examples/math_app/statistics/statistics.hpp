#ifndef MATHAPP_STATISTICS_HPP
#define MATHAPP_STATISTICS_HPP

#include <optional>
#include <vector>

namespace Statistics
{
    std::optional<float> mean(const std::vector<float> &data);
    std::optional<float> variance(const std::vector<float> &data);
    std::optional<float> standard_deviation(const std::vector<float> &data);
    std::optional<float> covariance(const std::vector<float> &data1, const std::vector<float> &data2);

} // namespace Statistics

#endif // MATHAPP_STATISTICS_HPP

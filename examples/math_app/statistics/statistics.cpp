#include <cmath>
#include <numeric>
#include <statistics.hpp>

std::optional<float>
Statistics::mean(const std::vector<float> &data)
{
    if (data.empty())
    {
        return std::nullopt;
    }
    float sum = std::accumulate(data.begin(), data.end(), 0.0f);
    return sum / static_cast<float>(data.size());
}

std::optional<float>
Statistics::variance(const std::vector<float> &data)
{
    auto avg = mean(data);
    if (!avg.has_value())
    {
        return std::nullopt;
    }
    float mean_value        = avg.value();
    float sum_squared_diffs = std::accumulate(data.begin(),
                                              data.end(),
                                              0.0f,
                                              [mean_value](float acc, float value)
                                              {
                                                  float diff = value - mean_value;
                                                  return acc + diff * diff;
                                              });
    return sum_squared_diffs / static_cast<float>(data.size());
}

std::optional<float>
Statistics::standard_deviation(const std::vector<float> &data)
{
    auto var = variance(data);
    if (!var.has_value())
    {
        return std::nullopt;
    }
    return std::sqrt(var.value());
}

std::optional<float>
Statistics::covariance(const std::vector<float> &data1, const std::vector<float> &data2)
{
    if (data1.size() != data2.size() || data1.empty())
    {
        return std::nullopt;
    }

    auto mean1 = mean(data1);
    auto mean2 = mean(data2);
    if (!mean1.has_value() || !mean2.has_value())
    {
        return std::nullopt;
    }

    float mean_value1 = mean1.value();
    float mean_value2 = mean2.value();

    float sum = 0.0f;
    for (size_t i = 0; i < data1.size(); ++i)
    {
        sum += (data1[i] - mean_value1) * (data2[i] - mean_value2);
    }
    return sum / static_cast<float>(data1.size());
}

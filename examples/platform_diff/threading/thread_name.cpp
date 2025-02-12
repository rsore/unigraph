#include <thread_name.hpp>

#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <random>
#include <sstream>
#include <string>

extern void platform_initialize_thread_naming();
extern void platform_set_current_thread_name(const std::string&);
extern std::string platform_get_current_thread_name();

static std::string
generate_random_suffix()
{
    static thread_local std::mt19937 gen(std::random_device{}());
    static std::uniform_int_distribution<> dis(0, 9999);

    std::ostringstream oss;
    oss << '_' << std::setw(4) << std::setfill('0') << dis(gen);
    return oss.str();
}

void
initialize_thread_naming()
{
    platform_initialize_thread_naming();
}

void
set_current_thread_name(const std::string_view name)
{
    constexpr std::size_t max_thread_name_length = 10;

    std::string final_thread_name = std::string(name);
    if (name.length() > max_thread_name_length)
    {
        final_thread_name = final_thread_name.substr(0, max_thread_name_length);
        std::cerr << "Thread name \"" << name << "\" is too long, truncating to \"" << final_thread_name << "\"" << std::endl;
    }

    final_thread_name += generate_random_suffix();
    platform_set_current_thread_name(final_thread_name);
}

std::string
get_current_thread_name()
{
    return platform_get_current_thread_name();
}

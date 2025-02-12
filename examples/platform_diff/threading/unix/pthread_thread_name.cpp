#include <thread_name.hpp>

#include <iostream>
#include <string>

#include <pthread.h>

static constexpr std::string_view undefined_thread_name = "_undefined_";

void
platform_initialize_thread_naming()
{
    // noop
}

void
platform_set_current_thread_name(const std::string& name)
{
    if (name.length() >= 16)
    {
        return;
    }

    pthread_t thread = pthread_self();

    const int result = pthread_setname_np(thread, name.c_str());
    if (result != 0)
    {
        std::cerr << "Failed to set thread name to \"" << name << "\", pthread_setname_np return non-zero result" << std::endl;
    }
}

std::string
platform_get_current_thread_name()
{
    pthread_t thread = pthread_self();
    char thread_name[16] = {};
    const int result = pthread_getname_np(thread, thread_name, sizeof(thread_name));
    if (result != 0)
    {
        std::cerr << "Failed to get thread name, pthread_getname_np returned non-zero result" << std::endl;
        return std::string(undefined_thread_name);
    }

    return std::string(thread_name);
}

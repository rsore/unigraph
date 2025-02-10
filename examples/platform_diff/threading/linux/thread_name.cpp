#include <thread_name.hpp>

#include <string>

#include <pthread.h>

void set_thread_name(std::string name)
{
    pthread_t thread = pthread_self();
    pthread_setname_np(thread, name.c_str());
}

std::string get_thread_name()
{
    char name[256];
    pthread_t thread = pthread_self();
    pthread_getname_np(thread, name, sizeof(name));
    return std::string(name);
}

#include <thread>
#include <thread_name.hpp>

#include <iostream>

int
main()
{
    set_thread_name("main_thread");

    std::cout << "Thread name: " << get_thread_name() << std::endl;

    std::thread t([]
    {
        set_thread_name("other_thread");
        std::cout << "Thread name: " << get_thread_name() << std::endl;
    });
    t.join();

    std::cout << "Thread name: " << get_thread_name() << std::endl;

    return 0;
}

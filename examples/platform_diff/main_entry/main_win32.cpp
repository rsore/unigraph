#include <thread.hpp>
#include <thread_name.hpp>

#include <iostream>

#include <windows.h>

int APIENTRY WinMain(HINSTANCE hInst, HINSTANCE hInstPrev, PSTR cmdline, int cmdshow)
{
    initialize_thread_naming();

    set_current_thread_name("main");

    std::cout << "Thread name: " << get_current_thread_name() << std::endl;


    Thread t("worker", []
    {
        std::cout << "Thread name: " << get_current_thread_name() << std::endl;
    });
    t.join();

    std::cout << "Thread name: " << get_current_thread_name() << std::endl;

    return 0;
}

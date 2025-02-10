#include <thread_name.hpp>

#include <codecvt>
#include <windows.h>

void set_thread_name(std::string new_name)
{
    std::wstring name(new_name.begin(), new_name.end());
    HANDLE current_thread = GetCurrentThread();
    HRESULT hr = SetThreadDescription(current_thread, name.c_str());
}

std::string get_thread_name()
{
    HANDLE current_thread = GetCurrentThread();
    PWSTR thread_name = nullptr;
    HRESULT hr = GetThreadDescription(current_thread, &thread_name);

    std::wstring name(thread_name);
    LocalFree(thread_name);

    std::wstring_convert<std::codecvt_utf8<wchar_t>> converter;
    std::string result = converter.to_bytes(name);

    return result;
}

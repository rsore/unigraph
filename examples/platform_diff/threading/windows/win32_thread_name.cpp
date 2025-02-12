#include <thread_name.hpp>

#include <iostream>
#include <string>
#include <vector>

#include <Windows.h>

typedef HRESULT(WINAPI *SetThreadDescriptionFunc)(HANDLE, PCWSTR);
typedef HRESULT(WINAPI *GetThreadDescriptionFunc)(HANDLE, PWSTR*);

static SetThreadDescriptionFunc win32_set_thread_description = nullptr;
static GetThreadDescriptionFunc win32_get_thread_description = nullptr;

static constexpr std::string_view undefined_thread_name = "_undefined_";

void
platform_initialize_thread_naming()
{
    HMODULE kernel_base_handle = LoadLibrary("KernelBase.dll");
    if (kernel_base_handle == nullptr)
    {
        std::cerr << "Failed to load KernelBase.dll, thread naming will be unavailable" << std::endl;
        return;
    }

    win32_set_thread_description = (SetThreadDescriptionFunc)GetProcAddress(kernel_base_handle, "SetThreadDescription");
    if (win32_set_thread_description == nullptr)
    {
        std::cerr << "Failed to retrieve proc address of SetThreadDescription, thread naming will be unavailable" << std::endl;
    }

    win32_get_thread_description = (GetThreadDescriptionFunc)GetProcAddress(kernel_base_handle, "GetThreadDescription");
    if (win32_get_thread_description == nullptr)
    {
        std::cerr << "Failed to retrieve proc address of GetThreadDescription, thread naming will be unavailable" << std::endl;
    }

    FreeLibrary(kernel_base_handle);
}

void
platform_set_current_thread_name(const std::string& name)
{
    if (win32_set_thread_description == nullptr)
    {
        return;
    }

    HANDLE current_thread = GetCurrentThread();

    const int size_needed = MultiByteToWideChar(CP_UTF8, 0, name.c_str(), static_cast<int>(name.length()), nullptr, 0);
    if (size_needed <= 0)
    {
        std::cerr << "Failed to set thread name to \"" << name << "\", MultiByteToWideChar returned " << size_needed << std::endl;
        return;
    }

    std::vector<wchar_t> wname(size_needed + 1, L'\0');
    MultiByteToWideChar(CP_UTF8, 0, name.c_str(), static_cast<int>(name.length()), wname.data(), size_needed);

    const HRESULT hr = win32_set_thread_description(current_thread, wname.data());
    if (!SUCCEEDED(hr))
    {
        std::cerr << "Failed to set thread name to \"" << name << "\", win32_set_thread_description (SetThreadDescription) returned an invalid result" << std::endl;
    }
}

std::string
platform_get_current_thread_name()
{
    if (win32_get_thread_description == nullptr)
    {
        return std::string(undefined_thread_name);
    }

    HANDLE current_thread = GetCurrentThread();
    PWSTR thread_name = nullptr;

    const HRESULT hr = win32_get_thread_description(current_thread, &thread_name);
    if (!SUCCEEDED(hr))
    {
        std::cerr << "Failed to get current thread name, win32_get_thread_description (GetThreadDescription) returned an invalid result" << std::endl;
        return std::string(undefined_thread_name);
    }
    if (thread_name == nullptr)
    {
        // This should be unreachable, if win32_get_thread_description succeeded, then thread_name should never be nullptr.
        // But let's be extra safe and check anyway
        std::cerr << "Failed to get current thread name, thread_name is still nullptr for some reason" << std::endl;
        return std::string(undefined_thread_name);
    }

    const int size_needed = WideCharToMultiByte(CP_UTF8, 0, thread_name, -1, nullptr, 0, nullptr, nullptr);
    if (size_needed <= 0)
    {
        std::cerr << "Failed to get current thread name, MultiByteToWideChar returned " << size_needed << std::endl;
        return std::string(undefined_thread_name);
    }

    std::string result(size_needed - 1, '\0');
    WideCharToMultiByte(CP_UTF8, 0, thread_name, -1, result.data(), size_needed, nullptr, nullptr);

    LocalFree(thread_name);
    return result;
}

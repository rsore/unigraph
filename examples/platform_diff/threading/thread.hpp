#pragma once

#include <thread_name.hpp>

#include <cstdint>
#include <functional>
#include <string_view>
#include <thread>

class Thread
{
public:
    Thread() noexcept = default;

    template <typename Invocable, typename... Args>
    Thread(const std::string_view name, Invocable&& func, Args&&... args) requires std::is_invocable_v<Invocable, Args...>;

    Thread(Thread&& other) noexcept;
    Thread& operator=(Thread&& other) noexcept;

    Thread(const Thread&) = delete;
    Thread& operator=(const Thread&) = delete;

    [[nodiscard]] bool joinable() const noexcept;
    [[nodiscard]] std::thread::id get_id() const noexcept;
    [[nodiscard]] std::thread::native_handle_type native_handle();
    [[nodiscard]] static std::uint32_t hardware_concurrency() noexcept;

    void join();
    void detach();
    void swap(Thread& other) noexcept;

protected:
    std::thread underlying_thread_;
};

template <typename Invocable, typename... Args>
Thread::Thread(const std::string_view name, Invocable&& func, Args&&... args) requires std::is_invocable_v<Invocable, Args...>
    : underlying_thread_([name, func = std::forward<Invocable>(func), ...args = std::forward<Args>(args)]
        {
            set_current_thread_name(name);
            std::invoke(func, args...);
        })
{
}

Thread::Thread(Thread &&other) noexcept
    : underlying_thread_(std::move(other.underlying_thread_))
{
}

Thread&
Thread::operator=(Thread&& other) noexcept
{
    if (this != &other)
    {
        underlying_thread_ = std::move(other.underlying_thread_);
    }
    return *this;
}

bool
Thread::joinable() const noexcept
{
    return underlying_thread_.joinable();
}

std::thread::id
Thread::get_id() const noexcept
{
    return underlying_thread_.get_id();
}

std::thread::native_handle_type
Thread::native_handle()
{
    return underlying_thread_.native_handle();
}

std::uint32_t
Thread::hardware_concurrency() noexcept
{
    return std::thread::hardware_concurrency();
}

void
Thread::join()
{
    underlying_thread_.join();
}

void
Thread::detach()
{
    underlying_thread_.detach();
}

void
Thread::swap(Thread& other) noexcept
{
    underlying_thread_.swap(other.underlying_thread_);
}

#pragma once

#include <thread.hpp>

class ScopedThread
    : public Thread
{
public:
    using Thread::Thread;

    ~ScopedThread();
};

ScopedThread::~ScopedThread()
{
    if (underlying_thread_.joinable())
    {
        underlying_thread_.join();
    }
}

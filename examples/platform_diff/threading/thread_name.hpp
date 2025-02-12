#pragma once

#include <string>
#include <string_view>

void initialize_thread_naming();
void set_current_thread_name(std::string_view);
[[nodiscard]] std::string get_current_thread_name();

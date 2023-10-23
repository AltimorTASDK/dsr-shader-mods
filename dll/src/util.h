#pragma once

#include <cstddef>
#include <tuple>

std::tuple<std::byte*, std::byte*> get_module_bounds(const char *name);
std::byte *sigscan(const char *name, const char *sig, const char *mask);
void apply_jmp_hook(void *target, const void *hook);
void apply_call_hook(void *target, const void *hook, size_t pad_size);

inline std::byte *sigscan(const char *sig, const char *mask)
{
	return sigscan(nullptr, sig, mask);
}

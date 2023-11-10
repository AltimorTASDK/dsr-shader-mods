#pragma once

#include "util/logger.h"
#include <cstddef>
#include <source_location>
#include <tuple>

std::tuple<std::byte*, std::byte*> get_module_bounds(const char *name);

std::byte *sigscan_impl(const char *name, const char *sig, const char *mask);

void apply_jmp_hook(void *target, const void *hook);

void apply_call_hook(void *target, const void *hook, size_t pad_size);

void patch_code(void *target, const void *patch, size_t size);

template<size_t N>
void patch_code(void *target, const char (&patch)[N])
{
	patch_code(target, patch, N - 1);
}

inline std::byte *sigscan(
	const char *name, const char *sig, const char *mask,
	const std::source_location &location = std::source_location::current())
{
	auto *result = sigscan_impl(name, sig, mask);
	logger.println(
		"{}:{}: Sigscan result: {:016X}",
		base_file_name(location), location.line(), (uintptr_t)result);
	return result;
}

inline std::byte *sigscan(
	const char *sig, const char *mask,
	const std::source_location &location = std::source_location::current())
{
	return sigscan(nullptr, sig, mask, location);
}

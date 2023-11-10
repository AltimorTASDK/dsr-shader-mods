#include <cstddef>
#include <stdexcept>
#include <tuple>
#include <Windows.h>
#include <Psapi.h>

std::tuple<std::byte*, std::byte*> get_module_bounds(const char *name)
{
	const auto handle = GetModuleHandle(name);
	if (handle == nullptr)
		return {nullptr, nullptr};

	MODULEINFO info;
	GetModuleInformation(GetCurrentProcess(), handle, &info, sizeof(info));
	auto *start = (std::byte*)info.lpBaseOfDll;
	auto *end = start + info.SizeOfImage;
	return {start, end};
}

std::byte *sigscan_impl(const char *name, const char *sig, const char *mask)
{
	auto [start, end] = get_module_bounds(name);
	auto *last_scan = end - strlen(mask) + 1;

	for (auto *addr = start; addr < last_scan; addr++) {
		for (size_t i = 0; ; i++) {
			if (mask[i] == '\0')
				return addr;
			if (mask[i] != '?' && sig[i] != (char)addr[i])
				break;
		}
	}

	return nullptr;
}

void apply_jmp_hook(void *target, const void *hook)
{
	constexpr size_t patch_size = 12;

	DWORD old_protect;
	VirtualProtect(target, patch_size, PAGE_EXECUTE_READWRITE, &old_protect);

	// mov rax, hook
	*(uint16_t*)target = 0xB848;
	*(const void**)((std::byte*)target + 2) = hook;
	// call rax
	*(uint16_t*)((std::byte*)target + 10) = 0xE0FF;

	VirtualProtect(target, patch_size, old_protect, &old_protect);
}

void apply_call_hook(void *target, const void *hook, size_t pad_size)
{
	constexpr size_t patch_size = 12;
	const auto total_size = max(patch_size, pad_size);

	DWORD old_protect;
	VirtualProtect(target, total_size, PAGE_EXECUTE_READWRITE, &old_protect);

	// mov rax, hook
	*(uint16_t*)target = 0xB848;
	*(const void**)((std::byte*)target + 2) = hook;
	// call rax
	*(uint16_t*)((std::byte*)target + 10) = 0xD0FF;
	// nop
	memset((std::byte*)target + patch_size, 0x90, total_size - patch_size);

	VirtualProtect(target, total_size, old_protect, &old_protect);
}

void patch_code(void *target, const void *patch, size_t size)
{
	DWORD old_protect;
	VirtualProtect(target, size, PAGE_EXECUTE_READWRITE, &old_protect);
	memcpy(target, patch, size);
	VirtualProtect(target, size, old_protect, &old_protect);
}
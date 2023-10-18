#include <cstddef>
#include <stdexcept>
#include <tuple>

#include <Windows.h>
#include <Psapi.h>

float *hook_WhackAssLightScaling(float *out, short *in, float alpha)
{
	// The original treats input alpha as a percentage over 100 and
	// converts from srgb space despite light colors being linear
	float multiplier = (float)in[3] / 255.0f;
	out[0] = (float)in[0] / 255.0f * multiplier;
	out[1] = (float)in[1] / 255.0f * multiplier;
	out[2] = (float)in[2] / 255.0f * multiplier;
	out[3] = alpha;
	return out;
}

static std::tuple<std::byte*, std::byte*> get_module_bounds(const char *name)
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

static std::byte *sigscan(const char *name, const char *sig, const char *mask)
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

	throw std::runtime_error("Signature not found");
}

static void apply_jmp_hook(void *target, const void *hook)
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

static void apply_call_hook(void *target, const void *hook, size_t pad_size)
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

extern "C" void hook_copy_shader_params1();
extern "C" void hook_copy_shader_params2();
extern "C" void hook_copy_shader_params3();

static DWORD apply_hooks(void *param)
{
	// Wait to unpack
	Sleep(1000);

	auto *target1 = sigscan(
		"DarkSoulsRemastered.exe",
		// movaps xmm0, [rbp-0x60]
		// lea rdx, [rbp]
		// movaps [rdi+0x12A0], xmm0
		"\x0F\x28\x45\xA0\x48\x8D\x55\x00\x0F\x29\x87\xA0\x12\x00\x00",
		"xxxxxxxxxxxxxxx");

	apply_call_hook(target1, hook_copy_shader_params1, 15);

	auto *target2 = sigscan(
		"DarkSoulsRemastered.exe",
		// movaps xmm6, [rbp-0x10]
		// mov rcx, rbx
		// movaps [rdi+0x12A0], xmm0
		"\x0F\x28\x75\xF0\x48\x8B\xCB\x0F\x29\x87\xA0\x12\x00\x00",
		"xxxxxxxxxxxxxx");

	apply_call_hook(target2, hook_copy_shader_params2, 14);

	auto *target3 = sigscan(
		"DarkSoulsRemastered.exe",
		// movaps xmm6, [rbp-0x10]
		// mov r8d, r15d
		// movaps [rdi+0x12A0], xmm0
		"\x0F\x28\x75\xF0\x45\x8B\xC7\x0F\x29\x87\xA0\x12\x00\x00",
		"xxxxxxxxxxxxxx");

	apply_call_hook(target3, hook_copy_shader_params3, 14);

	auto* target_light_scaling = sigscan(
		"DarkSoulsRemastered.exe",
		// mov [rsp+8], rbx
		// push rdi
		// sub rsp, 0x40
		// movsx eax, word ptr [rdx+6]
		"\x48\x89\x5C\x24\x08\x57\x48\x83\xEC\x40\x0F\xBF\x42\x06",
		"xxxxxxxxxxxxxx");

	apply_jmp_hook(target_light_scaling, hook_WhackAssLightScaling);

	return 0;
}

BOOL WINAPI DllMain(HINSTANCE instance, DWORD reason, void *reserved)
{
	if (reason != DLL_PROCESS_ATTACH)
		return FALSE;

	CreateThread(nullptr, 0, apply_hooks, nullptr, 0, nullptr);

	return TRUE;
}

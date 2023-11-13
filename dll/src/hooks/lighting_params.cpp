#include "util/memory.h"

// lerp factor between lightmap mask and 1.0
extern "C" float point_light_attenuation[] = {
	0.6f, // LocalPlayerLantern
	1.0f, // Sfx
	1.0f, // DynamicMap
	0.0f, // FixedMap
};

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

extern "C" void hook_copy_shader_params1();
extern "C" void hook_copy_shader_params2();
extern "C" void hook_copy_shader_params3();
extern "C" void hook_point_light_attenuation();

void apply_hooks_lighting_params()
{
	auto *target1 = sigscan(
		// movaps xmm0, [rbp-0x60]
		// lea rdx, [rbp]
		// movaps [rdi+0x12A0], xmm0
		"\x0F\x28\x45\xA0\x48\x8D\x55\x00\x0F\x29\x87\xA0\x12\x00\x00",
		"xxxxxxxxxxxxxxx");

	apply_call_hook(target1, hook_copy_shader_params1, 15);

	auto *target2 = sigscan(
		// movaps xmm6, [rbp-0x10]
		// mov rcx, rbx
		// movaps [rdi+0x12A0], xmm0
		"\x0F\x28\x75\xF0\x48\x8B\xCB\x0F\x29\x87\xA0\x12\x00\x00",
		"xxxxxxxxxxxxxx");

	apply_call_hook(target2, hook_copy_shader_params2, 14);

	auto *target3 = sigscan(
		// movaps xmm6, [rbp-0x10]
		// mov r8d, r15d
		// movaps [rdi+0x12A0], xmm0
		"\x0F\x28\x75\xF0\x45\x8B\xC7\x0F\x29\x87\xA0\x12\x00\x00",
		"xxxxxxxxxxxxxx");

	apply_call_hook(target3, hook_copy_shader_params3, 14);

	auto *target_light_scaling = sigscan(
		// mov [rsp+8], rbx
		// push rdi
		// sub rsp, 0x40
		// movsx eax, word ptr [rdx+6]
		"\x48\x89\x5C\x24\x08\x57\x48\x83\xEC\x40\x0F\xBF\x42\x06",
		"xxxxxxxxxxxxxx");

	apply_jmp_hook(target_light_scaling, hook_WhackAssLightScaling);

	auto *target_point_light_attenuation = sigscan(
		// call [rax+0x60]
		// movzx eax, byte ptr [rdi+0x18]
		"\xFF\x50\x60\x0F\xB6\x47\x18",
		"xxxxxxx") + 3;

	apply_call_hook(target_point_light_attenuation, hook_point_light_attenuation, 27);
}
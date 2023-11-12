#include "Dantelion2/DLResourceManager.h"
#include "Dantelion2/DLSamplerState11.h"
#include "util/memory.h"

// Non-comparison sampler for sampling depth values
DLGR::DLSamplerState11 *shadow_map_sampler;

extern "C" void create_shadow_map_sampler(DLGR::DLResourceManager *resource_manager)
{
	auto *device = resource_manager->device;
	auto *allocator = resource_manager->allocator;
	shadow_map_sampler = allocator->New<DLGR::DLSamplerState11>(device, allocator);
	shadow_map_sampler->Ref();
	shadow_map_sampler->CreateSamplerState({
		.type = DLGR::DLSamplerType::min_mag_mip_linear,
		.address_u = DLGR::DLTextureAddressMode::border,
		.address_v = DLGR::DLTextureAddressMode::border,
		.address_w = DLGR::DLTextureAddressMode::border
	});
}

extern "C" void hook_AddShadowMapSampler();

void apply_hooks_shadows()
{
	auto *target_vertex_lisp_asm_model = sigscan(
		// jz +0xB1
		// movaps xmm0, [rsi+0x60]
		"\x0F\x84\xAB\x00\x00\x00\x0F\x28\x46\x60",
		"xxxxxxxxxx");

	// Skip attempt to apply LiSP matrix in vertex shader
	// jmp +0xB1
	patch_code(target_vertex_lisp_asm_model, "\xE9\xAC\x00\x00\x00\x90");

	auto *target_vertex_lisp_model = sigscan(
		// jz +0xB1
		// movaps xmm0, [r13+0x60]
		"\x0F\x84\xAB\x00\x00\x00\x41\x0F\x28\x45\x60",
		"xxxxxxxxxxx");

	// Skip attempt to apply LiSP matrix in vertex shader
	// jmp +0xB1
	patch_code(target_vertex_lisp_model, "\xE9\xAC\x00\x00\x00\x90");

	auto *target_AddShadowMapSampler = sigscan(
		// mov [r14+0x388], rsi
		"\x49\x89\xB6\x88\x03\x00\x00",
		"xxxxxxx");

	apply_call_hook(target_AddShadowMapSampler, hook_AddShadowMapSampler, 14);
}
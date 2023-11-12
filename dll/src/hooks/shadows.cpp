#include "Dantelion2/DLResourceManager.h"
#include "Dantelion2/DLSamplerState11.h"
#include "Dantelion2/HGDrawContext.h"
#include "FRPG/FrpgDrawContext.h"
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

void hook_SetPSResourceToDFG(NS_FRPG::FrpgDrawContext *context, UINT slot)
{
	// We don't need the DFG texture, use it for the new shadow map sampler
	auto *dl_context = context->dl_context;

	if (dl_context->samplers[slot] != shadow_map_sampler) {
		auto *sampler = shadow_map_sampler->d3d_sampler_state;
		dl_context->d3d_context->PSSetSamplers(slot, 1, &sampler);
		dl_context->samplers[slot] = shadow_map_sampler;
	}
}

extern "C" void hook_add_shadow_map_sampler();

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

	auto *target_add_shadow_map_sampler = sigscan(
		// mov [r14+0x388], rsi
		"\x49\x89\xB6\x88\x03\x00\x00",
		"xxxxxxx");

	apply_call_hook(target_add_shadow_map_sampler, hook_add_shadow_map_sampler, 14);

	auto *target_SetPSResourceToDFG = sigscan(
		// mov rsi, [r8+0x310]
		"\x49\x8B\xB0\x10\x03\x00\x00",
		"xxxxxxx") - 0x36;

	apply_jmp_hook(target_SetPSResourceToDFG, hook_SetPSResourceToDFG);
}
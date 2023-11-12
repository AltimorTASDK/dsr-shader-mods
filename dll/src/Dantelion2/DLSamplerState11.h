#pragma once

#include "Dantelion2/DLGPUResource.h"
#include "Dantelion2/HeapAllocator.h"
#include "util/memory.h"
#include "util/meta.h"
#include "util/vector.h"
#include <d3d11.h>

namespace DLGR {

enum class DLSamplerType {
	min_mag_mip_point        = 0,
	min_mag_linear_mip_point = 1,
	min_mag_mip_linear       = 2,
	anisotropic              = 3,
	comparison_greater       = 4
};

enum class DLTextureAddressMode {
	wrap        = 0,
	mirror      = 1,
	clamp       = 2,
	border      = 3,
	mirror_once = 4
};

struct DLSamplerDesc {
	DLSamplerType type;
	DLTextureAddressMode address_u;
	DLTextureAddressMode address_v;
	DLTextureAddressMode address_w;
	float mip_lod_bias;
	int max_anisotropy;
	int unknown018;
	color_rgba_f32 border_color;
	float min_lod;
	float max_lod;
};

struct DLSamplerState11 : DLGPUResource {
	ID3D11SamplerState *d3d_sampler_state;

	DLSamplerState11(struct DLDrawDevice *device, DLKRD::HeapAllocator *allocator)
	{
		using func_t = void(*)(DLSamplerState11*, DLDrawDevice*, DLKRD::HeapAllocator*);

		static auto *func = (func_t)(read_rel32(sigscan(
			// mov [r14+0x388], rsi
			"\x49\x89\xB6\x88\x03\x00\x00",
			"xxxxxxx") - 0x21));

		func(this, device, allocator);
	}

	bool CreateSamplerState(const DLSamplerDesc &desc)
	{
		using func_t = to_static_function_t<decltype(&DLSamplerState11::CreateSamplerState)>;

		static auto *func = (func_t)(sigscan(
			// sub rsp, 0x68
			// movsxd r8, [rdx]
			"\x48\x83\xEC\x68\x4C\x63\x02",
			"xxxxxxx"));

		return func(this, desc);
	}
};

} // namespace DLGR

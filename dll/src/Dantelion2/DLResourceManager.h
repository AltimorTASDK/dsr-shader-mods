#pragma once

#include "Dantelion2/HeapAllocator.h"

namespace DLGR {

struct DLResourceManager {
	void *pad000;
	struct DLDrawDevice *device;
	struct DLBlendState *blend_states[60];
	struct DLDepthStencilState *depth_stencil_states[13];
	struct DLRasterizerState *rasterizer_states[19];
	struct DLSamplerState11 *samplers[20];
	// Unused, constructor does nothing
	struct {
		char pad[0x34];
	} samplers_unused[20];
	DLKRD::HeapAllocator *allocator;
};

} // namespace DLHG

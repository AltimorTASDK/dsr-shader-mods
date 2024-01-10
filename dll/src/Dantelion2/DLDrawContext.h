#pragma once

#include "Dantelion2/DLGfxReferenceCountObject.h"
#include <d3d11.h>

namespace DLGR {

struct DLDrawContext : DLGfxReferenceCountObject {
	void *unknown018;
	ID3D11DeviceContext *d3d_context;
	struct DLSurface *render_targets[4];
	struct DLSurface *depth_stencil;
	char pad050[0xB8 - 0x50];
	struct DLSamplerState11 *samplers[16];
	char pad138[0x310 - 0x138];
};

} // namespace DLGR

#pragma once

#include "Dantelion2/DLGfxReferenceCountObject.h"

namespace DLGR {

struct DLGPUResource : DLGfxReferenceCountObject {
	struct DLDrawDevice *device;
	int unknown020;
};

} // namespace DLGR

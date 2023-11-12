#pragma once

#include "Dantelion2/DLReferenceCountObject.h"
#include "Dantelion2/HeapAllocator.h"

namespace DLGR {

struct DLGfxReferenceCountObject : DLUT::DLReferenceCountObject {
	DLKRD::HeapAllocator *allocator;
};

} // namespace DLGR

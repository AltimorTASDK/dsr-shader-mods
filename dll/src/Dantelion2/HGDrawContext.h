#pragma once

#include "Dantelion2/DLDrawContext.h"

namespace DLHG {

struct HGDrawContext {
	void **vtable;
	char pad0008[0x90 - 0x08];
	DLGR::DLDrawContext *dl_context;
	char pad0098[0x2300 - 0x98];
};

} // namespace DLHG

#pragma once

#include "Dantelion2/HGDrawContext.h"

namespace NS_FRPG {

struct FrpgDrawContext : DLHG::HGDrawContext {
	char pad2300[0x2500 - 0x2300];
};

} // namespace NS_FRPG

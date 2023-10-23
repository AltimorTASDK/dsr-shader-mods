#pragma once

#include "util/memory.h"
#include "util/meta.h"
#include "util/vector.h"

namespace NS_FRPG {

inline const vec2 &GetScreenSize()
{
	using func_t = std::add_pointer_t<decltype(GetScreenSize)>;

	static auto *func = (func_t)(sigscan(
		// mov rax, [rax+0x6F0]
		// ret
		"\x48\x8B\x80\xF0\x06\x00\x00\xC3",
		"xxxxxxxx") - 7);

	return func();
}

} // namespace NS_FRPG

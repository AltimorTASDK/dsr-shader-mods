#pragma once

#include "FRPG/FrpgRenderTextureEntity.h"
#include "util/memory.h"
#include "util/meta.h"

namespace NS_FRPG {

struct HgManUnknown;

using entity_t = unsigned int;

struct FrpgEntityFactory {
	void **vtable;
	HgManUnknown *unknown;

	inline entity_t NewRenderTexture(
		int width, int height, int type, int miplevels,
		const RenderTextureParams1 *params1, const RenderTextureParams2 *params2)
	{
		using func_t = to_static_function_t<decltype(&FrpgEntityFactory::NewRenderTexture)>;

		static auto *func = (func_t)(sigscan(
			// mov [rdi+0x10], r15d
			// mov [rdi+0x14], r14d
			// mov [rdi+0x18], ebp
			"\x44\x89\x7F\x10\x44\x89\x77\x14\x89\x6F\x18",
			"xxxxxxxxxxx") - 0xA7);

		return func(this, width, height, type, miplevels, params1, params2);
	}

	inline entity_t NewTextureSurface(entity_t texture)
	{
		using func_t = to_static_function_t<decltype(&FrpgEntityFactory::NewTextureSurface)>;

		static auto *func = (func_t)(sigscan(
			// mov [rdi+0x38], ebp
			// mov [rdi+0x3C], cl
			"\x89\x6F\x38\x88\x4F\x3C",
			"xxxxxx") - 0xB6);

		return func(this, texture);
	}
};

} // namespace NS_FRPG

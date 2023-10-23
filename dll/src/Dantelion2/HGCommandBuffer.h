#pragma once

#include <cstddef>
#include "util/memory.h"
#include "util/meta.h"

namespace DLHG {

using Entity_t = unsigned int;

enum class HGCommand : unsigned int {
	DrawPlan = 0x16
};

enum class HGDrawCommand : unsigned int {
	CreateRenderTarget                 = 0x00006,
	DestroyRenderTarget                = 0x00007,
	FlushRenderTarget                  = 0x00008,
	ClearRenderTarget                  = 0x00009,
	ClearRenderTargetIndex             = 0x0000A,
	CustomCommand                      = 0x0000B,
	ScreenShot                         = 0x0000C,
	FlushRenderTarget_Own              = 0x0001C,
	StretchRect                        = 0x0001D,
	PrecompiledDrawPlan                = 0x00020,
	BeginFrame                         = 0x00022,
	EnableObjectIds                    = 0x00023,
	DisableObjectIds                   = 0x00024,
	SetCheckerboardState               = 0x00025,
	FlipSurface                        = 0x00026,
	DecompressDepthSurface             = 0x00027,
	BeginDrawPlan                      = 0x10001,
	BeginTargetSurface                 = 0x10002,
	BeginPredicatedTilingTargetSurface = 0x10003,
	BeginTargetCamera                  = 0x10004,
	BeginTargetScene                   = 0x10005,
	BeginDeferredDrawPlan              = 0x10021,
	EndDrawPlan                        = 0x20001,
	EndTargetSurface                   = 0x20002,
	EndPredicatedTilingTargetSurface   = 0x20003,
	EndTargetCamera                    = 0x20004,
	EndTargetScene                     = 0x20005,
	EndDeferredDrawPlan                = 0x20021,
	AddDrawPlan                        = 0x30001,
	AddTargetSurface                   = 0x30002,
	AddCullingCamera                   = 0x3000D,
	AddLight                           = 0x3000E,
	AddDrawContextFactory              = 0x3000F,
	AddCollectorFactory                = 0x30010,
	AddDrawStageMask                   = 0x30011,
	AddDrawGroupMask                   = 0x30012,
	AddViewport                        = 0x30013,
	AddViewportRect                    = 0x30014,
	AddViewportZ                       = 0x30015,
	AddSurfaceViewportRect             = 0x30016,
	AddTextureViewportRect             = 0x30017,
	AddScissorBox                      = 0x30018,
	AddSurfaceScissorBox               = 0x30019,
	AddTextureScissorBox               = 0x3001A,
	AddSwapTexture                     = 0x3001B,
};

struct HGCommandBuffer {
	std::byte *buffer;
	char pad08[0x30 - 0x08];

	template<typename T>
	inline void Write(T value)
	{
		buffer = (std::byte*)((uintptr_t)(buffer + alignof(T) - 1) & ~(alignof(T) - 1));
		*(T*)buffer = value;
		buffer += sizeof(T);
	}

	inline void Write(auto... values) requires (sizeof...(values) > 1)
	{
		(Write(values), ...);
	}

	inline void Begin(HGCommand command, Entity_t entity)
	{
		using func_t = to_static_function_t<decltype(&HGCommandBuffer::Begin)>;

		static auto *func = (func_t)(sigscan(
			// jnz 0x7
			// bts edx, 0x10
			"\x75\x07\x0F\xBA\xEA\x10",
			"xxxxxx") - 0xB);

		return func(this, command, entity);
	}

	inline void End()
	{
		using func_t = to_static_function_t<decltype(&HGCommandBuffer::End)>;

		static auto *func = (func_t)(sigscan(
			// shr rdx, 2
			// shl rdx, 17
			"\x48\xC1\xEA\x02\x48\xC1\xE2\x11",
			"xxxxxxxx") - 0x21);

		return func(this);
	}

	inline void AddTargetSurface(Entity_t draw_plan, int index, Entity_t surface)
	{
		Begin(HGCommand::DrawPlan, draw_plan);
		Write(HGDrawCommand::AddTargetSurface, index, surface);
		End();
	}
};

} // namespace DLHG

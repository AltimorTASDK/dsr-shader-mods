#include "FRPG/FrpgEntityFactory.h"
#include "FRPG/FrpgUtil.h"
#include "util/logger.h"
#include "util/memory.h"
#include <tuple>

using NS_FRPG::entity_t;

constexpr size_t GBUFFER_COUNT = 2;

static entity_t gbuffer_textures[GBUFFER_COUNT];
static entity_t gbuffer_surfaces[GBUFFER_COUNT];

extern "C" void create_render_targets(NS_FRPG::FrpgEntityFactory *factory)
{
	const auto screen_size = NS_FRPG::GetScreenSize();
	const auto width  = (int)screen_size.x;
	const auto height = (int)screen_size.y;

	const auto params1 = NS_FRPG::RenderTextureParams1{.unk12 = true, .unk13 = true};
	const auto params2 = NS_FRPG::RenderTextureParams2{};

	for (size_t index = 0; index < GBUFFER_COUNT; index++) {
		gbuffer_textures[index] = factory->NewRenderTexture(width, height, 6, 1, &params1, &params2);
		gbuffer_surfaces[index] = factory->NewTextureSurface(gbuffer_textures[index]);

		logger.println(
			"GBuffer {} texture {:08X} surface {:08X}",
			index, gbuffer_textures[index], gbuffer_surfaces[index]);
	}
}

extern "C" void hook_RenderTargetManImp();

void apply_hooks_deferred()
{
	auto *target_RenderTargetManImp = sigscan(
		// mov rax, r13
		// mov rcx, [rbp+0x17]
		// xor rcx, rsp
		"\x49\x8B\xC5\x48\x8B\x4D\x17\x48\x33\xCC",
		"xxxxxxxxxx") + 0xF;

	apply_call_hook(target_RenderTargetManImp, hook_RenderTargetManImp, 15);
}

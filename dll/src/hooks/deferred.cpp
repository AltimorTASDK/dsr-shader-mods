#include "Dantelion2/HGCommandBuffer.h"
#include "FRPG/FrpgEntityFactory.h"
#include "FRPG/FrpgUtil.h"
#include "util/logger.h"
#include "util/memory.h"
#include <tuple>

constexpr auto GBUFFER_COUNT = 2;

static DLHG::Entity_t gbuffer_textures[GBUFFER_COUNT];
static DLHG::Entity_t gbuffer_surfaces[GBUFFER_COUNT];

extern "C" void create_render_targets(NS_FRPG::FrpgEntityFactory *factory)
{
	const auto screen_size = NS_FRPG::GetScreenSize();
	const auto width  = (int)screen_size.x;
	const auto height = (int)screen_size.y;

	const auto params1 = NS_FRPG::RenderTextureParams1{.unk12 = true, .unk13 = true};
	const auto params2 = NS_FRPG::RenderTextureParams2{};

	for (auto index = 0; index < GBUFFER_COUNT; index++) {
		gbuffer_textures[index] = factory->NewRenderTexture(width, height, 6, 1, &params1, &params2);
		gbuffer_surfaces[index] = factory->NewTextureSurface(gbuffer_textures[index]);

		logger.println(
			"GBuffer {} texture {:08X} surface {:08X}",
			index, gbuffer_textures[index], gbuffer_surfaces[index]);
	}
}

extern "C" void create_gbuffer_draw_plan(
	DLHG::HGCommandBuffer *cmd, DLHG::Entity_t draw_plan, DLHG::Entity_t surface_gbuffer1)
{
	// Vanilla subsurface scatterring
	cmd->AddTargetSurface(draw_plan, 1, surface_gbuffer1);

	for (auto index = 0; index < GBUFFER_COUNT; index++)
		cmd->AddTargetSurface(draw_plan, 2 + index, gbuffer_surfaces[index]);
}

extern "C" void hook_RenderTargetManImp();
extern "C" void hook_PrecompileCommonDrawPlans();

void apply_hooks_deferred()
{
	auto *target_RenderTargetManImp = sigscan(
		// mov rax, r13
		// mov rcx, [rbp+0x17]
		// xor rcx, rsp
		"\x49\x8B\xC5\x48\x8B\x4D\x17\x48\x33\xCC",
		"xxxxxxxxxx") + 0xF;

	apply_call_hook(target_RenderTargetManImp, hook_RenderTargetManImp, 15);

	auto *target_PrecompileCommonDrawPlans = sigscan(
		// mov edi, [rax+0xA4]
		// mov ebx, [rax+0xA8]
		"\x8B\xB8\xA4\x00\x00\x00\x8B\x98\xA8\x00\x00\x00",
		"xxxxxxxxxxxx") + 0x40;

	// Replace the whole original AddTargetSurface
	apply_call_hook(target_PrecompileCommonDrawPlans, hook_PrecompileCommonDrawPlans, 0x58);
}

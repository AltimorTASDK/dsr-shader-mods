#include "util.h"
#include "hooks/lighting_params.h"

#include <Windows.h>

extern "C" void apply_hooks()
{
	apply_hooks_lighting_params();
}

extern "C" void hook_SteamAPI_Init();

BOOL WINAPI DllMain(HINSTANCE instance, DWORD reason, void *reserved)
{
	if (reason != DLL_PROCESS_ATTACH)
		return FALSE;

	// Hook SteamAPI_Init to immediately apply hooks after SteamStub unpacking
	const auto steam_api64 = GetModuleHandle("steam_api64.dll");
	auto *SteamAPI_Init = GetProcAddress(steam_api64, "SteamAPI_Init");
	apply_call_hook(SteamAPI_Init, hook_SteamAPI_Init, 12);

	return TRUE;
}

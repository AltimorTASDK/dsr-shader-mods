#include "util/memory.h"

void apply_hooks_shadows()
{
	auto *target_vertex_lisp_flver = sigscan(
		// jz +0xB1
		// movaps xmm0, [rsi+0x60]
		"\x0F\x84\xAB\x00\x00\x00\x0F\x28\x46\x60",
		"xxxxxxxxxx");

	// Skip attempt to apply LiSP matrix in vertex shader
	// jmp +0xB1
	patch_code(target_vertex_lisp_flver, "\xE9\xAC\x00\x00\x00\x90");

	auto *target_vertex_lisp_fgflver = sigscan(
		// jz +0xB1
		// movaps xmm0, [r13+0x60]
		"\x0F\x84\xAB\x00\x00\x00\x41\x0F\x28\x45\x60",
		"xxxxxxxxxxx");

	// Skip attempt to apply LiSP matrix in vertex shader
	// jmp +0xB1
	patch_code(target_vertex_lisp_fgflver, "\xE9\xAC\x00\x00\x00\x90");
}
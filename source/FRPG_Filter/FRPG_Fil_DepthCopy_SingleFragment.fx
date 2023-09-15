#include "FRPG_Fil_Common.fxh"

#if defined(_ORBIS)
#define Texture2DMS MS_Texture2D
#endif

struct PsInput
{
	float4 pos : SV_Position;
	float2 uv : Texcoord0;
};

PsInput VertexMain(uint vertexId : SV_VertexID)
{
	const float2 ndc[6] = {
		float2( 1, 1),
		float2( 1,-1),
		float2(-1,-1),
		float2(-1,-1),
		float2(-1, 1),
		float2( 1, 1),
	};
	const float2 uv[6] = {
		float2(1, 0),
		float2(1, 1),
		float2(0, 1),
		float2(0, 1),
		float2(0, 0),
		float2(1, 0),
	};

	PsInput output;
	output.pos = float4(ndc[vertexId], 0, 1);
	output.uv = uv[vertexId];
	return output;
}

Texture2DMS<float> g_depth : register(t0);

float FragmentMain(PsInput input) : SV_Depth
{
	return g_depth.Load(uint2(input.uv * gFC_ScreenSize.xy), 0);
}
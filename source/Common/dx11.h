#ifndef ___QLOC_DX11___
#define ___QLOC_DX11___

#if defined(_ORBIS)

#pragma warning (disable: 5202) // Implicit cast from float4 to float2, float, etc.

#if defined(ORBIS_OUTPUT_FMT_32_R)
#pragma PSSL_target_output_format(default FMT_32_R)
#endif

#define TEX2DSAMPLER( name ) name, name##Sampler
#define TEX2DSAMPLERDECL( name ) Texture2D name, SamplerState name##Sampler
#define TEXCUBESAMPLER( name ) name, name##Sampler
#define TEXCUBESAMPLERDECL( name ) TextureCube name, SamplerState name##Sampler
#define TEXCUBEARRAYSAMPLERDECL( name ) TextureCube_Array name, SamplerState name##Sampler

#define SAMPLER2D( name, reg ) Texture2D name : register(t##reg); SamplerState name##Sampler : register(s##reg);
#define SAMPLERCUBE( name, reg ) TextureCube name : register(t##reg); SamplerState name##Sampler : register(s##reg);
#define SAMPLERCUBEARRAY( name, reg ) TextureCube_Array name : register(t##reg); SamplerState name##Sampler : register(s##reg);
#define SAMPLER3D( name, reg ) Texture3D name : register( t##reg); SamplerState name##Sampler : register(s##reg);
#define SAMPLERCMP2D( name, reg ) Texture2D name : register(t##reg); SamplerComparisonState name##Sampler : register(s##reg);

#define tex2D( tex, uv ) tex.Sample( tex##Sampler, uv)
#define tex2Dlod( tex, uv ) tex.SampleLOD( tex##Sampler, uv.rg, uv.w )
#define tex2Dgrad( tex, uv, dx, dy ) tex.SampleGradient ( tex##Sampler, uv, dx, dy )
#define texCUBE( tex, uv ) tex.Sample( tex##Sampler, uv )
#define texCUBElod( tex, uv ) tex.SampleLOD( tex##Sampler, uv.rgb, uv.w )
#define texCUBEArray( tex, uv, index ) tex.Sample( tex##Sampler, float4(uv.rgb,index) )
#define texCUBEArraylod( tex, uv, index ) tex.SampleLOD( tex##Sampler, float4(uv.rgb,index), uv.w )

#define tex2Dsamp( tex, samp, uv ) tex.Sample( samp, uv )

#define tex3Dlod( tex, uv ) tex.SampleLOD( tex##Sampler, uv.rgb, uv.w )

#define QLOC_int2 int2
#define QLOC_int4 int4

ConstantBuffer AlphaTestBuffer : register(b1)
{
	int AlphaTest;
	float3 AlphaTestRef;
	float4 AlphaTest_padding;
}
float4 qlocDoAlphaTest(const float4 outColor)
{
	if (AlphaTest == 1)
	{
		clip(outColor.a <= AlphaTestRef.x ? -1 : 1);
	}
	return outColor;
}

ConstantBuffer ClipPlaneBuffer : register(b2)
{
	int ClipPlaneEnabled;
	float4 ClipPlane;
}
float qlocClipPlaneDistance(float4 pos)
{
	if (ClipPlaneEnabled == 1)
	{
		return dot(ClipPlane, pos);
	}
	else
	{
		return 0.0f;
	}
}

#define SV_Target S_TARGET_OUTPUT
#define SV_Target0 S_TARGET_OUTPUT0
#define SV_Target1 S_TARGET_OUTPUT1
#define SV_Target2 S_TARGET_OUTPUT2
#define SV_Target3 S_TARGET_OUTPUT3
#define SV_Target4 S_TARGET_OUTPUT4
#define SV_Target5 S_TARGET_OUTPUT5
#define SV_Target6 S_TARGET_OUTPUT6
#define SV_Target7 S_TARGET_OUTPUT7
#define SV_Position S_POSITION
#define SV_VertexID S_VERTEX_ID
#define SV_Depth S_DEPTH_OUTPUT
#define SV_ClipDistance0 S_CLIP_DISTANCE
#define SV_IsFrontFace S_FRONT_FACE
#define StructuredBuffer RegularBuffer

#elif defined(_DX11)

//#define sampler2D Texture2D
#define TEX2DSAMPLER( name ) name, name##Sampler
#define TEX2DSAMPLERDECL( name ) Texture2D name, SamplerState name##Sampler
#define TEXCUBESAMPLER( name ) name, name##Sampler
#define TEXCUBESAMPLERDECL( name ) TextureCube name, SamplerState name##Sampler
#define TEXCUBEARRAYSAMPLERDECL( name ) TextureCubeArray name, SamplerState name##Sampler

#define SAMPLER2D( name, reg ) Texture2D name : register(t##reg); SamplerState name##Sampler : register(s##reg);
#define SAMPLERCUBE( name, reg ) TextureCube name : register(t##reg); SamplerState name##Sampler : register(s##reg);
#define SAMPLERCUBEARRAY( name, reg ) TextureCubeArray name : register(t##reg); SamplerState name##Sampler : register(s##reg);
#define SAMPLER3D( name, reg ) Texture3D name : register( t##reg); SamplerState name##Sampler : register(s##reg);
#define SAMPLERCMP2D( name, reg ) Texture2D name : register(t##reg); SamplerComparisonState name##Sampler : register(s##reg);

#define tex2D( tex, uv ) tex.Sample( tex##Sampler, uv)
#define tex2Dlod( tex, uv ) tex.SampleLevel( tex##Sampler, uv.rg, uv.w )
#define tex2Dgrad( tex, uv, dx, dy ) tex.SampleGrad ( tex##Sampler, uv, dx, dy )
#define texCUBE( tex, uv ) tex.Sample( tex##Sampler, uv )
#define texCUBEArray( tex, uv, index ) tex.Sample( tex##Sampler, float4(uv.rgb,index) )
#define texCUBElod( tex, uv ) tex.SampleLevel( tex##Sampler, uv.rgb, uv.w )
#define texCUBEArraylod( tex, uv, index ) tex.SampleLevel( tex##Sampler, float4(uv.rgb,index), uv.w )

#define tex2Dsamp( tex, samp, uv ) tex.Sample( samp, uv )

#define tex3Dlod( tex, uv ) tex.SampleLevel( tex##Sampler, uv.rgb, uv.w )

#define QLOC_int2 int2
#define QLOC_int4 int4

cbuffer AlphaTestBuffer : register(b1)
{
	int AlphaTest;
	float3 AlphaTestRef;
	float4 AlphaTest_padding;
}
float4 qlocDoAlphaTest(const float4 outColor)
{
	if (AlphaTest==1)
	{
		clip( outColor.a <= AlphaTestRef.x ? -1:1 );
	}
	return outColor;
}

cbuffer ClipPlaneBuffer : register(b2)
{
	int ClipPlaneEnabled;
	float4 ClipPlane;
}
float qlocClipPlaneDistance(float4 pos)
{
	if (ClipPlaneEnabled==1)
	{
		return dot(ClipPlane, pos);
	}
	else
	{
		return 0.0f;
	}
}

#if defined(WITH_WriteObjectIDs)
cbuffer ObjectIDBuffer : register(b3)
{
	uint ObjectID;
}
float qlocGetObjectID(int VertexID)
{
	return ObjectID << 24 | (VertexID & 0xFFFF);
}
#endif

#else

#define TEX2DSAMPLER( name ) name
#define TEX2DSAMPLERDECL( name ) sampler2D name
#define TEXCUBESAMPLER( name ) name
#define TEXCUBESAMPLERDECL( name ) samplerCUBE name
#define TEXCUBEARRAYSAMPLERDECL( name ) samplerCUBE name

#define SAMPLER2D( name, reg ) sampler2D name : register(s##reg);
#define SAMPLERCUBE( name, reg ) samplerCUBE name : register(s##reg);
#define SAMPLERCUBEARRAY( name, reg ) samplerCUBE name : register(s##reg);
#define SAMPLER3D( name, reg ) sampler3D name : register( s##reg);

#define tex2Dsamp( tex, samp, uv ) tex2D(tex,uv)
#define texCUBEArray( tex, uv, index ) texCUBE( tex, uv )
#define texCUBEArraylod( tex, uv, index ) texCUBElod( tex, uv)

#define tex3Dlod( tex, uv ) tex3Dlod( tex, uv )

#define SV_Target0 COLOR0
#define SV_Target1 COLOR1
#define SV_Target2 COLOR2
#define SV_Target3 COLOR3
#define SV_Target4 COLOR4
#define SV_Target5 COLOR5
#define SV_Target6 COLOR6
#define SV_Target7 COLOR7
#define SV_Position POSITION
#define SV_Depth DEPTH

#define QLOC_int2 float2
#define QLOC_int4 float4

float4 qlocDoAlphaTest(const float4 outColor)
{
	return outColor;
}

#endif

#endif

#pragma warning (disable: 3571) // pow(f, e) will not work for negative f, use abs(f) or conditionally handle negative values if you expect them
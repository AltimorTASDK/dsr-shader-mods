/***************************************************************************//**

	@file		FRPG_Common_VTX_IN.fxh
	@brief		<ファイルの説明>
	@par 		<ファイルの詳細な説明>
	@author		itoj
	@version	v1.0

	@note		//<ポート元情報>

	@note		//<ポート元著作権表記>

	@note		//<フロム・ソフトウエア著作権表記>

	Copyright &copy; @YEAR@ FromSoftware, Inc.

*//****************************************************************************/
/*!
	@par
*/
#ifndef ___FRPG_Flver_FRPG_Common_VTX_IN_fxh___
#define ___FRPG_Flver_FRPG_Common_VTX_IN_fxh___




//**バーテックスシェーダ入力


//#define WITH_BumpMap
//#define WITH_LightMap
//#define WITH_Skin
	#include "FRPG_Common_VTX_IN_Base.fxh"
//#undef WITH_BumpMap
//#undef WITH_LightMap
//#undef WITH_Skin



#define WITH_BumpMap
//#define WITH_LightMap
//#define WITH_Skin
	#include "FRPG_Common_VTX_IN_Base.fxh"
#undef WITH_BumpMap
//#undef WITH_LightMap
//#undef WITH_Skin



//#define WITH_BumpMap
#define WITH_LightMap
//#define WITH_Skin
	#include "FRPG_Common_VTX_IN_Base.fxh"
//#undef WITH_BumpMap
#undef WITH_LightMap
//#undef WITH_Skin



#define WITH_BumpMap
#define WITH_LightMap
//#define WITH_Skin
	#include "FRPG_Common_VTX_IN_Base.fxh"
#undef WITH_BumpMap
#undef WITH_LightMap
//#undef WITH_Skin



//#define WITH_BumpMap
//#define WITH_LightMap
#define WITH_Skin
	#include "FRPG_Common_VTX_IN_Base.fxh"
//#undef WITH_BumpMap
//#undef WITH_LightMap
#undef WITH_Skin



#define WITH_BumpMap
//#define WITH_LightMap
#define WITH_Skin
	#include "FRPG_Common_VTX_IN_Base.fxh"
#undef WITH_BumpMap
//#undef WITH_LightMap
#undef WITH_Skin



//#define WITH_BumpMap
#define WITH_LightMap
#define WITH_Skin
	#include "FRPG_Common_VTX_IN_Base.fxh"
//#undef WITH_BumpMap
#undef WITH_LightMap
#undef WITH_Skin



#define WITH_BumpMap
#define WITH_LightMap
#define WITH_Skin
	#include "FRPG_Common_VTX_IN_Base.fxh"
#undef WITH_BumpMap
#undef WITH_LightMap
#undef WITH_Skin






	//!ゴースト描画用(TOD)
	struct VTX_IN_GHOST_TOD
	{
		float3 VecPos : POSITION;
		uint4 BlendIdx : BLENDINDICES;	//!<ローカル→ワールド行列インデックス(TODのときは全要素同値)
		float3 VecNrm : NORMAL;
		float4 VecTan : TANGENT;

		float4 ColVtx : COLOR0;	//!<頂点色

		QLOC_int2 TexDif_int_qloc : TEXCOORD0;	//!<ディフューズUV
	};

	//!ゴースト描画用(スキン)
	struct VTX_IN_GHOST_SKIN
	{
		float3 VecPos : POSITION;
		uint4 BlendIdx : BLENDINDICES;	//!<ローカル→ワールド行列インデックス(TODのときは全要素同値)
		float4 BlendWeight : BLENDWEIGHT;
		float3 VecNrm : NORMAL;
		float4 VecTan : TANGENT;

		float4 ColVtx : COLOR0;	//!<頂点色

		QLOC_int2 TexDif_int_qloc : TEXCOORD0;	//!<ディフューズUV
	};





	//!水面描画用
/*
	struct VTX_IN_WATER
	{
		float3 VecPos : POSITION;
		int4 BlendIdx : BLENDINDICES;	//!<ローカル→ワールド行列インデックス(全要素同値)
		float3 VecNrm : NORMAL;
		float4 VecTan : TANGENT;

		float4 ColVtx : COLOR0;	//!<頂点色

		float2 TexDif : TEXCOORD0;
	};
*/
#define VTX_IN_WATER VTX_IN_PINT_D	//!<同じのがあるので使い回し
#define VTX_IN_WATER_Skin VTX_IN_PIWNT_D	//!<同じのがあるので使い回し

#define VTX_IN_SNOW_D	VTX_IN_PINT_D	//!<同じのがあるので使い回し
#define VTX_IN_SNOW_DL	VTX_IN_PINT_DL	//!<同じのがあるので使い回し
#define VTX_IN_SNOW_Skin_D	VTX_IN_PIWNT_D	//!<同じのがあるので使い回し
#define VTX_IN_SNOW_Skin_DL VTX_IN_PIWNT_DL	//!<同じのがあるので使い回し












#endif //___FRPG_Flver_FRPG_Common_VTX_IN_fxh___

/***************************************************************************//**

	@file		FRPG_Common_VTX_OUT.fxh
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
#ifndef ___FRPG_Flver_FRPG_Common_VTX_OUT_fxh___
#define ___FRPG_Flver_FRPG_Common_VTX_OUT_fxh___




//**バーテックスシェーダ出力


//#define WITH_GhostMap
//#define WITH_BumpMap
//#define WITH_LightMap
//#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap

#define WITH_GhostMap
//#define WITH_BumpMap
//#define WITH_LightMap
//#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap


//#define WITH_GhostMap
#define WITH_BumpMap
//#define WITH_LightMap
//#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap

#define WITH_GhostMap
#define WITH_BumpMap
//#define WITH_LightMap
//#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap




//#define WITH_GhostMap
//#define WITH_BumpMap
#define WITH_LightMap
//#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap

#define WITH_GhostMap
//#define WITH_BumpMap
#define WITH_LightMap
//#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap


//#define WITH_GhostMap
#define WITH_BumpMap
#define WITH_LightMap
//#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap

#define WITH_GhostMap
#define WITH_BumpMap
#define WITH_LightMap
//#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap










//#define WITH_GhostMap
//#define WITH_BumpMap
//#define WITH_LightMap
#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap

#define WITH_GhostMap
//#define WITH_BumpMap
//#define WITH_LightMap
#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap


//#define WITH_GhostMap
#define WITH_BumpMap
//#define WITH_LightMap
#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap

#define WITH_GhostMap
#define WITH_BumpMap
//#define WITH_LightMap
#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap




//#define WITH_GhostMap
//#define WITH_BumpMap
#define WITH_LightMap
#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap

#define WITH_GhostMap
//#define WITH_BumpMap
#define WITH_LightMap
#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap


//#define WITH_GhostMap
#define WITH_BumpMap
#define WITH_LightMap
#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap

#define WITH_GhostMap
#define WITH_BumpMap
#define WITH_LightMap
#define WITH_ShadowMap
	#include "FRPG_Common_VTX_OUT_Base.fxh"
#undef WITH_ShadowMap
#undef WITH_LightMap
#undef WITH_BumpMap
#undef WITH_GhostMap






	//!デプス描画用
	struct VTX_OUT_C__
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		#if defined(_PS3_)//PS3
		#elif defined(_Xenon_)//XBOX360
		#elif defined(_WIN32_)//WIN32
			float2 VtxClp_forCreateDepthTexure : TEXCOORD0;	//!<デプステクスチャ作成用頂点座標(クリップ空間)(x:VtxClp.z, y:VtxClp.w)
		#else
			不明
		#endif
	};
	//!デプス描画用(α抜き)
	struct VTX_OUT_C__D
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		#if defined(_PS3_)//PS3
		#elif defined(_Xenon_)//XBOX360
		#elif defined(_WIN32_)//WIN32
			float2 VtxClp_forCreateDepthTexure : TEXCOORD0;	//!<デプステクスチャ作成用頂点座標(クリップ空間)(x:VtxClp.z, y:VtxClp.w)
		#else
			不明
		#endif
		float4 ColVtx : TEXCOORD6;	//!<頂点色
		float2 TexDif : TEXCOORD7;	//!<ディフューズUV
	};
	//!デプス描画用(マルチα抜き)
	struct VTX_OUT_C__DD
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		#if defined(_PS3_)//PS3
		#elif defined(_Xenon_)//XBOX360
		#elif defined(_WIN32_)//WIN32
			float2 VtxClp_forCreateDepthTexure : TEXCOORD0;	//!<デプステクスチャ作成用頂点座標(クリップ空間)(x:VtxClp.z, y:VtxClp.w)
		#else
			不明
		#endif
		//不要//float4 ColVtx : TEXCOORD6;	//!<頂点色
		//不要//float4 TexDifDif : TEXCOORD7;	//!<ディフューズUV＋ディフューズUV
//2012.02.17:itoj>↑なぜ不要なのか不明.マルチα抜き非対応にしたとかか？
	};
	//!デプス描画用(ノーマルtoアルファ)
	struct VTX_OUT_C__NE_D_forNtoA
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		#if defined(_PS3_)//PS3
		#elif defined(_Xenon_)//XBOX360
		#elif defined(_WIN32_)//WIN32
			float2 VtxClp_forCreateDepthTexure : TEXCOORD0;	//!<デプステクスチャ作成用頂点座標(クリップ空間)(x:VtxClp.z, y:VtxClp.w)
		#else
			不明
		#endif

		float4 VecNrm : TEXCOORD2;	//!<法線(xyz:法線, w:フォグ係数)
		float4 VecEye : TEXCOORD3;	//!<視線ベクトル(ワールド空間)(xyz:正規化済み頂点→カメラベクトル, w:頂点→カメラ距離)

		float4 ColVtx : COLOR;	//!<頂点色

		float2 TexDif : TEXCOORD6;	//!<ディフューズUV
		
		#if defined(_DX11) && defined(WITH_ClipPlane)
			float oClip0 : SV_ClipDistance0; 
		#endif
	};
	
	
	//オブジェクトモーションブラー用
	struct VTX_OUT___V
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		float3 VtxVel : TEXCOORD0;	//!<スクリーン空間速度
	};

	//オブジェクトモーションブラー用(α抜き)
	struct VTX_OUT_C__DV
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		float4 ColVtx  : COLOR;	//!<頂点色
		float2 TexDif : TEXCOORD0;	//!<xy: ディフューズUV	
		float3 VtxVel : TEXCOORD1;	//!<スクリーン空間速度
	};



	//!ゴースト描画用
	struct VTX_OUT_GHOST
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		float4 VtxWld : TEXCOORD0;	//!<頂点座標(ワールド空間)(xyz:ワールド空間での位置, w:View空間でのZ)

		float4 VecNrm : TEXCOORD2;	//!<法線(xyz:法線, w:フォグ係数)
		float4 VecEye : TEXCOORD3;	//!<視線ベクトル(ワールド空間)(xyz:正規化済み頂点→カメラベクトル, w:頂点→カメラ距離)
		float4 VecTan : TEXCOORD4;

		float4 ColVtx : COLOR;	//!<頂点色

		float2 TexDif : TEXCOORD6;	//!<ディフューズUV(バンプ用)
//2010/08/30 nacheon ゴーストテクスチャスクロール削除	float4 TexDifDif : TEXCOORD7;	//!<ディフューズUV+ディフューズUV(スクロールディフューズ用)
		
		#ifdef VSLS
			float3 LsMul : TEXCOORD8;	
			float3 LsAdd : TEXCOORD9;	
		#endif

		#if defined(_DX11) && defined(WITH_ClipPlane)
			float oClip0 : SV_ClipDistance0; 
		#endif
	};






	//!水面描画用
	struct VTX_OUT_WATER
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		float4 VtxWld : TEXCOORD0;	//!<頂点座標(ワールド空間)(xyz:ワールド空間での位置, w:View空間でのZ)

		float4 VecNrm : TEXCOORD1;	//!<法線(xyz:法線, w:フォグ係数)
		float4 VecEye : TEXCOORD2;	//!<視線ベクトル(ワールド空間)(xyz:正規化済み頂点→カメラベクトル, w:頂点→カメラ距離)
		float4 VecTan : TEXCOORD3;

		float4 ColVtx : COLOR;	//!<頂点色

//		float4 TexDifDif : TEXCOORD7;	//!<バンプUV+バンプUV
//		float2 TexDif : TEXCOORD8;	//!<バンプUV

//		float4 VtxLit : TEXCOORD4;			//!<頂点座標(ライト空間)
		float4 VtxScr : TEXCOORD5;			//!<頂点座標(スクリーン空間)
		
		float4 VtxWldOffetX : TEXCOORD6;	//!<
		float4 VtxWldOffetY : TEXCOORD7;	//!<
		float4 VtxClpOffsetX : TEXCOORD8;	//!<
		float4 VtxClpOffsetY : TEXCOORD9;	//!<
	};
	
	
	struct VTX_OUT_WATER_Lit
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		float4 VtxWld : TEXCOORD0;	//!<頂点座標(ワールド空間)(xyz:ワールド空間での位置, w:View空間でのZ)

		float4 VecNrm : TEXCOORD1;	//!<法線(xyz:法線, w:フォグ係数)
		float4 VecEye : TEXCOORD2;	//!<視線ベクトル(ワールド空間)(xyz:正規化済み頂点→カメラベクトル, w:頂点→カメラ距離)
		float4 VecTan : TEXCOORD3;

		float4 ColVtx : COLOR;	//!<頂点色

//		float4 TexDifDif : TEXCOORD7;	//!<バンプUV+バンプUV
//		float2 TexDif : TEXCOORD8;	//!<バンプUV

		float4 VtxLit : TEXCOORD4;			//!<頂点座標(ライト空間)
		float4 VtxScr : TEXCOORD5;			//!<頂点座標(スクリーン空間)
		
		float4 VtxWldOffetX : TEXCOORD6;	//!<
		float4 VtxWldOffetY : TEXCOORD7;	//!<
		float4 VtxClpOffsetX : TEXCOORD8;	//!<
		float4 VtxClpOffsetY : TEXCOORD9;	//!<
	};
	
	//!雪面描画用
	struct VTX_OUT_SNOW
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		float4 VtxWld : TEXCOORD0;	//!<頂点座標(ワールド空間)(xyz:ワールド空間での位置, w:View空間でのZ)

		float4 VecNrm : TEXCOORD1;	//!<法線(xyz:法線, w:フォグ係数)
		float4 VecEye : TEXCOORD2;	//!<視線ベクトル(ワールド空間)(xyz:正規化済み頂点→カメラベクトル, w:頂点→カメラ距離)
		float4 VecTan : TEXCOORD3;

		float4 ColVtx : COLOR;	//!<頂点色

//		float4 VtxLit : TEXCOORD4;			//!<頂点座標(ライト空間)
		float4 VtxScr : TEXCOORD5;			//!<頂点座標(XY:スクリーン空間)
		
		float4 vTexDifDif : TEXCOORD6;		//!<Detail BumpのUV, DiffuseのUV
		float4 VtxWldOffetY : TEXCOORD7;	//!<
		float4 VtxClpOffsetXYXY : TEXCOORD8;	//!<
		float4 VtxClpOffsetWWUV : TEXCOORD9;	//!<
	};

	struct VTX_OUT_SNOW_Lit
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		float4 VtxWld : TEXCOORD0;	//!<頂点座標(ワールド空間)(xyz:ワールド空間での位置, w:View空間でのZ)

		float4 VecNrm : TEXCOORD1;	//!<法線(xyz:法線, w:フォグ係数)
		float4 VecEye : TEXCOORD2;	//!<視線ベクトル(ワールド空間)(xyz:正規化済み頂点→カメラベクトル, w:頂点→カメラ距離)
		float4 VecTan : TEXCOORD3;

		float4 ColVtx : COLOR;	//!<頂点色

		float4 VtxLit : TEXCOORD4;			//!<頂点座標(ライト空間)
		float4 VtxScr : TEXCOORD5;			//!<頂点座標(XY:スクリーン空間, ZW:ライトマップUV)
		
		float4 vTexDifDif : TEXCOORD6;		//!<Detail BumpのUV, DiffuseのUV
		float4 VtxWldOffetY : TEXCOORD7;	//!<
		float4 VtxClpOffsetXYXY : TEXCOORD8;	//!<
		float4 VtxClpOffsetWWUV : TEXCOORD9;	//!<
	};
		
	
	//!水面高さ描画用
	struct VTX_OUT_WATER_HEIGHT
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)

		float4 TexDif1 : TEXCOORD0;	//!<バンプUV+バンプUV
		float4 TexDif2 : TEXCOORD1;	//!<XY:バンプUV, Z: Z値、W:未使用
	};
	
	
	//!水面波SFX描画用(α抜き)
	struct VTX_OUT_WH_C__D
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		float4 ColVtx : COLOR;	//!<頂点色
		float2 TexDif : TEXCOORD7;	//!<ディフューズUV
	};
	//!水面波SFX描画用(マルチα抜き)
	struct VTX_OUT_WH_C__DD
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		float4 ColVtx : COLOR;	//!<頂点色
		float4 TexDifDif : TEXCOORD7;	//!<ディフューズUV＋ディフューズUV
	};

/*
float4 VecPos : POSITION;
float4 VecVtx : TEXCOORD0;
float4 VecNrm : TEXCOORD1;
float4 VecEye : TEXCOORD2;
float4 VecTan : TEXCOORD3;
float4 tex_bump: TEXCOORD4;
float2 tex_bump2: TEXCOORD5;
float4 VecScreenPos: TEXCOORD6;
float4 ColVtx : TEXCOORD7;
*/







#endif //___FRPG_Flver_FRPG_Common_VTX_OUT_fxh___

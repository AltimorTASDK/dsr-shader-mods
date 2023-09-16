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

//下記の組み合わせ
//#define WITH_GhostMap	//!<ゴーストマップあり
//#define WITH_BumpMap	//!<バンプマップあり
//#define WITH_LightMap	//!<ライトマップあり
//#define WITH_ShadowMap	//!<シャドウマップあり



struct VTX_OUT
{
	float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
	float4 VtxWld : TEXCOORD0;	//!<頂点座標(ワールド空間)(xyz:ワールド空間での位置, w:View空間でのZ)
	#if WITH_ShadowMap == CalcLispPos_VS
		float4 VtxLit : TEXCOORD1;	//!<頂点座標(ライト空間)
	#endif

	float4 VecNrm : TEXCOORD2;	//!<法線(xyz:法線, w:フォグ係数)
	float4 VecEye : TEXCOORD3;	//!<視線ベクトル(ワールド空間)(xyz:正規化済み頂点→カメラベクトル, w:頂点→カメラ距離)
	#ifdef WITH_BumpMap
		#ifdef WITH_MultiTexture
			float4 VecTan : TEXCOORD4;
			float4 VecTan2 : TEXCOORD5;
			#ifdef CALC_VS_BINORMAL
				float3 VecBin : TEXCOORD8;
				float3 VecBin2 : TEXCOORD9;
			#endif
		#else
			float4 VecTan : TEXCOORD4;
			#ifdef CALC_VS_BINORMAL
				float3 VecBin : TEXCOORD5;
			#endif
		#endif
	#endif

	float4 ColVtx : COLOR;	//!<頂点色

	#ifdef WITH_LightMap
		#ifdef WITH_MultiTexture
			float4 TexDifDif : TEXCOORD6;	//!<ディフューズUV＋ディフューズUV
			float2 TexLit : TEXCOORD7;	//!<ライトマップUV
		#else
			float4 TexDifLit : TEXCOORD6;	//!<ディフューズUV＋ライトマップUV
		#endif
	#else
		#ifdef WITH_MultiTexture
			float4 TexDifDif : TEXCOORD6;	//!<ディフューズUV＋ディフューズUV
		#else
			float2 TexDif : TEXCOORD6;	//!<ディフューズUV
		#endif
	#endif

	#ifdef VSLS //消したほうが、、LightScatteringをVSでするのは厳しい
		float3/*float3*/ LsMul : TEXCOORD8;
		float3/*float3*/ LsAdd : COLOR1;
	#endif //VSLS

	#if defined(_DX11) && defined(WITH_ClipPlane)
		float oClip0 : SV_ClipDistance0;
	#endif

	#if defined(_DX11) && defined(_FRAGMENT_SHADER)
		uint isFrontFace : SV_IsFrontFace;
	#endif
};

#endif //___FRPG_Flver_FRPG_Common_VTX_OUT_fxh___
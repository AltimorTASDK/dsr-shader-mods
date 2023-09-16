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

//下記の組み合わせ
//#define WITH_BumpMap	//!<バンプマップあり
//#define WITH_LightMap	//!<ライトマップあり
//#define WITH_Skin	//!<スキンあり



struct VTX_IN
{
	float3 VecPos : POSITION;
	uint4 BlendIdx : BLENDINDICES;	//!<ローカル→ワールド行列インデックス(TODのときは全要素同値)
	#ifdef WITH_Skin
		float4 BlendWeight : BLENDWEIGHT;
	#endif
	float3 VecNrm : NORMAL;
	#ifdef WITH_BumpMap
		float4 VecTan : TANGENT;
		#ifdef WITH_MultiTexture
			float4 VecTan2 : BINORMAL;//実際にはTANGENT
		#endif
	#endif

	float4 ColVtx : COLOR0;	//!<頂点色

	#ifdef WITH_MultiTexture
		#ifdef WITH_LightMap
			QLOC_int4 TexDifDif_int_qloc : TEXCOORD0;	//!<ディフューズUV＋ディフューズUV
			QLOC_int2 TexLit_int_qloc : TEXCOORD1;	//!<ライトマップUV

			#ifdef WITH_Wind
				half4 WindParam : TEXCOORD2;
			#endif
		#else
			QLOC_int4 TexDifDif_int_qloc : TEXCOORD0;	//!<ディフューズUV＋ディフューズUV

			#ifdef WITH_Wind
				QLOC_int4 WindParam : TEXCOORD1;
			#endif
		#endif
	#else
		#ifdef WITH_LightMap
			QLOC_int4 TexDifLit_int_qloc : TEXCOORD0;	//!<ディフューズUV＋ライトマップUV
		#else
			QLOC_int2 TexDif_int_qloc : TEXCOORD0;	//!<ディフューズUV
		#endif

		#ifdef WITH_Wind
			QLOC_int4 WindParam : TEXCOORD1;
		#endif
	#endif
};

#endif //___FRPG_Flver_FRPG_Common_VTX_IN_fxh___
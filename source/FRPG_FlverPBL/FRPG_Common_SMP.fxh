/***************************************************************************//**

	@file		FRPG_Common_SMP.fxh
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
#ifndef ___FRPG_Flver_FRPG_Common_SMP_fxh___
#define ___FRPG_Flver_FRPG_Common_SMP_fxh___

#include "../Common/dx11.h" //qloc: dx11



//**サンプラ
#ifdef _FRAGMENT_SHADER //X360の場合 VS/PS両方register(cN)を使うんでかぶるとエラーになる. 定義はMake_FS.bat
	#define SMP_REG(reg) register(reg)
#else //VertexShader
	#define SMP_REG(reg) reg
#endif

#ifdef _DX11 //qloc: dx11
	SAMPLER2D(gSMP_0, 0);	//テクスチャ０用サンプラ
	SAMPLER2D(gSMP_1, 1);	//テクスチャ１用サンプラ
	SAMPLER2D(gSMP_2, 2);	//テクスチャ２用サンプラ
	SAMPLER2D(gSMP_3, 3);	//テクスチャ３用サンプラ
	SAMPLER2D(gSMP_4, 4);	//テクスチャ４用サンプラ
	SAMPLER2D(gSMP_5, 5);	//テクスチャ５用サンプラ
	SAMPLER2D(gSMP_6, 6);	//テクスチャ６用サンプラ
	SAMPLERCMP2D(gSMP_7, 7);//QLOC: comparison sampler!
	SAMPLER2D(gSMP_8, 8);	//テクスチャ８用サンプラ
	SAMPLER2D(gSMP_9, 9);	//テクスチャ９用サンプラ
	SAMPLER2D(gSMP_10, 10);	//テクスチャ１０用サンプラ
//	SAMPLER2D(gSMP_11, 11);	//テクスチャ１１用サンプラ
//	SAMPLER2D(gSMP_12, 12);	//テクスチャ１２用サンプラ
//	SAMPLER2D(gSMP_13, 13);	//テクスチャ１３用サンプラ
//	SAMPLER2D(gSMP_14, 14);	//テクスチャ１４用サンプラ
	SAMPLER2D(gSMP_15, 15);	//テクスチャ１５用サンプラ

//	SAMPLERCUBE(gSMP_0_CUBE, 0);	//テクスチャ０用サンプラ
//	SAMPLERCUBE(gSMP_1_CUBE, 1);	//テクスチャ１用サンプラ
//	SAMPLERCUBE(gSMP_2_CUBE, 2);	//テクスチャ２用サンプラ
//	SAMPLERCUBE(gSMP_3_CUBE, 3);	//テクスチャ３用サンプラ
//	SAMPLERCUBE(gSMP_4_CUBE, 4);	//テクスチャ４用サンプラ
//	SAMPLERCUBE(gSMP_5_CUBE, 5);	//テクスチャ５用サンプラ
//	SAMPLERCUBE(gSMP_6_CUBE, 6);	//テクスチャ６用サンプラ
//	SAMPLERCUBE(gSMP_7_CUBE, 7);	//テクスチャ７用サンプラ
//	SAMPLERCUBE(gSMP_8_CUBE, 8);	//テクスチャ８用サンプラ
//	SAMPLERCUBE(gSMP_9_CUBE, 9);	//テクスチャ９用サンプラ
//	SAMPLERCUBE(gSMP_10_CUBE, 10);	//テクスチャ１０用サンプラ
	SAMPLERCUBE(gSMP_11_CUBE, 11);	//テクスチャ１１用サンプラ
	SAMPLERCUBE(gSMP_12_CUBE, 12);	//テクスチャ１２用サンプラ
#ifdef USE_SH
	SAMPLER3D(gSMP_13_3D, 13);	//テクスチャ１３用サンプラ
#else
	SAMPLERCUBE(gSMP_13_CUBE, 13);	//テクスチャ１３用サンプラ
#endif
	SAMPLERCUBE(gSMP_14_CUBE, 14);	//テクスチャ１４用サンプラ
//	SAMPLERCUBE(gSMP_15_CUBE, 15);	//テクスチャ１５用サンプラ
#else
	sampler2D gSMP_0 :SMP_REG(s0);	//テクスチャ０用サンプラ
	sampler2D gSMP_1 :SMP_REG(s1);	//テクスチャ１用サンプラ
	sampler2D gSMP_2 :SMP_REG(s2);	//テクスチャ２用サンプラ
	sampler2D gSMP_3 :SMP_REG(s3);	//テクスチャ３用サンプラ
	sampler2D gSMP_4 :SMP_REG(s4);	//テクスチャ４用サンプラ
	sampler2D gSMP_5 :SMP_REG(s5);	//テクスチャ５用サンプラ
	sampler2D gSMP_6 :SMP_REG(s6);	//テクスチャ６用サンプラ
	sampler2D gSMP_7 :SMP_REG(s7);	//テクスチャ７用サンプラ
	sampler2D gSMP_8 :SMP_REG(s8);	//テクスチャ８用サンプラ
	sampler2D gSMP_9 :SMP_REG(s9);	//テクスチャ９用サンプラ
	sampler2D gSMP_10 :SMP_REG(s10);	//テクスチャ１０用サンプラ
//	sampler2D gSMP_11 :SMP_REG(s11);	//テクスチャ１１用サンプラ
//	sampler2D gSMP_12 :SMP_REG(s12);	//テクスチャ１２用サンプラ
//	sampler2D gSMP_13 :SMP_REG(s13);	//テクスチャ１３用サンプラ
//	sampler2D gSMP_14 :SMP_REG(s14);	//テクスチャ１４用サンプラ
	sampler2D gSMP_15 :SMP_REG(s15);	//テクスチャ１５用サンプラ

//	samplerCUBE gSMP_0_CUBE :SMP_REG(s0);	//テクスチャ０用サンプラ
//	samplerCUBE gSMP_1_CUBE :SMP_REG(s1);	//テクスチャ１用サンプラ
//	samplerCUBE gSMP_2_CUBE :SMP_REG(s2);	//テクスチャ２用サンプラ
//	samplerCUBE gSMP_3_CUBE :SMP_REG(s3);	//テクスチャ３用サンプラ
//	samplerCUBE gSMP_4_CUBE :SMP_REG(s4);	//テクスチャ４用サンプラ
//	samplerCUBE gSMP_5_CUBE :SMP_REG(s5);	//テクスチャ５用サンプラ
//	samplerCUBE gSMP_6_CUBE :SMP_REG(s6);	//テクスチャ６用サンプラ
//	samplerCUBE gSMP_7_CUBE :SMP_REG(s7);	//テクスチャ７用サンプラ
//	samplerCUBE gSMP_8_CUBE :SMP_REG(s8);	//テクスチャ８用サンプラ
//	samplerCUBE gSMP_9_CUBE :SMP_REG(s9);	//テクスチャ９用サンプラ
//	samplerCUBE gSMP_10_CUBE :SMP_REG(s10);	//テクスチャ１０用サンプラ
	samplerCUBE gSMP_11_CUBE :SMP_REG(s11);	//テクスチャ１１用サンプラ
	samplerCUBE gSMP_12_CUBE :SMP_REG(s12);	//テクスチャ１２用サンプラ
#ifdef USE_SH
	sampler3D gSMP_13_3D :SMP_REG(s13);	//テクスチャ１３用サンプラ
#else
	samplerCUBE gSMP_13_CUBE :SMP_REG(s13);	//テクスチャ１３用サンプラ
#endif
	samplerCUBE gSMP_14_CUBE :SMP_REG(s14);	//テクスチャ１４用サンプラ
//	samplerCUBE gSMP_15_CUBE :SMP_REG(s15);	//テクスチャ１５用サンプラ
#endif

#define gSMP_DiffuseMap		gSMP_0	//ディフューズマップ用サンプラ
#define gSMP_SpecularMap	gSMP_1	//スペキュラマップ用サンプラ
#define gSMP_BumpMap		gSMP_2	//バンプマップ用サンプラ
#define gSMP_DiffuseMap2	gSMP_3	//ディフューズマップ用サンプラ
#define gSMP_SpecularMap2	gSMP_4	//スペキュラマップ用サンプラ
#define gSMP_BumpMap2		gSMP_5	//バンプマップ用サンプラ
#define gSMP_LightMap		gSMP_6	//ライトマップ用サンプラ
#define gSMP_LumTex			gSMP_6  //qloc - for reverse tonemap
#define gSMP_ShadowMap		gSMP_7	//シャドウマップ用サンプラ
#define gSMP_EnvMap			gSMP_12_CUBE	//環境マップ用サンプラ
#define gSMP_AOMap			gSMP_8	//QLOC: Ambient Occlusion map
#define gSMP_PBLMap			gSMP_1	//QLOC: reuse specular as PBL data
#define gSMP_PBLMap2		gSMP_4	//QLOC: reuse specular as PBL data
#define gSMP_Subsurf		gSMP_10	//QLOC: subsurface scattering parameters
#define gSMP_Height			gSMP_10	//QLOC: heightmap (reused subsurface scattering map)
//2010/08/30 nacheon ゴーストテクスチャスクロール削除 #define gSMP_GhostMap		gSMP_9	//ゴーストマップ用サンプラ
//2010/08/30 nacheon ゴーストテクスチャスクロール削除 #define gSMP_GhostMap2		gSMP_10	//ゴーストマップ用サンプラ
#define gSMP_EnvDifMap		gSMP_11_CUBE	//環境光源ディフューズマップ用サンプラ
#define gSMP_EnvSpcMap		gSMP_12_CUBE	//環境光源スペキュラマップ用サンプラ
#ifdef USE_SH
#define gSMP_SHMap			gSMP_13_3D		//環境光源ディフューズマップ用サンプラ
#else
#define gSMP_EnvDifMap2		gSMP_13_CUBE		//環境光源ディフューズマップ用サンプラ
#endif
#define gSMP_EnvSpcMap2		gSMP_14_CUBE	//環境光源スペキュラマップ用サンプラ
//#define gSMP_DitherMatrix	gSMP_15			//DitherMatrixマップ用サンプラ
#define gSMP_DetailBumpMap	gSMP_15			//DetailBumpマップ用サンプラ

#ifdef _DX11 //qloc
#define gSMP_DiffuseMapSampler		gSMP_0Sampler	//ディフューズマップ用サンプラ
#define gSMP_SpecularMapSampler		gSMP_1Sampler	//スペキュラマップ用サンプラ
#define gSMP_BumpMapSampler		gSMP_2Sampler	//バンプマップ用サンプラ
#define gSMP_DiffuseMap2Sampler		gSMP_3Sampler	//ディフューズマップ用サンプラ
#define gSMP_SpecularMap2Sampler	gSMP_4Sampler	//スペキュラマップ用サンプラ
#define gSMP_BumpMap2Sampler		gSMP_5Sampler	//バンプマップ用サンプラ
#define gSMP_LightMapSampler		gSMP_6Sampler	//ライトマップ用サンプラ
#define gSMP_ShadowMapSampler		gSMP_7Sampler	//シャドウマップ用サンプラ
#define gSMP_EnvMapSampler		gSMP_12_CUBESampler	//環境マップ用サンプラ
#define gSMP_AOMapSampler		gSMP_8Sampler	//QLOC: Ambient Occlusion map
#define gSMP_PBLMapSampler		gSMP_1Sampler	//QLOC: reuse specular as PBL data
#define gSMP_ShadowMapReadSampler	gSMP_9Sampler	//non-comparison shadow map sampler
#define gSMP_SubsurfMapSampler	gSMP_10Sampler	//QLOC: subsurface scattering parameters
//2010/08/30 nacheon ゴーストテクスチャスクロール削除 #define gSMP_GhostMap		gSMP_9	//ゴーストマップ用サンプラ
//2010/08/30 nacheon ゴーストテクスチャスクロール削除 #define gSMP_GhostMap2		gSMP_10	//ゴーストマップ用サンプラ
#define gSMP_EnvDifMapSampler		gSMP_11_CUBESampler	//環境光源ディフューズマップ用サンプラ
#define gSMP_EnvSpcMapSampler		gSMP_12_CUBESampler	//環境光源スペキュラマップ用サンプラ
#ifdef USE_SH
#define gSMP_SHMapSampler			gSMP_13_3DSampler	//環境光源ディフューズマップ用サンプラ
#else
#define gSMP_EnvDifMap2Sampler		gSMP_13_CUBESampler	//環境光源スペキュラマップ用サンプラ
#endif
#define gSMP_EnvSpcMap2Sampler		gSMP_14_CUBESampler	//環境光源スペキュラマップ用サンプラ
//#define gSMP_DitherMatrixSampler	gSMP_15Sampler			//DitherMatrixマップ用サンプラ
#define gSMP_DetailBumpMapSampler	gSMP_15Sampler			//DetailBumpマップ用サンプラ
#endif

#define gSMP_Reflection		gSMP_0	//反射マップ用サンプラ(とりあえず０番)
#define gSMP_Refraction		gSMP_1	//屈折マップ用サンプラ(とりあえず１番)
#define gSMP_WaterHeight	gSMP_2	//水面高さマップ用サンプラ(とりあえず２番)


























#endif //___FRPG_Flver_FRPG_Common_SMP_fxh___

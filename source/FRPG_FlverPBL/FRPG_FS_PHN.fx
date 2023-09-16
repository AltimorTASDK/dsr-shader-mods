/***************************************************************************//**

	@file		FRPG_FS_HemEnv.fx
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
#ifdef _PS3
	#define ENABLE_FS	//フラグメントシェーダ
#else //define展開の時にFRPG_Commonで定義されている関数で使われるコンスタントの宣言が必要
	#define ENABLE_VS	//バーテックスシェーダ
	#define ENABLE_FS	//フラグメントシェーダ
#endif

#include "FRPG_Common.fxh"



/*-------------------------------------------------------------------*//*!
@brief フラグメントシェーダ
*/



//#define WITH_BumpMap
//#define WITH_LightMap
//#define WITH_ShadowMap
	#include "FRPG_FS_HemEnv_Base.fxh"
//#undef WITH_BumpMap
//#undef WITH_LightMap
//#undef WITH_ShadowMap



#define WITH_BumpMap
//#define WITH_LightMap
//#define WITH_ShadowMap
	#include "FRPG_FS_HemEnv_Base.fxh"
#undef WITH_BumpMap
//#undef WITH_LightMap
//#undef WITH_ShadowMap



//#define WITH_BumpMap
#define WITH_LightMap
//#define WITH_ShadowMap
	#include "FRPG_FS_HemEnv_Base.fxh"
//#undef WITH_BumpMap
#undef WITH_LightMap
//#undef WITH_ShadowMap



#define WITH_BumpMap
#define WITH_LightMap
//#define WITH_ShadowMap
	#include "FRPG_FS_HemEnv_Base.fxh"
#undef WITH_BumpMap
#undef WITH_LightMap
//#undef WITH_ShadowMap



//#define WITH_BumpMap
//#define WITH_LightMap
#define WITH_ShadowMap CalcLispPos_VS
	#include "FRPG_FS_HemEnv_Base.fxh"
//#undef WITH_BumpMap
//#undef WITH_LightMap
#undef WITH_ShadowMap



#define WITH_BumpMap
//#define WITH_LightMap
#define WITH_ShadowMap CalcLispPos_VS
	#include "FRPG_FS_HemEnv_Base.fxh"
#undef WITH_BumpMap
//#undef WITH_LightMap
#undef WITH_ShadowMap



//#define WITH_BumpMap
#define WITH_LightMap
#define WITH_ShadowMap CalcLispPos_VS
	#include "FRPG_FS_HemEnv_Base.fxh"
//#undef WITH_BumpMap
#undef WITH_LightMap
#undef WITH_ShadowMap



#define WITH_BumpMap
#define WITH_LightMap
#define WITH_ShadowMap CalcLispPos_VS
	#include "FRPG_FS_HemEnv_Base.fxh"
#undef WITH_BumpMap
#undef WITH_LightMap
#undef WITH_ShadowMap



//#define WITH_BumpMap
//#define WITH_LightMap
#define WITH_ShadowMap CalcLispPos_PS
	#include "FRPG_FS_HemEnv_Base.fxh"
//#undef WITH_BumpMap
//#undef WITH_LightMap
#undef WITH_ShadowMap



#define WITH_BumpMap
//#define WITH_LightMap
#define WITH_ShadowMap CalcLispPos_PS
	#include "FRPG_FS_HemEnv_Base.fxh"
#undef WITH_BumpMap
//#undef WITH_LightMap
#undef WITH_ShadowMap



//#define WITH_BumpMap
#define WITH_LightMap
#define WITH_ShadowMap CalcLispPos_PS
	#include "FRPG_FS_HemEnv_Base.fxh"
//#undef WITH_BumpMap
#undef WITH_LightMap
#undef WITH_ShadowMap



#define WITH_BumpMap
#define WITH_LightMap
#define WITH_ShadowMap CalcLispPos_PS
	#include "FRPG_FS_HemEnv_Base.fxh"
#undef WITH_BumpMap
#undef WITH_LightMap
#undef WITH_ShadowMap









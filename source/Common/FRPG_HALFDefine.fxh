/***************************************************************************//**

	@file		DS_HALFDefine.fxh
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
#ifndef ___DEMONSSOUL_DS_Shader_HALFDefine_fxh___
#define ___DEMONSSOUL_DS_Shader_HALFDefine_fxh___


//QLOC: disable float usage, we want full float
//#define	DS_USE_HALF

#if		defined( DS_USE_HALF )

#define		HALF				half

#define		HALF1				half1
#define		HALF2				half2
#define		HALF3				half3
#define		HALF4				half4

#define		HALF1x1				half1x1
#define		HALF2x1				half2x1
#define		HALF3x1				half3x1
#define		HALF4x1				half4x1

#define		HALF1x2				half1x2
#define		HALF2x2				half2x2
#define		HALF3x2				half3x2
#define		HALF4x2				half4x2

#define		HALF1x3				half1x3
#define		HALF2x3				half2x3
#define		HALF3x3				half3x3
#define		HALF4x3				half4x3

#define		HALF1x4				half1x4
#define		HALF2x4				half2x4
#define		HALF3x4				half3x4
#define		HALF4x4				half4x4


#else

//	float扱いにするバージョン

#define		HALF				float

#define		HALF1				float1
#define		HALF2				float2
#define		HALF3				float3
#define		HALF4				float4

#define		HALF1x1				float1x1
#define		HALF2x1				float2x1
#define		HALF3x1				float3x1
#define		HALF4x1				float4x1

#define		HALF1x2				float1x2
#define		HALF2x2				float2x2
#define		HALF3x2				float3x2
#define		HALF4x2				float4x2

#define		HALF1x3				float1x3
#define		HALF2x3				float2x3
#define		HALF3x3				float3x3
#define		HALF4x3				float4x3

#define		HALF1x4				float1x4
#define		HALF2x4				float2x4
#define		HALF3x4				float3x4
#define		HALF4x4				float4x4


#endif


#endif	//___DEMONSSOUL_DS_Shader_HALFDefine_fxh___

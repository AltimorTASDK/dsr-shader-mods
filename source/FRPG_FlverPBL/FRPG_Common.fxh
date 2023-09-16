/***************************************************************************//**

	@file		FRPG_Common.fxh
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
#ifndef ___FRPG_Flver_FRPG_Common_fxh___
#define ___FRPG_Flver_FRPG_Common_fxh___

#ifdef _PS3
#define _PS3_	//PS3
#endif

#ifdef _X360
#define _Xenon_	//Xbox360
#endif

#ifdef _WIN32
#define _WIN32_ //Windows
#endif

#if defined(_ORBIS) && defined(_NEO) // QLOC: 4k checkerboard rendering, this will increase texture quality when rendering checkerboarded - MPursche
#pragma argument(gradientadjust=always)
#pragma argument(barycentricmode=sample)
#pragma argument(nofastmath)
#endif






//**バーテックスシェーダ定数
#ifdef ENABLE_VS
	#include "FRPG_Common_VC.fxh"
#endif




//**フラグメントシェーダ定数
#ifdef ENABLE_FS
	#include "FRPG_Common_FC.fxh"
#endif

#include "../Common/dx11.h" //qloc: dx11
#include "../Common/FRPG_HALFDefine.fxh"


#if defined(_PS3_)//PS3
#elif defined(_Xenon_)//XBOX360
#elif defined(_WIN32_)//WIN32
	//2012.02.17:itoj>ワーニング無効化//warning X3205: conversion from larger type to smaller, possible loss of data
	//#pragma warning( disable : 3205 3205 )
	#pragma warning( once : 3205 )
	//#pragma warning( error : 3205 )
#else
	不明
#endif

#define MAX_POINT_LIGHTS 4
#define MAX_DIR_LIGHTS 3


#define SHADOWMAP_ENABLE
#define CLIPPLANE_ENABLE

// トーンマップをリニアで行う(0～Rangeでトーンマップする)
// Rangeを越える明るさは表現できない
// 0にすると、ノンリニアな式でトーンマッピングする(無限大の明るさも表現できる)
#define	TONEMAP_LINEAR_VER		1


//PS3用リマップフォーマットを使用する場合は「PS3_NORMAL_REMAP」を#defineしてください
#define PS3_NORMAL_REMAP


//2012.01.04:itoj>廃止
////バーテックスシェーダでライトスキャッタリングを処理する場合は「VSLS」を#defineしてください
////#define VSLS


//バーテックスシェーダで従法線を求める場合は「CALC_VS_BINORMAL」を#defineしてください
#define CALC_VS_BINORMAL
#ifdef _WIN32
#ifndef _DX11 //qloc: removed in dx11
	#undef CALC_VS_BINORMAL//Win32ではバーテックスシェーダで求めても出力レジスタが足りない
#endif
#endif//_WIN32

#define EMISSIVE_STRENGTH 10.f //qloc


//ShadowMapでの位置をどこで計算するか
#define CalcLispPos_VS 1
#define CalcLispPos_PS 2

#define CalcLispPos_PS_Csd 2
#define CalcLispPos_PS_NoCsd 3

//**バーテックスシェーダ入力
#ifdef ENABLE_VS
	#include "FRPG_Common_VTX_IN.fxh"
#endif


//**バーテックスシェーダ出力
#include "FRPG_Common_VTX_OUT.fxh"


//**フラグメントシェーダ出力
#ifdef ENABLE_FS
	//!フラグメントシェーダ出力
	struct GBUFFER_OUT
	{
		float4 GBuffer0 : SV_Target0;
		float4 GBuffer1 : SV_Target1; //qloc: subsurface scattering strength. We don't seem to ever modify it so it might be a good idea to move it to the stencil
	};
	//!フラグメントシェーダ出力
	struct FRAGMENT_OUT
	{
		float4 Color : SV_Target0;
	};
	//qloc
	struct PS_OUT_SFX
	{
		float4 Color : SV_Target0;
		float4 Glow : SV_Target1;
	};
#endif



//**サンプラ
#ifdef ENABLE_FS
	#include "FRPG_Common_SMP.fxh"
#endif

#ifdef ENABLE_FS
	#include "FRPG_Common_ForwardPBL.fxh"
#endif




//**点光源用定義
#define POINT_LIGHT_TYPE_None 0	//!<なし
#define POINT_LIGHT_TYPE_Distance 1	//!<距離減衰
#define POINT_LIGHT_TYPE_Diffuse 2	//!<ディフューズ＋距離減衰
#define POINT_LIGHT_TYPE_Specular 3	//!<スペキュラ＋ディフューズ＋距離減衰
//点光源を有効にする場合は,以下の設定を#undefして上の設定を行ってください
#define POINT_LIGHT_0 POINT_LIGHT_TYPE_None	//!<点光源０
#define POINT_LIGHT_1 POINT_LIGHT_TYPE_None	//!<点光源１
#define POINT_LIGHT_2 POINT_LIGHT_TYPE_None	//!<点光源２
#define POINT_LIGHT_3 POINT_LIGHT_TYPE_None	//!<点光源３




// 計算後のカラーをフレームバッファに出力する形式に変換するマクロ
//QLOC: removed tonemapping from base shader - it will be reapplied in the PostFX
#ifdef _DX11 //qloc: apply alpha test
	//#define			FS_FINAL_COLOR(col)			(qlocDoAlphaTest(col))
	#define			FS_FINAL_COLOR(col)			(qlocDoAlphaTest(ToneMap_FS(col)))
	//#define			FS_FINAL_COLOR( col )		(qlocDoAlphaTest( col * gFC_ColorRangeScale ))
#else
	//#define			FS_FINAL_COLOR(col)			(col)
	#define			FS_FINAL_COLOR(col)			(ToneMap_FS(col))
	//#define			FS_FINAL_COLOR( col )		( col * gFC_ColorRangeScale )
#endif


#ifdef _PS3
#define			FRPG_H4Tex2D(tex, coord)			h4tex2D(tex, coord)
#define			FRPG_H2Tex2D(tex, coord)			h2tex2D(tex, coord)
#else
#define			FRPG_H4Tex2D(tex, coord)			tex2D(tex, coord)
#define			FRPG_H2Tex2D(tex, coord)			(tex2D(tex, coord).xy)
#endif

#define WITH_DETAILBUMP
#ifdef WITH_DETAILBUMP
	#define APPLY_DETAIL_BUMP_TAN( pixNrm, vecTan, texUv )	pixNrm = ApplyDetailBump( texUv, pixNrm, vecTan )
	#define APPLY_DETAIL_BUMP( pixNrm, texUv )	pixNrm = ApplyDetailBump( texUv, pixNrm )
#else
	#define APPLY_DETAIL_BUMP_TAN( pixNrm, vecTan, texUv )
	#define APPLY_DETAIL_BUMP( pixNrm, texUv )
#endif

#define FRPG_CLAMP(_x, _fmin, _fmax) max(_fmin, min(_x, _fmax))

/*-------------------------------------------------------------------*//*!
@brief トーンマップ圧縮する
@param[in] col カラー
@return トーンマップ圧縮したカラー(アルファ値は変わりません)
@par
*/
float4
ToneMap_FS(float4 col)
{
	// 露光スケール
	col.rgb *= gFC_ToneMap.x;

	// トーンマップ
#if TONEMAP_LINEAR_VER
	col.rgb /= gFC_ToneMap.y;
	col.rgb = saturate(col.rgb);
#else
	col.rgb /= (gFC_ToneMap.y+col.rgb);
#endif

	return col;
}


/*-------------------------------------------------------------------*//*!
@brief 視線ベクトルを算出して取得(バーテックスシェーダ側)
@param[in] vecPos 頂点座標(ワールド空間)
@param[in] camPos カメラ座標(ワールド空間)
@return 視線ベクトル(ワールド空間)(xyz:非正規化頂点→カメラベクトル, w:0.0)
@par
	頂点→カメラ距離を格納してもw=0を挟んだときに補間が正しく動作しないので格納しません.<br>
	そのため,視線ベクトルは正規化せずに格納しておき,フラグメントシェーダ側で正規化＆距離の算出を行います.<br>
*/
float4
CalcGetVecEye_VS(float4 vecPos, float4 camPos)
{
	float4 vecEye;
	vecEye.xyz = camPos.xyz - vecPos.xyz;	//頂点からカメラへのベクトル(ワールド空間)
	vecEye.w = 0.0f;	//0.0
	return vecEye;
}
/*-------------------------------------------------------------------*//*!
@brief 視線ベクトルを算出して取得(フラグメントシェーダ側)
@param[in] vsVecEye バーテックスシェーダで求めた視線ベクトル
@return 視線ベクトル(ワールド空間)(xyz:正規化頂点→カメラベクトル, w:頂点→カメラ距離)
@par
	バーテックスシェーダ側で求められなかった距離を求めて,ベクトルの正規化も行います.<br>
*/
float4
CalcGetVecEye_FS(float4 vsVecEye)
{
	float4 vecEye;
	vecEye.w = length(vsVecEye.xyz);	//頂点からカメラへの距離
	vecEye.xyz = vsVecEye.xyz / vecEye.w;	//正規化
	return vecEye;
}


/*-------------------------------------------------------------------*//*!
@brief 法線テクスチャから法線算出デコード
@param[in] normalTexSmp 法線テクスチャのサンプラ
@param[in] texUv テクスチャUV
@return デコードされた法線 //正規化済み
@par
*/
float3
DecodeNormalMap(TEX2DSAMPLERDECL(normalTexSmp), float2 texUv)
{
	HALF3 vecTex;
	#ifdef PS3_NORMAL_REMAP//PS3用リマップフォーマット、360のCTX1,DXNはPS3_NORMAL_REMAPのデコード
		vecTex.xy = FRPG_H2Tex2D(normalTexSmp, texUv) * 2.0f - 1.0f; //テクスチャ法線をデコード
	#else//PS3_NORMAL_REMAP//通常フォーマット
		//テクスチャ法線のデコード処理
		//DXT1エンコード：(r,g,b,a) = (x, y, 1, 1)
		//DXT5エンコード：(r,g,b,a) = (1, y, 1, x)
		//テクスチャのフォーマットによってエンコードが異なるが
		//(X, Y, Z) = (r*a, g, Z), Z = sqrt(1-X*X-Y*Y)
		//で生成することでフォーマットの違いは無視できる
		HALF4 colTex = FRPG_H4tex2D(normalTexSmp, texUv);	//法線テクスチャをサンプリング
		vecTex.xy = colTex.rg * colTex.ab * 2.0f - 1.0f;	//テクスチャ法線をデコード
	#endif//PS3_NORMAL_REMAP
	vecTex.z = sqrt(1.0f - saturate(dot(vecTex.xy, vecTex.xy)));
	//vecTex = normalize(vecTex); //無用
	return vecTex;
}

/*-------------------------------------------------------------------*//*!
@brief Detail Bump 適用 Tangent Binormal あり版
@param[in] texUv テクスチャUV
@param[in] normal //正規化済み
@param[in] tangent //正規化済み
@param[in] binormal //正規化済み
@return Detail Bump反映法線
@par
*/
HALF3
_ApplyDetailBump(float2 texUv, HALF3 vecNrm, HALF3 vecTan, HALF3 vecBin)
{
	HALF3 detailBump = DecodeNormalMap(TEX2DSAMPLER(gSMP_DetailBumpMap), (texUv*gFC_DetailBumpParam.xx) );
	detailBump.xy *= gFC_DetailBumpParam.w;
	detailBump.z += (dot(detailBump.xy,detailBump.xy) < 0.00001f); //Zero Devideの回避 detailBump.zがマイナスにはならない
	detailBump = normalize(detailBump);//正規化

	HALF3 pixDNormal = normalize(vecBin*detailBump.x+vecTan*detailBump.y+vecNrm*detailBump.z);
	return pixDNormal;
}

/*-------------------------------------------------------------------*//*!
@brief Detail Bump 適用　あり版
@param[in] texUv テクスチャUV
@param[in] normal //正規化済み
@param[in] tangent　//正規化済み
@return Detail Bump反映法線
@par
*/
HALF3
ApplyDetailBump(float2 texUv, HALF3 vecNrm, HALF4 vecTan)
{
	HALF3 vecBin = normalize(cross(vecNrm, vecTan.xyz))*vecTan.w;
	vecTan.xyz = normalize(cross(vecBin, vecNrm));

	return _ApplyDetailBump(texUv, vecNrm, vecTan.xyz, vecBin);
}


/*-------------------------------------------------------------------*//*!
@brief Detail Bump 適用 Tangent　なし版
@param[in] texUv テクスチャUV
@param[in] normal //正規化済み
@return Detail Bump反映法線
@par
*/
HALF3
ApplyDetailBump(float2 texUv, HALF3 vecNrm)
{
	HALF3 vecBin = vecNrm.zyx;
	HALF3 vecTan = vecNrm.xzy;

	return _ApplyDetailBump(texUv, vecNrm, vecTan, vecBin);
}


/*-------------------------------------------------------------------*//*!
@brief 法線テクスチャから法線算出
@param[in] normalTexSmp 法線テクスチャのサンプラ
@param[in] texUv テクスチャUV
@param[in] vecNrm 主法線
@param[in] vecTan 接線(w:従法線の向き)
@return 法線
@par
	主法線戦と接線から従法線を求めます.<br>
	主法線と接線は正規化されていなくてかまいません(内部で正規化します).<br>
	vecTan.wは求まった従法線に掛けます.<br>
*/
HALF3
CalcGetNormal_FromNormalTex(TEX2DSAMPLERDECL(normalTexSmp), float2 texUv, HALF3 vecNrm, HALF4 vecTan)
{
	HALF3 vecTex = DecodeNormalMap(TEX2DSAMPLER(normalTexSmp), texUv);

	//主法線,接線,従法線のデコード処理
	vecNrm = normalize(vecNrm);			//normal normalize
	vecTan.xyz = normalize(vecTan.xyz);	//tangent normalize

	HALF3 vecBin = normalize(cross(vecNrm, vecTan.xyz) * vecTan.w);//従法線を生成(In.VecTan.wは従法線の向き)
	/*丁寧にやるならここで接線を再計算*/
	//	vecTan.xyz = cross(vecBin, vecNrm) * vecTan.w;//接線を再計算
	/**/

	//テクスチャ法線と主法線,接線,従法線から最終法線を算出
	HALF3 pixNrm = normalize(vecBin*vecTex.x + vecTan.xyz*vecTex.y + vecNrm*vecTex.z);

	APPLY_DETAIL_BUMP_TAN(pixNrm, vecTan, texUv );
	return pixNrm;
}

/*-------------------------------------------------------------------*//*!
brief 法線テクスチャから法線算出 マルチ用
@param[in] normalTexSmp 法線テクスチャのサンプラ
@param[in] texUv テクスチャUV+UV2
@param[in] vecNrm 主法線
@param[in] vecTan 接線(w:従法線の向き)
@param[in] vecTan2 接線(w:従法線の向き)
@return 法線
@par
	主法線戦と接線から従法線を求めます.<br>
	主法線と接線は正規化されていなくてかまいません(内部で正規化します).<br>
	vecTan.wは求まった従法線に掛けます.<br>
*/
HALF3
CalcGetNormal_FromNormalTex_Mul(TEX2DSAMPLERDECL(normalTexSmp), TEX2DSAMPLERDECL(normalTexSmp2), float4 texUv, HALF3 vecNrm, HALF4 vecTan, HALF4 vecTan2, HALF blendRate)
{
	HALF3 vecTex = DecodeNormalMap(TEX2DSAMPLER(normalTexSmp), texUv.xy);
	HALF3 vecTex2 = DecodeNormalMap(TEX2DSAMPLER(normalTexSmp2), texUv.zw);

	//主法線,接線,従法線のデコード処理
	vecNrm = normalize(vecNrm);			//normal normalize
	vecTan.xyz = normalize(vecTan.xyz);	//tangent normalize
	vecTan2.xyz = normalize(vecTan2.xyz);	//tangent normalize

	HALF3 vecBin = normalize(cross(vecNrm, vecTan.xyz) * vecTan.w);//従法線を生成(In.VecTan.wは従法線の向き)
	HALF3 vecBin2 = normalize(cross(vecNrm, vecTan2.xyz) * vecTan2.w);//従法線を生成(In.VecTan.wは従法線の向き)
	/*丁寧にやるならここで接線を再計算*/
	//	vecTan.xyz = cross(vecBin, vecNrm) * vecTan.w;//接線を再計算
	/**/

	//テクスチャ法線と主法線,接線,従法線から最終法線を算出
	HALF3 vecNrmA = normalize(vecBin*vecTex.x + vecTan.xyz*vecTex.y + vecNrm*vecTex.z);
	HALF3 vecNrmB = normalize(vecBin2*vecTex2.x + vecTan.xyz*vecTex2.y + vecNrm*vecTex2.z);

	HALF3 pixNrm = normalize(lerp(vecNrmA, vecNrmB, blendRate));	//法線をブレンド

	APPLY_DETAIL_BUMP_TAN(pixNrm, vecTan, texUv.xy );
	return pixNrm;
}


/*-------------------------------------------------------------------*//*!
@brief 法線テクスチャから法線算出
@param[in] normalTexSmp 法線テクスチャのサンプラ
@param[in] texUv テクスチャUV
@param[in] vecNrm 主法線
@param[in] vecTan 接線(w:従法線の向き)
@return 法線
@par
	主法線戦と接線から従法線を求めます.<br>
	主法線と接線は正規化されていなくてかまいません(内部で正規化します).<br>
	vecTan.wは求まった従法線に掛けます.<br>
*/
HALF3
CalcGetNormal_FromNormalTex_Bin(TEX2DSAMPLERDECL(normalTexSmp), float2 texUv, HALF3 vecNrm, HALF4 vecTan, HALF3 vecBin)
{
	HALF3 vecTex = DecodeNormalMap(TEX2DSAMPLER(normalTexSmp), texUv);

	//主法線,接線,従法線のデコード処理
	vecNrm = normalize(vecNrm);			//normal normalize
	vecTan.xyz = normalize(vecTan.xyz);	//tangent normalize

	vecBin = normalize(vecBin); //正規化

	/*丁寧にやるならここで接線を再計算*/
	//	vecTan.xyz = cross(vecBin, vecNrm) * vecTan.w;//接線を再計算
	/**/

	vecTex = lerp(float3(0,0,1), vecTex, gFC_NormalScale);

	//テクスチャ法線と主法線,接線,従法線から最終法線を算出
	HALF3 pixNrm = normalize(vecBin*vecTex.x + vecTan.xyz*vecTex.y + vecNrm*vecTex.z);

	APPLY_DETAIL_BUMP_TAN(pixNrm, vecTan, texUv );
	return pixNrm;
}

/*-------------------------------------------------------------------*//*!
brief 法線テクスチャから法線算出 マルチ用
@param[in] normalTexSmp 法線テクスチャのサンプラ
@param[in] texUv テクスチャUV+UV2
@param[in] vecNrm 主法線
@param[in] vecTan 接線(w:従法線の向き)
@param[in] vecTan2 接線(w:従法線の向き)
@return 法線
@par
	主法線戦と接線から従法線を求めます.<br>
	主法線と接線は正規化されていなくてかまいません(内部で正規化します).<br>
	vecTan.wは求まった従法線に掛けます.<br>
*/
HALF3
CalcGetNormal_FromNormalTex_Mul_Bin(TEX2DSAMPLERDECL(normalTexSmp), TEX2DSAMPLERDECL(normalTexSmp2), float4 texUv, HALF3 vecNrm, HALF4 vecTan, HALF4 vecTan2, HALF3 vecBin, HALF3 vecBin2, HALF blendRate)
{
	HALF3 vecTex = DecodeNormalMap(TEX2DSAMPLER(normalTexSmp), texUv.xy);
	HALF3 vecTex2 = DecodeNormalMap(TEX2DSAMPLER(normalTexSmp2), texUv.zw);

	//主法線,接線,従法線のデコード処理
	vecNrm = normalize(vecNrm);			//normal normalize
	vecTan.xyz = normalize(vecTan.xyz);	//tangent normalize
	vecTan2.xyz = normalize(vecTan2.xyz);	//tangent normalize

	vecBin = normalize(vecBin); //正規化
	vecBin2 = normalize(vecBin2); //正規化

	/*丁寧にやるならここで接線を再計算*/
	//	vecTan.xyz = cross(vecBin, vecNrm) * vecTan.w;//接線を再計算
	/**/
	vecTex = lerp(float3(0, 0, 1), vecTex, gFC_NormalScale);
	vecTex2 = lerp(float3(0, 0, 1), vecTex2, gFC_NormalScale);

	//テクスチャ法線と主法線,接線,従法線から最終法線を算出
	HALF3 vecNrmA = normalize(vecBin*vecTex.x + vecTan.xyz*vecTex.y + vecNrm*vecTex.z);
	HALF3 vecNrmB = normalize(vecBin2*vecTex2.x + vecTan.xyz*vecTex2.y + vecNrm*vecTex2.z);

	HALF3 pixNrm = normalize(lerp(vecNrmA, vecNrmB, blendRate));	//法線をブレンド

	APPLY_DETAIL_BUMP_TAN(pixNrm, vecTan, texUv.xy );
	return pixNrm;
}





/*-------------------------------------------------------------------*//*!
@brief 半球ライト色を算出して取得
@param[in] hemLightCol_u 上半球色
@param[in] hemLightCol_d 下半球色
@param[in] lerpRate 0.0:hemLightCol_d ~ 1.0:hemLightCol_d
@return 半球ライト色
@par
	法線のy成分で出力色を求めます.<br>
*/
float3
CalcGetHemLightCol(float3 hemLightCol_u, float3 hemLightCol_d, float lerpRate)
{
	return lerp(hemLightCol_d, hemLightCol_u, lerpRate);
}




/*-------------------------------------------------------------------*//*!
@brief 平行光源ディフューズライト色を算出して取得(平行光源１本のみ)
@param[in] vecNrm 法線(正規化済み)
@param[in] vecLightA 平行光源Aの方向(正規化済み)
@param[in] colLightA 平行光源Aの色
@return 平行光源ディフューズライト色
@par
*/
float3
CalcGetDirDifLightCol_1(float3 vecNrm, float3 vecLightA, float3 colLightA)
{
	return colLightA*max(-dot(vecLightA.xyz, vecNrm), 0.0f);
}
/*-------------------------------------------------------------------*//*!
@brief 平行光源ディフューズライト色を算出して取得
@param[in] vecNrm 法線(正規化済み)
@param[in] vecLightA 平行光源Aの方向(正規化済み)
@param[in] vecLightB 平行光源Bの方向(正規化済み)
@param[in] vecLightC 平行光源Cの方向(正規化済み)
@param[in] colLightA 平行光源Aの色
@param[in] colLightB 平行光源Bの色
@param[in] colLightC 平行光源Cの色
@return 平行光源ディフューズライト色
@par
*/
float3
CalcGetDirDifLightCol(float3 vecNrm, float3 vecLightA, float3 vecLightB, float3 vecLightC, float3 colLightA, float3 colLightB, float3 colLightC)
{
	return colLightA*max(-dot(vecLightA.xyz, vecNrm), 0.0f)
	     + colLightB*max(-dot(vecLightB.xyz, vecNrm), 0.0f)
	     + colLightC*max(-dot(vecLightC.xyz, vecNrm), 0.0f);
}




/*-------------------------------------------------------------------*//*!
@brief 反射視点ベクトルを算出して取得
@param[in] vecNrm 法線(正規化済み)
@param[in] vecEye 視線方向ベクトル(正規化済み)
@return 反射視点ベクトル
@par
	vecEyeは頂点から視点へのベクトルです.<br>
*/
float3
CalcGetDirSpcLightCol(float3 vecNrm, float3 vecEye)
{
	return -vecEye + 2.0f * dot( vecNrm, vecEye ) * vecNrm;	//法線で反転した視線ベクトル
}

/*-------------------------------------------------------------------*//*!
@brief 平行光源スペキュラライト色を算出して取得(平行光源１本のみ)
@param[in] vecRef 反射視線方向ベクトル(正規化済み)
@param[in] spcParam スペキュラパラメータ
@param[in] vecLightA 平行光源Aの方向(正規化済み)
@param[in] colLightA 平行光源Aの色
@return 平行光源スペキュラライト色
@par
	vecEyeは頂点から視点へのベクトルです.<br>
*/
float3
CalcGetDirSpcLightCol_1(float3 vecRef, float4 spcParam, float3 vecLightA, float3 colLightA)
{
	float spcInt;	//スペキュラの強さ
	spcInt = -dot(vecRef, vecLightA);
	spcInt = pow(max(spcInt, 0.0f), spcParam.x);

	return colLightA*spcInt;
}

/*-------------------------------------------------------------------*//*!
@brief 平行光源スペキュラライト色を算出して取得
@param[in] vecRef 反射視線方向ベクトル(正規化済み)
@param[in] spcParam スペキュラパラメータ
@param[in] vecLightA 平行光源Aの方向(正規化済み)
@param[in] vecLightB 平行光源Bの方向(正規化済み)
@param[in] vecLightC 平行光源Cの方向(正規化済み)
@param[in] colLightA 平行光源Aの色
@param[in] colLightB 平行光源Bの色
@param[in] colLightC 平行光源Cの色
@return 平行光源スペキュラライト色
*/
float3
CalcGetDirSpcLightCol(float3 vecRef, float4 spcParam, float3 vecLightA, float3 vecLightB, float3 vecLightC, float3 colLightA, float3 colLightB, float3 colLightC)
{
	float3 spcInt;	//スペキュラの強さ
	spcInt.x = -dot(vecRef, vecLightA);
	spcInt.y = -dot(vecRef, vecLightB);
	spcInt.z = -dot(vecRef, vecLightC);
	spcInt = pow(max(spcInt, 0.0f), spcParam.x);

	return colLightA*spcInt.x + colLightB*spcInt.y + colLightC*spcInt.z;
}




/*-------------------------------------------------------------------*//*!
@brief 環境光源ディフューズライト色を算出して取得
@param[in] vecNrm 法線(正規化済み)
@param[in] envLightTexSmp 環境光源テクスチャサンプラ
@return 環境光源ディフューズライト色
@par
*/
float3
CalcGetEnvDifLightCol(float3 vecNrm, TEXCUBESAMPLERDECL(envLightTexSmp))
{
//	return texCUBE(envLightTexSmp, vecNrm).rgb;
	float4 col = texCUBE(envLightTexSmp, vecNrm);// , gFC_LightProbeSlot);
//	return (col.rgb / col.a); //col.rgb/max(col.a, 1.f/255.f);
	return col.rgb; //col.rgb/max(col.a, 1.f/255.f);
}

/*-------------------------------------------------------------------*//*!
@brief 環境光源スペキュラライト色を算出して取得
@param[in] vecRef 反射視線方向ベクトル(正規化済み)
@param[in] envLightTexSmp 環境光源テクスチャサンプラ
@return 環境光源スペキュラライト色
*/
float3
CalcGetEnvSpcLightCol(float3 vecRef, TEXCUBESAMPLERDECL(envLightTexSmp))
{
//	return texCUBE(envLightTexSmp, vecRef).rgb;
	float4 col = texCUBE(envLightTexSmp, vecRef);// , gFC_LightProbeSlot);
//	return (col.rgb / col.a); //col.rgb/max(col.a, 1.f/255.f);
	return col.rgb; //col.rgb/max(col.a, 1.f/255.f);
}




/*-------------------------------------------------------------------*//*!
@brief 点光源距離減衰色を算出して取得
@param[in] vecVtx 頂点座標(ワールド空間)
@param[in] pntLitPos 点光源位置(xyz:位置, w:1/(減衰終了距離-減衰開始距離))(ワールド空間)
@param[in] pntLitCol 点光源色(rgb:色, a:減衰終了距離)
@return 点光源距離減衰色
@par
*/
float3
CalcGetPntLengthLightCol(float3 vecVtx, float4 pntLitPos, float4 pntLitCol)
{
	const float len = length(pntLitPos.xyz - vecVtx);	//頂点→点光源への距離
	return pntLitCol.rgb * saturate((pntLitCol.w-len)*pntLitPos.w);
}


/*-------------------------------------------------------------------*//*!
@brief 点光源の方向と減衰係数を算出して取得
@param[in] vecVtx 頂点座標(ワールド空間)
@param[in] pntLitPos 点光源位置(xyz:位置, w:1/(減衰終了距離-減衰開始距離))(ワールド空間)
@param[in] pntLitCol 点光源色(rgb:色, a:減衰終了距離)
@return 点光源の方向と減衰係数(xyz:点光源の方向(正規化済み), w:減衰係数)
@par
*/
float4
CalcGetVecPnt(float3 vecVtx, float4 pntLitPos, float4 pntLitCol)
{
	float4 vecPnt;
	vecPnt.xyz = pntLitPos.xyz - vecVtx;	//頂点→点光源へのベクトル
	vecPnt.w = length(vecPnt.xyz);	//頂点→点光源への距離
	vecPnt.xyz /= vecPnt.w;	//頂点→点光源へのベクトルを正規化
	vecPnt.w = saturate((pntLitCol.w-vecPnt.w)*pntLitPos.w);
	return vecPnt;
}


/*-------------------------------------------------------------------*//*!
@brief 点光源ディフューズライト色を算出して取得
@param[in] vecNrm 法線(正規化済み)
@param[in] vecPnt 点光源の方向(xyz:頂点→光源)(正規化済み)
@param[in] colPnt 点光源の色(rgb:色)(減衰済)
@return 点光源ディフューズライト色
@par
*/
float3
CalcGetPntDifLightCol(float3 vecNrm, float3 vecPnt, float3 colPnt)
{
	return colPnt*max(dot(vecPnt.xyz, vecNrm), 0.0f);
}


/*-------------------------------------------------------------------*//*!
@brief 点光源スペキュラライト色を算出して取得
@param[in] vecRef 反射視線方向ベクトル(正規化済み)
@param[in] spcParam スペキュラパラメータ
@param[in] vecPnt 点光源の方向(xyz:頂点→光源)(正規化済み)
@param[in] colPnt 点光源の色(rgb:色)(減衰済)
@return 点光源スペキュラライト色
@par
	vecEyeは頂点から視点へのベクトルです.<br>
*/
float3
CalcGetPntSpcLightCol(float3 vecRef, float4 spcParam, float3 vecPnt, float3 colPnt)
{
	float spcInt;	//スペキュラの強さ
	spcInt = dot(vecRef, vecPnt);
	spcInt = pow(max(spcInt, 0.0f), spcParam.x);

	return colPnt*spcInt;
}


/*-------------------------------------------------------------------*//*!
@brief ゴーストライト源の方向と減衰係数を算出して取得
@param[in] vecVtx 頂点座標(ワールド空間)
@return ゴーストライト源の方向と減衰係数(xyz:光源の方向(正規化済み), w:減衰係数)
@par
*/
float4
CalcGetGhostLightVec(float3 vecVtx)
{
	//@param[in] gFC_GhostLightPos 光源位置(xyz:位置, w:1/(減衰終了距離-減衰開始距離))(ワールド空間)
	//@param[in] gFC_GhostLightCol 光源色(rgb:色, a:減衰終了距離)

	float4 vecPnt;
	vecPnt.xyz = gFC_GhostLightPos.xyz - vecVtx;	//頂点→点光源へのベクトル
	vecPnt.w = length(vecPnt.xyz);	//頂点→点光源への距離
	vecPnt.xyz /= vecPnt.w;	//頂点→点光源へのベクトルを正規化
	vecPnt.w = saturate((gFC_GhostLightCol.w-vecPnt.w)*gFC_GhostLightPos.w);
	return vecPnt;
}


/*-------------------------------------------------------------------*//*!
@brief ゴーストライトディフューズライト色を算出して取得
@param[in] vecNrm 法線(正規化済み)
@param[in] vecPnt 点光源の方向(xyz:頂点→光源)(正規化済み)
@param[in] colPnt 点光源の色(rgb:色)(減衰済)
@return ゴーストライトディフューズライト色
@par
*/
float3
CalcGetGhostLightDifLightCol(float3 vecNrm, float3 vecPnt, float3 colPnt)
{
	return colPnt*max(dot(vecPnt.xyz, vecNrm), 0.0f);
}


/*-------------------------------------------------------------------*//*!
@brief ゴーストライトスペキュラライト色を算出して取得
@param[in] vecRef 反射視線方向ベクトル(正規化済み)
@param[in] spcParam スペキュラパラメータ
@param[in] vecPnt ゴーストライトの方向(xyz:頂点→光源)(正規化済み)
@param[in] colPnt ゴーストライトの色(rgb:色)(減衰済)
@return ゴーストライトスペキュラライト色
@par
	vecEyeは頂点から視点へのベクトルです.<br>
*/
float3
CalcGetGhostLightSpcLightCol(float3 vecRef, float4 spcParam, float3 vecPnt, float3 colPnt)
{
	float spcInt;	//スペキュラの強さ
	spcInt = dot(vecRef, vecPnt);
	spcInt = pow(max(spcInt, 0.0f), spcParam.x);

	return colPnt*spcInt;
}






/*-------------------------------------------------------------------*//*!
@brief フォグパラムからフォグ係数を算出して取得
@param[in] vecPos クリップ空間での頂点座標
@param[in] fogParam フォグパラム(x:ビュー空間での開始位置, y:ビュー空間での終了位置-ビュー空間での開始位置, z:謎, w:フォグ係数乗数)
@return フォグ係数
*/
float
CalcGetFogCoef(float4 vecPos, float4 fogParam)
{
	{//GL_LINEAR相当
		//f = (z - start)/(end - start)
		//return (vecPos.w-fogParam.x)/fogParam.y;
		//float fogCoef = saturate( (vecPos.w-fogParam.x)/fogParam.y );
		float fogCoef = (vecPos.w-fogParam.x)*fogParam.y ;
		//return saturate(fogCoef); //saturateはPSの方で
		return fogCoef;
	}

	//GL_EXP相当
	//f = exp(-(density - z))


	//GL_EXP2相当
	//f = exp(-((density - z)^2))
}
/*-------------------------------------------------------------------*//*!
@brief 入力カラーをフォグ係数でフォグカラーとブレンド
@param[in] inCol 入力カラー
@param[in] fogCol フォグカラー
@param[in] fogCoef フォグ係数(0.0:入力カラー 1.0:フォグカラー)
@return 出力カラー
*/
float4
CalcGetFogCol(float4 inCol, float4 fogCol, float fogCoef)
{
	//※αをブレンドしてしまうと半透明がおかしくなってしまうのでαはとりあえず除外
	//return float4(lerp(inCol.rgb, fogCol.rgb, fogCol.a*saturate(fogCoef)), inCol.a);
	//return float4(lerp(inCol.rgb, fogCol.rgb, fogCol.a*saturate(fogCoef)), inCol.a);

	float mulFogCoef = fogCol.a*saturate(fogCoef);
	return float4(lerp(inCol.rgb, fogCol.rgb, saturate(mulFogCoef) ), inCol.a);
}




/*-------------------------------------------------------------------*//*!
@brief 入力カラーをライトスキャッタリングカラーとブレンド
@param[in] inCol 入力カラー
@param[in] eyeVec 視線ベクトル(ワールド空間)(xyz:正規化頂点→カメラへのベクdトル, w:頂点→カメラへの距離)
@return 出力カラー
*/
float4
CalcGetLightScatteringCol(float4 inCol, float4 eyeVec)
{
	float dotEL = -dot(eyeVec.xyz, gFC_LsLightDir.xyz);	//視線ベクトルと光源ベクトルの内積
	float phase1 = dotEL * dotEL + 1.0f;


	//この乗算は要るのかしら・・・？？
	float log2e = 1.4426950f;
	float3 extinction = exp(-gFC_LsBeta1PlusBeta2.xyz * eyeVec.w * gFC_LsLightDir.w * log2e);	//※gFC_LsLightDir.wは距離倍率

	//ピクセルカラーに乗算する値
	float3 totalExtinction = extinction * gFC_LsTerrainReflectance.rgb;

	//itoj:よくわからんが,うちではdotELを求めるときにライトベクトルの向きを頂点→カメラに変換しているので-は不要？//元の実装では-が無かった.ライトベクトルの反転を考慮してる
	float tmp = gFC_LsHGg.z * dotEL + gFC_LsHGg.y;//-は不要だと思うので//float tmp = -gFC_LsHGg.z * dotEL + gFC_LsHGg.y;
	float phase2 = rsqrt(tmp) * (1.0f/tmp) * gFC_LsHGg.x;


	float3 inscattering = (gFC_LsBetaDash1.xyz*phase1 + gFC_LsBetaDash2.xyz*phase2) * (1.0f - extinction) * gFC_LsOneOverBeta1PlusBeta2.xyz;

	//係数
	inscattering *= gFC_LsTerrainReflectance.w;	//※gFC_LsTerrainReflectance.wはインスキャッタリング倍率

	//スキャッタリング後の色
	float3 scatCol = inCol.rgb*totalExtinction + gFC_LsSunColor.rgb*inscattering;

	//ブレンド
	float3 outcol = float3(lerp(inCol.rgb, scatCol, gFC_LsSunColor.a));
	return float4(outcol, inCol.a);	//※gFC_LsSunColor.aはブレンド率
}




#ifdef OLD_VERSION

//VSLS
/*-------------------------------------------------------------------*//*!
@brief ライトスキャッタリングカラー
@param[in] eyeVec 視線ベクトル(ワールド空間)(xyz:正規化頂点→カメラへのベクトル, w:頂点→カメラへの距離)
@return Extinction
*/

float3
CalcGetLightScatteringCol_Extinction(float4 eyeVec)
{
	//この乗算は要るのかしら・・・？？
	float log2e = 1.4426950f;
	float3 extinction = exp(-gVC_LsBeta1PlusBeta2.xyz * eyeVec.w * gVC_LsLightDir.w * log2e);	//※gVC_LsLightDir.wは距離倍率
	return extinction;
}

/*-------------------------------------------------------------------*//*!
@brief ライトスキャッタリングカラー
@param[in] Extinction
@return totalExtinction
*/

float3
CalcGetLightScatteringCol_TotalExtinction(float3 extinction)
{
	//ピクセルカラーに乗算する値
	float3 totalExtinction = extinction * gVC_LsTerrainReflectance.rgb;
	return totalExtinction;
}

/*-------------------------------------------------------------------*//*!
@brief ライトスキャッタリングカラー
@param[in] Extinction
@return 出力カラー (xyz:ライトスキャッタリングカラー色、w:BlendRate)
*/
float4
CalcGetLightScatteringCol_InScatColor(float4 eyeVec, float3 extinction)
{
	float dotEL = -dot(eyeVec.xyz, gVC_LsLightDir.xyz);	//視線ベクトルと光源ベクトルの内積
	float phase1 = dotEL * dotEL + 1.0f;

	//itoj:よくわからんが,うちではdotELを求めるときにライトベクトルの向きを頂点→カメラに変換しているので-は不要？//元の実装では-が無かった.ライトベクトルの反転を考慮してる
	float tmp = gVC_LsHGg.z * dotEL + gVC_LsHGg.y;//-は不要だと思うので//float tmp = -gVC_LsHGg.z * dotEL + gVC_LsHGg.y;
	float phase2 = rsqrt(tmp) * (1.0f/tmp) * gVC_LsHGg.x;

	float3 inscattering = (gVC_LsBetaDash1.xyz*phase1 + gVC_LsBetaDash2.xyz*phase2) * (1.0f - extinction) * gVC_LsOneOverBeta1PlusBeta2.xyz;

	//係数
	inscattering *= gVC_LsTerrainReflectance.w;	//※gVC_LsTerrainReflectance.wはインスキャッタリング倍率

	//スキャッタリング後の色
	float4 scatCol;
	scatCol.rgb = gVC_LsSunColor.rgb*inscattering;
	scatCol.a = gVC_LsSunColor.a;

	return scatCol;
}


/*-------------------------------------------------------------------*//*!
@brief PSでライトスキャッタリングカラー演算でかける数値
@param[in] Extinction
@return 出力カラー (xyz:ライトスキャッタリングカラー色、w:BlendRate)
*/
float3
CalcGetLightScatteringMulFactor(float3 te, float4 scatCol)
{
	//PSの側で演算は
	// FScatC = FinalC*totalExtinction+scatCol.rgb
	// blend = scatCol.a
	// FinalC+ (FScatC-FinalC)* blend  -> Lerp(FinalC, FScatC, blend);
	// FinalC+ FScatC*blend-FinalC*blend
	// FinalC*(1-blend)+(FinalC*totalExtinction+scatCol.rgb)*blend
	// FinalC*(1-blend+blend*totalExtinction)+scatCol.rgb*A
	// PSい渡すのは(1-blend+blend*totalExtinction)(かけ)　とscatCol.rgb*blend（たし）

	// 1+blend*totalExtinction-blend
	// 1+(totalExtinction-1)*blend
	float3 ret = (te-(1.f).xxx)*scatCol.a+(1.f).xxx;
	return ret;
}

/*-------------------------------------------------------------------*//*!
@brief PSでライトスキャッタリングカラー演算でのだす数値
@param[in] ライトスキャッタリングカラー
@return 出力カラー (xyz:ライトスキャッタリングカラー色、w:BlendRate)
*/
float3
CalcGetLightScatteringAddFactor(float4 scatCol)
{
	//説明は上を
	return scatCol.rgb*scatCol.a;
}



#endif // OLD_VERSION



/*-------------------------------------------------------------------*//*!
@brief 入力カラーをライトスキャッタリングカラーとブレンド
@param[in] inCol 入力カラー
@param[in] totalExtinction
@param[in] スキャッタリングカラー
@return 出力カラー
*/
float4 CalcGetLightScatteringCol_Blend(float4 inCol, float3 LsMul, float3 LsAdd)
{
//	float3 fScatCol= inCol.rgb*totalExtinction+scatCol.rgb;
//	return float4(lerp(inCol.rgb, fScatCol, scatCol.a), inCol.a);	//※gVC_LsSunColor.aはブレンド率
//ここでする演算を軽くするためこの計算をとけてVertexShaderの方で必要な数値で渡してくれる
	return float4( inCol.rgb*LsMul+LsAdd, inCol.a );
}




/*-------------------------------------------------------------------*//*!
@brief 出力色を算出して取得(アンビエント＋ディフューズ＋スペキュラ)
@param[in] colAmbLight アンビエントライティング色
@param[in] colDifLight ディフューズライティング色
@param[in] colSpcLight スペキュラライティング色
@param[in] colDifTex ディフューズテクスチャ色
@param[in] colSpcTex スペキュラテクスチャ色
@return 出力色
*/
float4
CalcGetMixCol_AmbDifSpc(float3 colAmbLight, float3 colDifLight, float3 colSpcLight, float4 colDifTex, float4 colSpcTex)
{
//	return float4(colDifTex.rgb*(colAmbLight.rgb+colDifLight.rgb) + colSpcTex.rgb*colSpcLight.rgb, colDifTex.a);
return float4(colDifTex.rgb*(colAmbLight.rgb+colDifLight.rgb) + colSpcTex.rgb*colSpcLight.rgb, colDifTex.a) * gFC_ModelMulCol;
}
/*-------------------------------------------------------------------*//*!
@brief 出力色を算出して取得(アンビエント＋ディフューズ)
@param[in] colAmbLight アンビエントライティング色
@param[in] colDifLight ディフューズライティング色
@param[in] colSpcLight スペキュラライティング色
@param[in] colDifTex ディフューズテクスチャ色
@param[in] colSpcTex スペキュラテクスチャ色
@return 出力色
*/
float4
CalcGetMixCol_AmbDif(float3 colAmbLight, float3 colDifLight, float4 colDifTex)
{
//	return float4(colDifTex.rgb*(colAmbLight.rgb+colDifLight.rgb), colDifTex.a);
	return float4(colDifTex.rgb*(colAmbLight.rgb+colDifLight.rgb), colDifTex.a) * gFC_ModelMulCol;//出力α対応
}




/*-------------------------------------------------------------------*//*!
@brief トーンマップ済フレーム色を復元
@param[in] col 入力カラー
@return 出力色
*/
float3
DecodeToneMapColor(float3 col)
{
#if TONEMAP_LINEAR_VER
	col *= gFC_ToneMap.y;
#else
	col = col * gFC_ToneMap.y / (1.0f - col);
#endif
	col /= gFC_ToneMap.x;

	return col;
}




/*-------------------------------------------------------------------*//*!
@brief ゴースト化
@param[in] inCol 入力カラー
@param[in] vecNrm 法線(正規化済み)
@param[in] vecEye 視線方向ベクトル(正規化済み)
@param[in] targetCol 目標色
@return 出力色
*/
//float4
//CalcGetChost(float4 inCol, float3 vecNrm, float3 vecEye, float4 targetCol)
//{
//	float ghostPow = max(abs(dot(vecNrm.xyz, vecEye.xyz)), 0.0f);
//	ghostPow *= ghostPow;
//	return float4(lerp(targetCol.rgb, inCol.rgb*0.3f, ghostPow), inCol.a);
//}
float4
CalcGetGhost_Test(float4 inCol, float3 vecNrm, float3 vecEye, float4 targetCol)
{
/*第１弾６０％/
	const float ghostPow = FRPG_CLAMP(abs(dot(vecNrm.xyz, vecEye.xyz)), 0.0f, 0.6f)*(1.0f/0.6f);
	return float4(lerp(targetCol.rgb, inCol.rgb, ghostPow), inCol.a);
/**/

/*第２弾*/
	const float ghostPow = (FRPG_CLAMP(abs(dot(vecNrm.xyz, vecEye.xyz)), 0.1f, 0.7f)-0.1f)*(1.0f/0.6f);
	return float4(lerp(targetCol.rgb, inCol.rgb, ghostPow), inCol.a);
/**/

/*第３弾逆/
	const float ghostPow = 1.0f - (FRPG_CLAMP(abs(dot(vecNrm.xyz, vecEye.xyz)), 0.7f, 1.0f)-0.7f)*(1.0f/0.30f);
	return float4(lerp(targetCol.rgb, inCol.rgb, ghostPow), inCol.a);
/**/
}
/*-------------------------------------------------------------------*//*!
@brief ゴースト化(逆用)
@param[in] inCol 入力カラー
@param[in] vecNrm 法線(正規化済み)
@param[in] vecEye 視線方向ベクトル(正規化済み)
@param[in] targetCol 目標色
@return 出力色
*/
//float4
//CalcGetChostInv(float4 inCol, float3 vecNrm, float3 vecEye, float4 targetCol)
//{
//	float ghostPow = min(max((dot(vecNrm.xyz, vecEye.xyz)-0.3f)*(1.3f/0.3f), 0.0f), 1.0f);
//	return lerp(targetCol.rgba, inCol.rgba, ghostPow);
//}





/*-------------------------------------------------------------------*//*!
@brief ゴースト化
@param[in] ghostTexSmp ゴーストテクスチャサンプラ
@param[in] ghostTexSmp2 ゴーストテクスチャサンプラ
@param[in] texUv テクスチャUVx2
@param[in] inCol 入力カラー
@param[in] vecNrm 法線(正規化済み)
@param[in] vecEye 視線方向ベクトル(正規化済み)
@param[in] ghostEdgeCol ゴーストエッジ色
@param[in] ghostTexCol ゴーストテクスチャ色
@param[in] ghostParam ゴーストパラム(x:ブレンド率(0.0～1.0), yzw:未使用)
@return 出力色
*/
float4
CalcGetGhost(TEX2DSAMPLERDECL(ghostTexSmp), TEX2DSAMPLERDECL(ghostTexSmp2), float4 texUv, float4 inCol, float3 vecNrm, float3 vecEye, float4 ghostEdgeCol, float4 ghostTexCol, float4 ghostParam)
{
/*第１弾/
	const float ghostPow = (FRPG_CLAMP(abs(dot(vecNrm.xyz, vecEye.xyz)), 0.1f, 0.7f)-0.1f)*(1.0f/0.6f);
	return float4(lerp(inCol.rgb, ghostEdgeCol.rgb, (1.0f-ghostPow)*ghostEdgeCol.a), inCol.a);
/**/

/*第２弾*/
	const float3 texCol = (tex2D(ghostTexSmp, texUv.xy).rgb + tex2D(ghostTexSmp2, texUv.zw).rgb) * 0.5f * ghostTexCol.rgb * ghostTexCol.a;
	const float3 edgeCol = ghostEdgeCol.rgb * ghostEdgeCol.a;
	const float ghostPow = (FRPG_CLAMP(abs(dot(vecNrm.xyz, vecEye.xyz)), 0.1f, 0.7f)-0.1f)*(1.0f/0.6f);
	const float3 ghostCol = lerp(edgeCol.rgb, texCol.rgb, ghostPow) * ghostParam.x;

	inCol.rgb += ghostCol.rgb;
	return inCol;

/**/
}

/*-------------------------------------------------------------------*//*!
@brief ゴースト化

@ゴーストテクスチャスクロール用テクスチャを削除版

@param[in] inCol 入力カラー
@param[in] vecNrm 法線(正規化済み)
@param[in] vecEye 視線方向ベクトル(正規化済み)
@param[in] ghostEdgeCol ゴーストエッジ色
@param[in] ghostTexCol ゴーストテクスチャ色
@param[in] ghostParam ゴーストパラム(x:ブレンド率(0.0～1.0), yzw:未使用)
@return 出力色
*/
float4
CalcGetGhost_NoTex(float4 inCol, float3 vecNrm, float3 vecEye, float4 ghostEdgeCol, float4 ghostTexCol, float4 ghostParam)
{
	//const float3 texCol = (tex2D(ghostTexSmp, texUv.xy).rgb + tex2D(ghostTexSmp2, texUv.zw).rgb) * 0.5f * ghostTexCol.rgb * ghostTexCol.a;
	const float3 texCol = ghostTexCol.rgb * ghostTexCol.a;
	const float3 edgeCol = ghostEdgeCol.rgb * ghostEdgeCol.a;
	const float ghostPow = (FRPG_CLAMP(abs(dot(vecNrm.xyz, vecEye.xyz)), 0.1f, 0.7f)-0.1f)*(1.0f/0.6f);
	const float3 ghostCol = lerp(edgeCol.rgb, texCol.rgb, ghostPow) * ghostParam.x;

	inCol.rgb += ghostCol.rgb;
	return inCol;
}




//シャドウ関連の関数
#include "FRPG_ShadowFunc.fxh"





//水面高さ関連定義

#define encode4ch


//#define chBit	(256.f)			//
#define chBit	(16.f)			//
#define chBitSq	(chBit*chBit)
#define EncodeScale (16.f)		//16回まで重なってもOK



#ifdef encode4ch
#define fullbit (chBitSq*chBitSq-1.f)
#else
#define fullbit (chBitSq*chBit-1.f)
#endif

//4Bit 4Channel
float4 FloatTo16Bit(float f)
{
	float4 encode =  (f.xxxx*fullbit.xxxx)*float4( 1.f/(chBit*chBitSq), 1.f/(chBitSq), 1.f/(chBit), 1.f ) ;
	encode.yzw = fmod(encode.yzw, (chBit).xxx );
	encode = trunc(encode);
	return encode;
}


float4 EncodeWaterHeight(float fHeight)
{
	fHeight = min(fHeight, 1.f);
	float4 encode = FloatTo16Bit(fHeight);
	encode = encode / 255.f;
	return encode;
}

//マップモデルはハイトを3枚かさねってある
float4 EncodeWaterHeight_Terrain(float fHeight)
{
	fHeight = min(fHeight/3.f, 1.f);
	float4 encode = FloatTo16Bit(fHeight);
	encode = encode*3.f / 255.f;
	return encode;
}


float DecodeWaterHeight(float4 color)
{
	float4 height = color;
	return dot(height, float4(chBitSq*chBit*255.f, chBitSq*255.f, chBit*255.f, 255.f )).x/fullbit;
}



float4 InverseEncodeWaterHeight_Terrain(float fHeight)
{
	fHeight = 1.f-(fHeight/3.f);	//Inverse
	float4 encode = FloatTo16Bit(fHeight);
	encode = encode*3.f / 255.f;
	return encode;
}

//マップモデルはハイトを3枚かさねってある
float InverseDecodeWaterHeight(float4 color)
{
	// (45.f/255.f) = (15.f/255.f)*3.f
	color = (45.f/255.f).xxxx-color;	//Inverseされている値を復元
	return max(DecodeWaterHeight(color) ,0.f);
}


//ディザ
//float4 Dither(float4 outCol, float4 vtxScr)
//{
//	float2 scrPos = (vtxScr.xy/vtxScr.w) * float2(1280.f/4.f, 720/4.f) *(0.5f).xx;
//	float fDitherValue = tex2D( gSMP_DitherMatrix ,scrPos).x;
//	outCol.w *= (gFC_DitherParam.x > fDitherValue); //Dither値より低いとαを0に
//	return outCol;
//}


float4 _TexDiff(TEX2DSAMPLERDECL(tex), float2 uv)
{
#if 1
	return tex2D(tex, uv);
#else //ガンマ補正
	float4 diff = tex2D(tex, uv);
	diff.rgb = pow(diff.rgb, gFC_ToneMap.w); //gFC_ToneMap.wはテクスチャガンマ
	return diff;
#endif
}



float4 TexDiff(float2 uv)
{
	return _TexDiff(TEX2DSAMPLER(gSMP_DiffuseMap), uv);
}

float4 TexDiff2(float2 uv)
{
	return _TexDiff(TEX2DSAMPLER(gSMP_DiffuseMap2), uv);
}

float4 TexLightmap(float2 uv)
{
	float4 lightMapVal = tex2D(gSMP_LightMap, uv);
	lightMapVal.rgb = pow(abs(lightMapVal.rgb), gFC_DebugPointLightParams.z);
	//lightMapVal.rgb = pow(lightMapVal.rgb, gFC_DebugPointLightParams.z)*gFC_DebugPointLightParams.y;// (TODO: increase contrast between white and black (common value is 100 for lit areas and 25 for dark areas)
	return lightMapVal;
}

//スクリーン空間での速度計算
float2 CalcScrSpaceVelocity(float4 vtxClip, float4 vtxClipPrev)
{
	return vtxClip.xy - vtxClipPrev.xy;
	/*
	vtxClip.xy /= abs(vtxClip.w);
	vtxClipPrev.xy /= abs(vtxClipPrev.w);
	float2 vel = vtxClip.xy-vtxClipPrev.xy;

//速度を２(スクリーン空間の最大幅)に制限
#if 1
	float velLength = length(vel)+0.00001f; //Zero Devide 回避
	vel /= velLength;
	vel *= min(2.f, velLength);
#endif
	vel = vel*((0.5f).xx*float2(0.49804f,-0.49804f))+(0.49804f).xx; //-2 ~ 2 -> 0 ~ 1
	return vel;*/
}

float2 OctWrap(float2 v)
{
	return (1.0 - abs(v.yx)) * (v.xy >= 0.0 ? 1.0 : -1.0);
}

float2 OctEncode(float3 n)
{
	n /= (abs(n.x) + abs(n.y) + abs(n.z));
	n.xy = n.z >= 0.0 ? n.xy : OctWrap(n.xy);
	n.xy = n.xy * 0.5 + 0.5;
	return n.xy;
}
#endif //___FRPG_Flver_FRPG_Common_fxh___

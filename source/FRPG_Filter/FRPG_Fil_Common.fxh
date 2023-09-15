/***************************************************************************//**

	@file		FRPG_Fil_Common.fxh
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
#ifndef ___FRPG_Filter_FRPG_Fil_Common_fxh___
#define ___FRPG_Filter_FRPG_Fil_Common_fxh___

#include "../Common/dx11.h" //qloc: dx11

#ifdef _PS3
#define _PS3_	//PS3
#endif

#ifdef _X360
#define _Xenon_	//Xbox360
#endif 

#ifdef _WIN32
#define _WIN32_ //Windows
#endif

#ifdef _ORBIS // QLOC: 4k checkerboard rendering, this will increase texture quality when rendering checkerboarded - MPursche
//#pragma argument(barycentricmode=sample)
#endif

#include "../Common/FRPG_HALFDefine.fxh"


#define LIGHT_DOF_GAUSSIAN 1

#ifdef LIGHT_DOF_GAUSSIAN
	#define  DOF_GAUSS_SAMPLE 9
#else
	#define  DOF_GAUSS_SAMPLE 15
#endif //LIGHT_DOF_GAUSSIAN

//**コンパイルスイッチ
// トーンマップをリニアで行う(0～Rangeでトーンマップする)
// Rangeを越える明るさは表現できない
// 0にすると、ノンリニアな式でトーンマッピングする(無限大の明るさも表現できる)
#define	TONEMAP_LINEAR_VER		1

//**バーテックスシェーダ入力
	//!バーテックスシェーダ入力
	struct VTX_IN_Filter
	{
		uint Id : SV_VertexID;//QLOC: auto draw
		//float3 VecPos : POSITION;
		//float4 ColVtx : COLOR0;	//!<頂点色
		//float2 TexDif : TEXCOORD0;
	};







//**バーテックスシェーダ出力
	//!バーテックスシェーダ出力
	struct VTX_OUT_Filter
	{
		float4 VecPos : SV_Position;
		//float4 ColVtx : TEXCOORD0;	//!<頂点色//QLOC: auto draw
		float2 TexDif : TEXCOORD0;
	};

	VTX_OUT_Filter VertexMain_Base(VTX_IN_Filter In, float4x4 mvcMtx)//QLOC: auto draw
	{
		VTX_OUT_Filter Out;
		float2 pos = 2 * float2(In.Id % 2, 1.0f - In.Id / 2) - float2(1.0f, 1.0f);
		Out.VecPos = float4(pos, 0.0f, 1.0f);// mul(float4(pos, 0.0f, 1.0f), mvcMtx);
		Out.TexDif.xy = float2(In.Id % 2, In.Id / 2);
		return Out;
	}

//**フラグメントシェーダ出力
	//!フラグメントシェーダ出力

#if defined(_ORBIS)

#define SAO_FP32	1

struct FRAGMENT_OUT
	{
		HALF4 Color : SV_Target0;

	};

	struct FRAGMENT_OUT_FP_R
	{
		HALF Color : SV_Target0; 

	};
	
	
#else
	struct FRAGMENT_OUT
	{
		HALF4 Color : SV_Target0; //qloc: dx11

	};
#endif

//**フラグメントシェーダ定数
//**バーテックスシェーダ定数
#ifdef _FRAGMENT_SHADER //MAKE_FS.batで定義
	#ifdef _PS3
		#define VC_REG(reg) reg
		#define FC_REG(reg) reg
	#else 
		#define VC_REG(reg) reg
		#define FC_REG(reg) register(reg)
	#endif
#else
	#define VC_REG(reg) register(reg)
	#define FC_REG(reg) reg
#endif



	uniform float4x4 gVC_WorldViewClipMtx : VC_REG(c0);	//!<ワールド→ビュー→クリップ行列
	uniform float4x4 gVC_CameraMtx : VC_REG(c4);	//!<カメラ行列(ワールド座標系)

	//DoF用パラメータ
//バーテックスシェーダでは使いません//	uniform float4 gVC_CameraParam : VC_REG(c8);	//!<カメラパラメータ(x:ニア, y:ファー, zw:未使用)
//バーテックスシェーダでは使いません//	uniform float4 gVC_DofFarParam : VC_REG(c9);	//!<遠方被写界深度パラメータ(x:開始距離, y:終了距離, z:倍率, w:未使用)
//バーテックスシェーダでは使いません//	uniform float4 gVC_DofNearParam : VC_REG(c10);	//!<近傍被写界深度パラメータ(x:開始距離, y:終了距離, z:倍率, w:未使用)
//バーテックスシェーダでは使いません//	uniform float4 gVC_BloomParam : VC_REG(c11);	//!<ブルームパラメータ(x:閾値(0～1), y:倍率, zw:未使用)

	uniform float4 gVC_ScreenSize : VC_REG(c12);	//!<スクリーンのサイズ(xy:横縦サイズ[pix], zw:横縦サイズの逆数[1/pix])
//バーテックスシェーダでは使いません	c12~c67//	
	uniform float4 gVC_NoiseParam : VC_REG(c68);	//!<ノイズフィルターParam(xy:UVスケール倍率, zw:UVオプセット)




	//精密射撃ボケ用
	#define gFC_AimBloomParam DL_FREG_007
	uniform float4 gFC_AimBloomParam : FC_REG(c7);	//!<精密射撃ボケパラメータ(x:ボケ開始半径[pix], y:1/(ボケ終了半径[pix]-ボケ開始半径[pix]), z:ボケ強度(0.0～1.0), w:未使用)

	//DoF用パラメータ
	#define gFC_CameraParam DL_FREG_008
	#define gFC_DofFarParam DL_FREG_009
	#define gFC_DofNearParam DL_FREG_010
	#define gFC_BloomParam DL_FREG_011
	#define gFC_ScreenSize DL_FREG_012
	//DoF用パラメータ
	uniform float4 gFC_CameraParam : FC_REG(c8);	//!<カメラパラメータ(x:ニア, y:ファー, z: ニア-ファー w:ニア*ファー)
	uniform float4 gFC_DofFarParam : FC_REG(c9);	//!<遠方被写界深度パラメータ(x:開始距離, y:終了距離, z:倍率, w:未使用)
	uniform float4 gFC_DofNearParam : FC_REG(c10);	//!<近傍被写界深度パラメータ(x:開始距離, y:終了距離, z:倍率, w:未使用)
	uniform float4 gFC_BloomParam : FC_REG(c11);	//!<ブルームパラメータ(x:閾値(0～1), y:倍率, zw:未使用)
	uniform float4 gFC_ScreenSize : FC_REG(c12);	//!<スクリーンのサイズ(xy:横縦サイズ[pix], zw:横縦サイズの逆数[1/pix])

	//ガウスフィルタ用パラメータ
	#define gFC_GaussWeight0 DL_FREG_013
	#define gFC_GaussWeight1 DL_FREG_014
	#define gFC_GaussWeight2 DL_FREG_015
	#define gFC_GaussWeight3 DL_FREG_016
	#define gFC_GaussWeight4 DL_FREG_017
	#define gFC_GaussWeight5 DL_FREG_018
	#define gFC_GaussWeight6 DL_FREG_019
	#define gFC_GaussWeight7 DL_FREG_020
	#define gFC_GaussOffset DL_FREG_021
	uniform float4 gFC_GaussWeight0 : FC_REG(c13);		//!<重み
	uniform float4 gFC_GaussWeight1 : FC_REG(c14);		//!<重み
	uniform float4 gFC_GaussWeight2 : FC_REG(c15);		//!<重み
	uniform float4 gFC_GaussWeight3 : FC_REG(c16);		//!<重み
	uniform float4 gFC_GaussWeight4 : FC_REG(c17);		//!<重み
	uniform float4 gFC_GaussWeight5 : FC_REG(c18);		//!<重み
	uniform float4 gFC_GaussWeight6 : FC_REG(c19);		//!<重み
	uniform float4 gFC_GaussWeight7 : FC_REG(c20);		//!<重み
	uniform float4 gFC_GaussOffset : FC_REG(c21);	//!<オフセット

	//フィルタオフセット
	#define gFC_avSampleOffsets0 DL_FREG_022
	#define gFC_avSampleOffsets1 DL_FREG_023
	#define gFC_avSampleOffsets2 DL_FREG_024
	#define gFC_avSampleOffsets3 DL_FREG_025
	#define gFC_avSampleOffsets4 DL_FREG_026
	#define gFC_avSampleOffsets5 DL_FREG_027
	#define gFC_avSampleOffsets6 DL_FREG_028
	#define gFC_avSampleOffsets7 DL_FREG_029
	#define gFC_avSampleOffsets8 DL_FREG_030
	#define gFC_avSampleOffsets9 DL_FREG_031
	#define gFC_avSampleOffsets10 DL_FREG_032
	#define gFC_avSampleOffsets11 DL_FREG_033
	#define gFC_avSampleOffsets12 DL_FREG_034
	#define gFC_avSampleOffsets13 DL_FREG_035
	#define gFC_avSampleOffsets14 DL_FREG_036
	#define gFC_avSampleOffsets15 DL_FREG_037
	uniform float4 gFC_avSampleOffsets0 : FC_REG(c22);
	uniform float4 gFC_avSampleOffsets1 : FC_REG(c23);
	uniform float4 gFC_avSampleOffsets2 : FC_REG(c24);
	uniform float4 gFC_avSampleOffsets3 : FC_REG(c25);
	uniform float4 gFC_avSampleOffsets4 : FC_REG(c26);
	uniform float4 gFC_avSampleOffsets5 : FC_REG(c27);
	uniform float4 gFC_avSampleOffsets6 : FC_REG(c28);
	uniform float4 gFC_avSampleOffsets7 : FC_REG(c29);
	uniform float4 gFC_avSampleOffsets8 : FC_REG(c30);
	uniform float4 gFC_avSampleOffsets9 : FC_REG(c31);
	uniform float4 gFC_avSampleOffsets10 : FC_REG(c32);
	uniform float4 gFC_avSampleOffsets11 : FC_REG(c33);
	uniform float4 gFC_avSampleOffsets12 : FC_REG(c34);
	uniform float4 gFC_avSampleOffsets13 : FC_REG(c35);
	uniform float4 gFC_avSampleOffsets14 : FC_REG(c36);
	uniform float4 gFC_avSampleOffsets15 : FC_REG(c37);

	//フィルタ重み
	#define gFC_avSampleWeights0 DL_FREG_038
	#define gFC_avSampleWeights1 DL_FREG_039
	#define gFC_avSampleWeights2 DL_FREG_040
	#define gFC_avSampleWeights3 DL_FREG_041
	#define gFC_avSampleWeights4 DL_FREG_042
	#define gFC_avSampleWeights5 DL_FREG_043
	#define gFC_avSampleWeights6 DL_FREG_044
	#define gFC_avSampleWeights7 DL_FREG_045
	#define gFC_avSampleWeights8 DL_FREG_046
	#define gFC_avSampleWeights9 DL_FREG_047
	#define gFC_avSampleWeights10 DL_FREG_048
	#define gFC_avSampleWeights11 DL_FREG_049
	#define gFC_avSampleWeights12 DL_FREG_050
	#define gFC_avSampleWeights13 DL_FREG_051
	#define gFC_avSampleWeights14 DL_FREG_052
	#define gFC_avSampleWeights15 DL_FREG_053
	uniform float4 gFC_avSampleWeights0 : FC_REG(c38);
	uniform float4 gFC_avSampleWeights1 : FC_REG(c39);
	uniform float4 gFC_avSampleWeights2 : FC_REG(c40);
	uniform float4 gFC_avSampleWeights3 : FC_REG(c41);
	uniform float4 gFC_avSampleWeights4 : FC_REG(c42);
	uniform float4 gFC_avSampleWeights5 : FC_REG(c43);
	uniform float4 gFC_avSampleWeights6 : FC_REG(c44);
	uniform float4 gFC_avSampleWeights7 : FC_REG(c45);
	uniform float4 gFC_avSampleWeights8 : FC_REG(c46);
	uniform float4 gFC_avSampleWeights9 : FC_REG(c47);
	uniform float4 gFC_avSampleWeights10 : FC_REG(c48);
	uniform float4 gFC_avSampleWeights11 : FC_REG(c49);
	uniform float4 gFC_avSampleWeights12 : FC_REG(c50);
	uniform float4 gFC_avSampleWeights13 : FC_REG(c51);
	uniform float4 gFC_avSampleWeights14 : FC_REG(c52);
	uniform float4 gFC_avSampleWeights15 : FC_REG(c53);

	#define gFC_AdaptParam DL_FREG_054
	uniform float4 gFC_AdaptParam : FC_REG(c54);	//!<適応パラメータ(x:経過時間、y:最小適応値、z:最大適応値、w:キーバリュー)

	#define gFC_fMiddleGray DL_FREG_055
	uniform float4 gFC_fMiddleGray : FC_REG(c55);

	#define gFC_PostEffectScale DL_FREG_056
	uniform float4 gFC_PostEffectScale : FC_REG(c56);	//!<ポストエフェクトスケール(x:ブルーム効果のスケール,y:光芒効果のスケール,z:カラーレンジスケール,w:露出スケールの逆数)
	#define gFC_CameraBlurParam DL_FREG_057
	uniform float4 gFC_CameraBlurParam : FC_REG(c57);	//!<カメラブラー用のパラメータ
	#define gFC_CameraDelta DL_FREG_058
	uniform float4x4 gFC_CameraDelta : FC_REG(c58);	//!<以前カメラからDelta
	#define gFC_ColorAdjustParam DL_FREG_062
	uniform float4x4 gFC_ColorAdjustParam : FC_REG(c62);	//!<//!<カラー調節パラメータ　x:brightness、y:Contrast, z:saturation w:hue
	
	#define gFC_DofCoCRateMulParam DL_FREG_066
	uniform float4 gFC_DofCoCRateMulParam : FC_REG(c66);	//!<CoCからSamplingWeightを求めるときに出す数値
	#define gFC_DofCoCRateAddParam DL_FREG_067
	uniform float4 gFC_DofCoCRateAddParam : FC_REG(c67);	//!<CoCからSamplingWeightを求めるときに掛ける数値

	#define gFC_NoiseParam DL_FREG_068
	uniform float4 gFC_NoiseParam : FC_REG(c68);			//!<x:ノイズブレンドウェート y:ディスプレイガンマ(未使用)　zw:未使用

	#define gFC_ScreenLightPos DL_FREG_069
	uniform float4 gFC_ScreenLightPos : FC_REG(c69);			//!<スクーリン空間のライト位置（スケール、オフセット済み 0.0左上）zw:実際、未使用
	
	#define gFC_LightShaftParam DL_FREG_070
	uniform float4 gFC_LightShaftParam : FC_REG(c70);			//X:伸ばす最大長さ、Y:LightShaft色の倍率　Z:LightShaft減衰率 W:未使用

	#define gFC_BloomDistParam DL_FREG_071
	uniform float4 gFC_BloomDistParam : FC_REG(c71);			//ブルーム変化パラメータ(x:閾値(0～1), y:倍率, z: 開始距離　w:終了)

	#define gFC_SAOParam DL_FREG_072
	uniform float4 gFC_SAOParam : FC_REG(c72);	// QLOC: SAO parameters (x: scale - 1m width @1m distance in pixels, y: radius, z: bias, w: intensity)

	#define gFC_SAOProjInfo DL_FREG_073
	uniform float4 gFC_SAOProjInfo : FC_REG(c73); // QLOC: SAO Projection Info

	#define gFC_PrevWorldViewClipMtx DL_FREG_074
	uniform float4x4 gFC_PrevWorldViewClipMtx : FC_REG(c74); //qloc

	#define gFC_CameraWorldPosition DL_FREG_078
	uniform float4 gFC_CameraWorldPosition : FC_REG(c78); // qloc

//	#define gFC_TAAFilterWeights0 DL_FREG_081
//	#define gFC_TAAFilterWeights1 DL_FREG_082
//	#define gFC_TAAFilterWeights2 DL_FREG_083
//	#define gFC_TAAFilterWeights3 DL_FREG_084
//	#define gFC_TAAFilterWeights4 DL_FREG_085
//	#define gFC_TAAFilterWeights5 DL_FREG_086
	uniform float4 gFC_TAAFilterWeights0 : FC_REG(c81);
	uniform float4 gFC_TAAFilterWeights1 : FC_REG(c82);
	uniform float4 gFC_TAAFilterWeights2 : FC_REG(c83);
	uniform float4 gFC_TAAFilterWeights3 : FC_REG(c84);
	uniform float4 gFC_TAAFilterWeights4 : FC_REG(c85);
	uniform float4 gFC_TAAFilterWeights5 : FC_REG(c86);

//**サンプラ
#define SMP_REG(reg) register(reg)
	//qloc: dx11
	//sampler2D gSMP_0 :SMP_REG(s0);	//テクスチャ０用サンプラ
	//sampler2D gSMP_1 :SMP_REG(s1);	//テクスチャ１用サンプラ
	//sampler2D gSMP_2 :SMP_REG(s2);	//テクスチャ２用サンプラ
	//sampler2D gSMP_3 :SMP_REG(s3);	//テクスチャ３用サンプラ
	//sampler2D gSMP_4 :SMP_REG(s4);	//テクスチャ４用サンプラ
	//sampler2D gSMP_5 :SMP_REG(s5);	//テクスチャ５用サンプラ
	//sampler2D gSMP_6 :SMP_REG(s6);	//テクスチャ６用サンプラ
	//sampler2D gSMP_7 :SMP_REG(s7);	//テクスチャ７用サンプラ
	SAMPLER2D(gSMP_0, 0);
	SAMPLER2D(gSMP_1, 1);
	SAMPLER2D(gSMP_2, 2);
	SAMPLER2D(gSMP_3, 3);
	SAMPLER2D(gSMP_4, 4);
	SAMPLER2D(gSMP_5, 5);
	SAMPLER2D(gSMP_6, 6);
	//SAMPLER2D(gSMP_7, 7);
	SAMPLERCUBE(gSMP_8, 8);
	SAMPLERCUBE(gSMP_9, 9);
	SAMPLERCUBE(gSMP_10, 10);
	SAMPLERCUBE(gSMP_11, 11);







/*-------------------------------------------------------------------*//*!
@brief BlendMode Overlay
@par
	PhotoShopなどでのブレンドモードOverlay	
	
	fomula:
	if (Base > 0.5) R = 1 - (1-2×(Base-0.5)) × (1-Blend)
	if (Base <= 0.5) R = (2×Base) × Blend 
*/

float4 Blend_Overlay(float4 fg, float4 bg, float blendRate)
{
    float4  a = 2.0f * bg * fg;
    float4  b = 1.0f - 2.0f * (1.0f - bg) * (1.0f - fg);
    float4  f = step(bg,0.5f);
    float4 overlay =  b * f + a * (1.0f-f);
	float4 result = lerp(fg, overlay, blendRate);
	return result;
    
}



float4 Blend_Overlay2(float4 base, float4 blend, float blendRate)
{
	float4 r1 = 1.f-((2.f*(1.f-base)) * (1.f-blend));
	float4 r2 = 2.f*base*blend;
	
	float4 bGreat = step( 0.5f, base ); //0.5より明るいか？
	
	float4 overlay = r1*bGreat + r2*( 1.f-bGreat);
	float4 result = lerp(base, overlay, blendRate);
	return result;
}

/*メモ
//PS3の場合深度テクスチャをA8R8G8B8で渡しているので自前でデコードする必要があります
//デプス値は24bitの値が上から8bitずつARGに格納されています.
//また,それぞれが255.0で割られて正規化されているので,元の値に戻すには
//  A*255*65536 + R*255*256 + G*255*1
//とする必要があります.
//この計算は内積を使って
//  dot( (A,R,G), (255*65536, 255*256, 255*1) )
//と表すことが出来ます.
//また,このままでは扱いにくいので正規化するために16777215(0xFFFFFF)で割って正規化すると
//  dot( (A,R,G), (255*65536/16777215, 255*256/16777215, 255*1/16777215) )
//となります.
float depth = dot(tex2D(gSMP_Depth, In.TexDif).arg, float3(65536.0*255.0/16777215.0, 256.0*255.0/16777215.0, 1.0*255.0/16777215.0));

//Xbox360はRチャンネルからFloat値のデブスを取れる
//
*/
float DecodeDepthTexture( float4 depthColor)
{
#if defined(_PS3_)//PS3
	float3	depthFactor = float3(65536.0f*255.0f/16777215.0f, 256.0f*255.0f/16777215.0f, 1.0f*255.0f/16777215.0f);
	return dot(depthColor.arg, depthFactor);
#elif defined(_Xenon_)//XBOX360
	return 1.0f - depthColor.r;
#elif defined(_WIN32_)//WIN32
#ifdef _DX11 // enabled reads from depth buffer
	return depthColor.r;
#else
	//return dot(depthColor.rgb, float3(65536.0f*256.0f/16777215.0f, 256.0f*256.0f/16777215.0f, 1.0f*256.0f/16777215.0f));//@win32depth@//
	return dot(depthColor.rgb, float3(255.0f/256.0f, 255.0f/65536.0f, 255.0f/16777216.0f));//@win32depth@//
#endif
#else
	不明
#endif
}

//ただ読み込み用、Depthコピーで使う　XboxはDepthの反転をしない
float ReadDepthTexture( float4 depthColor)
{
#if defined(_PS3_)//PS3
	float3	depthFactor = float3(65536.0f*255.0f/16777215.0f, 256.0f*255.0f/16777215.0f, 1.0f*255.0f/16777215.0f);
//	float3	errorDepthFactor = float3(-0.000000190628182329427142705151, 0.000000001442858662775675223808,  -1.467633334853251865699999e-11);
////  実際	- 丸まった値
////	0.996093809371817670572857294849-0.996094
////	0.0038909914428586627756752238080039-0.00389099
////	1.5199185323666651467481343000015e-5-1.51992e-05
	 
	return dot(depthColor.arg, depthFactor);// - dot(depthColor.arg, errorDepthFactor);
#elif defined(_Xenon_)//XBOX360
	return depthColor.r;
#elif defined(_WIN32_)//WIN32
#ifdef _DX11 // enabled reads from depth buffer
	return depthColor.r;
#else
	//return dot(depthColor.rgb, float3(65536.0f*256.0f/16777215.0f, 256.0f*256.0f/16777215.0f, 1.0f*256.0f/16777215.0f));//@win32depth@//
	return dot(depthColor.rgb, float3(255.0f/256.0f, 255.0f/65536.0f, 255.0f/16777216.0f));//@win32depth@//
#endif
#else
	不明
#endif
}

//PS3用のデブステクスチャの高精度版　X360はReadDepthTexture同様
//ただ読み込み用、Depthコピーで使う　XboxはDepthの反転をしない
//PS3のtexDepth2D_preciseを使っても速度のコストは高い　ReadDepthTexture（1024*720 0.68ms） ReadDepthTexture_Precise(1.30ms)
//texDepth2D_preciseはテクスチャをRGBAをARGBにリマップする必要があるんで自前の方が楽
float ReadDepthTexture_Precise( float4 depthColor)
{
#ifdef _PS3
	float3 c = round(depthColor.arg * 255.0f);
	//float3 c = depthColor.arg * 255.0f + (0.5).xxx ;
	//c = floor(c);
	float3 depthFactor = float3(65536.0f/16777215.0f, 256.0f/16777215.0f, 1.0f/16777215.0f);
	return dot(c, depthFactor);
#else
	return 0.0f; //qloc: make ps4 pssl compiler happy
#endif	
}

float3 Linear2srgb(float3 c)
{
	return pow(abs(c), float3(1 / 2.2, 1 / 2.2, 1 / 2.2));
}

#ifdef _PS3
#define			FRPG_H4Tex2D(tex, coord)			h4tex2D(tex, coord)
#define			FRPG_H3Tex2D(tex, coord)			h3tex2D(tex, coord)
#define			FRPG_H2Tex2D(tex, coord)			h2tex2D(tex, coord)
#define			FRPG_H1Tex2D(tex, coord)			h1tex2D(tex, coord)
#else
#define			FRPG_H4Tex2D(tex, coord)			tex2D(tex, coord)
#define			FRPG_H3Tex2D(tex, coord)			tex2D(tex, coord)
#define			FRPG_H2Tex2D(tex, coord)			tex2D(tex, coord)
#define			FRPG_H1Tex2D(tex, coord)			tex2D(tex, coord)
#endif


#define FRPG_CLAMP(_x, _fmin, _fmax) max(_fmin, min(_x, _fmax))



















#endif //___FRPG_Filter_FRPG_Fil_Common_fxh___

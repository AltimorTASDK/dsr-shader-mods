/***************************************************************************//**

	@file		FRPG_Common_FC.fxh
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
#ifndef ___FRPG_Flver_FRPG_Common_FC_fxh___
#define ___FRPG_Flver_FRPG_Common_FC_fxh___




//**フラグメントシェーダ定数
#ifdef _FRAGMENT_SHADER //X360の場合 VS/PS両方register(cN)を使うんでかぶるとエラーになる. 定義はMake_FS.bat
	#ifdef _PS3
		#define FC_REG(reg) reg		//PS3registerなし
	#else
		#define FC_REG(reg) register(reg)
	#endif
#else //VertexShader
	#define FC_REG(reg) reg
#endif

#if defined(_PS3)//PS3
	#define UNIFORM_FLOAT uniform float
	#define UNIFORM_FLOAT2 uniform float2
	#define UNIFORM_FLOAT3 uniform float3
	#define UNIFORM_FLOAT4 uniform float4
	#define UNIFORM_FLOAT4x4 uniform float4x4
	#define UNIFORM_HALF4 uniform float4
	#define UNIFORM_UINT4 uniform uint4
#elif defined(_X360)//XBOX360
	#define UNIFORM_FLOAT uniform float
	#define UNIFORM_FLOAT2 uniform float2
	#define UNIFORM_FLOAT3 uniform float3
	#define UNIFORM_FLOAT4 uniform float4
	#define UNIFORM_FLOAT4x4 uniform float4x4
	#define UNIFORM_HALF4 uniform float4
	#define UNIFORM_UINT4 uniform uint4
#elif defined(_WIN32)//WIN32
	#define UNIFORM_FLOAT uniform float
	#define UNIFORM_FLOAT2 uniform float2
	#define UNIFORM_FLOAT3 uniform float3
	#define UNIFORM_FLOAT4 uniform float4
	#define UNIFORM_FLOAT4x4 uniform float4x4
	#define UNIFORM_HALF4 uniform float4
	#define UNIFORM_UINT4 uniform uint4
#else
	不明
#endif


#ifdef OLD_VERSION

	//環境光源テクスチャ乗算色(切替ブレンド用)
	#define gFC_EnvDifMapMulCol2 DL_FREG_084
	#define gFC_EnvSpcMapMulCol2 DL_FREG_085
	UNIFORM_HALF4 gFC_EnvDifMapMulCol2 : FC_REG(c84);	//!<環境光源ディフューズ乗算色2(a:補間率(0.0～1.0))
	UNIFORM_HALF4 gFC_EnvSpcMapMulCol2 : FC_REG(c85);	//!<環境光源スペキュラ乗算色2(a:補間率(0.0～1.0))
	//環境光源テクスチャ乗算色
	#define gFC_EnvDifMapMulCol DL_FREG_086
	#define gFC_EnvSpcMapMulCol DL_FREG_087
	UNIFORM_HALF4 gFC_EnvDifMapMulCol : FC_REG(c86);	//!<環境光源ディフューズ乗算色
	UNIFORM_HALF4 gFC_EnvSpcMapMulCol : FC_REG(c87);	//!<環境光源スペキュラ乗算色

	#define gFC_SpcLightVec DL_FREG_088
	#define gFC_SpcLightCol DL_FREG_089
	UNIFORM_FLOAT4 gFC_SpcLightVec : FC_REG(c88);	//!<平行スペキュラ光源方向
	UNIFORM_HALF4 gFC_SpcLightCol : FC_REG(c89);	//!<平行スペキュラ光源色
	#define gFC_HemLightCol_u DL_FREG_090
	#define gFC_HemLightCol_d DL_FREG_091
	UNIFORM_HALF4 gFC_HemLightCol_u : FC_REG(c90);	//!<半球光源色上色
	UNIFORM_HALF4 gFC_HemLightCol_d : FC_REG(c91);	//!<半球光源色下色

	UNIFORM_HALF4 gFC_DirLightVec[3] : FC_REG(c92);	//!<平行光源方向0
	UNIFORM_HALF4 gFC_DirLightCol[3] : FC_REG(c95);	//!<平行光源色0
	#define gFC_HemAmbCol_u DL_FREG_098
	#define gFC_HemAmbCol_d DL_FREG_099
	UNIFORM_HALF4 gFC_HemAmbCol_u : FC_REG(c98);	//!<半球アンビエント光源色上色
	UNIFORM_HALF4 gFC_HemAmbCol_d : FC_REG(c99);	//!<半球アンビエント光源色下色

	#define gFC_DifMapMulCol DL_FREG_100
	UNIFORM_HALF4 gFC_DifMapMulCol : FC_REG(c100);	//!<ディフューズマップに掛ける色
	#define gFC_SpcMapMulCol DL_FREG_101
	UNIFORM_HALF4 gFC_SpcMapMulCol : FC_REG(c101);	//!<スペキュラマップに掛ける色
	#define gFC_SpcParam DL_FREG_102
	UNIFORM_FLOAT4 gFC_SpcParam : FC_REG(c102);	//!<スペキュラパラメータ(x:次数)
	#define gFC_FogCol DL_FREG_103
	UNIFORM_HALF4 gFC_FogCol : FC_REG(c103);	//!<フォグカラー(gVC側はフォグパラムなので注意)

	//ライトスキャッタリングパラメータ
	#define gFC_LsBeta1PlusBeta2 DL_FREG_104
	#define gFC_LsTerrainReflectance DL_FREG_105
	#define gFC_LsOneOverBeta1PlusBeta2 DL_FREG_106
	#define gFC_LsHGg DL_FREG_107
	#define gFC_LsBetaDash1 DL_FREG_108
	#define gFC_LsBetaDash2 DL_FREG_109
	#define gFC_LsSunColor DL_FREG_110
	#define gFC_LsLightDir DL_FREG_111
	UNIFORM_FLOAT4	gFC_LsBeta1PlusBeta2 : FC_REG(c104);	//!<ライトスキャッタリングパラメータ(謎)
	UNIFORM_FLOAT4	gFC_LsTerrainReflectance : FC_REG(c105);	//!<ライトスキャッタリングパラメータ(rgb:地上乱反射光色, a:インスキャッタリング倍率)
	UNIFORM_FLOAT4	gFC_LsOneOverBeta1PlusBeta2 : FC_REG(c106);	//!<ライトスキャッタリングパラメータ(謎)
	UNIFORM_FLOAT4	gFC_LsHGg : FC_REG(c107);	//!<ライトスキャッタリングパラメータ(謎)
	UNIFORM_FLOAT4	gFC_LsBetaDash1 : FC_REG(c108);	//!<ライトスキャッタリングパラメータ(謎)
	UNIFORM_FLOAT4	gFC_LsBetaDash2 : FC_REG(c109);	//!<ライトスキャッタリングパラメータ(謎)
	UNIFORM_FLOAT4	gFC_LsSunColor : FC_REG(c110);	//!<ライトスキャッタリング光源カラー(rgb:光源色, a:ブレンド係数)
	UNIFORM_FLOAT4	gFC_LsLightDir : FC_REG(c111);	//!<ライトスキャッタリング光源ベクトル(ワールド空間)(正規化済み)(xyz:光源からカメラへのベクトル, w:距離倍率)

	UNIFORM_FLOAT4 gFC_PntLightPos[4] : FC_REG(c112);	//Point light source position (xyz: position, w: 1 / (attenuation end distance - attenuation start distance)) (world space)
	UNIFORM_FLOAT4 gFC_PntLightCol[4] : FC_REG(c116);	//Point light source color (rgb: color, a: attenuation end distance)

	#define gFC_AlphaChannelMask DL_FREG_120
	UNIFORM_FLOAT gFC_AlphaChannelMask : FC_REG(c120);	//!<シャドウマップ描画用アルファチャンネルマスク

	#define gFC_ShadowMapParam DL_FREG_121
	#define gFC_ShadowColor	   DL_FREG_122
	#define gFC_ShadowStartDist	   DL_FREG_123
	UNIFORM_FLOAT4 gFC_ShadowMapParam : FC_REG(c121);	//!<シャドウマップパラメータ
	UNIFORM_HALF4 gFC_ShadowColor    : FC_REG(c122);	//!<シャドウカラー
	UNIFORM_FLOAT4 gFC_ShadowStartDist : FC_REG(c123);	//!<シャドウslice別の開始距離

	#define gFC_WaterReflectBand		DL_FREG_124
	#define gFC_WaterRefractBand		DL_FREG_125
	#define gFC_WaterWaveHeight			DL_FREG_126
	#define gFC_WaterColor				DL_FREG_127
	#define gFC_WaterFadeBegin			DL_FREG_128
	#define gFC_WaterFresnelPow			DL_FREG_129
	#define gFC_WaterFresnelBias		DL_FREG_130
	#define gFC_WaterFresnelScale		DL_FREG_131
	#define gFC_WaterFresnelColor		DL_FREG_132
	#define gFC_WaterFresnelFakeColor	DL_FREG_133
	#define gFC_WaterTileBlend			DL_FREG_134
#if 0 //qloc: not used, causes dx11 compile error since c123 is already used
UNIFORM_FLOAT4 gFC_WaterScreenOffset : FC_REG(c123);//////////////////////////////////未使用？？////////////////////////////
#endif
	UNIFORM_FLOAT  gFC_WaterReflectBand : FC_REG(c124);	// 反射揺らぎ幅。
	UNIFORM_FLOAT  gFC_WaterRefractBand : FC_REG(c125);	// 屈折揺らぎ幅。
	UNIFORM_FLOAT  gFC_WaterWaveHeight : FC_REG(c126); // 水面波の高さを適用
	UNIFORM_FLOAT4 gFC_WaterColor : FC_REG(c127); // 水の色
	UNIFORM_FLOAT2 gFC_WaterFadeBegin: FC_REG(c128); // 水のフェード開始α値(0～1)
	UNIFORM_FLOAT  gFC_WaterFresnelPow : FC_REG(c129); // フレネル係数(1～128)
	UNIFORM_FLOAT  gFC_WaterFresnelBias : FC_REG(c130); // フレネルバイアス(0～1)
	UNIFORM_FLOAT  gFC_WaterFresnelScale : FC_REG(c131); // フレネルスケール(0～1)
	UNIFORM_FLOAT4 gFC_WaterFresnelColor : FC_REG(c132); // フレネルカラー
	UNIFORM_FLOAT4 gFC_WaterFresnelFakeColor : FC_REG(c133); // フレネルフェイクカラー
	UNIFORM_FLOAT3 gFC_WaterTileBlend : FC_REG(c134); // タイリングブレンド(x:タイル0ブレンド率、y:タイル1ブレンド率、z:タイル2ブレンド率)

	#define gFC_ToneMap					DL_FREG_135
	UNIFORM_FLOAT4 gFC_ToneMap : FC_REG(c135);	// トーンマップ(x:露出スケール値, y:トーンマッピングのスケール, z:未使用, w:テクスチャガンマ(未使用))

	//ゴーストパラメータ
	#define gFC_GhostEdgeColor			DL_FREG_136
	#define gFC_GhostTexColor			DL_FREG_137
	#define gFC_GhostParam				DL_FREG_138
	UNIFORM_HALF4 gFC_GhostEdgeColor : FC_REG(c136);	//!<ゴーストエッジ色
	UNIFORM_HALF4 gFC_GhostTexColor : FC_REG(c137);	//!<ゴーストテクスチャ色
	UNIFORM_FLOAT4 gFC_GhostParam : FC_REG(c138);	//!<ゴーストパラム(x:ブレンド率(0.0～1.0), yzw:未使用)

	#define gFC_ModelMulCol DL_FREG_139
	UNIFORM_HALF4 gFC_ModelMulCol : FC_REG(c139);	//!<モデル乗算色


	#define SHADOWMAP_SLICE_NUM 4
	//QLOC: use array instead of weights
	#define gFC_ShadowMapMtxArray DL_FREG_140A
	UNIFORM_FLOAT4x4 gFC_ShadowMapMtxArray[SHADOWMAP_SLICE_NUM] : FC_REG(c140);	//!<
	#define gFC_ShadowMapMtxArray0 gFC_ShadowMapMtxArray[0]
	#define gFC_ShadowMapMtxArray1 gFC_ShadowMapMtxArray[1]
	#define gFC_ShadowMapMtxArray2 gFC_ShadowMapMtxArray[2]
	#define gFC_ShadowMapMtxArray3 gFC_ShadowMapMtxArray[3]
	/*#define gFC_ShadowMapMtxArray0 DL_FREG_140
	#define gFC_ShadowMapMtxArray1 DL_FREG_144
	#define gFC_ShadowMapMtxArray2 DL_FREG_148
	#define gFC_ShadowMapMtxArray3 DL_FREG_152
	UNIFORM_FLOAT4x4 gFC_ShadowMapMtxArray0 : FC_REG(c140);	//!<
	UNIFORM_FLOAT4x4 gFC_ShadowMapMtxArray1 : FC_REG(c144);	//!<
	UNIFORM_FLOAT4x4 gFC_ShadowMapMtxArray2 : FC_REG(c148);	//!<
	UNIFORM_FLOAT4x4 gFC_ShadowMapMtxArray3 : FC_REG(c152);	//!<*/

	#define gFC_FgSkinAddColor DL_FREG_156
	UNIFORM_HALF4 gFC_FgSkinAddColor : FC_REG(c156); //!<FaceGenの肌色に変えるための加算色

	#define gFC_ShadowMapClamp DL_FREG_157A
	UNIFORM_FLOAT4 gFC_ShadowMapClamp[SHADOWMAP_SLICE_NUM] : FC_REG(c157);	//!<
	#define gFC_ShadowMapClamp0 gFC_ShadowMapClamp[0]
	#define gFC_ShadowMapClamp1 gFC_ShadowMapClamp[1]
	#define gFC_ShadowMapClamp2 gFC_ShadowMapClamp[2]
	#define gFC_ShadowMapClamp3 gFC_ShadowMapClamp[3]
	/*#define gFC_ShadowMapClamp0 DL_FREG_157
	#define gFC_ShadowMapClamp1 DL_FREG_158
	#define gFC_ShadowMapClamp2 DL_FREG_159
	#define gFC_ShadowMapClamp3 DL_FREG_160
	UNIFORM_FLOAT4 gFC_ShadowMapClamp0 : FC_REG(c157); //!<ShadowMap Clamp
	UNIFORM_FLOAT4 gFC_ShadowMapClamp1 : FC_REG(c158); //!<ShadowMap Clamp
	UNIFORM_FLOAT4 gFC_ShadowMapClamp2 : FC_REG(c159); //!<ShadowMap Clamp
	UNIFORM_FLOAT4 gFC_ShadowMapClamp3 : FC_REG(c160); //!<ShadowMap Clamp*/

	//ゴーストパラメータ
//2010/08/30 nacheon ゴーストテクスチャスクロール削除	#define gFC_GhostTexScrl_0 DL_FREG_161
//2010/08/30 nacheon ゴーストテクスチャスクロール削除	#define gFC_GhostTexScrl_1 DL_FREG_162
//2010/08/30 nacheon ゴーストテクスチャスクロール削除	UNIFORM_FLOAT4 gFC_GhostTexScrl_0 : FC_REG(c161);	//!<ゴーストテクスチャスクロール
//2010/08/30 nacheon ゴーストテクスチャスクロール削除	UNIFORM_FLOAT4 gFC_GhostTexScrl_1 : FC_REG(c162);	//!<ゴーストテクスチャスクロール

	#define gFC_WaterWaveParam DL_FREG_163
	UNIFORM_FLOAT4 gFC_WaterWaveParam : FC_REG(c163);		//!水面高さ関連パラメータ x: Game描画カメラのFovYのTangent値 y:水面波のFade距離　z:雪面のFade距離　w:HeightMapの横縦中小さい方のサイズ

	#define gFC_WaterHeightMapSize DL_FREG_164
	UNIFORM_FLOAT4 gFC_WaterHeightMapSize : FC_REG(c164);	//!水面高さマップサイズ xy:heightmapのサイズ　zw:heightmapのサイズの逆数

	#define gFC_WorldViewClipMtx DL_FREG_165
	UNIFORM_FLOAT4x4 gFC_WorldViewClipMtx : FC_REG(c165);	//!<

	#define gFC_SnowParam DL_FREG_169
	UNIFORM_FLOAT4 gFC_SnowParam: FC_REG(c169);		//雪関連パラメータ x:雪の高さ倍率 y:表面下散乱 z:表面下散乱Power w:Parallax 倍率

	#define gFC_SnowColor DL_FREG_170
	UNIFORM_FLOAT4 gFC_SnowColor: FC_REG(c170);		//雪色

	#define gFC_SnowTileBlend DL_FREG_171
	UNIFORM_FLOAT4 gFC_SnowTileBlend: FC_REG(c171);	//雪タイリングブレンド(x:タイル0ブレンド率、y:タイル1ブレンド率、z:タイル2ブレンド率)

	#define gFC_SnowDetailParam DL_FREG_172
	UNIFORM_FLOAT4 gFC_SnowDetailParam: FC_REG(c172); //雪面のDetailにかんするパラメータ (x:DetailBumpのスケール値, y: SnowBlend Top-Bottomの逆数, z : SnowBlend Bottom,  w:未使用)

	#define gFC_SnowSpecParam DL_FREG_173
	UNIFORM_FLOAT4 gFC_SnowSpecParam: FC_REG(c173);	  //雪面のSpecularかんするパラメータ (x:SpecBlend Top-Bottomの逆数, y: SpecBlend Bottom, z : 逆さ差分の制限値, w:未使用)

	#define gFC_FaceEyeCol	DL_FREG_174
	UNIFORM_FLOAT4 gFC_FaceEyeCol: FC_REG(c174);	  //FaceGen顔の瞳の色

	#define gFC_ShadowLightDir	DL_FREG_175
	UNIFORM_FLOAT4 gFC_ShadowLightDir: FC_REG(c175);	//シャードウを作る光源の方向

	#define gFC_NormalToAlphaParam DL_FREG_176				//カメラと法線の方向でαが決まるシェーダ用のパラメータ
	UNIFORM_FLOAT4 gFC_NormalToAlphaParam: FC_REG(c176);	//カメラと法線の方向でαが決まる (x: minAngle, y: 1/(maxAngle-minAngle), 0.f, 0.f)

	#define gFC_SnowParam2 DL_FREG_177				//qloc
	UNIFORM_FLOAT4 gFC_SnowParam2: FC_REG(c177);	//(x: Roughness, y: MetalMask, z: DiffuseF0)

//	#define gFC_DitherParam	DL_FREG_176
//	UNIFORM_FLOAT4 gFC_DitherParam: FC_REG(c176);	//DitherParam x:DitherThreshold yzw:未使用

	#define gFC_GhostLightPos DL_FREG_180
	UNIFORM_FLOAT4 gFC_GhostLightPos: FC_REG(c180);	//光源位置(xyz:位置, w:1/(減衰終了距離-減衰開始距離))(ワールド空間)

	#define gFC_GhostLightCol DL_FREG_181
	UNIFORM_FLOAT4 gFC_GhostLightCol: FC_REG(c181);	//光源色(rgb:色, a:減衰終了距離)

	#define gFC_DetailBumpParam DL_FREG_182
	UNIFORM_FLOAT4 gFC_DetailBumpParam: FC_REG(c182);	//DetailBumpParam(xy: UVScale, z:BumpPower)

	#define gFC_LightProbeParam DL_FREG_184
	UNIFORM_FLOAT4 gFC_LightProbeParam: FC_REG(c184);

	#define gFC_DebugMaterialParams DL_FREG_185
	UNIFORM_FLOAT4 gFC_DebugMaterialParams: FC_REG(c185);

	#define gFC_DebugPointLightParams DL_FREG_186
	UNIFORM_FLOAT4 gFC_DebugPointLightParams : FC_REG(c186);

	#define gFC_SHEnabled DL_FREG_187
	UNIFORM_FLOAT gFC_SHEnabled : FC_REG(c187);

	#define gFC_IVMtx DL_FREG_188
	UNIFORM_FLOAT4x4 gFC_IVMtx : FC_REG(c188);

	#define gFC_SubsurfaceParam DL_FREG_192
	UNIFORM_FLOAT4 gFC_SubsurfaceParam : FC_REG(c192);

	#define gFC_SAOEnabled DL_FREG_193
	UNIFORM_FLOAT gFC_SAOEnabled : FC_REG(c193);

	#define gFC_MagicLightParam DL_FREG_194
	UNIFORM_FLOAT4 gFC_MagicLightParam : FC_REG(c194);
	#define gFC_NormalScale gFC_MagicLightParam.z

	#define gFC_reserved DL_FREG_195
	UNIFORM_FLOAT4 gFC_reserved : FC_REG(c195);

	#define gFC_PntLightCount DL_FREG_196
	UNIFORM_UINT4 gFC_PntLightCount : FC_REG(c196);

	#define gFC_ParallaxParams DL_FREG_197
	UNIFORM_FLOAT4 gFC_ParallaxParams : FC_REG(c197);

	#define gFC_DirLightCount DL_FREG_198
	UNIFORM_UINT4 gFC_DirLightCount : FC_REG(c198);

	#define gFC_DirLightParam DL_FREG_199
	UNIFORM_FLOAT4 gFC_DirLightParam : FC_REG(c199);

	//qloc: for SFX
	#define gFC_GlowColor DL_FREG_35
	UNIFORM_FLOAT4 gFC_GlowColor : FC_REG(c35);

	#define gFC_SfxLightScatteringParams DL_FREG_34
	UNIFORM_FLOAT4 gFC_SfxLightScatteringParams : FC_REG(c34);

	#define gFC_MaterialWorkflow DL_FREG_202
	UNIFORM_UINT4 gFC_MaterialWorkflow : FC_REG(c202);

	#define gFC_ClipInfo DL_FREG_203
	UNIFORM_FLOAT4 gFC_ClipInfo : FC_REG(c203);

	#define gFC_ClusterParam DL_FREG_204
	UNIFORM_FLOAT4 gFC_ClusterParam : FC_REG(c204);

	#define gFC_ToneCorrectParams DL_FREG_205
	UNIFORM_FLOAT4 gFC_ToneCorrectParams : FC_REG(c205);

	#define gFC_AdaptParam DL_FREG_206
	UNIFORM_FLOAT4 gFC_AdaptParam : FC_REG(c206);

	#define gFC_fMiddleGray DL_FREG_207
	UNIFORM_FLOAT4 gFC_fMiddleGray : FC_REG(c207);

	#define gFC_PostEffectScale DL_FREG_208
	UNIFORM_FLOAT4 gFC_PostEffectScale : FC_REG(c208);
	//~qloc

#else //OLD_VERSION

	float4 gFC_EnvDifMapMulCol2 : FC_REG(c1);
	float4 gFC_EnvSpcMapMulCol2 : FC_REG(c2);
	float4 gFC_EnvDifMapMulCol : FC_REG(c3);
	float4 gFC_EnvSpcMapMulCol : FC_REG(c4);
	float4 gFC_SpcLightVec : FC_REG(c5);
	float4 gFC_SpcLightCol : FC_REG(c6);
	float4 gFC_HemAmbCol_u : FC_REG(c7);
	float4 gFC_HemAmbCol_d : FC_REG(c8);
	float4 gFC_DifMapMulCol : FC_REG(c9);
	float4 gFC_SpcMapMulCol : FC_REG(c10);
	float4 gFC_SpcParam : FC_REG(c11);
	float4 gFC_FogCol : FC_REG(c12);
	float4 gFC_LsBeta1PlusBeta2 : FC_REG(c13);
	float4 gFC_LsTerrainReflectance : FC_REG(c14);
	float4 gFC_LsOneOverBeta1PlusBeta2 : FC_REG(c15);
	float4 gFC_LsHGg : FC_REG(c16);
	float4 gFC_LsBetaDash1 : FC_REG(c17);
	float4 gFC_LsBetaDash2 : FC_REG(c18);
	float4 gFC_LsSunColor : FC_REG(c19);
	float4 gFC_LsLightDir : FC_REG(c20);
	float4 gFC_ShadowMapParam : FC_REG(c21);
	float4 gFC_ShadowColor : FC_REG(c22);
	float4 gFC_ShadowStartDist : FC_REG(c23);
	//float gFC_WaterReflectBand : FC_REG(c24);
	//float gFC_WaterRefractBand : FC_REG(c25);
	//float gFC_WaterWaveHeight : FC_REG(c26);
	float4 gFC_DirLightVec[3] : FC_REG(c24);
	//float4 gFC_WaterColor : FC_REG(c27);
	//float2 gFC_WaterFadeBegin : FC_REG(c28);
	//float gFC_WaterFresnelPow : FC_REG(c29);
	float4 gFC_DirLightCol[3] : FC_REG(c27);
	float gFC_WaterFresnelBias : FC_REG(c30);
	float gFC_WaterFresnelScale : FC_REG(c31);
	float4 gFC_WaterFresnelColor : FC_REG(c32);
	float4 gFC_WaterFresnelFakeColor : FC_REG(c33);
	float3 gFC_WaterTileBlend : FC_REG(c34);
	float4 gFC_ToneMap : FC_REG(c35);
	float4 gFC_GhostEdgeColor : FC_REG(c36);
	float4 gFC_GhostTexColor : FC_REG(c37);
	float4 gFC_GhostParam : FC_REG(c38);
	float4 gFC_ModelMulCol : FC_REG(c39);
#define gFC_ShadowMapMtxArray0 gFC_ShadowMapMtxArray[0]
#define gFC_ShadowMapMtxArray1 gFC_ShadowMapMtxArray[1]
#define gFC_ShadowMapMtxArray2 gFC_ShadowMapMtxArray[2]
#define gFC_ShadowMapMtxArray3 gFC_ShadowMapMtxArray[3]
	float4x4 gFC_ShadowMapMtxArray[4] : FC_REG(c40);
#define gFC_ShadowMapClamp0 gFC_ShadowMapClamp[0]
#define gFC_ShadowMapClamp1 gFC_ShadowMapClamp[1]
#define gFC_ShadowMapClamp2 gFC_ShadowMapClamp[2]
#define gFC_ShadowMapClamp3 gFC_ShadowMapClamp[3]
	float4 gFC_ShadowMapClamp[4] : FC_REG(c56);
	float4 gFC_FgSkinAddColor : FC_REG(c60);
	float4 gFC_WaterWaveParam : FC_REG(c61);
	float4 gFC_WaterHeightMapSize : FC_REG(c62);
	float4x4 gFC_WorldViewClipMtx : FC_REG(c63);
	float4 gFC_SnowParam : FC_REG(c67);
	float4 gFC_SnowColor : FC_REG(c68);
	float4 gFC_SnowTileBlend : FC_REG(c69);
	float4 gFC_SnowDetailParam : FC_REG(c70);
	float4 gFC_SnowSpecParam : FC_REG(c71);
	float4 gFC_FaceEyeCol : FC_REG(c72);
	float4 gFC_ShadowLightDir : FC_REG(c73);
	float4 gFC_NormalToAlphaParam : FC_REG(c74);
	float4 gFC_SnowParam2 : FC_REG(c75);
	float4 gFC_GhostLightPos : FC_REG(c76);
	float4 gFC_GhostLightCol : FC_REG(c77);
	float4 gFC_DetailBumpParam : FC_REG(c78);
#define gFC_NormalScale gFC_LightProbeParam.z
	float4 gFC_LightProbeParam : FC_REG(c79);
	float4 gFC_SubsurfaceParam : FC_REG(c80);
	uint4 gFC_PntLightCount : FC_REG(c81);
	float4 gFC_ParallaxParams : FC_REG(c82);
	float4 gFC_GlowColor : FC_REG(c83);
	float4 gFC_SfxLightScatteringParams : FC_REG(c84);
	uint4 gFC_MaterialWorkflow : FC_REG(c85);
	float4 gFC_ClipInfo : FC_REG(c86);
	float4 gFC_ClusterParam : FC_REG(c87);
	float4 gFC_ToneCorrectParams : FC_REG(c88);
	float4 gFC_AdaptParam : FC_REG(c89);
#define gFC_SAOEnabled gFC_SAOParams.w
	float4 gFC_SAOParams : FC_REG(c90);
	float4 gFC_InverseToneMapEnable : FC_REG(c91);
	float4 gFC_PntLightPos[4] : FC_REG(c92);
	float4 gFC_PntLightCol[4] : FC_REG(c96);
#define gFC_DebugMaterialParams gFC_MaterialOverrideParams
	float4 gFC_MaterialOverrideParams : FC_REG(c100);
	float4 gFC_DebugPointLightParams : FC_REG(c101);
	// x: m_dbgShowGBuffer
	// y: m_dbgForceDiffuseMapChangeMode bits 0-1
	//    m_dbgForceSpecularMapChangeMode bits 2-3
	uint4 gFC_DebugDraw : FC_REG(c102);

#endif //OLD_VERSION

#endif //___FRPG_Flver_FRPG_Common_FC_fxh___

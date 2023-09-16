/***************************************************************************//**

	@file		FRPG_Common_VC.fxh
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
#ifndef ___FRPG_Flver_FRPG_Common_VC_fxh___
#define ___FRPG_Flver_FRPG_Common_VC_fxh___



//**バーテックスシェーダ定数
#ifdef _FRAGMENT_SHADER //X360の場合 VS/PS両方register(cN)を使うんでかぶるとエラーになる. 定義はMake_FS.bat
	#define VC_REG(reg) reg
#else //VertexShader
	#define VC_REG(reg) register(reg)
#endif

#ifdef UNMODIFIED

	#define gVC_WorldViewClipMtx VR_000
	#define gVC_CameraMtx VR_004
	uniform float4x4 gVC_WorldViewClipMtx : VC_REG(c0);	//!<ワールド→ビュー→クリップ行列
	uniform float4x4 gVC_CameraMtx : VC_REG(c4);	//!<カメラ行列(ワールド空間)
#define LOCAL_WORLD_MTX_NUM (38)	//ローカル→ワールド行列数
//8～121
	#define gVC_LocalWorldMtx VR_008
	#define gVC_LocalWorldMtxArray VR_008A

#ifdef _PS3
	uniform float3x4 gVC_LocalWorldMtx : VC_REG(c8);	//!<ローカル→ワールド行列(転置しているので注意)
	uniform float3x4 gVC_LocalWorldMtxArray[LOCAL_WORLD_MTX_NUM] : VC_REG(c8);	//!<ローカル→ワールド行列配列(転置しているので注意)
#else //column_majorならfloat3x4コンスタントを４つ使うことになる
	uniform row_major float3x4 gVC_LocalWorldMtx : VC_REG(c8);	//!<ローカル→ワールド行列(転置しているので注意)
	uniform row_major float3x4 gVC_LocalWorldMtxArray[LOCAL_WORLD_MTX_NUM] : VC_REG(c8);	//!<ローカル→ワールド行列配列(転置しているので注意)
#endif


	#define gVC_FogParam VR_128
	uniform float4 gVC_FogParam : VC_REG(c128);	//!<フォグパラメータフォグパラム(x:ビュー空間での開始位置, y:ビュー空間での終了位置-ビュー空間での開始位置, z:謎, w:フォグ係数乗数)(gFC側はフォグカラーなので注意)



	//ライトスキャッタリングパラメータ
	#define gVC_LsBeta1PlusBeta2			VR_129
	#define gVC_LsTerrainReflectance		VR_130
	#define gVC_LsOneOverBeta1PlusBeta2		VR_131
	#define gVC_LsHGg						VR_132
	#define gVC_LsBetaDash1					VR_133
	#define gVC_LsBetaDash2					VR_134
	#define gVC_LsSunColor					VR_135
	#define gVC_LsLightDir					VR_136

	uniform float4 gVC_LsBeta1PlusBeta2		:	VC_REG(c129); //!<ライトスキャッタリングパラメータ(謎)
	uniform float4 gVC_LsTerrainReflectance	:	VC_REG(c130); //!<ライトスキャッタリングパラメータ(rgb:地上乱反射光色, a:インスキャッタリング倍率)
	uniform float4 gVC_LsOneOverBeta1PlusBeta2	:	VC_REG(c131); //!<ライトスキャッタリングパラメータ(謎)
	uniform float4 gVC_LsHGg					:	VC_REG(c132); //!<ライトスキャッタリングパラメータ(謎)
	uniform float4 gVC_LsBetaDash1	:			VC_REG(c133); //!<ライトスキャッタリングパラメータ(謎)
	uniform float4 gVC_LsBetaDash2	:			VC_REG(c134); //!<ライトスキャッタリングパラメータ(謎)
	uniform float4 gVC_LsSunColor	:			VC_REG(c135); //!<ライトスキャッタリング光源カラー(rgb:光源色, a:ブレンド係数)
	uniform float4 gVC_LsLightDir	:			VC_REG(c136); //!<ライトスキャッタリング光源ベクトル(ワールド空間)(正規化済み)(xyz:光源からカメラへのベクトル, w:距離倍率)

	#define gVC_ShadowMapMtx VR_137
	uniform float4x4 gVC_ShadowMapMtx : VC_REG(c137);		//!(4)<ワールド→ライト行列(ライト空間)


	#define gVC_WaterTileScale VR_141
	uniform float4 gVC_WaterTileScale : VC_REG(c141);

	//水面高さ
	#define gVC_WaterWaveParam VR_142
	uniform float4 gVC_WaterWaveParam : VC_REG(c142);		//!水面高さ関連パラメータ (　: Game描画カメラのFovYのTangent値 y:波のFade距離　z:水面heigthMapのサイズ　w: １/heigthMapのサイズ)


	#define gVC_SnowTileScale0 VR_143
	uniform float4 gVC_SnowTileScale : VC_REG(c143);

	#define gVC_SnowDetailBumpTileScale VR_144
	uniform float4 gVC_SnowDetailBumpTileScale : VC_REG(c144);
	#define gVC_SnowDiffuseTileScale VR_145
	uniform float4 gVC_SnowDiffuseTileScale : VC_REG(c145);

	#define gVC_WindParam_0 VR_122
	#define gVC_WindParam_1 VR_123
	uniform float4 gVC_WindParam_0 : VC_REG(c122);
	uniform float4 gVC_WindParam_1 : VC_REG(c123);

#ifndef _DX11 //qloc: dx11: avoid error X4019: multiple variables found with the same user-specified location

//MotionBlur //128～241 register 120個 他のコンスタントと重複可能です。
	#define gVC_prevLocalWorldMtx VR_128_ //VR_128と重複でコンパイルエラー回避
	#define gVC_prevLocalWorldMtxArray VR_128A
#ifdef _PS3
	uniform float3x4 gVC_prevLocalWorldMtx : VC_REG(c128);								//!<以前プレイムのローカル→ワールド行列(転置しているので注意)
	uniform float3x4 gVC_prevLocalWorldMtxArray[LOCAL_WORLD_MTX_NUM] : VC_REG(c128);	//!<以前プレイムのローカル→ワールド行列配列(転置しているので注意)
#else //column_majorならfloat3x4コンスタントを４つ使うことになる
	uniform row_major float3x4 gVC_prevLocalWorldMtx : VC_REG(c128);							//!<以前プレイムのローカル→ワールド行列(転置しているので注意)
	uniform row_major float3x4 gVC_prevLocalWorldMtxArray[LOCAL_WORLD_MTX_NUM] : VC_REG(c128);	//!<以前プレイムのローカル→ワールド行列(転置しているので注意)
#endif

#endif


	#define gVC_TexScrl_0 VR_246
	#define gVC_TexScrl_1 VR_247
	#define gVC_TexScrl_2 VR_248

	uniform float4 gVC_TexScrl_0 : VC_REG(c246);			//!<テクスチャスクロール0
	uniform float4 gVC_TexScrl_1 : VC_REG(c247);			//!<テクスチャスクロール1
	uniform float4 gVC_TexScrl_2 : VC_REG(c248);			//!<テクスチャスクロール2




	//------------------------------------------------------------------------------
	//	ユーザークリッププレーン(PS3のみ)
	//------------------------------------------------------------------------------
#if		defined(CLIPPLANE_ENABLE) //&& !defind( _FRAGMENT_SHADER )
	#define gVC_aClipPlane VR_249A
	uniform	float4 gVC_aClipPlane[6] : VC_REG(c249); //0番のみ使用中

	#ifdef _PS3
		#define		DECLARE_OUT_CLIPPLANE0		out float oClip0	: CLP0
		#define		DECLARE_OUT_CLIPPLANE1		out float oClip1	: CLP1
		#define		DECLARE_OUT_CLIPPLANE2		out float oClip2	: CLP2
		#define		DECLARE_OUT_CLIPPLANE3		out float oClip3	: CLP3
		#define		DECLARE_OUT_CLIPPLANE4		out float oClip4	: CLP4
		#define		DECLARE_OUT_CLIPPLANE5		out float oClip5	: CLP5

		#ifdef WITH_ClipPlane
			#define		COMPUTE_CLIPPLANE0(pos)		oClip0	= dot(  gVC_aClipPlane[0] , pos )
			#define		COMPUTE_CLIPPLANE1(pos)		oClip1	= dot(  gVC_aClipPlane[1] , pos )
			#define		COMPUTE_CLIPPLANE2(pos)		oClip2	= dot(  gVC_aClipPlane[2] , pos )
			#define		COMPUTE_CLIPPLANE3(pos)		oClip3	= dot(  gVC_aClipPlane[3] , pos )
			#define		COMPUTE_CLIPPLANE4(pos)		oClip4	= dot(  gVC_aClipPlane[4] , pos )
			#define		COMPUTE_CLIPPLANE5(pos)		oClip5	= dot(  gVC_aClipPlane[5] , pos )
		#else
			#define		COMPUTE_CLIPPLANE0(pos)		//なにもしない
			#define		COMPUTE_CLIPPLANE1(pos)		//なにもしない
			#define		COMPUTE_CLIPPLANE2(pos)		//なにもしない
			#define		COMPUTE_CLIPPLANE3(pos)		//なにもしない
			#define		COMPUTE_CLIPPLANE4(pos)		//なにもしない
			#define		COMPUTE_CLIPPLANE5(pos)		//なにもしない
		#endif

	#elif defined(_DX11) //qloc
		#define		DECLARE_OUT_CLIPPLANE0
		#define		DECLARE_OUT_CLIPPLANE1
		#define		DECLARE_OUT_CLIPPLANE2
		#define		DECLARE_OUT_CLIPPLANE3
		#define		DECLARE_OUT_CLIPPLANE4
		#define		DECLARE_OUT_CLIPPLANE5

		#ifdef WITH_ClipPlane
			#define		COMPUTE_CLIPPLANE0(pos)		Out.oClip0	= qlocClipPlaneDistance(pos);
			#define		COMPUTE_CLIPPLANE1(pos)		Out.oClip1	= 0.0;
			#define		COMPUTE_CLIPPLANE2(pos)		Out.oClip2	= 0.0;
			#define		COMPUTE_CLIPPLANE3(pos)		Out.oClip3	= 0.0;
			#define		COMPUTE_CLIPPLANE4(pos)		Out.oClip4	= 0.0;
			#define		COMPUTE_CLIPPLANE5(pos)		Out.oClip5	= 0.0;
		#else
			#define		COMPUTE_CLIPPLANE0(pos)		//なにもしない
			#define		COMPUTE_CLIPPLANE1(pos)		//なにもしない
			#define		COMPUTE_CLIPPLANE2(pos)		//なにもしない
			#define		COMPUTE_CLIPPLANE3(pos)		//なにもしない
			#define		COMPUTE_CLIPPLANE4(pos)		//なにもしない
			#define		COMPUTE_CLIPPLANE5(pos)		//なにもしない
		#endif

	#else
		#define		DECLARE_OUT_CLIPPLANE0
		#define		DECLARE_OUT_CLIPPLANE1
		#define		DECLARE_OUT_CLIPPLANE2
		#define		DECLARE_OUT_CLIPPLANE3
		#define		DECLARE_OUT_CLIPPLANE4
		#define		DECLARE_OUT_CLIPPLANE5

		#define		COMPUTE_CLIPPLANE0(pos)		//なにもしない
		#define		COMPUTE_CLIPPLANE1(pos)		//なにもしない
		#define		COMPUTE_CLIPPLANE2(pos)		//なにもしない
		#define		COMPUTE_CLIPPLANE3(pos)		//なにもしない
		#define		COMPUTE_CLIPPLANE4(pos)		//なにもしない
		#define		COMPUTE_CLIPPLANE5(pos)		//なにもしない

	#endif

#else

	#define		DECLARE_OUT_CLIPPLANE0
	#define		DECLARE_OUT_CLIPPLANE1
	#define		DECLARE_OUT_CLIPPLANE2
	#define		DECLARE_OUT_CLIPPLANE3
	#define		DECLARE_OUT_CLIPPLANE4
//	#define		DECLARE_OUT_CLIPPLANE5

	#define		COMPUTE_CLIPPLANE0(pos)
	#define		COMPUTE_CLIPPLANE1(pos)
	#define		COMPUTE_CLIPPLANE2(pos)
	#define		COMPUTE_CLIPPLANE3(pos)
	#define		COMPUTE_CLIPPLANE4(pos)
//	#define		COMPUTE_CLIPPLANE5(pos)

#endif

	//ゴーストパラメータ
//2010/08/30 nacheon ゴーストテクスチャスクロール削除	#define gVC_GhostTexScrl_0 VR_169
//2010/08/30 nacheon ゴーストテクスチャスクロール削除	#define gVC_GhostTexScrl_1 VR_170
//2010/08/30 nacheon ゴーストテクスチャスクロール削除	uniform float4 gVC_GhostTexScrl_0 : VC_REG(c169);	//!<ゴーストテクスチャスクロール
//2010/08/30 nacheon ゴーストテクスチャスクロール削除	uniform float4 gVC_GhostTexScrl_1 : VC_REG(c170);	//!<ゴーストテクスチャスクロール



#else //UNMODIFIED

	float4x4 gVC_WorldViewClipMtx : VC_REG(c0);
	float4 gVC_CameraPos : VC_REG(c4);
	float4 gVC_WindParam_0 : VC_REG(c5);
	float4 gVC_WindParam_1 : VC_REG(c6);
	float4 gVC_FogParam : VC_REG(c7);
	float4x4 gVC_CommonREG8 : VC_REG(c8);
	float4x4 gVC_CommonREG12 : VC_REG(c12);
	float4x4 gVC_ShadowMapMtx : VC_REG(c16);
	float4 gVC_WaterTileScale : VC_REG(c20);
	float4 gVC_WaterWaveParam : VC_REG(c21);
	float4 gVC_SnowTileScale : VC_REG(c22);
	float4 gVC_SnowDetailBumpTileScale : VC_REG(c23);
	float4 gVC_SnowDiffuseTileScale : VC_REG(c24);
	float4 gVC_TexScrl_0 : VC_REG(c25);
	float4 gVC_TexScrl_1 : VC_REG(c26);
	float4 gVC_ModelMulCol : VC_REG(c27);
	row_major float3x4 gVC_LocalWorldMtxArray[38] : VC_REG(c28);
	row_major float3x4 gVC_prevLocalWorldMtxArray[38] : VC_REG(c142);

#endif //UNMODIFIED


#ifdef _PS3
	#ifdef CLIPPLANE_ENABLE
		#define	__DECL_VertexShader( FuncName, _in )	FuncName(_in, DECLARE_OUT_CLIPPLANE0)
	#else
		#define	__DECL_VertexShader( FuncName, _in )	FuncName(_in)
	#endif
#else
	#define	__DECL_VertexShader( FuncName, _in )		FuncName(_in)
#endif

#endif //___FRPG_Flver_FRPG_Common_VC_fxh___

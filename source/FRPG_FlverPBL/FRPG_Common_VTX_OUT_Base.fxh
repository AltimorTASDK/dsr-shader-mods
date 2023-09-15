//下記の組み合わせ
//#define WITH_GhostMap	//!<ゴーストマップあり
//#define WITH_BumpMap	//!<バンプマップあり
//#define WITH_LightMap	//!<ライトマップあり
//#define WITH_ShadowMap	//!<シャドウマップあり



//シングルテクスチャ
#ifdef WITH_GhostMap
	#ifdef WITH_BumpMap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NET_DLGG
			#else
				struct VTX_OUT_CW_NET_DLGG
			#endif
		#else
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NET_DGG
			#else
				struct VTX_OUT_CW_NET_DGG
			#endif
		#endif
	#else
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NE_DLGG
			#else
				struct VTX_OUT_CW_NE_DLGG
			#endif
		#else
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NE_DGG
			#else
				struct VTX_OUT_CW_NE_DGG
			#endif
		#endif
	#endif
#else
	#ifdef WITH_BumpMap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NET_DL
			#else
				struct VTX_OUT_CW_NET_DL
			#endif
		#else
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NET_D
			#else
				struct VTX_OUT_CW_NET_D
			#endif
		#endif
	#else
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NE_DL
			#else
				struct VTX_OUT_CW_NE_DL
			#endif
		#else
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NE_D
			#else
				struct VTX_OUT_CW_NE_D
			#endif
		#endif
	#endif
#endif
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		float4 VtxWld : TEXCOORD0;	//!<頂点座標(ワールド空間)(xyz:ワールド空間での位置, w:View空間でのZ)
		#ifdef WITH_ShadowMap
			float4 VtxLit : TEXCOORD1;	//!<頂点座標(ライト空間)
		#endif

		float4 VecNrm : TEXCOORD2;	//!<法線(xyz:法線, w:フォグ係数)
		float4 VecEye : TEXCOORD3;	//!<視線ベクトル(ワールド空間)(xyz:正規化済み頂点→カメラベクトル, w:頂点→カメラ距離)
		#ifdef WITH_BumpMap
			float4 VecTan : TEXCOORD4;
			#ifdef CALC_VS_BINORMAL
				float3 VecBin : TEXCOORD5;
			#endif
		#endif

		float4 ColVtx : COLOR;	//!<頂点色

		#ifdef WITH_LightMap
			float4 TexDifLit : TEXCOORD6;	//!<ディフューズUV＋ライトマップUV
			#ifndef VSLS
			#ifdef WITH_GhostMap
//2010/08/30 nacheon ゴーストテクスチャスクロール削除				float4 TexGstGst : TEXCOORD7;	//!<ゴーストUV＋ゴーストUV
			#endif
			#endif//VSLS
		#else
			float2 TexDif : TEXCOORD6;	//!<ディフューズUV
			#ifndef VSLS
			#ifdef WITH_GhostMap
//2010/08/30 nacheon ゴーストテクスチャスクロール削除				float4 TexGstGst : TEXCOORD7;	//!<ゴーストUV＋ゴーストUV
			#endif
			#endif//VSLS
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







//マルチテクスチャ
#ifdef WITH_GhostMap
	#ifdef WITH_BumpMap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NETT_DDLGG
			#else
				struct VTX_OUT_CW_NETT_DDLGG
			#endif
		#else
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NETT_DDGG
			#else
				struct VTX_OUT_CW_NETT_DDGG
			#endif
		#endif
	#else
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NE_DDLGG
			#else
				struct VTX_OUT_CW_NE_DDLGG
			#endif
		#else
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NE_DDGG
			#else
				struct VTX_OUT_CW_NE_DDGG
			#endif
		#endif
	#endif
#else
	#ifdef WITH_BumpMap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NETT_DDL
			#else
				struct VTX_OUT_CW_NETT_DDL
			#endif
		#else
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NETT_DD
			#else
				struct VTX_OUT_CW_NETT_DD
			#endif
		#endif
	#else
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NE_DDL
			#else
				struct VTX_OUT_CW_NE_DDL
			#endif
		#else
			#ifdef WITH_ShadowMap
				struct VTX_OUT_CWL_NE_DD
			#else
				struct VTX_OUT_CW_NE_DD
			#endif
		#endif
	#endif
#endif
	{
		float4 VtxClp : SV_Position;	//!<頂点座標(クリップ空間)
		float4 VtxWld : TEXCOORD0;	//!<頂点座標(ワールド空間)(xyz:ワールド空間での位置, w:View空間でのZ)
		#ifdef WITH_ShadowMap
			float4 VtxLit : TEXCOORD1;	//!<頂点座標(ライト空間)
		#endif

		float4 VecNrm : TEXCOORD2;	//!<法線(xyz:法線, w:フォグ係数)
		float4 VecEye : TEXCOORD3;	//!<視線ベクトル(ワールド空間)(xyz:正規化済み頂点→カメラベクトル, w:頂点→カメラ距離)
		#ifdef WITH_BumpMap
			float4 VecTan : TEXCOORD4;
			float4 VecTan2 : TEXCOORD5;
			
			#ifdef CALC_VS_BINORMAL
				float3 VecBin : TEXCOORD8;
				float3 VecBin2 : TEXCOORD9;
			#endif
		#endif

		float4 ColVtx : COLOR;	//!<頂点色

		#ifdef WITH_LightMap
			float4 TexDifDif : TEXCOORD6;	//!<ディフューズUV＋ディフューズUV
			float2 TexLit : TEXCOORD7;	//!<ライトマップUV
			#ifndef VSLS
			#ifdef WITH_GhostMap
//2010/08/30 nacheon ゴーストテクスチャスクロール削除				float4 TexGstGst : TEXCOORD8;	//!<ゴーストUV＋ゴーストUV
			#endif
			#endif //VSLS
		#else
			float4 TexDifDif : TEXCOORD6;	//!<ディフューズUV＋ディフューズUV
			#ifndef VSLS
			#ifdef WITH_GhostMap
//2010/08/30 nacheon ゴーストテクスチャスクロール削除				float4 TexGstGst : TEXCOORD7;	//!<ゴーストUV＋ゴーストUV
			#endif
			#endif //VSLS
		#endif		
		
		#ifdef VSLS //消したほうが、、LightScatteringをVSでするのは厳しい
			float3 LsMul : TEXCOORD8;	
			float3 LsAdd : COLOR1;	
		#endif //VSLS

		#if defined(_DX11) && defined(WITH_ClipPlane)
			float oClip0 : SV_ClipDistance0; 
		#endif

		#if defined(_DX11) && defined(_FRAGMENT_SHADER)
			bool isFrontFace : SV_IsFrontFace; //works better on PS4
		#endif
	};






















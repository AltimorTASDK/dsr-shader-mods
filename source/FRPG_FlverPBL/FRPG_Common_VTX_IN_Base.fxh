//下記の組み合わせ
//#define WITH_BumpMap	//!<バンプマップあり
//#define WITH_LightMap	//!<ライトマップあり
//#define WITH_Skin	//!<スキンあり



//シングルテクスチャ
#ifdef WITH_BumpMap
	#ifdef WITH_LightMap
		#ifdef WITH_Skin
			struct VTX_IN_PIWNT_DL
		#else
			struct VTX_IN_PINT_DL
		#endif
	#else
		#ifdef WITH_Skin
			struct VTX_IN_PIWNT_D
		#else
			struct VTX_IN_PINT_D
		#endif
	#endif
#else
	#ifdef WITH_LightMap
		#ifdef WITH_Skin
			struct VTX_IN_PIWN_DL
		#else
			struct VTX_IN_PIN_DL
		#endif
	#else
		#ifdef WITH_Skin
			struct VTX_IN_PIWN_D
		#else
			struct VTX_IN_PIN_D
		#endif
	#endif
#endif
	{
		float3 VecPos : POSITION;
		uint4 BlendIdx : BLENDINDICES;	//!<ローカル→ワールド行列インデックス(TODのときは全要素同値)
		#ifdef WITH_Skin
			float4 BlendWeight : BLENDWEIGHT;
		#endif
		float3 VecNrm : NORMAL;
		#ifdef WITH_BumpMap
			float4 VecTan : TANGENT;
		#endif

		float4 ColVtx : COLOR0;	//!<頂点色

		#ifdef WITH_LightMap
			QLOC_int4 TexDifLit_int_qloc : TEXCOORD0;	//!<ディフューズUV＋ライトマップUV
		#else
			QLOC_int2 TexDif_int_qloc : TEXCOORD0;	//!<ディフューズUV
		#endif

		#ifdef WITH_Wind
			QLOC_int4 WindParam : TEXCOORD1;
		#endif
	};




//マルチテクスチャ
#ifdef WITH_BumpMap
	#ifdef WITH_LightMap
		#ifdef WITH_Skin
			struct VTX_IN_PIWNTT_DDL
		#else
			struct VTX_IN_PINTT_DDL
		#endif
	#else
		#ifdef WITH_Skin
			struct VTX_IN_PIWNTT_DD
		#else
			struct VTX_IN_PINTT_DD
		#endif
	#endif
#else
	#ifdef WITH_LightMap
		#ifdef WITH_Skin
			struct VTX_IN_PIWN_DDL
		#else
			struct VTX_IN_PIN_DDL
		#endif
	#else
		#ifdef WITH_Skin
			struct VTX_IN_PIWN_DD
		#else
			struct VTX_IN_PIN_DD
		#endif
	#endif
#endif
	{
		float3 VecPos : POSITION;
		uint4 BlendIdx : BLENDINDICES;	//!<ローカル→ワールド行列インデックス(TODのときは全要素同値)
		#ifdef WITH_Skin
			float4 BlendWeight : BLENDWEIGHT;
		#endif
		float3 VecNrm : NORMAL;
		#ifdef WITH_BumpMap
			float4 VecTan : TANGENT;
			float4 VecTan2 : BINORMAL;//実際にはTANGENT
		#endif

		float4 ColVtx : COLOR0;	//!<頂点色

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
	};
















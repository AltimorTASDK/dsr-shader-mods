/***************************************************************************//**

	@file		FRPG_ShadowFunc.fxh
	@brief		<ファイルの説明>
	@par 		<ファイルの詳細な説明>
	@author		takada
	@version	v1.0

	@note		//<ポート元情報>

	@note		//<ポート元著作権表記>

	@note		//<フロム・ソフトウエア著作権表記>

	Copyright &copy; @YEAR@ FromSoftware, Inc.

*//****************************************************************************/
/*!
	@par
*/
#ifndef ___FRPG_Shader_FRPG_ShadowFunc_fxh___
#define ___FRPG_Shader_FRPG_ShadowFunc_fxh___

//#define		SHADOWMAP_SIZE			(1024.0f+512.0f)	// (1024.0f+512.0f)から最適化のためサイズ縮小。
#define		SHADOWMAP_SIZE			2048.0f//(1024.0f)	//
#define		_ENABLE_SHADOW			(1)

#define M_PI 3.1415926535897932384626433832795

#define SOFT_SHADOW_WIDTH 0.01
#define SOFT_SHADOW_SAMPLES 32

//FRPG_Commonに移動//#define gSMP_ShadowMap	gSMP_7	//シャドウマップ用サンプラ


#ifndef		CUBESHADOWMAP_ENABLE

#ifdef _PS3
	//	Percentage Closer Filtering
	//	nVidiaのGPUはPercentage Closer Filteringは無償で行えます
	HALF __GetShadowRate_PCF4( float4 position_in_light  )
	{
		//	tex2DProjじゃないといけないと何かに書いてあった気がします
		HALF	shadowed = tex2Dproj( gSMP_ShadowMap , position_in_light ).x;
		return	shadowed;
	}

	HALF __GetShadowRate_PCF16( float4 position_in_light  )
	{
		//	1テクセル分のオフセット
		float	offset = 1.0f / SHADOWMAP_SIZE;
		float4	aOffsets[] = {
			float4( 0 ,		0,			0 , 0 ),
			float4( 0 , offset,			0 , 0 ),
			float4( 0 , -offset,		0 , 0 ),
			float4( -offset , 0,		0 , 0 ),
			float4( -offset , -offset,  0 , 0 ),
			float4( -offset , offset,	0 , 0 ),
			float4( offset , 0,			0 ,	0 ),
			float4( offset , -offset,	0 , 0 ),
			float4( offset , offset,	0 , 0 ),
		};
		HALF	shadowed = 0 ;
		for ( int i = 0 ; i < 9 ; ++i )
			shadowed += tex2Dproj( gSMP_ShadowMap , position_in_light + aOffsets[i] * position_in_light.w ).x;
		return	shadowed / 9.0f;
	}

	HALF __GetShadowRate_PCF9( float4 position_in_light  )
	{
		//	0.5テクセル分のオフセット
		float	offset = 0.5f / SHADOWMAP_SIZE;
		float4	aOffsets[] = {
			float4( -offset ,-offset,	0 , 0 ),
			float4( -offset , offset,	0 , 0 ),
			float4( offset  , -offset,	0 ,	0 ),
			float4( offset  , offset,	0 , 0 ),
		};
		HALF	shadowed = 0 ;
		for ( int i = 0 ; i < 4 ; ++i )
			shadowed += tex2Dproj( gSMP_ShadowMap , position_in_light + aOffsets[i] * position_in_light.w ).x;
		return	shadowed / 4.0f;
	}

	HALF __GetShadowRate_PCF16L( float4 position_in_light  )
	{
		//	1テクセル分のオフセット
		float	offset = 1.0f / SHADOWMAP_SIZE;
		float4	aOffsets[] = {
			float4( -offset ,-offset,	0 , 0 ),
			float4( -offset , offset,	0 , 0 ),
			float4( offset  , -offset,	0 ,	0 ),
			float4( offset  , offset,	0 , 0 ),
		};
		HALF	shadowed = 0 ;
		//shadowed += tex2Dproj( gSMP_ShadowMap , position_in_light ).x;
		for ( int i = 0 ; i < 4 ; ++i )
			shadowed += tex2Dproj( gSMP_ShadowMap , position_in_light + aOffsets[i] * position_in_light.w ).x;
		return	shadowed / 4.0f;
	}


	HALF __GetShadowRate_Rotated4( float4 position_in_light  )
	{
		//	1テクセル分のオフセット
		float	offset = 0.7f / SHADOWMAP_SIZE;
		float	gap    = 0.2f / SHADOWMAP_SIZE;

		float4	aOffsets[] = {
			float4( -offset , gap   ,	0 , 0 ),
			float4(  gap    , offset,	0 , 0 ),
			float4( offset  , -gap,	0 ,	0 ),
			float4( -gap    , -offset,	0 , 0 ),
		};
		HALF	shadowed = 0 ;
		for ( int i = 0 ; i < 4 ; ++i )
			shadowed += tex2Dproj( gSMP_ShadowMap , position_in_light + aOffsets[i] * position_in_light.w ).x;
		return	shadowed / 4.0f;
	}

	HALF __GetShadowRate_PossonDisc9( float4 position_in_light  )
	{
		//	2テクセル分のオフセット
		float	offset = position_in_light.w * 2.0f / SHADOWMAP_SIZE;
		const float4	poissonDisc[9] = {
									float4( 0 , 0 , 0 , 0 ),
									//float4(-0.326212f, -0.40581f	, 0 , 0  ),
									//float4(-0.840144f, -0.07358f	, 0 , 0  ),
									float4(-0.695914f,  0.457137f	, 0 , 0 ),
									float4(-0.203345f,  0.620716f	, 0 , 0 ),
									float4( 0.96234f,  -0.194983f	, 0 , 0 ),
									float4( 0.473434f, -0.480026f	, 0 , 0 ),
									float4( 0.519456f,  0.767022f	, 0 , 0 ),
									float4( 0.185461f, -0.893124f	, 0 , 0 ),
									float4( 0.507431f,  0.064425f	, 0 , 0 ),
									//float4( 0.89642f,   0.412458f , 0 , 0 ),
									//float4(-0.32194f,  -0.932615f , 0 , 0 ),
									float4(-0.791559f, -0.59771f	, 0 , 0 )	};

		HALF	shadowed = 0 ;
		for ( int i = 0 ; i < 9 ; ++i )
			shadowed += tex2Dproj( gSMP_ShadowMap , position_in_light + poissonDisc[i] * offset ).x / 9.0f;
		return	shadowed;
	}
	HALF __GetShadowRate_PossonDiscN( float4 position_in_light , int N )
	{
		//	2テクセル分のオフセット
		//float	offset = position_in_light.w * 2.0f / SHADOWMAP_SIZE;
		float	offset = position_in_light.w * 1.0f / SHADOWMAP_SIZE;
		const float4	poissonDisc[9] = {
									float4( 0 , 0 , 0 , 0 ),
									//float4(-0.326212f, -0.40581f	, 0 , 0  ),
									//float4(-0.840144f, -0.07358f	, 0 , 0  ),
									float4(-0.695914f,  0.457137f	, 0 , 0 ),
									float4(-0.203345f,  0.620716f	, 0 , 0 ),
									float4( 0.96234f,  -0.194983f	, 0 , 0 ),
									float4( 0.473434f, -0.480026f	, 0 , 0 ),
									float4( 0.519456f,  0.767022f	, 0 , 0 ),
									float4( 0.185461f, -0.893124f	, 0 , 0 ),
									float4( 0.507431f,  0.064425f	, 0 , 0 ),
									//float4( 0.89642f,   0.412458f , 0 , 0 ),
									//float4(-0.32194f,  -0.932615f , 0 , 0 ),
									float4(-0.791559f, -0.59771f	, 0 , 0 )	};

		HALF	shadowed = 0 ;
		for ( int i = 0 ; i < N ; ++i )
			shadowed += tex2Dproj( gSMP_ShadowMap , position_in_light + poissonDisc[i] * offset ).x;
		return	shadowed / (float)N;
	}
	HALF __GetShadowRate_PossonDisc8( float4 position_in_light  )
	{
		return __GetShadowRate_PossonDiscN( position_in_light , 8 );
	}
	HALF __GetShadowRate_PossonDisc7( float4 position_in_light  )
	{
		return __GetShadowRate_PossonDiscN( position_in_light , 7 );
	}
	HALF __GetShadowRate_PossonDisc6( float4 position_in_light  )
	{
		return __GetShadowRate_PossonDiscN( position_in_light , 6 );
	}
	HALF __GetShadowRate_PossonDisc5( float4 position_in_light  )
	{
		return __GetShadowRate_PossonDiscN( position_in_light , 5 );
	}
	HALF __GetShadowRate_PossonDisc4( float4 position_in_light  )
	{
		return __GetShadowRate_PossonDiscN( position_in_light , 4 );
	}
	HALF __GetShadowRate_PossonDisc3( float4 position_in_light  )
	{
		return __GetShadowRate_PossonDiscN( position_in_light , 3 );
	}
#endif //_PS3











#ifdef _X360
	HALF __GetShadowRate_PCF4( float4 position_in_light  )
	{
		float3 vShadowCoord = position_in_light.xyz/position_in_light.w;
		float4 SampledDepth;
		float4 Weights;
		asm {
			tfetch2D SampledDepth.x___, vShadowCoord.xy, gSMP_ShadowMap, OffsetX = -0.5, OffsetY = -0.5
			tfetch2D SampledDepth._x__, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  0.5, OffsetY = -0.5
			tfetch2D SampledDepth.__x_, vShadowCoord.xy, gSMP_ShadowMap, OffsetX = -0.5, OffsetY =  0.5
			tfetch2D SampledDepth.___x, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  0.5, OffsetY =  0.5

//			getWeights2D Weights, vShadowCoord.xy, DepthTex, MagFilter=linear, MinFilter=linear, UseComputedLOD=false, UseRegisterLOD=true
		};
//	    Weights = float4( (1-Weights.x)*(1-Weights.y), Weights.x*(1-Weights.y), (1-Weights.x)*Weights.y, Weights.x*Weights.y );
//		float4 Attenuation = step( vShadowCoord.z, SampledDepth );

		//とりあえずリニアにはしない
		Weights = 0.25f;
		float4 Attenuation = (vShadowCoord.zzzz< SampledDepth); //Depth値が小さいとかげになる、 Depthが反転しているので

		return dot( Attenuation, Weights );
	}

	HALF __GetShadowRate_PCF9( float4 position_in_light  )
	{
		float3 vShadowCoord = position_in_light.xyz/position_in_light.w;
		float4 SampledDepth;
		float SampledDepth2;

		asm {
			tfetch2D SampledDepth.x___, vShadowCoord.xy, gSMP_ShadowMap, OffsetX = -1.0, OffsetY = -1.0
			tfetch2D SampledDepth._x__, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  0.0, OffsetY = -1.0
			tfetch2D SampledDepth.__x_, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  1.0, OffsetY = -1.0
			tfetch2D SampledDepth.___x, vShadowCoord.xy, gSMP_ShadowMap, OffsetX = -1.0, OffsetY =  0.0
		};
		float4 Attenuation = (vShadowCoord.zzzz< SampledDepth); //Depth値が小さいとかげになる、 Depthが反転しているので
		HALF shadowed = dot( Attenuation, 1.0f);

		asm {
			tfetch2D SampledDepth.x___, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  0.0, OffsetY = 0.0
			tfetch2D SampledDepth._x__, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  1.0, OffsetY = 0.0
			tfetch2D SampledDepth.__x_, vShadowCoord.xy, gSMP_ShadowMap, OffsetX = -1.0, OffsetY = 1.0
			tfetch2D SampledDepth.___x, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  0.0, OffsetY = 1.0

			tfetch2D SampledDepth2	   , vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  1.0, OffsetY = 1.0
		};
		Attenuation = (vShadowCoord.zzzz< SampledDepth); //Depth値が小さいとかげになる、 Depthが反転しているので
		float  Attenuation2 = (vShadowCoord.z< SampledDepth2);
		shadowed += dot( Attenuation, 1.0f) + Attenuation2;

		return shadowed/9.0f;
	}


	HALF __GetShadowRate_PCF16( float4 position_in_light  )
	{
		float3 vShadowCoord = position_in_light.xyz/position_in_light.w;
		float4 SampledDepth;

		asm {
			tfetch2D SampledDepth.x___, vShadowCoord.xy, gSMP_ShadowMap, OffsetX = -1.5, OffsetY = -1.5
			tfetch2D SampledDepth._x__, vShadowCoord.xy, gSMP_ShadowMap, OffsetX = -0.5, OffsetY = -1.5
			tfetch2D SampledDepth.__x_, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  0.5, OffsetY = -1.5
			tfetch2D SampledDepth.___x, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  1.5, OffsetY = -1.5
		};
		float4 Attenuation = (vShadowCoord.zzzz< SampledDepth); //Depth値が小さいとかげになる、 Depthが反転しているので
		HALF shadowed = dot( Attenuation, 1.0f);

		asm {
			tfetch2D SampledDepth.x___, vShadowCoord.xy, gSMP_ShadowMap, OffsetX = -1.5, OffsetY = -0.5
			tfetch2D SampledDepth._x__, vShadowCoord.xy, gSMP_ShadowMap, OffsetX = -0.5, OffsetY = -0.5
			tfetch2D SampledDepth.__x_, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  0.5, OffsetY = -0.5
			tfetch2D SampledDepth.___x, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  1.5, OffsetY = -0.5
		};
		Attenuation = (vShadowCoord.zzzz< SampledDepth);
		shadowed += dot( Attenuation, 1.0f);

		asm {
			tfetch2D SampledDepth.x___, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  0.5, OffsetY = 0.5
			tfetch2D SampledDepth._x__, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  0.5, OffsetY = 0.5
			tfetch2D SampledDepth.__x_, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  0.5, OffsetY = 0.5
			tfetch2D SampledDepth.___x, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  0.5, OffsetY = 0.5
		};
		Attenuation = (vShadowCoord.zzzz< SampledDepth);
		shadowed += dot( Attenuation, 1.0f);

		asm {
			tfetch2D SampledDepth.x___, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  1.5, OffsetY = 1.5
			tfetch2D SampledDepth._x__, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  1.5, OffsetY = 1.5
			tfetch2D SampledDepth.__x_, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  1.5, OffsetY = 1.5
			tfetch2D SampledDepth.___x, vShadowCoord.xy, gSMP_ShadowMap, OffsetX =  1.5, OffsetY = 1.5
		};
		Attenuation = (vShadowCoord.zzzz< SampledDepth);
		shadowed += dot( Attenuation, 1.0f);

		return shadowed/16.0f;
	}
#endif //#ifdef _X360




#ifdef _WIN32
	//QLOC: rewritten with new capabilities (DX11,ORBIS)
	float DecodeDepthCmp(const float3 uvw) {
		return gSMP_ShadowMap.SampleCmp(gSMP_ShadowMapSampler, uvw.xy, uvw.z).x;
	}
	float DecodeDepthCmp(const float3 uvw, const int2 offset) {
		return gSMP_ShadowMap.SampleCmp(gSMP_ShadowMapSampler, uvw.xy, uvw.z, offset).x;
	}
	float __GetShadowRate_PCF4(const float4 position_in_light)
	{
		float retval = 0.0f;
		const float3 vShadowCoord = position_in_light.xyz/position_in_light.w;
		retval += DecodeDepthCmp(vShadowCoord);

		return retval;
	}

	float __GetShadowRate_PCF9(const float4 position_in_light)
	{
		float retval = 0.0f;
		const float3 vShadowCoord = position_in_light.xyz/position_in_light.w;
		const float4 weight = 1.0f / 4.0f;
		{
			const float4 attenuation = float4(
				DecodeDepthCmp(vShadowCoord, int2(0, 0)),
				DecodeDepthCmp(vShadowCoord, int2(1, 0)),
				DecodeDepthCmp(vShadowCoord, int2(0, 1)),
				DecodeDepthCmp(vShadowCoord, int2(1, 1))
			);
			retval += dot(attenuation, weight).x;
		}

		return retval;
	}


	float __GetShadowRate_PCF16(const float4 position_in_light)
	{
		float retval = 0.0f;
		const float3 vShadowCoord = position_in_light.xyz/position_in_light.w;
		const float4 weight = 1.0f / 9.0f;
		{
			const float4 attenuation = float4(
				DecodeDepthCmp(vShadowCoord, int2(-1, -1)),
				DecodeDepthCmp(vShadowCoord, int2( 0, -1)),
				DecodeDepthCmp(vShadowCoord, int2( 1, -1)),
				DecodeDepthCmp(vShadowCoord, int2(-1,  0))
			);
			retval += dot(attenuation, weight).x;
		}
		{
			const float4 attenuation = float4(
				DecodeDepthCmp(vShadowCoord, int2(0, 0)),
				DecodeDepthCmp(vShadowCoord, int2(1, 0)),
				DecodeDepthCmp(vShadowCoord, int2(-1, 1)),
				DecodeDepthCmp(vShadowCoord, int2(0, 1))
			);
			retval += dot(attenuation, weight).x;
		}
		{
			const float attenuation = (
				DecodeDepthCmp(vShadowCoord, int2(1,1))
				);
			retval += attenuation * weight.x;
		}

		return retval;
	}
#endif //#ifdef _WIN32




	//	関数を生成するマクロ
	#if	1
#define		DECL_SHADOW_FUNC( FuncName , ShadowFunc )										\
		float3		FuncName ( float4 position_in_light , float normalShadow, float4 eyeVec = 0)	\
		{																					\
			float3 rate = 1;																\
			if( _ENABLE_SHADOW ) {															\
				/*	視点からの距離(eyeVec.wに距離が入っている) */							\
				float dist = eyeVec.w;														\
				dist = saturate( ( gFC_ShadowMapParam.y - dist ) * gFC_ShadowMapParam.z ) ;	\
				/* 一定距離以上離れたら、薄くしていく */									\
				/*rate = 1- ((float3)dist) * gFC_ShadowColor.xyz * ShadowFunc( position_in_light.xyzw );*/ 		\
				float fShadow = ShadowFunc( position_in_light.xyzw ) + normalShadow;\
				fShadow = saturate(fShadow);\
				rate = 1- ((float3)dist) * gFC_ShadowColor.xyz * fShadow;\
			}																				\
			return rate;																	\
		}
	#else
#define		DECL_SHADOW_FUNC( FuncName , ShadowFunc )										\
		float3		FuncName ( float4 position_in_light , float4 eyeVec = 0 )				\
		{																					\
			float3 rate = 1;																\
			if( _ENABLE_SHADOW ) {															\
				rate = 1- ((float3)1) * gFC_ShadowColor.xyz *  ShadowFunc( position_in_light.xyzw );		\
			}																				\
			return rate;																	\
		}

	#endif



#ifdef _PS3
DECL_SHADOW_FUNC( GetShadowRate_PCF4 , 		__GetShadowRate_PCF4 )
DECL_SHADOW_FUNC( GetShadowRate_PCF9  , 	__GetShadowRate_PCF9 )
//DECL_SHADOW_FUNC( GetShadowRate_PCF16 , 	__GetShadowRate_PCF16 )
DECL_SHADOW_FUNC( GetShadowRate_PCF16  , 	__GetShadowRate_PCF16L )
DECL_SHADOW_FUNC( GetShadowRate_PossonDisc9 , 	__GetShadowRate_PossonDisc9 )
DECL_SHADOW_FUNC( GetShadowRate_PossonDisc8 , 	__GetShadowRate_PossonDisc8 )
DECL_SHADOW_FUNC( GetShadowRate_PossonDisc7 , 	__GetShadowRate_PossonDisc7 )
DECL_SHADOW_FUNC( GetShadowRate_PossonDisc6 , 	__GetShadowRate_PossonDisc6 )
DECL_SHADOW_FUNC( GetShadowRate_PossonDisc5 , 	__GetShadowRate_PossonDisc5 )
DECL_SHADOW_FUNC( GetShadowRate_PossonDisc4 , 	__GetShadowRate_PossonDisc4 )
DECL_SHADOW_FUNC( GetShadowRate_PossonDisc3 , 	__GetShadowRate_PossonDisc3 )
DECL_SHADOW_FUNC( GetShadowRate_Rotated4    , 	__GetShadowRate_Rotated4    )
#endif

#ifdef _X360
DECL_SHADOW_FUNC( GetShadowRate_PCF4 , 		__GetShadowRate_PCF4 )
DECL_SHADOW_FUNC( GetShadowRate_PCF9  , 	__GetShadowRate_PCF9 )
DECL_SHADOW_FUNC( GetShadowRate_PCF16 , 	__GetShadowRate_PCF16 )
#endif

#ifdef _WIN32
DECL_SHADOW_FUNC( GetShadowRate_PCF4 , 		__GetShadowRate_PCF4 )
DECL_SHADOW_FUNC( GetShadowRate_PCF9  , 	__GetShadowRate_PCF9 )
DECL_SHADOW_FUNC( GetShadowRate_PCF16 , 	__GetShadowRate_PCF16 )
#endif

	float2 VogelDiskSample(int index, float phi)
	{
		static const float goldenAngle = 2.4;
		float r = sqrt(index + 0.5) / sqrt(SOFT_SHADOW_SAMPLES);
		float theta = index * goldenAngle + phi;
		return float2(r * cos(theta), r * sin(theta));
	}

	float NoisePhi(float2 uv)
	{
		return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453) * (2 * M_PI);
	}

	/*float CalcPenumbra(float4 litPosition, float noisePhi)
	{
		for (int i = 0; i < SOFT_SHADOW_SAMPLES; i++)
		{
			float2 uv = litPosition.xy + SOFT_SHADOW_WIDTH * VogelDiskSample(i, phi);
		}
	}*/

	float3 GetShadowRateSoft_PCF16(float2 fragCoord, float4 litPosition, float normalShadow, float4 eyeVec = 0)
	{
		float3 rate = 1;
		if( _ENABLE_SHADOW ) {
			/*	視点からの距離(eyeVec.wに距離が入っている) */
			float dist = eyeVec.w;
			dist = saturate((gFC_ShadowMapParam.y - dist) * gFC_ShadowMapParam.z);

			float fShadow = 0.0;
			float noisePhi = NoisePhi(litPosition.xy);
			float4 offsetPosition = litPosition;

			for (int i = 0; i < SOFT_SHADOW_SAMPLES; i++) {
				float2 offset = VogelDiskSample(i, noisePhi);
				offsetPosition.xy = litPosition.xy + offset * SOFT_SHADOW_WIDTH * litPosition.w;
				fShadow += __GetShadowRate_PCF16(offsetPosition);
			}

			fShadow = saturate(fShadow * (1.0 / SOFT_SHADOW_SAMPLES) + normalShadow);
			rate = 1 - ((float3)dist) * gFC_ShadowColor.xyz * fShadow;
		}
		return rate;
	}

	float3	CalcGetShadowRate( float4 position_in_light, float3 normal, float4 eyeVec = 0)
	{
		float NdotL = dot( gFC_ShadowLightDir.xyz, normal);
		float fShadow = (NdotL+gFC_ShadowMapParam.x) * gFC_ShadowMapParam.w; //gFC_ShadowMapParam.w　影を落とすモデルかどうか　1:おとす。0:落とさない
		fShadow = saturate(fShadow);
		return pow(abs(GetShadowRate_PCF16(position_in_light, fShadow, eyeVec)), gFC_DebugPointLightParams.z);

//		float dbgNewShadow = (gFC_ShadowMapParam.x > -1.0f);
//
//		float3 retVal = GetShadowRate_PCF16L( position_in_light , fShadow, eyeVec) * dbgNewShadow;
//		retVal += GetShadowRate_PCF4( position_in_light , 0.0f, eyeVec) * (1.0f-dbgNewShadow);
//		return retVal;
	}

	float3 CalcGetShadowRateSoft(float2 fragCoord, float4 position_in_light, float3 normal, float4 eyeVec = 0)
	{
		float NdotL = dot( gFC_ShadowLightDir.xyz, normal);
		float fShadow = (NdotL+gFC_ShadowMapParam.x) * gFC_ShadowMapParam.w; //gFC_ShadowMapParam.w　影を落とすモデルかどうか　1:おとす。0:落とさない
		fShadow = saturate(fShadow);
		return pow(abs(GetShadowRateSoft_PCF16(fragCoord, position_in_light, fShadow, eyeVec)), gFC_DebugPointLightParams.z);
	}

	//VertexShaderで　World空間での位置をShadowMap空間に変換する
	//ジオメトリが一個のShadowMap空間完全含まれた時
	//ClampのみはPIXELで行う
	float3 CalcGetShadowRateLitSpace(float2 fragCoord, float4 position_in_light, float3 normal, float4 eyeVec = 0)
	{
		float4 clamp_qloc_renamed = gFC_ShadowMapClamp0;
		clamp_qloc_renamed *= position_in_light.w;

		// Clamp
		position_in_light.xy -= (position_in_light.xy < clamp_qloc_renamed.xy)*position_in_light.w; //画面外に
		position_in_light.xy += (position_in_light.xy > clamp_qloc_renamed.zw)*position_in_light.w;

		return CalcGetShadowRateSoft(fragCoord, position_in_light, normal, eyeVec);
	}


	//PixelShaderで　PixelのWorld空間での位置をShadowMap空間に変換する Cascade
	float3 CalcGetShadowRateWorldSpace(float2 fragCoord, float4 worldspace_Pos, float3 normal, float4 eyeVec = 0)
	{
		float4x4 shadowMtx;

		//float camDist = eyeVec.w; //カメラからの距離
		float  viewZ = worldspace_Pos.w;

		float4 zGreater = (gFC_ShadowStartDist < viewZ);
		float4 clamp_qloc_renamed = 0;

#if defined(_PS3)//PS3
	#if 0
			int  slice = dot(zGreater, 1.0f ) - 1;

			//float4 pos = mul(worldPos, gFC_ShadowMapMtxArray[slice] );
			if(slice == 0)
			{
				shadowMtx = gFC_ShadowMapMtxArray0;
				clamp_qloc_renamed = gFC_ShadowMapClamp0;
			}
			else if(slice == 1)
			{
				shadowMtx = gFC_ShadowMapMtxArray1;
				clamp_qloc_renamed = gFC_ShadowMapClamp1;
			}
			else if(slice == 2)
			{
				shadowMtx = gFC_ShadowMapMtxArray2;
				clamp_qloc_renamed = gFC_ShadowMapClamp2;
			}
			else //if(slice == 3)
			{
				shadowMtx = gFC_ShadowMapMtxArray3;
				clamp_qloc_renamed = gFC_ShadowMapClamp3;
			}
	#else
			float4 fEndDist = float4(gFC_ShadowStartDist.yzw, 65535.0f);
			float4 zLess = (fEndDist >= viewZ);
			float4 fWeight = zGreater* zLess;

			shadowMtx = gFC_ShadowMapMtxArray0* fWeight.x;
			shadowMtx += gFC_ShadowMapMtxArray1* fWeight.y;
			shadowMtx += gFC_ShadowMapMtxArray2* fWeight.z;
			shadowMtx += gFC_ShadowMapMtxArray3* fWeight.w;

			clamp_qloc_renamed = gFC_ShadowMapClamp0* fWeight.x;
			clamp_qloc_renamed += gFC_ShadowMapClamp1* fWeight.y;
			clamp_qloc_renamed += gFC_ShadowMapClamp2* fWeight.z;
			clamp_qloc_renamed += gFC_ShadowMapClamp3* fWeight.w;
	#endif
#elif defined(_X360) || defined(_DX11)//XBOX360
			int  slice = dot(zGreater, 1.0f ) - 1;
			shadowMtx = gFC_ShadowMapMtxArray[slice];
			clamp_qloc_renamed = gFC_ShadowMapClamp[slice];
#elif defined(_WIN32)//WIN32
			float4 fEndDist = float4(gFC_ShadowStartDist.yzw, 65535.0f);
			float4 zLess = (fEndDist >= viewZ);
			float4 fWeight = zGreater* zLess;

			shadowMtx = gFC_ShadowMapMtxArray0* fWeight.x;
			shadowMtx += gFC_ShadowMapMtxArray1* fWeight.y;
			shadowMtx += gFC_ShadowMapMtxArray2* fWeight.z;
			shadowMtx += gFC_ShadowMapMtxArray3* fWeight.w;

			clamp_qloc_renamed = gFC_ShadowMapClamp0* fWeight.x;
			clamp_qloc_renamed += gFC_ShadowMapClamp1* fWeight.y;
			clamp_qloc_renamed += gFC_ShadowMapClamp2* fWeight.z;
			clamp_qloc_renamed += gFC_ShadowMapClamp3* fWeight.w;
#else
	不明
#endif

		float4  worldPos = float4(worldspace_Pos.xyz, 1.0f);
		float4 position_in_light = mul( worldPos, shadowMtx);

		clamp_qloc_renamed *= position_in_light.w;

		// Clamp
		position_in_light.xy -= (position_in_light.xy < clamp_qloc_renamed.xy)*position_in_light.w; //画面外に
		position_in_light.xy += (position_in_light.xy > clamp_qloc_renamed.zw)*position_in_light.w;

		return CalcGetShadowRateSoft(fragCoord, position_in_light, normal, eyeVec);
	}



	//PixelShaderで　PixelのWorld空間での位置をShadowMap空間に変換する NoCascade
	//CascadeではないけどPixel計算する、水面の影で使う
	//水面の場合HeightMapからの高さでDisplceしているので、一つの影スライスに収まるモデルでも
	//PixelShaderでライト空間位置を計算する。(収まらないのは普通にCascade)
	float3 CalcGetShadowRateWorldSpaceNoCsd( float4 worldspace_Pos, float3 normal, float4 eyeVec = 0)
	{
		float4  worldPos = float4(worldspace_Pos.xyz, 1.0f);
		float4 position_in_light = mul( worldPos, gFC_ShadowMapMtxArray0);
		float4 clamp_qloc_renamed = gFC_ShadowMapClamp0*position_in_light.w;

		// Clamp
		position_in_light.xy -= (position_in_light.xy < clamp_qloc_renamed.xy)*position_in_light.w; //画面外に
		position_in_light.xy += (position_in_light.xy > clamp_qloc_renamed.zw)*position_in_light.w;

		return CalcGetShadowRate( position_in_light, normal, eyeVec);
	}

#define			GetShadowRate_Cube( a )				(1)
//	使っては駄目です。
//	分かりやすい様に変な色にしておく
#define			GetShadowRate_Proj( a )				float3( 1,0,1 )
#define			GetShadowRate_PCT9_xe				GetShadowRate

#else

	//	still not supported!
	#pragma		error
#endif










#endif //___FRPG_Shader_FRPG_ShadowFunc_fxh___

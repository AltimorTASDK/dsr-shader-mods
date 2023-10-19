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
//
//#define WITH_BumpMap	//!<バンプマップあり
//#define WITH_LightMap	//!<ライトマップあり
//#define WITH_ShadowMap	//!<シャドウマップあり
//#define WITH_EnvLerp	//!<環境光源の補間あり


//#define dbgShadow

#if defined(WITH_MultiTexture) && !defined(WITH_SpecularMap)

/*-------------------------------------------------------------------*//*!
@brief フラグメントシェーダ
@par ディフューズ
*/
GBUFFER_OUT FragmentMain(VTX_OUT In)
{
	MATERIAL Mtl;

	Mtl.LitColor = float4(1.0f, 0.f, 1.f, 1.f);
	Mtl.DiffuseColor = float3(0.f, 0.f, 0.f);
	Mtl.SpecularColor = float3(0.f, 0.f, 0.f);
	Mtl.EmissiveColor = float3(0.f, 0.f, 0.f);
	Mtl.Normal = float3(0.f, 0.f, 0.f);
	Mtl.Roughness = 1.0f;
	Mtl.SubsurfStrength = 0.0f;
	Mtl.SubsurfOpacity = 1.0f;

	GBUFFER_OUT Out;
	Out.GBuffer0.a = 1.0f;
#ifdef WITH_Glow
	Mtl.LitColor.rgb = ReverseToneMap(Mtl.LitColor.rgb * gFC_ToneCorrectParams.x);
#endif
	return PackGBuffer(Out, Mtl);
}

#else //defined(WITH_MultiTexture) && !defined(WITH_SpecularMap)

/*-------------------------------------------------------------------*//*!
@brief フラグメントシェーダ
@par ディフューズ
*/
GBUFFER_OUT FragmentMain(VTX_OUT In)
{
	GBUFFER_OUT Out;

#if defined(WITH_MultiTexture)
	float4 difTexUV = In.TexDifDif;
#elif defined(WITH_LightMap)
	float2 difTexUV = In.TexDifLit.xy;
#else
	float2 difTexUV = In.TexDif.xy;
#endif

	{//xyz - view vector, w - camera distance
		In.VecEye = CalcGetVecEye_FS(In.VecEye);
	}

#if defined(WITH_BumpMap) && defined(WITH_Parallax)
	if (gFC_ParallaxParams.x > 0.0f) {
		// qloc: we assume CALC_VS_BINORMAL is set (which is true on all our platforms)
		// also removed other parallax mapping types since we only use this one now
		difTexUV.xy = ParallaxOcclusionMapping(difTexUV.xy, gFC_ParallaxParams.x, In.VecEye.xyz, In.VecTan.xyz, In.VecBin, In.VecNrm.xyz);
	}
#endif //defined(WITH_BumpMap) && defined(WITH_Parallax)

#ifdef WITH_MultiTexture
	float4 sampledColor = TexDiff(difTexUV.xy);
	float4 sampledColor2 = TexDiff2(In.TexDifDif.zw);
	sampledColor2.rgb += gFC_FgSkinAddColor.rgb;
	sampledColor = float4(lerp(sampledColor.rgb, sampledColor2.rgb, In.ColVtx.a), 1.0)*float4(In.ColVtx.rgb, 1.0) * gFC_ModelMulCol;
	sampledColor = qlocDoAlphaTest(sampledColor);
#else //WITH_MultiTexture
	float4 sampledColor = TexDiff(difTexUV);
	sampledColor.rgb += gFC_FgSkinAddColor.rgb;
	sampledColor *= In.ColVtx;
	sampledColor = qlocDoAlphaTest(sampledColor);
#endif //WITH_MultiTexture

	Out.GBuffer0.a = saturate(sampledColor.a);

	//qloc: face is backwards, invert normal
	if (!In.isFrontFace) {
		In.VecNrm.xyz = -In.VecNrm.xyz;
	}
	float3 vertexNormal = In.VecNrm.xyz;

	{//Normal
		#ifdef WITH_BumpMap
			#ifdef WITH_MultiTexture
				#ifdef CALC_VS_BINORMAL
					In.VecNrm.xyz = CalcGetNormal_FromNormalTex_Mul_Bin(TEX2DSAMPLER(gSMP_BumpMap), TEX2DSAMPLER(gSMP_BumpMap2), difTexUV,  In.VecNrm.xyz, In.VecTan, In.VecTan2, In.VecBin, In.VecBin2, In.ColVtx.a);//法線テクスチャから法線算出
				#else//CALC_VS_BINORMAL
					const float3 localVecBin = cross(In.VecNrm.xyz, In.VecTan.xyz)*In.VecTan.w;
					const float3 localVecBin2 = cross(In.VecNrm.xyz, In.VecTan2.xyz)*In.VecTan2.w;
					In.VecNrm.xyz = CalcGetNormal_FromNormalTex_Mul_Bin(TEX2DSAMPLER(gSMP_BumpMap), TEX2DSAMPLER(gSMP_BumpMap2), difTexUV,  In.VecNrm.xyz, In.VecTan, In.VecTan2, localVecBin, localVecBin2, In.ColVtx.a);//法線テクスチャから法線算出
				#endif//CALC_VS_BINORMAL
			#else //WITH_MultiTexture
				#ifdef CALC_VS_BINORMAL
					In.VecNrm.xyz = CalcGetNormal_FromNormalTex_Bin(TEX2DSAMPLER(gSMP_BumpMap), difTexUV, In.VecNrm.xyz, In.VecTan, In.VecBin);	//法線テクスチャから法線算出
				#else//CALC_VS_BINORMAL
					const float3 localVecBin = cross(In.VecNrm.xyz, In.VecTan.xyz)*In.VecTan.w;
					In.VecNrm.xyz = CalcGetNormal_FromNormalTex_Bin(TEX2DSAMPLER(gSMP_BumpMap), difTexUV, In.VecNrm.xyz, In.VecTan, localVecBin);	//法線テクスチャから法線算出
				#endif//CALC_VS_BINORMAL
			#endif //WITH_MultiTexture
		#else
			In.VecNrm.xyz = normalize(In.VecNrm.xyz); //normalization
			APPLY_DETAIL_BUMP(In.VecNrm.xyz, difTexUV.xy); //depends on WITH_DetailBump
		#endif
	}

	float4 lightmapColor = 1.0f; // used for shadowing static map point lights
	{//lightmap and shadowmap
	#ifdef WITH_LightMap
		#ifdef WITH_MultiTexture
			const float2 lightmapUV = In.TexLit.xy;
		#else
			const float2 lightmapUV = In.TexDifLit.zw;
		#endif
		#ifdef WITH_ShadowMap
			//light map + shadow map
			const float4 lightMapVal = TexLightmap(lightmapUV);
			#if WITH_ShadowMap == CalcLispPos_VS
				const float3 shadowMapVal = CalcGetShadowRateLitSpace(In.VtxLit, In.VecNrm.xyz, In.VecEye).rgb;
			#else //WITH_ShadowMap == CalcLispPos_PS
				const float3 shadowMapVal = CalcGetShadowRateWorldSpace(In.VtxWld, In.VecNrm.xyz, In.VecEye).rgb;
			#endif
			lightmapColor.rgb = shadowMapVal.rgb*lightMapVal.rgb*gFC_DebugPointLightParams.y;
			lightmapColor.a = lightMapVal.a*shadowMapVal.r; //QLOC: store shadowing from shadow map too
		#else
			//light map only
			lightmapColor = TexLightmap(lightmapUV) * float4(gFC_DebugPointLightParams.y, gFC_DebugPointLightParams.y, gFC_DebugPointLightParams.y, 1);
		#endif
	#else
		#ifdef WITH_ShadowMap
			//shadow map only
			#if WITH_ShadowMap == CalcLispPos_VS
				const float3 shadowMapVal = CalcGetShadowRateLitSpace(In.VtxLit, In.VecNrm.xyz, In.VecEye).rgb;
			#else //WITH_ShadowMap == CalcLispPos_PS
				const float3 shadowMapVal = CalcGetShadowRateWorldSpace(In.VtxWld, In.VecNrm.xyz, In.VecEye).rgb;
			#endif
			lightmapColor.rgb = shadowMapVal.rgb;
		#endif
	#endif
	}

#if defined(WITH_MultiTexture) && defined(WITH_SpecularMap)
	float4 pblTexData = tex2D(gSMP_PBLMap, difTexUV.xy).rgba;
	float4 pblTexData2 = tex2D(gSMP_PBLMap2, In.TexDifDif.zw).rgba;
	pblTexData = lerp(pblTexData.rgba, pblTexData2.rgba, In.ColVtx.a);
#elif defined(WITH_SpecularMap)
	float4 pblTexData = tex2D(gSMP_PBLMap, difTexUV).rgba;
#else
	float4 pblTexData = float4(1.0f, 0.0f, 0.0f, 1.0f);
#endif

	MATERIAL Mtl = PackMaterial(sampledColor, pblTexData, In.VecNrm.xyz);
#ifdef FS_SUBSURF
#ifdef WITH_SpecularMap
	float2 subsurfData = tex2D(gSMP_Subsurf, difTexUV.xy).rg;
	Mtl.SubsurfStrength = subsurfData.r * gFC_SubsurfaceParam.x;
	Mtl.SubsurfOpacity = TranslucencyScaled(subsurfData.g, gFC_SubsurfaceParam.y);
#else //WITH_SpecularMap
	Mtl.SubsurfStrength = 0.0f;
	Mtl.SubsurfOpacity = 1.0f;
#endif //WITH_SpecularMap
#endif //FS_SUBSURF

	float specularF90 = calcSpecularF90(Mtl.SpecularColor);

	//emissive
	float3 emissiveComponent = CalcEmissive(Mtl);

	//environment directional lights
	float3 envLightComponent = float3(0, 0, 0);

	for (uint i = 0; i < 3; i++) {
		envLightComponent += CalcEnvDirLight(Mtl, gFC_DirLightVec[i], gFC_DirLightCol[i], vertexNormal, In.VecEye.xyz, specularF90, lightmapColor.rgb);
	}

	envLightComponent += CalcEnvDirLightSpc(Mtl, gFC_SpcLightVec, gFC_SpcLightCol, vertexNormal, In.VecEye.xyz, specularF90);

	//ambient diffuse
	float3 hemAmbient = CalcHemAmbient(Mtl.Normal) * AMBIENT_MULTIPLIER;
	envLightComponent += Mtl.DiffuseColor * hemAmbient;

	//ambient specular
	float3 specularLD = CalcSpecularLD(Mtl.Normal, Mtl.Roughness);
	float3 specularAmbient = hemAmbient * (1.0f - AMBIENT_CUBEMAP_STRENGTH + specularLD * AMBIENT_CUBEMAP_STRENGTH);
	envLightComponent += Mtl.SpecularColor * specularAmbient * AMBIENT_SPECULAR_MULTIPLIER;

#if(POINT_LIGHT_0 >POINT_LIGHT_TYPE_None)
	float3 pointLightComponent = CalcPointLightsLegacy(Mtl, vertexNormal, In.VecEye.xyz, In.VtxWld.xyz, specularF90, lightmapColor.a);
#else
	float3 pointLightComponent = CalcPointLightsClustered(Mtl, vertexNormal, In.VecEye.xyz, In.VtxWld.xyz, specularF90, lightmapColor.a);
#endif

	{//Ghost lights
	#ifdef WITH_GhostMap
		float3 L = gFC_GhostLightPos.xyz - In.VtxWld.xyz;
		float distL = length(L);

		pointLightComponent += PointLightContribution(
			Mtl.Normal, vertexNormal, L / distL, In.VecEye.xyz,
			Mtl.DiffuseColor, Mtl.SpecularColor, specularF90,
			Mtl.Roughness, gFC_GhostLightCol.rgb, distL,
			gFC_GhostLightPos.w, gFC_GhostLightCol.w, 0);
	#endif // WITH_GhostMap
	}

	float3 lightComponent = envLightComponent + pointLightComponent;

	if (gFC_SAOEnabled != 0.0f) {
		const float aoMapVal = tex2Dlod(gSMP_AOMap, float4(In.VtxClp.xy * gFC_SAOParams.xy, 0, 0)).r;
		lightComponent *= aoMapVal;
	}

	Mtl.LitColor.rgb = emissiveComponent + lightComponent;

	{//Ghosting
	#ifdef WITH_GhostMap
		Mtl.LitColor = CalcGetGhost_NoTex(Mtl.LitColor, Mtl.Normal, In.VecEye.xyz, gFC_GhostEdgeColor, gFC_GhostTexColor, gFC_GhostParam);
	#endif
	}

	//Fog
	Mtl.LitColor = CalcGetFogCol(Linear2srgb(Mtl.LitColor), gFC_FogCol, In.VecNrm.w); //fog is done in sRGB

#ifdef VSLS
	//VS light scattering
	float4 scatteredColor = CalcGetLightScatteringCol_Blend(Mtl.LitColor, In.LsMul, In.LsAdd); //light scattering is in sRGB as well
#else
	//PS light scattering
	float4 scatteredColor = CalcGetLightScatteringCol(Mtl.LitColor, In.VecEye); //light scattering is in sRGB as well
#endif
	Mtl.LitColor = scatteredColor;
	Mtl.LitColor = Srgb2linear(Mtl.LitColor); //convert back to linear

#ifdef WITH_Glow
	Mtl.LitColor.rgb = ReverseToneMap(Mtl.LitColor.rgb * gFC_ToneCorrectParams.x);
#endif
	return PackGBuffer(Out, Mtl);
}

#endif //defined(WITH_MultiTexture) && !defined(WITH_SpecularMap)
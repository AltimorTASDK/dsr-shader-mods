//
//#define WITH_BumpMap	//!<バンプマップあり
//#define WITH_LightMap	//!<ライトマップあり
//#define WITH_ShadowMap	//!<シャドウマップあり
//#define WITH_EnvLerp	//!<環境光源の補間あり


//#define dbgShadow


/*-------------------------------------------------------------------*//*!
@brief フラグメントシェーダ
@par シングルテクスチャ
@par ディフューズ
*/
#ifdef WITH_Glow
	PS_OUT_SFX
#else
	GBUFFER_OUT
#endif
#ifdef WITH_GhostMap
	#ifdef WITH_BumpMap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif___Bmp___LitSdw(VTX_OUT_CWL_NET_DLGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif___Bmp___LitCsd(VTX_OUT_CW_NET_DLGG In)
				#endif
			#else
	FragmentMain_Dif___Bmp___Lit___(VTX_OUT_CW_NET_DLGG In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif___Bmp______Sdw(VTX_OUT_CWL_NET_DGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif___Bmp______Csd(VTX_OUT_CW_NET_DGG In)
				#endif
			#else
	FragmentMain_Dif___Bmp_________(VTX_OUT_CW_NET_DGG In)
			#endif
		#endif
	#else
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif_________LitSdw(VTX_OUT_CWL_NE_DLGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif_________LitCsd(VTX_OUT_CW_NE_DLGG In)
				#endif
			#else
	FragmentMain_Dif_________Lit___(VTX_OUT_CW_NE_DLGG In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif____________Sdw(VTX_OUT_CWL_NE_DGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif____________Csd(VTX_OUT_CW_NE_DGG In)
				#endif
			#else
	FragmentMain_Dif_______________(VTX_OUT_CW_NE_DGG In)
			#endif
		#endif
	#endif
#else
	#ifdef WITH_BumpMap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif___Bmp___LitSdw(VTX_OUT_CWL_NET_DL In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif___Bmp___LitCsd(VTX_OUT_CW_NET_DL In)
				#endif 
			#else
	FragmentMain_Dif___Bmp___Lit___(VTX_OUT_CW_NET_DL In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif___Bmp______Sdw(VTX_OUT_CWL_NET_D In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif___Bmp______Csd(VTX_OUT_CW_NET_D In)
				#endif 
			#else
	FragmentMain_Dif___Bmp_________(VTX_OUT_CW_NET_D In)
			#endif
		#endif
	#else
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif_________LitSdw(VTX_OUT_CWL_NE_DL In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif_________LitCsd(VTX_OUT_CW_NE_DL In)
				#endif 
			#else
	FragmentMain_Dif_________Lit___(VTX_OUT_CW_NE_DL In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif____________Sdw(VTX_OUT_CWL_NE_D In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif____________Csd(VTX_OUT_CW_NE_D In)
				#endif 
			#else
	FragmentMain_Dif_______________(VTX_OUT_CW_NE_D In)
			#endif
		#endif
	#endif
#endif
{
#ifdef WITH_LightMap
	float2 difTexUV = In.TexDifLit.xy;
#else
	float2 difTexUV = In.TexDif.xy;
#endif

	{//xyz - view vector, w - camera distance
		In.VecEye = CalcGetVecEye_FS(In.VecEye);
	}

#ifdef WITH_BumpMap
	if (gFC_ParallaxParams.x > 0.0f) {
		// qloc: we assume CALC_VS_BINORMAL is set (which is true on all our platforms)
		// also removed other parallax mapping types since we only use this one now
		difTexUV = ParallaxOcclusionMapping(difTexUV, gFC_ParallaxParams.x, In.VecEye.xyz, In.VecTan.xyz, In.VecBin, In.VecNrm.xyz);
	}
#endif //WITH_BumpMap

#ifdef PLACEHOLDER
	// nothing else is used so we should not get any warnings
	MATERIAL Mtl;
	Mtl.LitColor = float4(1.0f, 0.f, 1.f, 1.f);
	Mtl.SubsurfStrength = 0.0f;
#else
	float4 sampledColor = TexDiff(difTexUV);
	sampledColor.rgb += gFC_FgSkinAddColor.rgb;
	sampledColor *= In.ColVtx * gFC_ModelMulCol;
	sampledColor = qlocDoAlphaTest(sampledColor);

	float4 pblTexData = float4(1.0f, 0.0f, 0.0f, 1.0f);

	//qloc: face is backwards, invert normal
	if (!In.isFrontFace) {
		In.VecNrm.xyz = -In.VecNrm.xyz;
	}
	float3 vertexNormal = In.VecNrm.xyz;

	{//Normal
#ifdef WITH_BumpMap
#ifdef CALC_VS_BINORMAL
		In.VecNrm.xyz = CalcGetNormal_FromNormalTex_Bin(TEX2DSAMPLER(gSMP_BumpMap), difTexUV, In.VecNrm.xyz, In.VecTan, In.VecBin);	//法線テクスチャから法線算出
#else//CALC_VS_BINORMAL
		const float3 localVecBin = cross(In.VecNrm.xyz, In.VecTan.xyz)*In.VecTan.w;
		In.VecNrm.xyz = CalcGetNormal_FromNormalTex_Bin(TEX2DSAMPLER(gSMP_BumpMap), difTexUV, In.VecNrm.xyz, In.VecTan, localVecBin);	//法線テクスチャから法線算出
#endif//CALC_VS_BINORMAL
#else
		In.VecNrm.xyz = normalize(In.VecNrm.xyz);//normalization
		APPLY_DETAIL_BUMP(In.VecNrm.xyz, difTexUV); //depends on WITH_DetailBump
#endif
	}

	MATERIAL Mtl = PackMaterial(sampledColor, pblTexData, In.VecNrm.xyz);
#ifdef FS_SUBSURF
	Mtl.SubsurfStrength = 0.0f;
	Mtl.SubsurfOpacity = 1.0f;
#endif

	float specularF90 = calcSpecularF90(Mtl.SpecularColor);

	//emissive
	float3 emissiveComponent = CalcEmissive(Mtl);

	//image-based lighting
	float3 envLightComponent = CalcEnvIBL(Mtl, vertexNormal, In.VecEye.xyz, In.VtxWld.xyz, specularF90);

	//directional lights
	float3 dirSpecular = float3(0.0f, 0.0f, 0.0f);
	for (uint i = 0; i < clamp(gFC_DirLightCount.x, 0, MAX_DIR_LIGHTS); ++i) {
		float3 outSpecular;
		envLightComponent += SunContributionSeparated(Mtl.DiffuseColor, Mtl.SpecularColor, specularF90, Mtl.Roughness, -gFC_DirLightVec[i].xyz, gFC_DirLightCol[i], Mtl.Normal, In.VecEye.xyz, outSpecular);
		dirSpecular += outSpecular;
	}

	float lightmapShadow = 1.0f; // used for shadowing static map point lights
	{//lightmap and shadowmap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				//light map + shadow map
				const float4 lightMapVal = TexLightmap(In.TexDifLit.zw);
				#if (WITH_ShadowMap == CalcLispPos_VS)
					const float3 shadowMapVal = CalcGetShadowRateLitSpace(In.VtxLit, Mtl.Normal, In.VecEye).rgb;
				#else //(WITH_ShadowMap == CalcLispPos_PS)
					const float3 shadowMapVal = CalcGetShadowRateWorldSpace(In.VtxWld, Mtl.Normal, In.VecEye).rgb;
				#endif
				envLightComponent *= min(shadowMapVal.rgb, lightMapVal.rgb)*gFC_DebugPointLightParams.y;
				
				lightmapShadow = lightMapVal.a*shadowMapVal.r; //QLOC: store shadowing from shadow map too
			#else
				//light map only
				const float4 lightMapVal = TexLightmap(In.TexDifLit.zw);
				envLightComponent *= lightMapVal.rgb*gFC_DebugPointLightParams.y;

				lightmapShadow = lightMapVal.a;
			#endif				
		#else			
			#ifdef WITH_ShadowMap
				//shadow map only
				#if (WITH_ShadowMap == CalcLispPos_VS)
					const float3 shadowMapVal = CalcGetShadowRateLitSpace(In.VtxLit, Mtl.Normal, In.VecEye).rgb;
				#else //(WITH_ShadowMap == CalcLispPos_PS)
					const float3 shadowMapVal = CalcGetShadowRateWorldSpace(In.VtxWld, Mtl.Normal, In.VecEye).rgb;
				#endif
				envLightComponent *= shadowMapVal.rgb;
			#endif
		#endif
	}

	//ambient light
	envLightComponent += Mtl.DiffuseColor * CalcHemAmbient(Mtl.Normal);

	if (gFC_SAOEnabled != 0.0f) {
		const float3 aoMapVal = gSMP_AOMap.Load(int3(In.VtxClp.xy, 0)).rrr;
		envLightComponent *= aoMapVal;
	}

#if(POINT_LIGHT_0 >POINT_LIGHT_TYPE_None)
	float3 pointLightComponent = CalcPointLightsLegacy(Mtl, In.VecEye.xyz, In.VtxWld.xyz, specularF90, lightmapShadow);
#else
	float3 pointLightComponent = CalcPointLightsClustered(Mtl, In.VecEye.xyz, In.VtxWld.xyz, specularF90, lightmapShadow);
#endif

	{//Ghost lights
#ifdef WITH_GhostMap
		const float4 vecPnt = CalcGetGhostLightVec(In.VtxWld.xyz);	//Calculate and obtain the direction and damping coefficient of ghost light
		const float3 colPnt = gFC_GhostLightCol.rgb * vecPnt.w;	//Attenuate point light source color
		pointLightComponent += CalcGetGhostLightDifLightCol(Mtl.Normal, vecPnt.xyz, colPnt.rgb);	//Diffuse

		// no specular (as per original)
		// pointLightComponent += CalcGetGhostLightSpcLightCol(Mtl.Normal, gFC_SpcParam, vecPnt.xyz, colPnt.rgb);	//Specular
#endif // WITH_GhostMap
	}

	Mtl.LitColor = float4((envLightComponent + pointLightComponent + emissiveComponent + dirSpecular), sampledColor.a);

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
#ifdef WITH_Glow
	Mtl.LitColor = lerp(Mtl.LitColor, scatteredColor, gFC_SfxLightScatteringParams.x);
#else
	Mtl.LitColor = scatteredColor;
#endif
	Mtl.LitColor = Srgb2linear(Mtl.LitColor); //convert back to linear

#endif //placeholder

#ifdef WITH_Glow
	PS_OUT_SFX SfxOut;
	SfxOut.Color = float4(ReverseToneMap(Mtl.LitColor.rgb * gFC_ToneCorrectParams.x), Mtl.LitColor.a);
	//SfxOut.Color = float4(ReverseToneMap(Mtl.LitColor.rgb * gFC_ToneCorrectParams.x), 0.f);
	SfxOut.Glow = Mtl.LitColor * gFC_GlowColor * min(gFC_ToneCorrectParams.x, 1);
	return SfxOut;
#else
	return PackGBuffer(Mtl);
#endif
}






/*-------------------------------------------------------------------*//*!
@brief フラグメントシェーダ
@par シングルテクスチャ
@par ディフューズ
@par スペキュラ
*/
#ifdef WITH_Glow
	PS_OUT_SFX
#else
	GBUFFER_OUT
#endif
#ifdef WITH_GhostMap
	#ifdef WITH_BumpMap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpcBmp___LitSdw(VTX_OUT_CWL_NET_DLGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpcBmp___LitCsd(VTX_OUT_CW_NET_DLGG In)
				#endif 
			#else
	FragmentMain_DifSpcBmp___Lit___(VTX_OUT_CW_NET_DLGG In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpcBmp______Sdw(VTX_OUT_CWL_NET_DGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpcBmp______Csd(VTX_OUT_CW_NET_DGG In)
				#endif 
			#else
	FragmentMain_DifSpcBmp_________(VTX_OUT_CW_NET_DGG In)
			#endif
		#endif
	#else
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpc______LitSdw(VTX_OUT_CWL_NE_DLGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpc______LitCsd(VTX_OUT_CW_NE_DLGG In)
				#endif 
			#else
	FragmentMain_DifSpc______Lit___(VTX_OUT_CW_NE_DLGG In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpc_________Sdw(VTX_OUT_CWL_NE_DGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpc_________Csd(VTX_OUT_CW_NE_DGG In)
				#endif 
			#else
	FragmentMain_DifSpc____________(VTX_OUT_CW_NE_DGG In)
			#endif
		#endif
	#endif
#else
	#ifdef WITH_BumpMap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpcBmp___LitSdw(VTX_OUT_CWL_NET_DL In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpcBmp___LitCsd(VTX_OUT_CW_NET_DL In)
				#endif 
			#else
	FragmentMain_DifSpcBmp___Lit___(VTX_OUT_CW_NET_DL In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpcBmp______Sdw(VTX_OUT_CWL_NET_D In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpcBmp______Csd(VTX_OUT_CW_NET_D In)
				#endif 
			#else
	FragmentMain_DifSpcBmp_________(VTX_OUT_CW_NET_D In)
			#endif
		#endif
	#else
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpc______LitSdw(VTX_OUT_CWL_NE_DL In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpc______LitCsd(VTX_OUT_CW_NE_DL In)
				#endif 
			#else
	FragmentMain_DifSpc______Lit___(VTX_OUT_CW_NE_DL In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpc_________Sdw(VTX_OUT_CWL_NE_D In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpc_________Csd(VTX_OUT_CW_NE_D In)
				#endif 
			#else
	FragmentMain_DifSpc____________(VTX_OUT_CW_NE_D In)
			#endif
		#endif
	#endif
#endif
{
	#ifdef WITH_LightMap
		float2 difTexUV = In.TexDifLit.xy;
	#else
		float2 difTexUV = In.TexDif.xy;
	#endif

	{//xyz - view vector, w - camera distance
		In.VecEye = CalcGetVecEye_FS(In.VecEye);
	}

#ifdef WITH_BumpMap
	if (gFC_ParallaxParams.x > 0.0f) {
		// qloc: we assume CALC_VS_BINORMAL is set (which is true on all our platforms)
		// also removed other parallax mapping types since we only use this one now
		difTexUV = ParallaxOcclusionMapping(difTexUV, gFC_ParallaxParams.x, In.VecEye.xyz, In.VecTan.xyz, In.VecBin, In.VecNrm.xyz);
	}
#endif //WITH_BumpMap

	float4 sampledColor = TexDiff(difTexUV);
	sampledColor.rgb += gFC_FgSkinAddColor.rgb;
	sampledColor *= In.ColVtx * gFC_ModelMulCol;
	sampledColor = qlocDoAlphaTest(sampledColor);

	float4 pblTexData = tex2D(gSMP_PBLMap, difTexUV).rgba;

	//qloc: face is backwards, invert normal
	if (!In.isFrontFace) {
		In.VecNrm.xyz = -In.VecNrm.xyz;
	}
	float3 vertexNormal = In.VecNrm.xyz;

	{//Normal
		#ifdef WITH_BumpMap
			#ifdef CALC_VS_BINORMAL
				In.VecNrm.xyz = CalcGetNormal_FromNormalTex_Bin(TEX2DSAMPLER(gSMP_BumpMap), difTexUV, In.VecNrm.xyz, In.VecTan, In.VecBin);	//apply tangent space normal map texture
			#else//CALC_VS_BINORMAL
				const float3 localVecBin = cross(In.VecNrm.xyz, In.VecTan.xyz)*In.VecTan.w;
				In.VecNrm.xyz = CalcGetNormal_FromNormalTex_Bin(TEX2DSAMPLER(gSMP_BumpMap), difTexUV, In.VecNrm.xyz, In.VecTan, localVecBin);	//apply tangent space normal map texture
			#endif//CALC_VS_BINORMAL
		#else
			In.VecNrm.xyz = normalize(In.VecNrm.xyz);//normalization
			APPLY_DETAIL_BUMP(In.VecNrm.xyz, difTexUV); //depends on WITH_DetailBump
		#endif
	}

	MATERIAL Mtl = PackMaterial(sampledColor, pblTexData, In.VecNrm.xyz);
#ifdef FS_SUBSURF
	float2 subsurfData = tex2D(gSMP_Subsurf, difTexUV).rg;
	Mtl.SubsurfStrength = subsurfData.r * gFC_SubsurfaceParam.x;
	Mtl.SubsurfOpacity = TranslucencyScaled(subsurfData.g, gFC_SubsurfaceParam.y);
#endif

	float specularF90 = calcSpecularF90(Mtl.SpecularColor);

	//emissive
	float3 emissiveComponent = CalcEmissive(Mtl);

	//image-based lighting
	float3 envLightComponent = CalcEnvIBL(Mtl, vertexNormal, In.VecEye.xyz, In.VtxWld.xyz, specularF90);

	//directional lights
	float3 dirSpecular = float3(0.0f, 0.0f, 0.0f);
	for (uint i = 0; i < clamp(gFC_DirLightCount.x, 0, MAX_DIR_LIGHTS); ++i) {
		float3 outSpecular;
		envLightComponent += SunContributionSeparated(Mtl.DiffuseColor, Mtl.SpecularColor, specularF90, Mtl.Roughness, -gFC_DirLightVec[i].xyz, gFC_DirLightCol[i], Mtl.Normal, In.VecEye.xyz, outSpecular);
		dirSpecular += outSpecular;
	}

	float lightmapShadow = 1.0f; //used for shadowing static map point lights
	{//lightmap and shadowmap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				//light map + shadow map
				const float4 lightMapVal = TexLightmap(In.TexDifLit.zw);
				#if (WITH_ShadowMap == CalcLispPos_VS)
					const float3 shadowMapVal = CalcGetShadowRateLitSpace(In.VtxLit, Mtl.Normal, In.VecEye).rgb;
				#else //(WITH_ShadowMap == CalcLispPos_PS)
					const float3 shadowMapVal = CalcGetShadowRateWorldSpace(In.VtxWld, Mtl.Normal, In.VecEye).rgb;
				#endif
				envLightComponent *= min(shadowMapVal.rgb, lightMapVal.rgb)*gFC_DebugPointLightParams.y;
				
				lightmapShadow = lightMapVal.a*shadowMapVal.r; //QLOC: store shadowing from shadow map too
			#else
				//light map only
				const float4 lightMapVal = TexLightmap(In.TexDifLit.zw);
				envLightComponent *= lightMapVal.rgb*gFC_DebugPointLightParams.y;

				lightmapShadow = lightMapVal.a;
			#endif				
		#else			
			#ifdef WITH_ShadowMap
				//shadow map only
				#if (WITH_ShadowMap == CalcLispPos_VS)
					const float3 shadowMapVal = CalcGetShadowRateLitSpace(In.VtxLit, Mtl.Normal, In.VecEye).rgb;
				#else //(WITH_ShadowMap == CalcLispPos_PS)
					const float3 shadowMapVal = CalcGetShadowRateWorldSpace(In.VtxWld, Mtl.Normal, In.VecEye).rgb;
				#endif
				envLightComponent *= shadowMapVal.rgb;
			#endif
		#endif
	}

	//ambient light
	envLightComponent += Mtl.DiffuseColor * CalcHemAmbient(Mtl.Normal);

	if (gFC_SAOEnabled != 0.0f) {
		const float3 aoMapVal = gSMP_AOMap.Load(int3(In.VtxClp.xy, 0)).rrr;
		envLightComponent *= aoMapVal;
	}
	
#if(POINT_LIGHT_0 >POINT_LIGHT_TYPE_None)
	float3 pointLightComponent = CalcPointLightsLegacy(Mtl, In.VecEye.xyz, In.VtxWld.xyz, specularF90, lightmapShadow);
#else
	float3 pointLightComponent = CalcPointLightsClustered(Mtl, In.VecEye.xyz, In.VtxWld.xyz, specularF90, lightmapShadow);
#endif

	{//Ghost lights
		#ifdef WITH_GhostMap
		const float4 vecPnt = CalcGetGhostLightVec(In.VtxWld.xyz);	//Calculate and obtain the direction and damping coefficient of ghost light
		const float3 colPnt = gFC_GhostLightCol.rgb * vecPnt.w;	//Attenuate point light source color
		pointLightComponent += CalcGetGhostLightDifLightCol(Mtl.Normal, vecPnt.xyz, colPnt.rgb);	//Diffuse
		
		pointLightComponent += CalcGetGhostLightSpcLightCol(Mtl.Normal, gFC_SpcParam, vecPnt.xyz, colPnt.rgb);	//Specular
		#endif // WITH_GhostMap
	}

	Mtl.LitColor = float4((envLightComponent + pointLightComponent + emissiveComponent + dirSpecular), sampledColor.a);

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
#ifdef WITH_Glow
	Mtl.LitColor = lerp(Mtl.LitColor, scatteredColor, gFC_SfxLightScatteringParams.x);
#else
	Mtl.LitColor = scatteredColor;
#endif
	Mtl.LitColor = Srgb2linear(Mtl.LitColor); //convert back to linear


#ifdef WITH_Glow
	PS_OUT_SFX SfxOut;
	SfxOut.Color = float4(ReverseToneMap(Mtl.LitColor.rgb * gFC_ToneCorrectParams.x), Mtl.LitColor.a);
	//SfxOut.Color = float4(ReverseToneMap(Mtl.LitColor.rgb * gFC_ToneCorrectParams.x), 0.f);
	SfxOut.Glow = Mtl.LitColor * gFC_GlowColor * min(gFC_ToneCorrectParams.x, 1);
	return SfxOut;
#else
	return PackGBuffer(Mtl);
#endif
}






/*-------------------------------------------------------------------*//*!
@brief フラグメントシェーダ
@par マルチテクスチャ
@par ディフューズ
*/
#ifdef WITH_Glow
	PS_OUT_SFX
#else
	GBUFFER_OUT
#endif
#ifdef WITH_GhostMap
	#ifdef WITH_BumpMap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif___BmpMulLitSdw(VTX_OUT_CWL_NETT_DDLGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif___BmpMulLitCsd(VTX_OUT_CW_NETT_DDLGG In)
				#endif 
			#else
	FragmentMain_Dif___BmpMulLit___(VTX_OUT_CW_NETT_DDLGG In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif___BmpMul___Sdw(VTX_OUT_CWL_NETT_DDGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif___BmpMul___Csd(VTX_OUT_CW_NETT_DDGG In)
				#endif 
			#else
	FragmentMain_Dif___BmpMul______(VTX_OUT_CW_NETT_DDGG In)
			#endif
		#endif
	#else
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif______MulLitSdw(VTX_OUT_CWL_NE_DDLGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif______MulLitCsd(VTX_OUT_CW_NE_DDLGG In)
				#endif 
			#else
	FragmentMain_Dif______MulLit___(VTX_OUT_CW_NE_DDLGG In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif______Mul___Sdw(VTX_OUT_CWL_NE_DDGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif______Mul___Csd(VTX_OUT_CW_NE_DDGG In)
				#endif 
			#else
	FragmentMain_Dif______Mul______(VTX_OUT_CW_NE_DDGG In)
			#endif
		#endif
	#endif
#else
	#ifdef WITH_BumpMap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif___BmpMulLitSdw(VTX_OUT_CWL_NETT_DDL In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif___BmpMulLitCsd(VTX_OUT_CW_NETT_DDL In)
				#endif 
			#else
	FragmentMain_Dif___BmpMulLit___(VTX_OUT_CW_NETT_DDL In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif___BmpMul___Sdw(VTX_OUT_CWL_NETT_DD In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif___BmpMul___Csd(VTX_OUT_CW_NETT_DD In)
				#endif 
			#else
	FragmentMain_Dif___BmpMul______(VTX_OUT_CW_NETT_DD In)
			#endif
		#endif
	#else
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif______MulLitSdw(VTX_OUT_CWL_NE_DDL In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif______MulLitCsd(VTX_OUT_CW_NE_DDL In)
				#endif 
			#else
	FragmentMain_Dif______MulLit___(VTX_OUT_CW_NE_DDL In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_Dif______Mul___Sdw(VTX_OUT_CWL_NE_DD In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_Dif______Mul___Csd(VTX_OUT_CW_NE_DD In)
				#endif 
			#else
	FragmentMain_Dif______Mul______(VTX_OUT_CW_NE_DD In)
			#endif
		#endif
	#endif
#endif
{
	MATERIAL Mtl;

	Mtl.LitColor = float4(1.0f, 0.f, 1.f, 1.f);
	Mtl.DiffuseColor = float3(0.f, 0.f, 0.f);
	Mtl.SpecularColor = float3(0.f, 0.f, 0.f);
	Mtl.Normal = float3(0.f, 0.f, 0.f);
	Mtl.Roughness = 1.0f;
	Mtl.SubsurfStrength = 0.0f;
	Mtl.SubsurfOpacity = 1.0f;

#ifdef WITH_Glow
	PS_OUT_SFX SfxOut;
	SfxOut.Color = float4(ReverseToneMap(Mtl.LitColor.rgb * gFC_ToneCorrectParams.x), Mtl.LitColor.a);
	//SfxOut.Color = float4(ReverseToneMap(Mtl.LitColor.rgb * gFC_ToneCorrectParams.x), 0.f);
	SfxOut.Glow = Mtl.LitColor * gFC_GlowColor * min(gFC_ToneCorrectParams.x, 1);
	return SfxOut;
#else
	return PackGBuffer(Mtl);
#endif
}






/*-------------------------------------------------------------------*//*!
@brief フラグメントシェーダ
@par マルチテクスチャ
@par ディフューズ
@par スペキュラ
*/
#ifdef WITH_Glow
	PS_OUT_SFX
#else
	GBUFFER_OUT
#endif
#ifdef WITH_GhostMap
	#ifdef WITH_BumpMap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpcBmpMulLitSdw(VTX_OUT_CWL_NETT_DDLGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpcBmpMulLitCsd(VTX_OUT_CW_NETT_DDLGG In)
				#endif 
			#else
	FragmentMain_DifSpcBmpMulLit___(VTX_OUT_CW_NETT_DDLGG In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpcBmpMul___Sdw(VTX_OUT_CWL_NETT_DDGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpcBmpMul___Csd(VTX_OUT_CW_NETT_DDGG In)
				#endif 
			#else
	FragmentMain_DifSpcBmpMul______(VTX_OUT_CW_NETT_DDGG In)
			#endif
		#endif
	#else
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpc___MulLitSdw(VTX_OUT_CWL_NE_DDLGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpc___MulLitCsd(VTX_OUT_CW_NE_DDLGG In)
				#endif 
			#else
	FragmentMain_DifSpc___MulLit___(VTX_OUT_CW_NE_DDLGG In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpc___Mul___Sdw(VTX_OUT_CWL_NE_DDGG In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpc___Mul___Csd(VTX_OUT_CW_NE_DDGG In)
				#endif 
			#else
	FragmentMain_DifSpc___Mul______(VTX_OUT_CW_NE_DDGG In)
			#endif
		#endif
	#endif
#else
	#ifdef WITH_BumpMap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpcBmpMulLitSdw(VTX_OUT_CWL_NETT_DDL In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpcBmpMulLitCsd(VTX_OUT_CW_NETT_DDL In)
				#endif 
			#else
	FragmentMain_DifSpcBmpMulLit___(VTX_OUT_CW_NETT_DDL In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpcBmpMul___Sdw(VTX_OUT_CWL_NETT_DD In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpcBmpMul___Csd(VTX_OUT_CW_NETT_DD In)
				#endif 
			#else
	FragmentMain_DifSpcBmpMul______(VTX_OUT_CW_NETT_DD In)
			#endif
		#endif
	#else
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpc___MulLitSdw(VTX_OUT_CWL_NE_DDL In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpc___MulLitCsd(VTX_OUT_CW_NE_DDL In)
				#endif 
			#else
	FragmentMain_DifSpc___MulLit___(VTX_OUT_CW_NE_DDL In)
			#endif
		#else
			#ifdef WITH_ShadowMap
				#if (WITH_ShadowMap == CalcLispPos_VS)
	FragmentMain_DifSpc___Mul___Sdw(VTX_OUT_CWL_NE_DD In)
				#else //(WITH_ShadowMap == CalcLispPos_PS)
	FragmentMain_DifSpc___Mul___Csd(VTX_OUT_CW_NE_DD In)
				#endif 
			#else
	FragmentMain_DifSpc___Mul______(VTX_OUT_CW_NE_DD In)
			#endif
		#endif
	#endif
#endif
{
	float4 difTexUV = In.TexDifDif;

	{//xyz - view vector, w - camera distance
		In.VecEye = CalcGetVecEye_FS(In.VecEye);
	}

#ifdef WITH_BumpMap
	if (gFC_ParallaxParams.x > 0.0f) {
		// qloc: we assume CALC_VS_BINORMAL is set (which is true on all our platforms)
		// also removed other parallax mapping types since we only use this one now
		difTexUV.xy = ParallaxOcclusionMapping(difTexUV.xy, gFC_ParallaxParams.x, In.VecEye.xyz, In.VecTan.xyz, In.VecBin, In.VecNrm.xyz);
	}
#endif //WITH_BumpMap

	float4 sampledColor = TexDiff(difTexUV.xy);
	float4 sampledColor2 = TexDiff2(In.TexDifDif.zw);
	sampledColor2.xyz += gFC_FgSkinAddColor.xyz;
	sampledColor = float4(lerp(sampledColor.rgb, sampledColor2.rgb, In.ColVtx.a), 1.0)*float4(In.ColVtx.rgb, 1.0) * gFC_ModelMulCol;
	sampledColor = qlocDoAlphaTest(sampledColor);

	float4 pblTexData = tex2D(gSMP_PBLMap, difTexUV.xy).rgba;
	float4 pblTexData2 = tex2D(gSMP_PBLMap2, In.TexDifDif.zw).rgba;
	pblTexData = lerp(pblTexData.rgba, pblTexData2.rgba, In.ColVtx.a);

	//qloc: face is backwards, invert normal
	if (!In.isFrontFace) {
		In.VecNrm.xyz = -In.VecNrm.xyz;
	}
	float3 vertexNormal = In.VecNrm.xyz;

	{//Normal
		#ifdef WITH_BumpMap
			#ifdef CALC_VS_BINORMAL
				In.VecNrm.xyz = CalcGetNormal_FromNormalTex_Mul_Bin(TEX2DSAMPLER(gSMP_BumpMap), TEX2DSAMPLER(gSMP_BumpMap2), difTexUV,  In.VecNrm.xyz, In.VecTan, In.VecTan2, In.VecBin, In.VecBin2, In.ColVtx.a);//法線テクスチャから法線算出
			#else//CALC_VS_BINORMAL
				const float3 localVecBin = cross(In.VecNrm.xyz, In.VecTan.xyz)*In.VecTan.w;
				const float3 localVecBin2 = cross(In.VecNrm.xyz, In.VecTan2.xyz)*In.VecTan2.w;
				In.VecNrm.xyz = CalcGetNormal_FromNormalTex_Mul_Bin(TEX2DSAMPLER(gSMP_BumpMap), TEX2DSAMPLER(gSMP_BumpMap2), difTexUV,  In.VecNrm.xyz, In.VecTan, In.VecTan2, localVecBin, localVecBin2, In.ColVtx.a);//法線テクスチャから法線算出
			#endif//CALC_VS_BINORMAL
		#else
			In.VecNrm.xyz = normalize(In.VecNrm.xyz); //normalization
			APPLY_DETAIL_BUMP(In.VecNrm.xyz, difTexUV.xy); //depends on WITH_DetailBump
		#endif
	}

	MATERIAL Mtl = PackMaterial(sampledColor, pblTexData, In.VecNrm.xyz);
#ifdef FS_SUBSURF
	float2 subsurfData = tex2D(gSMP_Subsurf, difTexUV.xy).rg;
	Mtl.SubsurfStrength = subsurfData.r * gFC_SubsurfaceParam.x;
	Mtl.SubsurfOpacity = TranslucencyScaled(subsurfData.g, gFC_SubsurfaceParam.y);
#endif

	float specularF90 = calcSpecularF90(Mtl.SpecularColor);

	//emissive
	float3 emissiveComponent = CalcEmissive(Mtl);

	//image-based lighting
	float3 envLightComponent = CalcEnvIBL(Mtl, vertexNormal, In.VecEye.xyz, In.VtxWld.xyz, specularF90);

	//directional lights
	float3 dirSpecular = float3(0.0f, 0.0f, 0.0f);
	for (uint i = 0; i < clamp(gFC_DirLightCount.x, 0, MAX_DIR_LIGHTS); ++i) {
		float3 outSpecular;
		envLightComponent += SunContributionSeparated(Mtl.DiffuseColor, Mtl.SpecularColor, specularF90, Mtl.Roughness, -gFC_DirLightVec[i].xyz, gFC_DirLightCol[i], Mtl.Normal, In.VecEye.xyz, outSpecular);
		dirSpecular += outSpecular;
	}

	float lightmapShadow = 1.0f; // used for shadowing static map point lights
	{//lightmap and shadowmap
		#ifdef WITH_LightMap
			#ifdef WITH_ShadowMap
				//light map + shadow map
				const float4 lightMapVal = TexLightmap(In.TexLit.xy);
				#if (WITH_ShadowMap == CalcLispPos_VS)
					const float3 shadowMapVal = CalcGetShadowRateLitSpace(In.VtxLit, Mtl.Normal, In.VecEye).rgb;
				#else //(WITH_ShadowMap == CalcLispPos_PS)
					const float3 shadowMapVal = CalcGetShadowRateWorldSpace(In.VtxWld, Mtl.Normal, In.VecEye).rgb;
				#endif
				envLightComponent *= min(shadowMapVal.rgb, lightMapVal.rgb)*gFC_DebugPointLightParams.y;
				
				lightmapShadow = lightMapVal.a*shadowMapVal.r; //QLOC: store shadowing from shadow map too
			#else
				//light map only
				const float4 lightMapVal = TexLightmap(In.TexLit.xy);
				envLightComponent *= lightMapVal.rgb*gFC_DebugPointLightParams.y;
				lightmapShadow = lightMapVal.a;
			#endif
		#else
			#ifdef WITH_ShadowMap
				//shadow map only
				#if (WITH_ShadowMap == CalcLispPos_VS)
					const float3 shadowMapVal = CalcGetShadowRateLitSpace(In.VtxLit, Mtl.Normal, In.VecEye).rgb;
				#else //(WITH_ShadowMap == CalcLispPos_PS)
					const float3 shadowMapVal = CalcGetShadowRateWorldSpace(In.VtxWld, Mtl.Normal, In.VecEye).rgb;
				#endif
				envLightComponent *= shadowMapVal.rgb;
			#endif
		#endif
	}
	
	//ambient light
	envLightComponent += Mtl.DiffuseColor * CalcHemAmbient(Mtl.Normal);

	if (gFC_SAOEnabled != 0.0f) {
		const float3 aoMapVal = gSMP_AOMap.Load(int3(In.VtxClp.xy, 0)).rrr;
		envLightComponent *= aoMapVal;
	}

#if(POINT_LIGHT_0 >POINT_LIGHT_TYPE_None)
	float3 pointLightComponent = CalcPointLightsLegacy(Mtl, In.VecEye.xyz, In.VtxWld.xyz, specularF90, lightmapShadow);
#else
	float3 pointLightComponent = CalcPointLightsClustered(Mtl, In.VecEye.xyz, In.VtxWld.xyz, specularF90, lightmapShadow);
#endif

	{//Ghost lights
		#ifdef WITH_GhostMap
		const float4 vecPnt = CalcGetGhostLightVec(In.VtxWld.xyz);	//Calculate and obtain the direction and damping coefficient of ghost light
		const float3 colPnt = gFC_GhostLightCol.rgb * vecPnt.w;	//Attenuate point light source color
		pointLightComponent += CalcGetGhostLightDifLightCol(Mtl.Normal, vecPnt.xyz, colPnt.rgb);	//Diffuse
		
		pointLightComponent += CalcGetGhostLightSpcLightCol(Mtl.Normal, gFC_SpcParam, vecPnt.xyz, colPnt.rgb);	//Specular
		#endif // WITH_GhostMap
	}

	Mtl.LitColor = float4((envLightComponent + pointLightComponent + emissiveComponent + dirSpecular), sampledColor.a);

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
#ifdef WITH_Glow
	Mtl.LitColor = lerp(Mtl.LitColor, scatteredColor, gFC_SfxLightScatteringParams.x);
#else
	Mtl.LitColor = scatteredColor;
#endif
	Mtl.LitColor = Srgb2linear(Mtl.LitColor); //convert back to linear


#ifdef WITH_Glow
	PS_OUT_SFX SfxOut;
	SfxOut.Color = float4(ReverseToneMap(Mtl.LitColor.rgb * gFC_ToneCorrectParams.x), Mtl.LitColor.a);
	//SfxOut.Color = float4(ReverseToneMap(Mtl.LitColor.rgb * gFC_ToneCorrectParams.x), 0.f);
	SfxOut.Glow = Mtl.LitColor * gFC_GlowColor * min(gFC_ToneCorrectParams.x, 1);
	return SfxOut;
#else
	return PackGBuffer(Mtl);
#endif
}

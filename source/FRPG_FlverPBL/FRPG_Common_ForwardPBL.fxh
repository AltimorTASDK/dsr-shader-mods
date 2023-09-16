/***************************************************************************//**

	@file		FRPG_Common_ForwardPBL.fxh
	@brief		Common PBL functions for Forward PBL
	@author		Piotr Michniewski
	@version	v1.0

	Copyright &copy; @YEAR@ QLOC S.A.

*//****************************************************************************/
/*!
	@par
*/

#define DISTANCE_ATTENUATION_MULT 1
#define DISTANCE_ATTENUATION_BIAS 1.0

#define M_INV_PI 0.31830988618379067153776752674503
#define M_PI 3.1415926535897932384626433832795
#define M_INV_LOG2 1.4426950408889634073599246810019

#define LAMP_FALLOFF_LEGACY_LINEAR 0
#define LAMP_FALLOFF_QLOC 1
#define LAMP_FALLOFF_UNREAL_MODIFIED 2
#define LAMP_FALLOFF_PERCEIVED_LINEAR 3
#define LAMP_FALLOFF_FIXED_LINEAR 4

#define DFG_TEXTURE_SIZE 128.0f

#define gFC_DifMapMultiplier gFC_LightProbeParam.x
#define gFC_SpcMapMultiplier gFC_LightProbeParam.x
#define gFC_LightProbeMipCount gFC_LightProbeParam.w
#define gFC_LightProbeSlot gFC_LightProbeParam.z
#define gSMP_LightProbeDif gSMP_EnvDifMap
#define gSMP_LightProbeSpec gSMP_EnvSpcMap

#define CLUSTER_COUNT_X 16
#define CLUSTER_COUNT_Y 8
#define CLUSTER_COUNT_Z 24

struct s_numLights {
	uint offsetNum;
};

struct s_lightID {
	uint id;
};

struct s_lightParams {
	float4 position;
	float4 color;
	float attenuation;
	uint falloffMode;
	uint padding0;
	uint padding1;
};

StructuredBuffer<s_numLights> numLightsBuffer : register(t16);
StructuredBuffer<s_lightID> lightIDBuffer : register(t17);
StructuredBuffer<s_lightParams> lightParamBuffer : register(t18);

float3 Srgb2linear(float3 c)
{
	return pow(abs(c), float3(2.2, 2.2, 2.2));
}

float3 Linear2srgb(float3 c)
{
	return pow(abs(c), float3(1 / 2.2, 1 / 2.2, 1 / 2.2));
}

float4 Srgb2linear(float4 c)
{
	return float4(Srgb2linear(c.rgb), c.a);
}

float4 Linear2srgb(float4 c)
{
	return float4(Linear2srgb(c.rgb), c.a);
}

float FitRoughness(float r)
{
	r = max(0.014f, r);
	return r;
}

float UnpackDiffuseF0(float f0)
{
	return f0 / 5.0f;//1.0f maps to 0.2
}

float PackDiffuseF0(float f0)
{
	return f0 * 5.0f;//0.2f maps to 1.0
}

struct MATERIAL
{
	float4 LitColor;
	float3 DiffuseColor;
	float3 SpecularColor;
	float3 EmissiveColor;
	float3 Normal;
	float Roughness;
	float SubsurfStrength;
	float SubsurfOpacity;
	float LightPower;
};

GBUFFER_OUT PackGBuffer(GBUFFER_OUT Out, MATERIAL mtl)
{
	float3 scatter;

	switch (gFC_DebugDraw.x) {
	default:
	#ifdef FS_SUBSURF
		scatter = float3(mtl.SubsurfStrength / 10.0f, 0, 0);
	#else
		scatter = float3(0, 0, 0);
	#endif
		break;
	case 1:
		scatter = mtl.LitColor.rgb;
		break;
	case 2:
		scatter = Linear2srgb(mtl.DiffuseColor);
		break;
	case 3:
		scatter = Linear2srgb(mtl.SpecularColor);
		break;
	case 4:
		scatter = mtl.EmissiveColor;
		break;
	case 5:
		scatter = mtl.Normal * 0.49804f + 0.49804f;
		break;
	case 6:
		scatter = float3(mtl.Roughness, 0, 0);
		break;
	}

	//light
	Out.GBuffer0.rgb = mtl.LitColor.rgb;
	Out.GBuffer1 = float4(scatter, 0);

	return Out;
}

//--------------------------------------------------------------------------------------
// Point lights
//--------------------------------------------------------------------------------------

float normal_distrib(float ndh, float Roughness)
{
	// use GGX / Trowbridge-Reitz, same as Disney and Unreal 4
	// cf http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf p3
	float alpha = Roughness * Roughness;
	float tmp = alpha / (ndh*ndh*(alpha*alpha - 1.0) + 1.0);
	return tmp * tmp * M_INV_PI;
}

float3 fresnel(float vdh, float3 F0, float F90)
{
	// Schlick with Spherical Gaussian approximation
	// cf http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf p3
	float sphg = exp2((-5.55473*vdh - 6.98316) * vdh);
	return F0 + (float3(F90, F90, F90) - F90*F0) * sphg;
}

float G1(float ndw, float k)// w is either Ln or Vn
{
	// One generic factor of the geometry function divided by ndw
	// NB : We should have k > 0
	return 1.0 / (ndw*(1.0 - k) + k);
}

float visibility(float ndl, float ndv, float Roughness)
{
	// Schlick with Smith-like choice of k
	// cf http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf p3
	// visibility is a Cook-Torrance geometry function divided by (n.l)*(n.v)
	float k = Roughness * Roughness * 0.5;
	return G1(ndl, k)*G1(ndv, k);
}

float3 microfacets_brdf(float3 Nn, float3 Ln, float3 Vn, float3 Ks, float Ks90, float Roughness)
{
	Roughness = FitRoughness(Roughness);
	float3 Hn = normalize(Vn + Ln);
	float vdh = saturate(dot(Vn, Hn));
	float ndh = saturate(dot(Nn, Hn));
	float ndl = saturate(dot(Nn, Ln));
	float ndv = saturate(dot(Nn, Vn));
	return fresnel(vdh, Ks, Ks90) * (normal_distrib(ndh, Roughness) * visibility(ndl, ndv, Roughness) / 4.0);
}

float buggedLinearAttenuation(float distance, float falloffEnd, float OneOverFalloffEndMinusStart)
{
	return saturate(1.0 - (distance - OneOverFalloffEndMinusStart) / (falloffEnd - OneOverFalloffEndMinusStart));
}

float linearAttenuation(float distance, float falloffEnd, float OneOverFalloffEndMinusStart)
{
	return saturate((falloffEnd - distance)*OneOverFalloffEndMinusStart);
}

float qlocAttenuation(float distance, float lightRadius, float decay)
{
	return pow(saturate(1.0 - pow((distance / lightRadius), 4.0)), 2.0) / (pow(distance, decay) + DISTANCE_ATTENUATION_BIAS);
}

float unrealOffsetAttenuation(float distance, float lightRadius, float OneOverFalloffEndMinusStart)
{
	float FalloffStart = lightRadius - 1.0 / OneOverFalloffEndMinusStart;
	distance = max(0, distance - FalloffStart);
	lightRadius = max(0, lightRadius - FalloffStart);
	return pow(saturate(1.0 - pow((distance / lightRadius), 4.0)), 2.0) / (pow(distance, 2) + DISTANCE_ATTENUATION_BIAS);
}

float perceivedLinear(float distance, float falloffEnd, float OneOverFalloffEndMinusStart)
{
	return saturate(pow((falloffEnd - distance)*OneOverFalloffEndMinusStart, 3));
}

float3 PointLightContribution(float3 N, float3 L, float3 V,
	float3 diffColor, float3 specColor, float specF90,
	float roughness, float3 LampColor, float LampDist,
	float OneOverFalloffEndMinusStart, float LampFalloffEnd, uint falloffMode)
{
	float3 diffContrib = diffColor * M_INV_PI;
	float3 specContrib = microfacets_brdf(N, L, V, specColor, specF90, roughness);

	// Note that the lamp intensity is using ½computer games units" i.e. it needs
	// to be multiplied by M_PI.
	// Cf https://seblagarde.wordpress.com/2012/01/08/pi-or-not-to-pi-in-game-lighting-equation/

	float lampAtt;
#ifdef OLD_VERSION
	switch (falloffMode)
	{
	default:
	case LAMP_FALLOFF_LEGACY_LINEAR:
		lampAtt = buggedLinearAttenuation(LampDist, LampFalloffEnd, OneOverFalloffEndMinusStart);
		break;
	case LAMP_FALLOFF_QLOC:
		lampAtt = qlocAttenuation(LampDist, LampFalloffEnd, OneOverFalloffEndMinusStart);
		break;
	case LAMP_FALLOFF_UNREAL_MODIFIED:
		lampAtt = unrealOffsetAttenuation(LampDist, LampFalloffEnd, OneOverFalloffEndMinusStart);
		break;
	case LAMP_FALLOFF_PERCEIVED_LINEAR:
#endif
		lampAtt = perceivedLinear(LampDist, LampFalloffEnd, OneOverFalloffEndMinusStart);
#ifdef OLD_VERSION
		break;
	case LAMP_FALLOFF_FIXED_LINEAR:
		lampAtt = linearAttenuation(LampDist, LampFalloffEnd, OneOverFalloffEndMinusStart);
		break;
	}
#endif

	return  saturate(dot(N, L)) * ((diffContrib + specContrib)	* LampColor * lampAtt * M_PI);
}

#ifdef OLD_VERSION

#define SUN_RADIUS 0.5f * M_PI/180.0f

float3 SunContribution(float3 diffColor, float3 specColor, float specF90,
	float roughness, float3 sunDirection, float4 sunColor, float3 N, float3 V)
{
	//prevent very bright directional reflections
	roughness = max(roughness, 0.08);

	const float r = sin(SUN_RADIUS);
	const float d = cos(SUN_RADIUS);

	float3 R = 2 * dot(V, N) * N - V;

	float DdotR = dot(sunDirection, R);
	float3 S = R - DdotR * sunDirection;
	float3 L = DdotR < d ? normalize(d * sunDirection + normalize(S) * r) : R;

	float illuminance = /*sunColor.a * 2.55f * */saturate(dot(N, sunDirection));

	float3 diffContrib = diffColor * M_INV_PI * gFC_DirLightParam.x;
	float3 specContrib = microfacets_brdf(N, L, V, specColor, specF90, roughness) * gFC_DirLightParam.y;

	//illuminance already contains NdotL
	return illuminance * ((diffContrib + specContrib) * sunColor.rgb * M_PI);
}

float3 SunContributionSeparated(float3 diffColor, float3 specColor, float specF90,
	float roughness, float3 sunDirection, float4 sunColor, float3 N, float3 V, out float3 specContrib)
{
	//prevent very bright directional reflections
	roughness = max(roughness, 0.08);

	const float r = sin(SUN_RADIUS);
	const float d = cos(SUN_RADIUS);

	float3 R = 2 * dot(V, N) * N - V;

	float DdotR = dot(sunDirection, R);
	float3 S = R - DdotR * sunDirection;
	float3 L = DdotR < d ? normalize(d * sunDirection + normalize(S) * r) : R;

	float3 illuminance = /*sunColor.a * 2.55f * */saturate(dot(N, sunDirection)) * sunColor.rgb;

	//illuminance already contains NdotL
	float3 diffContrib = illuminance * diffColor * gFC_DirLightParam.x;
	specContrib = illuminance * microfacets_brdf(N, L, V, specColor, specF90, roughness) * M_PI * gFC_DirLightParam.y;

	return diffContrib;
}

#endif //OLD_VERSION

//--------------------------------------------------------------------------------------
// Light probe
//--------------------------------------------------------------------------------------

float calcSpecularF90(float3 f0)
{
	return saturate(50.0f * dot(f0, 0.33));
}

float linearRoughnessToMipLevel(float lRoughness, float mipCount)
{
	//copied from Unreal
	float lastMip = mipCount - 1;
	return log2(lRoughness) * 1.2 + lastMip - 2;
}

float3 getSpecularDominantDir_forLightProbe(float3 N, float3 R, float roughness)
{
	float smoothness = saturate(1 - roughness);
	float lerpFactor = smoothness * (sqrt(smoothness) + roughness);
	// The result is not normalized as we fetch in a cubemap
	return lerp(N, R, lerpFactor);
}

float3 getDiffuseDominantDir_forLightProbe(float3 N, float3 V, float NdotV, float roughness)
{
	float a = 1.02341f * roughness - 1.51174f;
	float b = -0.511705f * roughness + 0.755868f;
	float lerpFactor = saturate((NdotV * a + b) * roughness);
	// The result is not normalized as we fetch in a cubemap
	return lerp(N, V, lerpFactor);
}

float CalcDiffuseFresnel(float NdotV, float roughness)
{
	return 0.04f;
	return tex2Dlod(gSMP_DFG, float4(roughness, NdotV, 0, 0)).z;
}

float2 CalcSpecularDFG(float NdotV, float roughness)
{
	return tex2Dlod(gSMP_DFG, float4(roughness, NdotV, 0, 0)).xy;
}

static const float c1 = 0.429043;
static const float c2 = 0.511664;
static const float c3 = 0.743125;
static const float c4 = 0.886227;
static const float c5 = 0.247708;

#ifdef USE_SH
//TODO: this could probably be further optimized wrt packing/unpacking
//look into one of the examples
float3 CalcSH(float3 N, float4 worldPos)
{
	float3 pos = mul(gFC_IVMtx, worldPos).xyz + float3(0.5f, 0.5f, 0.5f);
#ifdef USE_SH
	float4 sh0 = tex3Dlod(gSMP_SHMap, float4(pos.xz, (clamp(pos.y, 0.0f, 1.0f) + 0.0f) / 7.0f, 0));
	float4 sh1 = tex3Dlod(gSMP_SHMap, float4(pos.xz, (clamp(pos.y, 0.0f, 1.0f) + 1.0f) / 7.0f, 0));
	float4 sh2 = tex3Dlod(gSMP_SHMap, float4(pos.xz, (clamp(pos.y, 0.0f, 1.0f) + 2.0f) / 7.0f, 0));
	float4 sh3 = tex3Dlod(gSMP_SHMap, float4(pos.xz, (clamp(pos.y, 0.0f, 1.0f) + 3.0f) / 7.0f, 0));
	float4 sh4 = tex3Dlod(gSMP_SHMap, float4(pos.xz, (clamp(pos.y, 0.0f, 1.0f) + 4.0f) / 7.0f, 0));
	float4 sh5 = tex3Dlod(gSMP_SHMap, float4(pos.xz, (clamp(pos.y, 0.0f, 1.0f) + 5.0f) / 7.0f, 0));
	float4 sh6 = tex3Dlod(gSMP_SHMap, float4(pos.xz, (clamp(pos.y, 0.0f, 1.0f) + 6.0f) / 7.0f, 0));

	float3 sh7 = float3(sh0.w, sh1.w, sh2.w);
	float3 sh8 = float3(sh3.w, sh4.w, sh5.w);

	float3 E = c1 * sh8 * (N.x * N.x - N.y * N.y) + (c3 * N.z * N.z - c5) * sh6.xyz + c4 * sh0.xyz
		+ 2 * c1 * (N.x * N.y * sh4.xyz + N.x * N.z * sh7 + N.y * N.z * sh5.xyz)
		+ 2 * c2 * (N.x * sh3.xyz + N.y * sh1.xyz + N.z * sh2.xyz);
	return max(E/M_PI, 0.0f);
#else
	return 0.0f;
#endif
}
#endif //USE_SH

float3 CalcDiffuseLD(float3 dominantN)
{
#ifdef WITH_EnvLerp
	float3 spec1 = gFC_EnvDifMapMulCol.rgb * texCUBElod(gSMP_EnvDifMap, float4(dominantN, 0.0f)).rgb;
	float3 spec2 = gFC_EnvDifMapMulCol2.rgb * texCUBElod(gSMP_EnvDifMap2, float4(dominantN, 0.0f)).rgb;
	return gFC_DifMapMultiplier * lerp(spec1, spec2, gFC_EnvDifMapMulCol2.a);
#else
	return gFC_EnvDifMapMulCol.rgb * gFC_DifMapMultiplier * texCUBElod(gSMP_LightProbeDif, float4(dominantN, 0.0f)).rgb;
#endif
}

float3 CalcSpecularLD(float3 dominantR, float roughness)
{
	float mipLevel = linearRoughnessToMipLevel(roughness, gFC_LightProbeMipCount);
	//add directional light
#ifdef WITH_EnvLerp
	float3 spec1 = gFC_EnvSpcMapMulCol.rgb * texCUBElod(gSMP_EnvSpcMap, float4(dominantR, mipLevel)).rgb;
	float3 spec2 = gFC_EnvSpcMapMulCol2.rgb * texCUBElod(gSMP_EnvSpcMap2, float4(dominantR, mipLevel)).rgb;
	return gFC_SpcMapMultiplier * lerp(spec1, spec2, gFC_EnvSpcMapMulCol2.a);
#else
	return gFC_EnvSpcMapMulCol.rgb * gFC_SpcMapMultiplier * texCUBElod(gSMP_LightProbeSpec, float4(dominantR, mipLevel)).rgb;
#endif
}

float3 CalcHemAmbient(float3 dominantN)
{
	float HemLerpRate = dominantN.y * 0.5f + 0.5f;
	return lerp(gFC_HemAmbCol_d.xyz, gFC_HemAmbCol_u.xyz, HemLerpRate);
}

// Approximates luminance from an RGB value
float CalcLuminance(float3 color)
{
	return max(dot(color, float3(0.2126729, 0.7151522, 0.0721750)), 0.001f);
}

float3 evaluateIBLDiffuse(float3 N, float3 V, float NdotV, float roughness)
{
	//ignore dominant shift since we're not sure it goes well with lambert
	//float3 dominantN = getDiffuseDominantDir_forLightProbe(N, V, NdotV, roughness);
	//float3 diffuseLighting = CalcDiffuseLD(dominantN);

	float3 diffuseLighting = CalcDiffuseLD(N);

	return diffuseLighting;
}

float3 evaluateIBLSpecular(float3 N, float3 R, float3 vertexNormal, float NdotV, float roughness, float3 f0, float3 f90)
{
	float3 dominantR = getSpecularDominantDir_forLightProbe(N, R, roughness);

	// Rebuild the function
	// L . D. ( f0.Gv.(1-Fc) + Gv.Fc ) . cosTheta / (4 . NdotL . NdotV)
	float3 preLD = CalcSpecularLD(dominantR, roughness);

	// Horizon fading trick from http://marmosetco.tumblr.com/post/81245981087
	float ndl = dot(vertexNormal, R);
	const float horizonFade = 1.3;
	float horiz = clamp(1.0 + horizonFade * ndl, 0.0, 1.0);
	horiz *= horiz;
	preLD *= horiz;

	// Sample pre-integrate DFG
	// Fc = (1-H.L)^5
	// PreIntegratedDFG.r = Gv.(1-Fc)
	// PreIntegratedDFG.g = Gv.Fc
	float2 preDFG = CalcSpecularDFG(NdotV, roughness);

	// LD . ( f0.Gv.(1-Fc) + Gv.Fc.f90 )
	return preLD * (f0 * preDFG.x + f90 * preDFG.y);
}

// thicknessSqrt is sqrt(mesh thickness)
float TranslucencyScaled(float thicknessSqrt, float translucency) {
	return sqrt(1.0 - translucency) * thicknessSqrt;
}

float3 SSSSTransmittance(
	// this is sqrt(depth) * sqrt(1.0f - translucency)
	// where translucency is 0..1 and determines the effect strength
	// and depth is the mesh thickness
	float sqrtOpacity,

	/**
	* This parameter should be the same as the 'SSSSBlurPS' one. See below
	* for more details.
	*/
	float sssWidth) {
	/**
	* Calculate the scale of the effect.
	*/
	float scale = 8.25 / (sssWidth * 0.012f);

	float d = sqrtOpacity * sqrtOpacity * scale;

	/**
	* Armed with the thickness, we can now calculate the color by means of the
	* precalculated transmittance profile.
	* (It can be precomputed into a texture, for maximum performance):
	*/
	float dd = -d * d;
	float3 profile = float3(0.233, 0.455, 0.649) * exp(dd / 0.0064) +
		float3(0.1, 0.336, 0.344) * exp(dd / 0.0484) +
		float3(0.118, 0.198, 0.0)   * exp(dd / 0.187) +
		float3(0.113, 0.007, 0.007) * exp(dd / 0.567) +
		float3(0.358, 0.004, 0.0)   * exp(dd / 1.99) +
		float3(0.078, 0.0, 0.0)   * exp(dd / 7.41);

	/**
	* Using the profile, we finally approximate the transmitted lighting from
	* the back of the object:
	*/
	return profile;
}

float DepthToViewZ(float depth)
{
	// clipInfo ( x: Near, y: Far, z: Near-Far, w: Near*Far)

	// Vz    = (Near*Far)/( depth(Near-Far)+Far )
	float viewZ = (gFC_ClipInfo.w) / (depth*(gFC_ClipInfo.z) + gFC_ClipInfo.y);
	return viewZ;
}

uint3 GetClusterCoords(float3 worldPos) {
	float4 clipPos = mul(float4(worldPos, 1.0f), gFC_WorldViewClipMtx);
	clipPos.xyz /= clipPos.w;
	uint3 clusterCoords;
	clusterCoords.xy = min(floor((clipPos.xy * 0.5f + 0.5f) * float2(CLUSTER_COUNT_X, CLUSTER_COUNT_Y)), float2(CLUSTER_COUNT_X - 1, CLUSTER_COUNT_Y - 1));
	clusterCoords.z = min(float(CLUSTER_COUNT_Z - 1), log2(DepthToViewZ(clipPos.z) / gFC_ClipInfo.x) * gFC_ClusterParam.x);
	return clusterCoords;
}

float3 CalcPointLightsLegacy(MATERIAL Mtl, float3 V, float3 worldPos, float specularF90, float lightmapShadow)
{
	float3 pointLightComponent = float3(0.0f, 0.0f, 0.0f);

	//legacy forward
	for (uint i = 0; i < clamp(gFC_PntLightCount.x, 0, MAX_POINT_LIGHTS); ++i) {
		float3 L = gFC_PntLightPos[i].xyz - worldPos;
		float distL = length(L);
		if (distL < gFC_PntLightCol[i].w) {
			L *= 1.0 / distL;
			pointLightComponent += PointLightContribution(Mtl.Normal, L, V,
				Mtl.DiffuseColor, Mtl.SpecularColor, specularF90,
				Mtl.Roughness, gFC_PntLightCol[i].xyz, distL,
				gFC_PntLightPos[i].w, gFC_PntLightCol[i].w, (uint)gFC_DebugPointLightParams.x);
		}
	}

	return pointLightComponent;
}

float3 CalcPointLightsClustered(MATERIAL Mtl, float3 V, float3 worldPos, float specularF90, float lightmapShadow)
{
	float3 pointLightComponent = float3(0.0f, 0.0f, 0.0f);

	//clustered
	uint3 clusterCoords = GetClusterCoords(worldPos);
	uint offsetNum = numLightsBuffer[(clusterCoords.z * CLUSTER_COUNT_Y + clusterCoords.y) * CLUSTER_COUNT_X + clusterCoords.x].offsetNum;
#ifdef WITH_PntS
	uint lightNum = min((offsetNum >> 6) & 0x3f, gFC_PntLightCount.x);
#else
	uint lightNum = min(offsetNum & 0x3f, gFC_PntLightCount.x);
#endif
	uint offset = offsetNum >> 12;
	for (uint i = offset; i < offset + lightNum; ++i) {
#ifdef WITH_PntS
		uint lightID = (lightIDBuffer[i].id >> 9) & 0x1ff;
#else
		uint lightID = lightIDBuffer[i].id & 0x1ff;
#endif
		float4 lightPosition = lightParamBuffer[lightID].position;
		float4 lightColor = lightParamBuffer[lightID].color;
		float attenuation = lightParamBuffer[lightID].attenuation;
		uint falloffMode = lightParamBuffer[lightID].falloffMode;
		float3 L = lightPosition.xyz - worldPos;
		float distL = length(L);
		if (distL < lightColor.w) {
			float lightmapFactor = lerp(lightmapShadow, 1, attenuation);
			L /= distL;
			pointLightComponent += PointLightContribution(Mtl.Normal, L, V,
				Mtl.DiffuseColor, Mtl.SpecularColor, specularF90,
				Mtl.Roughness, lightColor.xyz, distL,
				lightPosition.w, lightColor.w, falloffMode) * lightmapFactor;
		}
	}

	return pointLightComponent;
}

float3 CalcEmissive(MATERIAL Mtl)
{
	float3 emissiveComponent = Mtl.EmissiveColor;

#ifdef FS_SUBSURF
	if (Mtl.SubsurfOpacity < 1.0f && Mtl.SubsurfStrength > 0.0f) {
#ifdef USE_SH
		if (gFC_SHEnabled != 0.0f) {
			emissiveComponent += Mtl.DiffuseColor * CalcSH(-Mtl.Normal, float4(In.VtxWld.xyz, 1.0f)) * SSSSTransmittance(Mtl.SubsurfOpacity, Mtl.SubsurfStrength);
		}
		else
#endif
		{
			emissiveComponent += Mtl.DiffuseColor * CalcDiffuseLD(-Mtl.Normal) * SSSSTransmittance(Mtl.SubsurfOpacity, Mtl.SubsurfStrength);
		}
	}
#endif

	return emissiveComponent;
}

float3 CalcEnvIBL(MATERIAL Mtl, float3 vertexNormal, float3 V, float3 worldPos, float specularF90)
{
	float NdotV = dot(Mtl.Normal, V);
	float3 R = 2.0f * NdotV * Mtl.Normal - V; // reflection direction
	NdotV = saturate(NdotV);

	float3 specularIBL = evaluateIBLSpecular(Mtl.Normal, R, vertexNormal, NdotV, Mtl.Roughness, Mtl.SpecularColor, specularF90);
	float3 diffuseIBL = evaluateIBLDiffuse(Mtl.Normal, V, NdotV, Mtl.Roughness);
#ifdef USE_SH
	if (gFC_SHEnabled != 0.0f) { // add SH component
		diffuseIBL += CalcSH(Mtl.Normal, float4(worldPos, 1.0f));
	}
#endif
	diffuseIBL *= Mtl.DiffuseColor;

	return Mtl.LightPower * (diffuseIBL + specularIBL);
}

MATERIAL PackMaterial(float4 albedo, float4 pblTexData, float3 normal)
{
	MATERIAL Mtl;

	if (gFC_MaterialWorkflow.x == 0) { // metalness
		Mtl.Roughness = lerp(pblTexData.r, gFC_DebugMaterialParams.x - 1.0f, saturate(gFC_DebugMaterialParams.x));
		float MetalMask = lerp(pblTexData.g, gFC_DebugMaterialParams.y - 1.0f, saturate(gFC_DebugMaterialParams.y));
		float DiffuseF0 = lerp(saturate(UnpackDiffuseF0(pblTexData.b)*CalcLuminance(gFC_SpcMapMulCol.xyz)), gFC_DebugMaterialParams.z - 1.0f, saturate(gFC_DebugMaterialParams.z));

		Mtl.LightPower = pblTexData.a;
		float EmissivePower = (1.0f - pblTexData.a) * gFC_DebugMaterialParams.w * EMISSIVE_STRENGTH;

		// this is actually slightly wrong but kept for compatibility
		// we should split the color to diffuse/specular first and then multiply them by respective multipliers
		float3 linearSampledColor = Srgb2linear(abs(albedo.rgb * lerp(gFC_DifMapMulCol.rgb, gFC_SpcMapMulCol.rgb, MetalMask)));

		Mtl.DiffuseColor = Mtl.LightPower * linearSampledColor * (1.f - MetalMask);
		Mtl.SpecularColor = saturate(Mtl.LightPower * lerp(DiffuseF0, linearSampledColor, MetalMask));
		Mtl.EmissiveColor = EmissivePower * linearSampledColor; // emissive only works with metalness
	}
	else {
		Mtl.LightPower = 1.0f;
		Mtl.DiffuseColor = Srgb2linear(albedo.rgb * gFC_DifMapMulCol.rgb);
		Mtl.SpecularColor = Srgb2linear(saturate(pblTexData.rgb * gFC_SpcMapMulCol.rgb));
		Mtl.Roughness = lerp(pblTexData.a, gFC_DebugMaterialParams.x - 1.0f, saturate(gFC_DebugMaterialParams.x));
		Mtl.EmissiveColor = float3(0.0f, 0.0f, 0.0f);
	}

	if (gFC_DebugDraw.y != 0) {
		int diffuseOverride = gFC_DebugDraw.y & 3;
		int specularOverride = (gFC_DebugDraw.y >> 2) & 3;
		switch (diffuseOverride) {
		case 1: Mtl.DiffuseColor = float3(0, 0, 0); break;
		case 2: Mtl.DiffuseColor = float3(1, 1, 1); break;
		}
		switch (specularOverride) {
		case 1: Mtl.SpecularColor = float3(0, 0, 0); break;
		case 2: Mtl.SpecularColor = float3(1, 1, 1); break;
		}
	}

	Mtl.Normal = normal;

	return Mtl;
}

float2 ParallaxMapping(float2 texCoords, float heightScale, float3 viewDir, float3 T, float3 B, float3 N)
{
	float3 tangentViewDir = normalize(float3(dot(viewDir, normalize(B)), dot(viewDir, normalize(T)), dot(viewDir, N)));
	float height = tex2D(gSMP_Height, texCoords).r;
	float2 p = tangentViewDir.xy * (height * heightScale);

	return texCoords - p;
}

float2 SteepParallaxMapping(float2 texCoords, float heightScale, float3 viewDir, float3 T, float3 B, float3 N)
{
	float3 tangentViewDir = normalize(float3(dot(viewDir, normalize(B)), dot(viewDir, normalize(T)), dot(viewDir, N)));

	const float numLayers = 10.0f;
	float layerDepth = 1.0f / numLayers;
	float currentLayerDepth = 0.0f;

	float2 P = tangentViewDir.xy * heightScale;
	float2 deltaTexCoords = P / numLayers;

	float2 currentTexCoords = texCoords;
	float2 dx = ddx(texCoords);
	float2 dy = ddy(texCoords);
	float currentDepthMapValue = tex2Dgrad(gSMP_Height, currentTexCoords, dx, dy).r;

	[loop]
	while (currentLayerDepth < currentDepthMapValue)
	{
		currentTexCoords -= deltaTexCoords;
		currentDepthMapValue = tex2Dgrad(gSMP_Height, currentTexCoords, dx, dy).r;
		currentLayerDepth += layerDepth;
	}

	return currentTexCoords;
}

float2 ParallaxOcclusionMapping(float2 texCoords, float heightScale, float3 viewDir, float3 T, float3 B, float3 N)
{
	float3 tangentViewDir = normalize(float3(dot(viewDir, normalize(B)), dot(viewDir, normalize(T)), dot(viewDir, N)));

	const float numLayers = 10.0f;
	float layerDepth = 1.0f / numLayers;
	float currentLayerDepth = 0.0f;

	float2 P = tangentViewDir.xy * heightScale;
	float2 deltaTexCoords = P / numLayers;

	float2 currentTexCoords = texCoords;
	float2 dx = ddx(texCoords);
	float2 dy = ddy(texCoords);
	float currentDepthMapValue = tex2Dgrad(gSMP_Height, currentTexCoords, dx, dy).r;
	float prevDepthMapValue = currentDepthMapValue;

	[loop]
	while (currentLayerDepth < currentDepthMapValue)
	{
		prevDepthMapValue = currentDepthMapValue;

		currentTexCoords -= deltaTexCoords;
		currentDepthMapValue = tex2Dgrad(gSMP_Height, currentTexCoords, dx, dy).r;
		currentLayerDepth += layerDepth;
	}

	float afterDepth = currentDepthMapValue - currentLayerDepth;
	float beforeDepth = prevDepthMapValue - currentLayerDepth + layerDepth;

	float weight = afterDepth / (afterDepth - beforeDepth);
	float2 finalTexCoords = (currentTexCoords + deltaTexCoords) * weight + currentTexCoords * (1.0f - weight);

	return finalTexCoords;
}

// Extracted to separate file because SFX shaders needs ReverseTonemap
#include "FRPG_Common_Tonemap.fxh"
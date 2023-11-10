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

#define M_PI 3.1415926535897932384626433832795

#define SOFT_SHADOW_SAMPLES 32
#define SOFT_SHADOW_MIN_PENUMBRA 0.03
#define SOFT_SHADOW_MAX_PENUMBRA 0.2
#define SOFT_SHADOW_AMBIENT_PENUMBRA 0.2

// FRPG_Commonに移動//#define gSMP_ShadowMap	gSMP_7	//シャドウマップ用サンプラ

float __GetShadowRate(const float4 lispPosition)
{
	const float3 uvw = lispPosition.xyz / lispPosition.w;
	return gSMP_ShadowMap.SampleCmp(gSMP_ShadowMapSampler, uvw.xy, uvw.z).x;
}

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

/*float CalcPenumbra(float4 lightSpacePosition, float noisePhi)
{
        for (int i = 0; i < SOFT_SHADOW_SAMPLES; i++)
        {
                float2 uv = lightSpacePosition.xy + SOFT_SHADOW_MAX_PENUMBRA * VogelDiskSample(i, phi);
        }
}*/

float3 GetShadowRate(
	float2 fragCoord,
	float4 worldPosition,
	float4 lispPosition,
	float4x4 shadowMtx,
	float4 shadowClamp,
	float normalShadow,
	float4 eyeVec = 0.0,
	float penumbraBias = 0.0)
{
	/* 視点からの距離(eyeVec.wに距離が入っている) */
	float dist = saturate((gFC_ShadowMapParam.y - eyeVec.w) * gFC_ShadowMapParam.z);
	float noisePhi = NoisePhi(fragCoord.xy);
	float penumbra = max(penumbraBias, SOFT_SHADOW_MIN_PENUMBRA);

	float4x4 worldToLightMatrix = DirectionMatrix(gFC_ShadowLightDir.xyz);
	float4x4 lightToLispMatrix = mul(MatrixTranspose(worldToLightMatrix), shadowMtx);
	float4 lightSpacePosition = mul(worldPosition, worldToLightMatrix);

	float4x4 offsetToLightMatrix = float4x4(
		penumbra, 0,        0,        0,
		0,        penumbra, 0,        0,
		0,        0,        penumbra, 0,
		lightSpacePosition);

	float4x4 offsetToLispMatrix = mul(offsetToLightMatrix, lightToLispMatrix);

	float shadow = normalShadow;

	for (int i = 0; i < SOFT_SHADOW_SAMPLES; i += 4) {
		float4x4 offsets = float4x4(
			VogelDiskSample(i + 0, noisePhi), 0, 1,
			VogelDiskSample(i + 1, noisePhi), 0, 1,
			VogelDiskSample(i + 2, noisePhi), 0, 1,
			VogelDiskSample(i + 3, noisePhi), 0, 1);

		float4x4 offsetPositions = mul(offsets, offsetToLispMatrix);

		// Clamp to cascade
		offsetPositions._m00_m01_m10_m11 = clamp(offsetPositions._m00_m01_m10_m11, shadowClamp.xyxy, shadowClamp.zwzw);
		offsetPositions._m20_m21_m30_m31 = clamp(offsetPositions._m20_m21_m30_m31, shadowClamp.xyxy, shadowClamp.zwzw);

		float4 samples = float4(
			__GetShadowRate(offsetPositions[0]),
			__GetShadowRate(offsetPositions[1]),
			__GetShadowRate(offsetPositions[2]),
			__GetShadowRate(offsetPositions[3]));

		shadow += dot(samples, dist * (1.0 / SOFT_SHADOW_SAMPLES));
	}

	return 1 - gFC_ShadowColor.xyz * saturate(shadow);
}

float3 CalcGetShadowRate(
	float2 fragCoord,
	float4 worldPosition,
	float4 lispPosition,
	float4x4 shadowMtx,
	float4 shadowClamp,
	float3 normal,
	float4 eyeVec = 0.0,
	float penumbraBias = 0.0)
{
	float NdotL = dot(gFC_ShadowLightDir.xyz, normal);
	// gFC_ShadowMapParam.w　影を落とすモデルかどうか　1:おとす。0:落とさない
	float fShadow = saturate((NdotL + gFC_ShadowMapParam.x) * gFC_ShadowMapParam.w);

	float3 rate = GetShadowRate(
		fragCoord,
		worldPosition,
		lispPosition,
		shadowMtx,
		shadowClamp,
		fShadow,
		eyeVec,
		penumbraBias);

	return pow(abs(rate), gFC_DebugPointLightParams.z);
}

// VertexShaderで World空間での位置をShadowMap空間に変換する
// ジオメトリが一個のShadowMap空間完全含まれた時
// ClampのみはPIXELで行う
float3 CalcGetShadowRateLitSpace(float2 fragCoord, float4 lispPosition, float3 normal, float4 eyeVec = 0.0, float penumbraBias = 0.0)
{
	float4 shadowClamp = gFC_ShadowMapClamp0 * lispPosition.w;
	float4 worldPosition = mul(lispPosition, MatrixInverse(gFC_ShadowMapMtxArray0));

	return CalcGetShadowRate(
		fragCoord,
		worldPosition,
		lispPosition,
		gFC_ShadowMapMtxArray0,
		shadowClamp,
		normal,
		eyeVec,
		penumbraBias);
}

// PixelShaderで PixelのWorld空間での位置をShadowMap空間に変換する Cascade
float3 CalcGetShadowRateWorldSpace(float2 fragCoord, float4 worldspace_Pos, float3 normal, float4 eyeVec = 0, float penumbraBias = 0.0)
{
	float4x4 shadowMtx;
	float4 shadowClamp;

	// float camDist = eyeVec.w; //カメラからの距離
	float viewZ = worldspace_Pos.w;

	float4 zGreater = (gFC_ShadowStartDist < viewZ);

	float4 fEndDist = float4(gFC_ShadowStartDist.yzw, 65535.0f);
	float4 zLess = (fEndDist >= viewZ);
	float4 fWeight = zGreater * zLess;

	shadowMtx  = gFC_ShadowMapMtxArray0 * fWeight.x;
	shadowMtx += gFC_ShadowMapMtxArray1 * fWeight.y;
	shadowMtx += gFC_ShadowMapMtxArray2 * fWeight.z;
	shadowMtx += gFC_ShadowMapMtxArray3 * fWeight.w;

	shadowClamp  = gFC_ShadowMapClamp0 * fWeight.x;
	shadowClamp += gFC_ShadowMapClamp1 * fWeight.y;
	shadowClamp += gFC_ShadowMapClamp2 * fWeight.z;
	shadowClamp += gFC_ShadowMapClamp3 * fWeight.w;

	float4 worldPosition = float4(worldspace_Pos.xyz, 1.0f);
	float4 lispPosition = mul(worldPosition, shadowMtx);

	shadowClamp *= lispPosition.w;

	return CalcGetShadowRate(
		fragCoord,
		worldPosition,
		lispPosition,
		shadowMtx,
		shadowClamp,
		normal,
		eyeVec,
		penumbraBias);
}

// PixelShaderで PixelのWorld空間での位置をShadowMap空間に変換する NoCascade
// CascadeではないけどPixel計算する、水面の影で使う
// 水面の場合HeightMapからの高さでDisplceしているので、一つの影スライスに収まるモデルでも
// PixelShaderでライト空間位置を計算する。(収まらないのは普通にCascade)
float3 CalcGetShadowRateWorldSpaceNoCsd(float2 fragCoord, float4 worldspace_Pos, float3 normal, float4 eyeVec = 0.0, float penumbraBias = 0.0)
{
	float4 worldPosition = float4(worldspace_Pos.xyz, 1.0f);
	float4 lispPosition = mul(worldPosition, gFC_ShadowMapMtxArray0);
	float4 shadowClamp = gFC_ShadowMapClamp0 * lispPosition.w;

	return CalcGetShadowRate(
		fragCoord,
		worldPosition,
		lispPosition,
		gFC_ShadowMapMtxArray0,
		shadowClamp,
		normal,
		eyeVec,
		penumbraBias);
}

#endif //___FRPG_Shader_FRPG_ShadowFunc_fxh___

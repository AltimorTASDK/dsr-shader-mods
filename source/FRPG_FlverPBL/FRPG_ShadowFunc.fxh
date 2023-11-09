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
#define SOFT_SHADOW_MAX_PENUMBRA 0.2
#define SOFT_SHADOW_AMBIENT_PENUMBRA 0.2

// FRPG_Commonに移動//#define gSMP_ShadowMap	gSMP_7	//シャドウマップ用サンプラ

float DecodeDepthCmp(const float3 uvw, const int2 offset)
{
	return gSMP_ShadowMap.SampleCmp(gSMP_ShadowMapSampler, uvw.xy, uvw.z, offset).x;
}

float __GetShadowRate_PCF16(const float4 position_in_light)
{
	float retval = 0.0f;
	const float3 vShadowCoord = position_in_light.xyz / position_in_light.w;
	const float4 weight = 1.0f / 9.0f;
	{
		const float4 attenuation = float4(
			DecodeDepthCmp(vShadowCoord, int2(-1, -1)),
			DecodeDepthCmp(vShadowCoord, int2( 0, -1)),
			DecodeDepthCmp(vShadowCoord, int2( 1, -1)),
			DecodeDepthCmp(vShadowCoord, int2(-1,  0))
		);
		retval += dot(attenuation, weight);
	}
	{
		const float4 attenuation = float4(
			DecodeDepthCmp(vShadowCoord, int2( 0,  0)),
			DecodeDepthCmp(vShadowCoord, int2( 1,  0)),
			DecodeDepthCmp(vShadowCoord, int2(-1,  1)),
			DecodeDepthCmp(vShadowCoord, int2( 0,  1)));
		retval += dot(attenuation, weight);
	}
	{
		const float attenuation = (
			DecodeDepthCmp(vShadowCoord, int2( 1,  1)));
		retval += attenuation * weight.x;
	}

	return retval;
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

float3 GetShadowRate_PCF16(
	float2 fragCoord,
	float4 lispPosition,
	float4x4 shadowMtx,
	float4 shadowClamp,
	float normalShadow,
	float4 eyeVec = 0.0,
	float penumbraBias = 0.0)
{
	/* 視点からの距離(eyeVec.wに距離が入っている) */
	float dist = saturate((gFC_ShadowMapParam.y - eyeVec.w) * gFC_ShadowMapParam.z);
	float fShadow = 0.0;
	float noisePhi = NoisePhi(fragCoord.xy);
	float penumbra = penumbraBias;

	float4x4 lightMatrix = DirectionMatrix(gFC_ShadowLightDir.xyz);
	float4x4 lispToLightMatrix = mul(MatrixInverse(shadowMtx), lightMatrix);
	float4x4 lightToLispMatrix = mul(MatrixInverse(lightMatrix), shadowMtx);
	float4 lightSpacePosition = mul(lispPosition, lispToLightMatrix);

	for (int i = 0; i < SOFT_SHADOW_SAMPLES; i++) {
		float2 offset = VogelDiskSample(i, noisePhi);
		float4 offsetPosition = lightSpacePosition + float4(offset * penumbra, 0, 0);
		float4 offsetLispPosition = mul(offsetPosition, lightToLispMatrix);

		// Clamp
		offsetLispPosition.xy -= (offsetLispPosition.xy < shadowClamp.xy) * offsetLispPosition.w;
		offsetLispPosition.xy += (offsetLispPosition.xy > shadowClamp.zw) * offsetLispPosition.w;

		fShadow += __GetShadowRate_PCF16(offsetLispPosition);
	}

	fShadow = saturate(fShadow * (1.0 / SOFT_SHADOW_SAMPLES) + normalShadow);
	return 1 - gFC_ShadowColor.xyz * dist * fShadow;
}

float3 CalcGetShadowRate(
	float2 fragCoord,
	float4 position_in_light,
	float4x4 shadowMtx,
	float4 shadowClamp,
	float3 normal,
	float4 eyeVec = 0.0,
	float penumbraBias = 0.0)
{
	float NdotL = dot(gFC_ShadowLightDir.xyz, normal);
	// gFC_ShadowMapParam.w　影を落とすモデルかどうか　1:おとす。0:落とさない
	float fShadow = saturate((NdotL + gFC_ShadowMapParam.x) * gFC_ShadowMapParam.w);
	float3 rate = GetShadowRate_PCF16(fragCoord, position_in_light, shadowMtx, shadowClamp, fShadow, eyeVec, penumbraBias);
	return pow(abs(rate), gFC_DebugPointLightParams.z);
}

// VertexShaderで World空間での位置をShadowMap空間に変換する
// ジオメトリが一個のShadowMap空間完全含まれた時
// ClampのみはPIXELで行う
float3 CalcGetShadowRateLitSpace(float2 fragCoord, float4 position_in_light, float3 normal, float4 eyeVec = 0.0, float penumbraBias = 0.0)
{
	float4 clamp_qloc_renamed = gFC_ShadowMapClamp0 * position_in_light.w;
	return CalcGetShadowRate(fragCoord, position_in_light, gFC_ShadowMapMtxArray0, clamp_qloc_renamed, normal, eyeVec, penumbraBias);
}

// PixelShaderで PixelのWorld空間での位置をShadowMap空間に変換する Cascade
float3 CalcGetShadowRateWorldSpace(float2 fragCoord, float4 worldspace_Pos, float3 normal, float4 eyeVec = 0, float penumbraBias = 0.0)
{
	float4x4 shadowMtx;

	// float camDist = eyeVec.w; //カメラからの距離
	float viewZ = worldspace_Pos.w;

	float4 zGreater = (gFC_ShadowStartDist < viewZ);
	float4 clamp_qloc_renamed = 0;

	float4 fEndDist = float4(gFC_ShadowStartDist.yzw, 65535.0f);
	float4 zLess = (fEndDist >= viewZ);
	float4 fWeight = zGreater * zLess;

	shadowMtx = gFC_ShadowMapMtxArray0 * fWeight.x;
	shadowMtx += gFC_ShadowMapMtxArray1 * fWeight.y;
	shadowMtx += gFC_ShadowMapMtxArray2 * fWeight.z;
	shadowMtx += gFC_ShadowMapMtxArray3 * fWeight.w;

	clamp_qloc_renamed = gFC_ShadowMapClamp0 * fWeight.x;
	clamp_qloc_renamed += gFC_ShadowMapClamp1 * fWeight.y;
	clamp_qloc_renamed += gFC_ShadowMapClamp2 * fWeight.z;
	clamp_qloc_renamed += gFC_ShadowMapClamp3 * fWeight.w;

	float4 worldPos = float4(worldspace_Pos.xyz, 1.0f);
	float4 position_in_light = mul(worldPos, shadowMtx);

	clamp_qloc_renamed *= position_in_light.w;

	return CalcGetShadowRate(fragCoord, position_in_light, shadowMtx, clamp_qloc_renamed, normal, eyeVec, penumbraBias);
}

// PixelShaderで PixelのWorld空間での位置をShadowMap空間に変換する NoCascade
// CascadeではないけどPixel計算する、水面の影で使う
// 水面の場合HeightMapからの高さでDisplceしているので、一つの影スライスに収まるモデルでも
// PixelShaderでライト空間位置を計算する。(収まらないのは普通にCascade)
float3 CalcGetShadowRateWorldSpaceNoCsd(float2 fragCoord, float4 worldspace_Pos, float3 normal, float4 eyeVec = 0.0, float penumbraBias = 0.0)
{
	float4 worldPos = float4(worldspace_Pos.xyz, 1.0f);
	float4 position_in_light = mul(worldPos, gFC_ShadowMapMtxArray0);
	float4 clamp_qloc_renamed = gFC_ShadowMapClamp0 * position_in_light.w;

	return CalcGetShadowRate(fragCoord, position_in_light, gFC_ShadowMapMtxArray0, clamp_qloc_renamed, normal, eyeVec, penumbraBias);
}

#endif //___FRPG_Shader_FRPG_ShadowFunc_fxh___

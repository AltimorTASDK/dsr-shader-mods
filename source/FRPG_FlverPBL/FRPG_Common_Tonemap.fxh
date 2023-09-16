float3 ReverseToneMap(float3 linearCol)
{
	if (gFC_InverseToneMapEnable.x)
	{
		float expScale = tex2D(gSMP_LumTex, float2(0.5f, 0.5f)).r;
		expScale = clamp(expScale, gFC_AdaptParam.z, gFC_AdaptParam.w);
		float3 rev = gFC_AdaptParam.y * linearCol;
		float middleGray = gFC_AdaptParam.x;
		return rev * (expScale + 0.0001) / middleGray;
	}
	else
	{
		return linearCol;
	}
}
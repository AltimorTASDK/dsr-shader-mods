float3 U2Func(float3 x)
{
	float ShoulderStrength = gFC_fMiddleGray.x; //0.15f;
	float LinearStrength = gFC_fMiddleGray.y; //0.5f;
	float LinearAngle = gFC_fMiddleGray.z; //0.1f;
	float ToeStrength = gFC_fMiddleGray.w; //0.2f;
	float ToeNumerator = gFC_AdaptParam.z;// 0.02f;
	float ToeDenominator = gFC_AdaptParam.w;// 0.3f;

	float A = ShoulderStrength;
	float B = LinearStrength;
	float C = LinearAngle;
	float D = ToeStrength;
	float E = ToeNumerator;
	float F = ToeDenominator;
	return ((x*(A*x + C*B) + D*E) / (x*(A*x + B) + D*F)) - E / F;
}

float ReverseU2(float Ux)
{
	float ShoulderStrength = gFC_fMiddleGray.x; //0.15f;
	float LinearStrength = gFC_fMiddleGray.y; //0.5f;
	float LinearAngle = gFC_fMiddleGray.z; //0.1f;
	float ToeStrength = gFC_fMiddleGray.w; //0.2f;
	float ToeNumerator = gFC_AdaptParam.z;// 0.02f;
	float ToeDenominator = gFC_AdaptParam.w;// 0.3f;

	float A = ShoulderStrength;
	float B = LinearStrength;
	float C = LinearAngle;
	float D = ToeStrength;
	float E = ToeNumerator;
	float F = ToeDenominator;

	float delta = (-4.0 * (Ux *Ux - Ux)*A*D*F *F*F + B *B * E *E
		- 2.0 * (B * B * C - B * B * Ux)*E*F + (B * B * C * C - 2.0 * B * B * C*Ux - 4.0 * A*D*E*Ux +
			B * B * Ux * Ux)*F *F);
	if (delta >= 0)
	{
		float ret1 = (-1.0 / 2.0 * (B*E - (B*C - B*Ux)*F + sqrt(delta)) / (A*F*(Ux - 1.0) + A*E));
		float ret2 = (-1.0 / 2.0 * (B*E - (B*C - B*Ux)*F - sqrt(delta)) / (A*F*(Ux - 1.0) + A*E)); //might always be < 0, need proof
		float ret = max(ret1, ret2);

		return max(ret, 0);
	}
	else //might be impossible with normal values, need proof
	{
		return 1 / 2 * (B*C*F - B*F*Ux - B*E) / (A*F*Ux + A*E - A*F);
	}
}

float3 ReverseToneMap(float3 linearCol)
{
	if (gFC_PostEffectScale.x)
	{
		float3 LinearWhite = float3(gFC_AdaptParam.y, gFC_AdaptParam.y, gFC_AdaptParam.y);
		float3 denominator = U2Func(LinearWhite);
	
		float3 tmp = saturate(linearCol)*denominator;
		float3 rev = float3(ReverseU2(tmp.x), ReverseU2(tmp.y), ReverseU2(tmp.z));

		float middleGray = gFC_AdaptParam.x;
		float expScale = tex2D(gSMP_LumTex, float2(0.5f, 0.5f)).r;
		expScale = clamp(expScale, gFC_PostEffectScale.z, gFC_PostEffectScale.w);
		return rev * (expScale + 0.0001) / middleGray;
		//return float3 (expScale, expScale, expScale);
	}
	else
	{
		return linearCol;
	}
}
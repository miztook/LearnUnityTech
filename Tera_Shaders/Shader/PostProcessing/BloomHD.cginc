// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


#include "UnityCG.cginc"

struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
};

struct v2f
{
	float2 uv : TEXCOORD0;
	float4 vertex : SV_POSITION;
};

v2f vert(appdata v)
{
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.uv = v.uv;
	return o;
}

sampler2D _MainTex;
float4 _MainTex_TexelSize;

float _Threshold;
float3 _Curve;
float _UpSampleScale;
float _Intensity;
sampler2D _BloomTex;

half GetBrightness(half3 c)
{
	return max(max(c.r, c.g), c.b);
}
half3 Median(half3 a, half3 b, half3 c)
{
	return a + b + c - min(min(a, b), c) - max(max(a, b), c);
}
half3 Clamp0Max(half3 rgb)
{
	half3 c;
	c.r = clamp(rgb.r, 0, 6000);
	c.g = clamp(rgb.g, 0, 6000);
	c.b = clamp(rgb.b, 0, 6000);
	return c;
}

half4 frag_filter(v2f i) : SV_Target
{
	half3 color = tex2D(_MainTex, i.uv);
#if UNITY_COLORSPACE_GAMMA
	color = GammaToLinearSpace(color);
#endif
	half bright = GetBrightness(color);
	half rq = clamp(bright - _Curve.x, 0, _Curve.y);
	rq = _Curve.z * rq * rq;
	color *= max(0, max(rq, bright - _Threshold) / max(bright, 1e-5));
	return half4(Clamp0Max(color), 1);
}
half4 frag_flickerfilter(v2f i) : SV_Target
{
	float3 d = _MainTex_TexelSize.xyx * float3(1, 1, 0);
	half3 c0 = tex2D(_MainTex, i.uv);
	half3 c1 = tex2D(_MainTex, i.uv - d.xz).rgb;
	half3 c2 = tex2D(_MainTex, i.uv + d.xz).rgb;
	half3 c3 = tex2D(_MainTex, i.uv - d.zy).rgb;
	half3 c4 = tex2D(_MainTex, i.uv + d.zy).rgb;
	half3 color = Median(Median(c0, c1, c2), c3, c4);

#if UNITY_COLORSPACE_GAMMA
	color = GammaToLinearSpace(color);
#endif
	half bright = GetBrightness(color);
	half rq = clamp(bright - _Curve.x, 0, _Curve.y);
	rq = _Curve.z * rq * rq;
	color *= max(0, max(rq, bright - _Threshold) / max(bright, 1e-5));
	return half4(Clamp0Max(color), 1);
}
half4 frag_downsampler(v2f i) : SV_Target
{
	float4 d = _MainTex_TexelSize.xyxy * float4(-1, -1, +1, +1);

	half4 s;
	s = (tex2D(_MainTex, i.uv));
	s += (tex2D(_MainTex, i.uv + d.xy));
	s += (tex2D(_MainTex, i.uv + d.zy));
	s += (tex2D(_MainTex, i.uv + d.xw));
	s += (tex2D(_MainTex, i.uv + d.zw));

	return s * (1.0 / 5);
}
half4 frag_flickerdownsampler(v2f i) : SV_Target
{
	float4 d = _MainTex_TexelSize.xyxy * float4(-1, -1, +1, +1) * _UpSampleScale;

	half3 s1 = (tex2D(_MainTex, i.uv + d.xy));
	half3 s2 = (tex2D(_MainTex, i.uv + d.zy));
	half3 s3 = (tex2D(_MainTex, i.uv + d.xw));
	half3 s4 = (tex2D(_MainTex, i.uv + d.zw));

	half s1w = 1 / (GetBrightness(s1) + 1);
	half s2w = 1 / (GetBrightness(s2) + 1);
	half s3w = 1 / (GetBrightness(s3) + 1);
	half s4w = 1 / (GetBrightness(s4) + 1);
	half sum = 1 / (s1w + s2w + s3w + s4w);

	return half4((s1 * s1w + s2 * s2w + s3 * s3w + s4 * s4w) * sum, 1);
}
half4 upsampler(v2f i)
{
	float4 d = _MainTex_TexelSize.xyxy * float4(-1, -1, +1, +1) * _UpSampleScale * 1.0;

	half4 s;
	s = (tex2D(_MainTex, i.uv + d.xy));
	s += (tex2D(_MainTex, i.uv + d.zy));
	s += (tex2D(_MainTex, i.uv + d.xw));
	s += (tex2D(_MainTex, i.uv + d.zw));

	s *= (1.0 / 4);

	return s;
}
half4 frag_upsampler(v2f i) : SV_Target
{
	half4 s;

	s = upsampler(i);
	s += tex2D(_BloomTex, i.uv);

	return s;
}
half4 frag_blend(v2f i) : SV_Target
{
	half3 color = frag_upsampler(i);
	color -= tex2D(_BloomTex, i.uv).rgb;
	color *= _Intensity;
//#if UNITY_COLORSPACE_GAMMA
//	color = LinearToGammaSpace(color);
//#endif
	return half4(color, 1);
}
half4 frag_final(v2f i) : SV_Target
{
	half3 main = tex2D(_MainTex, i.uv);
#if UNITY_COLORSPACE_GAMMA
	main = GammaToLinearSpace(main);
#endif
	half3 bloom = tex2D(_BloomTex, i.uv);
	half3 color = main + bloom;
#if UNITY_COLORSPACE_GAMMA
	color = LinearToGammaSpace(color);
#endif
	return half4(color, 1);
}
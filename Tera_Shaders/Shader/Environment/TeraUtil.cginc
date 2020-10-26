// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'unity_World2Shadow' with 'unity_WorldToShadow'


// Util
#if defined (SHADOWS_SCREEN)
	#if defined(UNITY_NO_SCREENSPACE_SHADOWS)
		#define TERA_SHADOWUV(a) a._ShadowCoord = mul( unity_WorldToShadow[0], mul( unity_ObjectToWorld, v.vertex ) );
	#else 
		#define TERA_SHADOWUV(a) a._ShadowCoord = ComputeScreenPos(a.vertex);
	#endif
#else
	#define TERA_SHADOWUV(a)
#endif

half3 decodelightmap( fixed4 color )
{
#if defined(UNITY_NO_RGBM)
	return DecodeLightmapDoubleLDR( color );
#else
	half4 hdr = half4(1, 0.01, 0, 0);
	hdr = half4(5, 1, 0, 0);
	return DecodeLightmapRGBM( color, hdr );
#endif
}

void TangentToWorld(half4 tangentToWorld[3], inout float3 n)
{
	half3 tangent = tangentToWorld[0].xyz;
	half3 binormal = tangentToWorld[1].xyz;
	half3 normal = tangentToWorld[2].xyz;

	n = normalize(tangent * n.x + binormal * n.y + normal * n.z);
}

void FaceUpFactor(inout fixed dir, half3 normalWorld)
{
	dir = (dot(normalWorld, half3(0, 1, 0))) > 0.5 ? 0 : 1;
}

// Rain
uniform sampler2D _RaindropRipple;
uniform float4 _RainParamters;

float3 ComputeRipple(float2 UV, float CurrentTime, float Weight)
{
	float4 Ripple = tex2D(_RaindropRipple, UV);
	Ripple.yz = Ripple.yz * 2 - 1; // Decompress perturbation

	float DropFrac = frac(Ripple.w + _Time.y); // Apply time shift
	float TimeFrac = DropFrac - 1.0f + Ripple.x;
	float DropFactor = saturate(0.2f + Weight * 0.8f - DropFrac);
	float FinalFactor = DropFactor * Ripple.x *
		sin(clamp(TimeFrac * 9.0f, 0.0f, 3.0f) * 3.14159);

	return float3(Ripple.yz * FinalFactor * 0.35f, 1.0f);
}

float3 GetRaindropRippleNormal(float2 mainUV)
{
	float2 uv = mainUV;
	// This are just visually tweak value
	float4 TimeMul = float4(1.0f, 0.85f, 0.93f, 1.13f);
	float4 TimeAdd = float4(0.0f, 0.2f, 0.45f, 0.7f);
	float4 Times = (_Time * TimeMul + TimeAdd) * 1.6f;
	Times = frac(Times);

	// Generate four shifted layer of animated circle
	float3 Ripple1 = ComputeRipple(uv + float2(0.25f, 0.0f), Times.x, 1);
	float3 Ripple2 = ComputeRipple(uv + float2(-0.55f, 0.3f), Times.y, 1);
	float3 Ripple3 = ComputeRipple(uv + float2(0.6f, 0.85f), Times.z, 1);
	float3 Ripple4 = ComputeRipple(uv + float2(0.5f, -0.75f), Times.w, 1);

	// We enable one layer by quarter intensity and progressively blend in the
	// current layer
	float4 Weights = _RainParamters.y + float4(0, 0.25, 0.5, 0.75);
	// Compose normal of the four layer based on weights
	float4 Z = lerp(1, float4(Ripple1.z, Ripple2.z, Ripple3.z, Ripple4.z), Weights);
	float3 Normal = float3(Weights.x * Ripple1.xy +
		Weights.y * Ripple2.xy +
		Weights.z * Ripple3.xy +
		Weights.w * Ripple4.xy,
		Z.x * Z.y * Z.z * Z.w);

	// return result
	return normalize(Normal) * 0.5 + 0.5;
}

half3 BlendNormalWithRaindrop(half3 normal, half3 ripple, fixed factor)
{
	half3 n;
	n.xy = normal.xy + ripple.xy * _RainParamters.x * factor;
	n.z = normal.z * _RainParamters.x;// * factor;
	return normalize(n);
}

// Snow
sampler2D _SnowTexUpperFace;
sampler2D _SnowTexSideFace;

float _SnowDensity;

void MixDiffuseWithSnow(inout fixed3 diffuse, float2 uv, inout half3 worldNormal, fixed factor)
{
	half snow_factor = saturate(dot(worldNormal, half3(0, 1, 0)) + lerp(-1, 1, _SnowDensity));

	fixed3 snowUpRGB = tex2D(_SnowTexUpperFace, uv);
	fixed3 snowSideRGB = tex2D(_SnowTexSideFace, uv);
	diffuse = lerp(snowUpRGB, snowSideRGB, factor) * snow_factor + (1 - snow_factor) * diffuse.rgb;

	worldNormal = lerp(worldNormal, half3(0, 1, 0), _SnowDensity * 0.8);
}
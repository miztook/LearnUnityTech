
//#include "UnityCG.cginc"
//#include "MainCharacterShadowMap.cginc"

//struct appdata
//{
//	float4 vertex : POSITION;
//	float2 uv : TEXCOORD0;
//	float3 normal : NORMAL;
//};
//
//struct v2f
//{
//	float2 uv : TEXCOORD0;
//	float4 vertex : SV_POSITION;
//	MCSHADOW_TC(1)
//	float3 normalWorld : TEXCOORD2;
//};
//
//sampler2D _MainTex;
//float4 _MainTex_ST;
//uniform float4 _SunDir;
//
//v2f vert(appdata v)
//{
//	v2f o;
//	o.vertex = UnityObjectToClipPos(v.vertex);
//	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
//
//	float3 normalWorld = UnityObjectToWorldNormal(v.normal);
//	float3 lightDir = normalize(_SunDir.xyz);
//
//	o.normalWorld = normalWorld;
//
//	TRANSFER_MCSHADOW_TC(o, normalWorld, lightDir);
//
//	return o;
//}
//
//fixed4 frag(v2f i) : SV_Target
//{
//	fixed4 col = tex2D(_MainTex, i.uv);
//
//	float3 lightDir = normalize(_SunDir.xyz);
//	//col *= saturate(dot(i.normalWorld, lightDir)) * 3;
//	
//	float shadow = SAMPLE_MCSHADOW(i);
//	
//	fixed4 final_color = col * shadow;
//	
//	return final_color;
//}

#define MCSHADOW_TC(idx) float4 _mcsm_tc : TEXCOORD##idx;
#define TRANSFER_MCSHADOW_TC(a, n, l) a._mcsm_tc = transfer_shadow_tc(v.vertex, l, n);
#define SAMPLE_MCSHADOW(a) sample_shadowmap(a._mcsm_tc);

UNITY_DECLARE_SHADOWMAP(_MainCharacterShadowMap);
uniform float4 _MainCharacterShadowMap_TexelSize;
uniform float _MCSM_Bias;
uniform float _MCSM_Intensity;
uniform float4x4 _MCSMMatrix;

float GetShadowBiasA1(float3 lightDir, float3 normal)
{
	float maxBias = 0.01;
	float baseBias = _MCSM_Bias;

	float cos_val = saturate(dot(lightDir, normal));
	float sin_val = sqrt(1 - cos_val*cos_val); // sin(acos(L·N))
	float tan_val = sin_val / cos_val;    // tan(acos(L·N))

	float bias = baseBias + clamp(tan_val, 0, maxBias);

	return bias;
}

float GetShadowBiasA2(float3 lightDir, float3 normal)
{
	float maxSlopeOffset = 0.01;
	float slopeBias = maxSlopeOffset * tan(acos(dot(normal, lightDir)));
	float bias = _MCSM_Bias + clamp(slopeBias, 0, maxSlopeOffset);

	return bias;
}

float4 transfer_shadow_tc(float4 vertex, float3 lightDir, float3 normal)
{
	float bias = GetShadowBiasA2(lightDir, normal);
	float4 tc = mul(_MCSMMatrix, mul(unity_ObjectToWorld, vertex));
	tc.z -= bias;
	return tc;
}

static half2 poisson[8] = {
	half2(0.02971195f, -0.8905211f),
	half2(0.2495298f, 0.732075f),
	half2(-0.3469206f, -0.6437836f),
	half2(-0.01878909f, 0.4827394f),
	half2(-0.2725213f, -0.896188f),
	half2(-0.6814336f, 0.6480481f),
	half2(0.4152045f, -0.2794172f),
	half2(0.1310554f, 0.2675925f),
};

half ShadowSample_Poisson(const half4 coords) {
	float MapSize = _MainCharacterShadowMap_TexelSize.z;
	//float ShadowFilterWidth = (1.0 / MapSize) * 6 * (MapSize / 2048);
	float ShadowFilterWidth = (1.0 / MapSize);
	half4 uv = coords;
	half shadow = 0.f;
	for (int i = 0; i < 8; ++i) {
		uv.xy = coords.xy + poisson[i] * ShadowFilterWidth;
		shadow += UNITY_SAMPLE_SHADOW(_MainCharacterShadowMap, uv.xyz);
	}
	return shadow / 8.f;
}

half ShadowSample_PCF(float4 coord)
{
	const float2 offset = float2(0.5, 0.5);
	float2 uv = (coord.xy * _MainCharacterShadowMap_TexelSize.zw) + offset;
	float2 base_uv = (floor(uv) - offset) * _MainCharacterShadowMap_TexelSize.xy;
	float2 st = frac(uv);

	float2 uw = float2(3 - 2 * st.x, 1 + 2 * st.x);
	float2 u = float2((2 - st.x) / uw.x - 1, (st.x) / uw.y + 1);
	u *= _MainCharacterShadowMap_TexelSize.x;

	float2 vw = float2(3 - 2 * st.y, 1 + 2 * st.y);
	float2 v = float2((2 - st.y) / vw.x - 1, (st.y) / vw.y + 1);
	v *= _MainCharacterShadowMap_TexelSize.y;

	half shadow;
	half sum = 0;

	sum += uw[0] * vw[0] * UNITY_SAMPLE_SHADOW(_MainCharacterShadowMap, float3(base_uv + float2(u[0], v[0]), coord.z));
	sum += uw[1] * vw[0] * UNITY_SAMPLE_SHADOW(_MainCharacterShadowMap, float3(base_uv + float2(u[1], v[0]), coord.z));
	sum += uw[0] * vw[1] * UNITY_SAMPLE_SHADOW(_MainCharacterShadowMap, float3(base_uv + float2(u[0], v[1]), coord.z));
	sum += uw[1] * vw[1] * UNITY_SAMPLE_SHADOW(_MainCharacterShadowMap, float3(base_uv + float2(u[1], v[1]), coord.z));

	shadow = sum / 16.0f;

	return shadow;
}

inline half ShadowIntensity(half shadow)
{
	return shadow * _MCSM_Intensity + (1 - _MCSM_Intensity);
}

float sample_shadowmap(float4 tc)
{
	fixed shadow = 1;
	
	// a1
	//shadow = UNITY_SAMPLE_SHADOW(_MainCharacterShadowMap, tc);

	// a2
	//shadow = ShadowSample_Poisson(tc);
	
	// a3
	shadow = ShadowSample_PCF(tc);

	// lerp
	shadow = ShadowIntensity(shadow);

	return shadow;
}

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/PostProcessing/Fog"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			float4x4 _InverseView;
			//uniform sampler2D_float _CameraDepthNormalsTexture;
			uniform sampler2D_float _CameraDepthTexture;
			float4 _FogColor;

			// distancefog_begin, distancefog_length, heightfog_begin, heightfog_length
			float4 fog_paramter;

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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			//float ComputeHalfSpace2(float3 wpos)
			//{
			//	float3 V = wpos - _WorldSpaceCameraPos;
			//	float3 C = _WorldSpaceCameraPos;
			//	float3 P = wpos;
			//
			//	float FDotC = _Height * C.y;
			//	float FDotP = _Height * P.y;
			//	float FDotV = _Height * V.y;
			//	float k = FDotC <= 0 ? 1 : 0;
			//
			//	float a = 1 / _Density;
			//
			//	float3 aV = (a * 0.5f) * V;
			//	float c1 = k * (FDotP + FDotC);
			//	float c2 = (1 - 2 * k) * FDotP;
			//	float FdotV = FDotV;
			//
			//	float g = min(c2, 0.0);
			//	g = -length(aV) * (c1 - g * g / abs(FdotV));
			//	return g;
			//}
			
			half4 frag (v2f i) : SV_Target
			{
				half4 sceneColor = tex2D(_MainTex, i.uv);

				//float depth;
				//float3 normal;
				//float4 depth_normal = tex2D(_CameraDepthNormalsTexture, i.uv);
				//DecodeDepthNormal(depth_normal, depth, normal);
				
				float depth = Linear01Depth (UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv)));
				
				if (depth >= 1) return sceneColor;

				float ez = depth * _ProjectionParams.z;
				float clamp_ez = max(ez, fog_paramter.x);
				float clamp_depth = clamp((clamp_ez - fog_paramter.x) / fog_paramter.y, 0, 1);

				float2 p11_22 = float2(unity_CameraProjection._11, unity_CameraProjection._22);
				float3 vpos = float3((i.uv * 2 - 1) / p11_22, -1) * ez;
				float4 wpos = mul(_InverseView, float4(vpos, 1));

				float distInFog = (wpos.y - fog_paramter.z) / fog_paramter.w;
				distInFog = 1 - clamp(distInFog, 0, 1);

				//float heigh_fogAmount = saturate((exp(distInFog * c)) *b);
				//float distance_fogAmount = 1 - saturate(exp(-clamp_depth * _Density));
				float heigh_fogAmount = distInFog;
				float distance_fogAmount = clamp_depth;
				//float fogAmount = max(heigh_fogAmount, distance_fogAmount);
				//fogAmount = heigh_fogAmount * (1 - clamp_depth) + distance_fogAmount * (clamp_depth);
				float fogAmount = heigh_fogAmount * distance_fogAmount;

				return lerp(sceneColor, _FogColor, fogAmount);
			}
			ENDCG
		}
	}
}

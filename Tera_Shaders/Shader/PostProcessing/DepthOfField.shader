// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/PostProcessing/DepthOfField"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		// 0
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			uniform sampler2D_float _CameraDepthTexture;

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
			float4 _MainTex_TexelSize;
			float3 _DepthOfFieldParamter;

			half4 frag (v2f i) : SV_Target
			{
				float final_color = 0;
				float depthEye = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv)));
				float coc = clamp((depthEye - _DepthOfFieldParamter.x) / _DepthOfFieldParamter.y, -1, 1);
				final_color = coc * _DepthOfFieldParamter.z + _DepthOfFieldParamter.z;
				// < 0 ? coc * half4(-1,0,0,1) : coc * half4(0,1,0,1);
				return half4(final_color, final_color, final_color, 1);
			}
			ENDCG
		}

		// 1
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			uniform sampler2D_float _bokehTex;

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

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			// From https://github.com/Unity-Technologies/PostProcessing/
			// blob/v2/PostProcessing/Shaders/Builtins/DiskKernels.hlsl
			static const int kernelSampleCount = 16;
			static const float2 kernel[kernelSampleCount] = {
				float2(0, 0),
				float2(0.54545456, 0),
				float2(0.16855472, 0.5187581),
				float2(-0.44128203, 0.3206101),
				float2(-0.44128197, -0.3206102),
				float2(0.1685548, -0.5187581),
				float2(1, 0),
				float2(0.809017, 0.58778524),
				float2(0.30901697, 0.95105654),
				float2(-0.30901703, 0.9510565),
				float2(-0.80901706, 0.5877852),
				float2(-1, 0),
				float2(-0.80901694, -0.58778536),
				float2(-0.30901664, -0.9510566),
				float2(0.30901712, -0.9510565),
				float2(0.80901694, -0.5877853),
			};
			float3 _DepthOfFieldParamter;

			half4 frag (v2f i) : SV_Target
			{
				float3 color = 0;
				for (int k = 0; k < kernelSampleCount; k++) {
					float2 o = kernel[k] * _DepthOfFieldParamter.z;
					o *= _MainTex_TexelSize.xy;
					color += tex2D(_MainTex, i.uv + o).rgb;
				}
				color *= 1.0 / kernelSampleCount;
				return half4(color, 1);
			}
			ENDCG
		}
		// 2
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			half4 frag (v2f i) : SV_Target
			{
				float4 o = _MainTex_TexelSize.xyxy * float2(-0.5, 0.5).xxyy;
				float4 s =
					tex2D(_MainTex, i.uv + o.xy) +
					tex2D(_MainTex, i.uv + o.zy) +
					tex2D(_MainTex, i.uv + o.xw) +
					tex2D(_MainTex, i.uv + o.zw);
				return s * 0.25;
			}
			ENDCG
		}
		// 3
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			uniform sampler2D_float _bokehTex;
			float3 _DepthOfFieldParamter;

			half4 frag (v2f i) : SV_Target
			{
				float4 o = _MainTex_TexelSize.xyxy * float2(-0.5, 0.5).xxyy;
				half coc0 = tex2D(_bokehTex, i.uv + o.xy).r - _DepthOfFieldParamter.z;
				half coc1 = tex2D(_bokehTex, i.uv + o.zy).r - _DepthOfFieldParamter.z;
				half coc2 = tex2D(_bokehTex, i.uv + o.xw).r - _DepthOfFieldParamter.z;
				half coc3 = tex2D(_bokehTex, i.uv + o.zw).r - _DepthOfFieldParamter.z;
					
				half cocMin = min(min(min(coc0, coc1), coc2), coc3);
				half cocMax = max(max(max(coc0, coc1), coc2), coc3);
				half coc = cocMax >= -cocMin ? cocMax : cocMin;

				return half4(tex2D(_MainTex, i.uv).rgb, coc);
			}
			ENDCG
		}
		// 4
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			uniform sampler2D_float _blurTex1;
			uniform sampler2D_float _bokehTex;
			float3 _DepthOfFieldParamter;

			half4 frag (v2f i) : SV_Target
			{
				half4 source = tex2D(_MainTex, i.uv);
				half coc = tex2D(_bokehTex, i.uv).r - _DepthOfFieldParamter.z;
				half4 dof = tex2D(_blurTex1, i.uv);
				// !TODO
				half dofStrength = smoothstep(0.1, 1, abs(coc));
				half3 color = lerp(source.rgb, dof.rgb, dofStrength);
				return half4(color, source.a);
			}
			ENDCG
		}
	}
}

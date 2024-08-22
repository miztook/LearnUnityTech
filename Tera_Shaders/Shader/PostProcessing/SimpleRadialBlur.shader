// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/PostProcessing/SimpleRadialBlur"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
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
			half2 _Pos;
			half4 _Params;

			half affectrange(half2 uv, half2 pos)
			{
				half length = distance(pos, uv);
				half t = length / _Params.y;
				half factor = length > _Params.y ? _Params.x : t * _Params.x;
				return factor;
			}

			half4 frag(v2f i) : SV_Target
			{
				half2 pos = saturate(_Pos);

				half4 color = (half4)0;
				float2 tc = i.uv - pos;
				half factor = affectrange(i.uv, pos);

				//for (int i = 0; i < 4; i++)
				//{
				//	half scale = 1.0 - factor * (i / 3.0f);
				//	color += tex2D(_MainTex, half2(tc * scale + pos));
				//}
				color = tex2D(_MainTex, i.uv) * 0.4f;
				half scale = 1.0 - factor * (1 / 3.0f);
				color += tex2D(_MainTex, half2(tc * scale + pos)) * 0.2f;
				scale = 1.0 - factor * (2 / 3.0f);
				color += tex2D(_MainTex, half2(tc * scale + pos)) * 0.2f;
				scale = 1.0 - factor * (3 / 3.0f);
				color += tex2D(_MainTex, half2(tc * scale + pos)) * 0.2f;
				return color;
			}
			ENDCG
		}
	}
}

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/PostProcessing/SpecialVision"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_MainColor("Color", Color) = (1, 1, 1, 1)
		_SecondTex("Texture", 2D) = "black" {}
		_AddFactor("Add", Vector) = (0, 0, 0, 0)
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
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
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
			float2 _AddFactor;

			half4 frag(v2f i) : SV_Target
			{
				half4 color = tex2D(_MainTex, i.uv.xy);

				half4 final_color = color;
				float l = pow(length(i.uv - float2(0.5, 0.5)) * 2, _AddFactor.x);
				final_color = color * (1 - l).xxxx;

				return final_color;
			}
			ENDCG
		}
	}
}

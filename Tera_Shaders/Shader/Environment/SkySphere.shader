Shader "TERA/Environment/SkySphere"
{
	Properties
	{
		_MainTex ("Texture (RGB)", 2D) = "white" {}
		_Color ("Main Color", color) = (1,1,1,1)
		_TopTex("Top Texture (RGBA)", 2D) = "black" {}
		_Layer2Tex("2nd layer (RGBA)", 2D) = "white" {}
		_Layer3Tex("3nd layer (RGBA)", 2D) = "black" {}
		_addTex("add layer (RGBA)", 2D) = "black" {}
		_RotSpeed("Rot Speed (L2, L3, TopRotaion, None)", Vector) = (0,0,0,0)
		_HeightFogBegin("_HeightFogBegin", float) = 0
		_HeightFogEnd("_HeightFogEnd", float) = 0
		_fogColor("Fog Color", Color) = (0.325, 0.325, 0.325, 1)
		[HideInInspector]_Alpha("Alpha", float) = 1
		[HideInInspector]_BlendFactorSrc("Blend Factor Src", Int) = 1
		[HideInInspector]_BlendFactorDest("Blend Factor Dest", Int) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry+300" }
		ZWrite Off
		Blend [_BlendFactorSrc] [_BlendFactorDest]

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				float2 uv3 : TEXCOORD3;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float f : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _Layer2Tex;
			float4 _Layer2Tex_ST;

			sampler2D _Layer3Tex;
			float4 _Layer3Tex_ST;
			
			sampler2D _addTex;
			float4 _addTex_ST;

			sampler2D _TopTex;
			float4 _TopTex_ST;

			fixed4 _RotSpeed;
			half _HeightFogBegin;
			half _HeightFogEnd;
			fixed4 _fogColor;
			fixed4 _Color;
			fixed _Alpha;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv0.xy = TRANSFORM_TEX(v.uv0, _MainTex);
				o.uv0.zw = TRANSFORM_TEX(v.uv1, _Layer2Tex);
				o.uv0.z += _RotSpeed.x * _Time.x;
				o.uv1.xy = TRANSFORM_TEX(v.uv2, _Layer3Tex);
				o.uv1.x += _RotSpeed.y * _Time.x;

				float h = mul(unity_ObjectToWorld, v.vertex).y;
				o.f = clamp(1 - (h - _HeightFogBegin) / (_HeightFogEnd - _HeightFogBegin), 0, 1);

				float2 pivot = float2(0.5,0.5);
				float cosAngle = cos(_Time.x * _RotSpeed.z);
				float sinAngle = sin(_Time.x * _RotSpeed.z);
				float2x2 rot = float2x2(cosAngle,-sinAngle,sinAngle,cosAngle);
				v.uv3 = v.uv3 - pivot;
				v.uv3 = mul(rot,v.uv3);
				v.uv3 += pivot;
				o.uv1.zw = TRANSFORM_TEX(v.uv3, _TopTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			    fixed3 maincolor = tex2D(_MainTex, i.uv0.xy).rgb;
				fixed3 final_color = maincolor;
				fixed4 l2 = tex2D(_Layer2Tex, i.uv0.zw);
				final_color = l2.a * l2.rgb + (1 - l2.a) * final_color;
				fixed4 l3 = tex2D(_Layer3Tex, i.uv1.xy);
				final_color = l3.a * l3.rgb + (1 - l3.a) * final_color;
				fixed l4 = tex2D(_addTex, i.uv0.xy).r;
				final_color += maincolor * l4;
				fixed4 top = tex2D(_TopTex, i.uv1.zw);
				final_color = top.a * top.rgb + (1 - top.a) * final_color;
				final_color = lerp(final_color, _fogColor.rgb, i.f);
				return fixed4(final_color, _Alpha);
			}
			ENDCG
		}
	}
}

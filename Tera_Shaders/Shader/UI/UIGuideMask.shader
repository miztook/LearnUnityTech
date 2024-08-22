Shader "TERA/UI/GuideMask"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Rect ("AAA", Vector) = (0, 0, 0, 0)
	}
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}

		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			ZTest[unity_GUIZTestMode]
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed4 vcolor : COLOR0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 vcolor : COLOR0;
			};

			sampler2D _MainTex;
			float4 _Rect;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.vcolor = v.vcolor;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = i.vcolor;

				float right = 1 - _Rect.z;
				float bottom = 1 - _Rect.w;

				if (i.uv.x > _Rect.x &&
					i.uv.x < right &&
					i.uv.y > _Rect.y &&
					i.uv.y < bottom)
				{
					float u = (i.uv.x - _Rect.x) / (right - _Rect.x);
					float v = (i.uv.y - _Rect.y) / (bottom - _Rect.y);
					col = fixed4(0, 0, 0, 0);
				}

				return col;
			}
			ENDCG
		}
	}
}

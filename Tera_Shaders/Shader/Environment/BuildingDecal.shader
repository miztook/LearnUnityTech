Shader "TERA/Environment/BuildingDecal"
{
	Properties
	{

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
            Zwrite Off
			Blend Zero One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return (fixed4)0;
			}
			ENDCG
		}
	}
}

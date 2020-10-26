Shader "TERA/Character/EtcMarkers" {
    Properties {
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _BaseRGB ("Base (RGB)", 2D) = "white" {}
        _EmissionScale ("Emission Scale", Range(1, 2)) = 1
    }
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		Lighting Off
		Pass
		{
			Tags { "LIGHTMODE" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 lmuv : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float3 ambient : COLOR0;
			};

			sampler2D _BaseRGB;
			float4 _BaseRGB_ST;
			uniform fixed  _EmissionScale;
			uniform fixed4 _MainColor;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _BaseRGB);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 final_color = fixed4(0, 0, 0, 1);
				half4 diffuse = tex2D(_BaseRGB, i.uv) * _MainColor;

				final_color.rgb = diffuse.rgb * _EmissionScale;
				return final_color;
			}
			ENDCG
		}
	}
	//FallBack "Mobile/Diffuse"
}
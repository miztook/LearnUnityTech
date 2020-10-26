Shader "TERA/Environment/MobileTransparentObject"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_MainColor("Base Color", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		ZWrite Off
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_mobile_diffuse_dir
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#include "MobileDiffuseInc.cginc"
			
			sampler2D _MainTex;
			uniform fixed4 _MainColor;

			uniform float4 _SunAmbientColor;

			fixed4 frag(v2f_mdd i) : SV_Target
			{
				fixed4 final_color = fixed4(0, 0, 0, 1);
				fixed4 diffuse = tex2D(_MainTex, i.uv);
				diffuse.rgb *= _MainColor.rgb;
				half3 light_color = half3(1, 1, 1);
				half atten = 1;
				final_color.a = diffuse.a;

#if defined(LIGHTMAP_ON)
				light_color = decodelightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmuv.xy));
				fixed3 ambient = _SunAmbientColor.rgb * _SunAmbientColor.a;
				final_color.rgb = ShadeWithDynamicLight_mdd_t(i, diffuse.rgb, light_color, atten, ambient);
#else
				final_color.rgb = ShadeWithDynamicLight_mdd_t(i, diffuse.rgb, light_color, atten, i.sh);
#endif
				UNITY_APPLY_FOG(i.fogCoord, final_color);
				return final_color;
			}
			ENDCG
		}
	}			
}

Shader "TERA/Environment/MobileDiffuseBumpGlassy"
{
	Properties
	{
	    _MainColor("Base Color", Color) = (1, 1, 1, 1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_BumpMap("Normalmap",2D) = "bump" {}
		_Shininess("Shininess", Range(0.03,1)) = 1
		spec("Spec Factor", Range(0,10)) = 1
		_reflint("Reflection Intenstiy",Range(0,5)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		Pass
		{
			Cull Front

			CGPROGRAM
			#pragma vertex vert_mobile_diffuse_bump_dir
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ RAIN_SURFACE_ON SNOW_SURFACE_ON
			
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#include "MobileDiffuseInc.cginc"

			sampler2D _MainTex;
			uniform float4 _MainColor;
			uniform half spec;

			uniform float4 _SunAmbientColor;

			fixed4 frag(v2f_mdbd i) : SV_Target
			{
				fixed4 final_color = fixed4(0, 0, 0, 1);
				fixed4 diffuse = tex2D(_MainTex, i.uv);
				diffuse.rgb *= _MainColor.rgb;
				half3 light_color = half3(1, 1, 1);
				fixed atten = 1;

#if defined(LIGHTMAP_ON)
				light_color = decodelightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmuv.xy));
				fixed3 ambient = _SunAmbientColor.rgb * _SunAmbientColor.a;
				final_color = ShadeWithDynamicLight_mdbd_t(i, diffuse, light_color, spec, atten, ambient);
#else
				final_color = ShadeWithDynamicLight_mdbd_t(i, diffuse, light_color, spec, atten, i.sh);
#endif
				UNITY_APPLY_FOG(i.fogCoord, final_color);
				return final_color;
			}
			ENDCG
		}

		Pass
		{
			Cull Back
			
			CGPROGRAM
			#pragma vertex vert_mobile_diffuse_bump_dir
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile __ SNOW_SURFACE_ON RAIN_SURFACE_ON

			#define TRANSPARENT_SCENEOBJECT
			#define ENVMAP_LIGHTING

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#include "MobileDiffuseInc.cginc"

			sampler2D _MainTex;
			uniform float4 _MainColor;
			uniform half spec;

			uniform float4 _SunAmbientColor;

			fixed4 frag(v2f_mdbd i) : SV_Target
			{
				fixed4 final_color = fixed4(0, 0, 0, 1);
				fixed4 diffuse = tex2D(_MainTex, i.uv);
				diffuse.rgb *= _MainColor.rgb;
				half3 light_color = half3(1, 1, 1);
				half atten = 1;
#if defined(LIGHTMAP_ON)
				light_color = decodelightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmuv.xy));
				fixed3 ambient = _SunAmbientColor.rgb * _SunAmbientColor.a;
				final_color = ShadeWithDynamicLight_mdbd_t(i, diffuse, light_color, spec,atten, ambient);
#else
				final_color = ShadeWithDynamicLight_mdbd_t(i, diffuse, light_color, spec,atten, i.sh);
#endif
				UNITY_APPLY_FOG(i.fogCoord, final_color);
				return final_color;
			}
			ENDCG
		}
	}
}

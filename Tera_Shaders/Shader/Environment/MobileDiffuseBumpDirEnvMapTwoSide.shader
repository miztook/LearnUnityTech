Shader "TERA/Environment/MobileDiffuseBumpEnvMapTwoSide"
{
	Properties
	{
		_MainColor("Base Color", Color) = (1, 1, 1, 1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_BumpMap("Normalmap", 2D) = "bump" {}
		_Shininess("Shininess", Range(0.03, 1)) = 1
		_SpecFactor("Spec Factor", Range(0, 1)) = 0
		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5
		_DstCull("Backface Cull 0=2Sided 2=1sided", Range(0,2)) = 0
	}
	SubShader
	{
		Tags { "RenderType" = "TransparentCutout" "Queue" = "AlphaTest-100" "IgnoreProjector" = "True" }
		LOD 400

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			Cull [_DstCull]

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
			fixed _SpecFactor;
			fixed _Cutoff;
			uniform fixed4 _MainColor;

			uniform float4 _SunAmbientColor;

			fixed4 frag(v2f_mdbd i) : SV_Target
			{
				fixed4 final_color = fixed4(0, 0, 0, 0);
				fixed4 diffuse = tex2D(_MainTex, i.uv);
				diffuse.rgb *= _MainColor.rgb;
				diffuse.a *= _MainColor.a;
				half3 light_color = half3(1, 1, 1);
				half atten = 1;
//				final_color.a = diffuse.a;
				clip(diffuse.a - _Cutoff);

#if defined(LIGHTMAP_ON)
				light_color = decodelightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmuv.xy));
				fixed3 ambient = _SunAmbientColor.rgb * _SunAmbientColor.a;
				final_color.rgb = ShadeWithDynamicLight_mdbd(i, diffuse.rgb, diffuse.a, light_color, atten, ambient);
#else
				final_color.rgb = ShadeWithDynamicLight_mdbd(i, diffuse.rgb, diffuse.a, light_color, atten, i.sh);
#endif
				UNITY_APPLY_FOG(i.fogCoord, final_color);
				return final_color;
			}
			ENDCG
		}

		UsePass "Hidden/Environment/EnvironmentPass/SHADOWCASTER"
	}
	SubShader
	{
		Tags { "RenderType" = "TransparentCutout" "Queue" = "AlphaTest-100" "IgnoreProjector" = "True" }
		LOD 200

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			Cull [_DstCull]

			CGPROGRAM
			#pragma vertex vert_200
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#include "MobileDiffuseInc.cginc"
			
			sampler2D _MainTex;
			uniform fixed4 _MainColor;
			fixed _Cutoff;

			uniform float4 _SunAmbientColor;

			fixed4 frag(v2f_mdd200 i) : SV_Target
			{
				fixed4 final_color = fixed4(0, 0, 0, 1);
				fixed4 diffuse = tex2D(_MainTex, i.uv);
				diffuse.rgb *= _MainColor.rgb;
				half3 light_color = half3(1, 1, 1);
				half atten = 1;
				clip(diffuse.a - _Cutoff);

#if defined(LIGHTMAP_ON)
				light_color = decodelightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmuv.xy));
				fixed3 ambient = _SunAmbientColor.rgb * _SunAmbientColor.a;
				final_color.rgb = ShadeWithLevel200(i, diffuse.rgb, light_color, ambient);
#else
				final_color.rgb = ShadeWithLevel200(i, diffuse.rgb, light_color);
#endif
				UNITY_APPLY_FOG(i.fogCoord, final_color);
				return final_color;
			}
			ENDCG
		}

		UsePass "Hidden/Environment/EnvironmentPass/SHADOWCASTER"
	}
//	FallBack "Mobile/Diffuse"
}

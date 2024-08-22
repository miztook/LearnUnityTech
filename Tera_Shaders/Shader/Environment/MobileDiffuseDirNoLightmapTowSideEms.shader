Shader "TERA/Environment/MobileDiffuseNoLightmapTowSideWithEmission"
{
	Properties
	{
		_MainColor("Main Color", color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5
		_DstCull("Backface Cull 0=2Sided 2=1sided", Range(0,2)) = 0
		_EmsTex("Emission (R)", 2D) = "black" {}
		_EmsColor("Emission Color", color) = (1,1,1,1)
		_Ems("Emission Intensity", Range(0,3)) = 1
	}
	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout" "Queue" = "AlphaTest-100" "IgnoreProjector" = "True" }

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			Cull [_DstCull]

			CGPROGRAM
			#pragma vertex vert_nolm_vcolor_mobile_diffuse_dir
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#include "TeraUtil.cginc"
			sampler2D _MainTex;
			sampler2D _EmsTex;
			fixed _Cutoff;
			fixed _Ems;

			uniform fixed4 _MainColor;
			uniform fixed4 _MainTex_ST;
			uniform fixed4 _EmsColor;
			uniform float4 _SunColor;
            uniform float4 _SunDir;
			uniform float4 _SunAmbientColor;

			struct appdata_nlmmdd
            {
	         float4 vertex : POSITION;
	         float3 normal : NORMAL;
	         float2 uv : TEXCOORD0;
	         fixed4 vcolor : COLOR0;
            };

            struct v2f_nlmmdd
            {
	         float4 vertex : SV_POSITION;
	         fixed4 lmcolor : COLOR0;
	         float2 uv : TEXCOORD0;
	         half3 normalWorld : TEXCOORD2;
	         UNITY_FOG_COORDS(3)
	        #if defined(SHADOWS_NATIVE) || defined(SHADOWS_SCREEN)
	         SHADOW_COORDS(4)
	        #endif
            };

            v2f_nlmmdd vert_nolm_vcolor_mobile_diffuse_dir(appdata_nlmmdd v) 
            {
                v2f_nlmmdd o = (v2f_nlmmdd)0;
                o.vertex = UnityObjectToClipPos(v.vertex );
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.lmcolor = v.vcolor;
                float3 posWorld = mul(unity_ObjectToWorld, v.vertex);
	            half3 normalWorld = UnityObjectToWorldNormal(v.normal);
                o.normalWorld = normalWorld;
             #if defined(SHADOWS_NATIVE) || defined(SHADOWS_SCREEN)
	            TERA_SHADOWUV(o)
             #endif
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }
			fixed4 frag(v2f_nlmmdd i) : SV_Target
			{
			    float3 lightDir = normalize(_SunDir.xyz);
	            half3 normal = i.normalWorld;
	            half3 lmcolor = 5 * i.lmcolor.a * i.lmcolor.rgb;
	            half3 sh = _SunAmbientColor.rgb * _SunAmbientColor.a;
	            half3 lightcolor = _SunColor.rgb * _SunColor.a * lmcolor;
	         #if defined(SHADOWS_NATIVE) || defined(SHADOWS_SCREEN)
	            half atten = SHADOW_ATTENUATION(i);
	            lightcolor *= atten;
	            sh *= atten;
             #endif
	            float nl = max(0, dot(normal, lightDir));
	                  sh = lerp(sh,dot(sh,float3(0.3,0.59,0.11)),nl);
	            half3 p1 = max(half3(0, 0, 0), lightcolor * nl + (sh*0.5) + (sh*0.5*lightcolor));
	            fixed4 diffuse = tex2D(_MainTex, i.uv);
				diffuse.rgb *= _MainColor.rgb;
				clip(diffuse.a - _Cutoff);
				fixed4 emission = tex2D(_EmsTex, i.uv);
				       emission.rgb = emission.r * _EmsColor.rgb * diffuse.rgb * _Ems;
				fixed4 final_color = fixed4(diffuse.rgb * p1 + (emission.rgb*2), diffuse.a);
				UNITY_APPLY_FOG(i.fogCoord, final_color);
				return final_color;
			}
			ENDCG
		}
		
		UsePass "Hidden/Environment/EnvironmentPass/CUTOUTSHADOWCASTER"
	}
}

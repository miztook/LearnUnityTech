Shader "TERA/Fx/RFX4/CutoutBorder" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (1,1,1,1)
		_EmissionTex("Emission (A)", 2D) = "black" {}
		_BumpTex ("Normal (RGB)", 2D) = "gray" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Cutoff ("_Cutoff", Range(0,1)) = 0
		//_Cutout2 ("Cutout2", Range(0,1)) = 0
		[HDR]_BorderColor ("Border Color", Color) = (1,1,1,1)
		_CutoutThickness ("Cutout Thickness", Range(0,1)) = 0.03
	}
	SubShader
	{
		Tags { "RenderType"="Tranparent"  "IgnoreProjector" = "True" }
		Pass
		{
            Zwrite On
			CGPROGRAM
			#pragma vertex vert_mobile_diffuse_bump_dir_forfx
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
            uniform fixed _Night;
            uniform fixed _lmfb;
            sampler2D _BumpTex;
            float4 _BumpTex_ST;
			sampler2D _EmissionTex;
			float4 _EmissionTex_ST;
			fixed _Shininess;
			half4 _Color;
		    half4 _BorderColor;
		    half4 _EmissionColor;
		    half _CutoutThickness;
		    half _Cutoff;

		    uniform fixed4 _SunColor;
            uniform float4 _SunDir;
			uniform fixed4 _SunAmbientColor;

			struct appdata_mdbdfx
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 uv : TEXCOORD0;
				float2 emuv : TEXCOORD1;
			};

			struct v2f_mdbdfx
			{
				float4 uv : TEXCOORD0;
				float2 emuv : TEXCOORD1;
				float4 vertex : SV_POSITION;
				UNITY_FOG_COORDS(2)
				half4 tangentToWorld[3]	: TEXCOORD3;
			};

			v2f_mdbdfx vert_mobile_diffuse_bump_dir_forfx(appdata_mdbdfx v)
			{
				v2f_mdbdfx o = (v2f_mdbdfx)0;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.uv, _BumpTex);
				o.emuv = TRANSFORM_TEX(v.uv, _EmissionTex);
				float3 posWorld = mul(unity_ObjectToWorld, v.vertex);
				half3 normalWorld = UnityObjectToWorldNormal(v.normal);

				float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
				float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
				o.tangentToWorld[0].xyz = tangentToWorld[0];
				o.tangentToWorld[1].xyz = tangentToWorld[1];
				o.tangentToWorld[2].xyz = tangentToWorld[2];

				float3 viewDir = posWorld.xyz - _WorldSpaceCameraPos;
				o.tangentToWorld[0].w = viewDir.x;
				o.tangentToWorld[1].w = viewDir.y;
				o.tangentToWorld[2].w = viewDir.z;

				UNITY_TRANSFER_FOG(o, o.vertex);
				return o;
			}
			fixed4 frag(v2f_mdbdfx i) : SV_Target
			{
				fixed4 final_color = fixed4(0, 0, 0, 1);
				fixed4 diffuse = tex2D(_MainTex, i.uv.xy);
				diffuse.rgb *= _Color.rgb;
				      
				half atten = 1;
				clip(diffuse.a - _Cutoff);
				half4 disp = diffuse.a < (_Cutoff + _CutoutThickness) ? _BorderColor : (tex2D(_EmissionTex,i.uv) * _EmissionColor);

				half3 viewDir = -normalize(half3(i.tangentToWorld[0].w, i.tangentToWorld[1].w, i.tangentToWorld[2].w));
				half3 lightDir = normalize(_SunDir.xyz);

				float3 normal = UnpackNormal(tex2D(_BumpTex, i.uv.zw));

				half3 tangent = i.tangentToWorld[0].xyz;
				half3 binormal = i.tangentToWorld[1].xyz;
				half3 normalworld = i.tangentToWorld[2].xyz;
				normal = normalize(tangent * normal.x + binormal * normal.y + normalworld * normal.z);

				half nl = saturate(dot(normal, lightDir));
				fixed3 ambient = saturate(_SunAmbientColor.rgb * _SunAmbientColor.a);
	     		       ambient = lerp(ambient,dot(ambient,float3(0.3,0.59,0.11)),nl);
				fixed3 aa_light_color = saturate(_SunColor.rgb * _SunColor.a);

				half3 p1 = max(half3(0, 0, 0), aa_light_color * nl + ambient);

				final_color.rgb = diffuse.rgb * p1 + disp.rgb;

				UNITY_APPLY_FOG(i.fogCoord, final_color);
				return final_color;
			}
			ENDCG
		}
	}
	 Fallback "Transparent/Cutout/Diffuse"
}

Shader "TERA/Fx/RFX4/Particle" {
	Properties {
	[HDR]_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,1)
	_MainTex ("Particle Texture", 2D) = "white" {}
	 [HideInInspector]_Cutout ("_Cutout", Float) = 0.2
	 [HideInInspector]_InvFade ("Soft Particles Factor", Float) = 1.0
	 [HideInInspector]SrcMode ("SrcMode", int) = 1
     [HideInInspector]DstMode ("DstMode", int) = 1
	 [HideInInspector]_Tiling ("Tiling", Vector) = (800, 800, 8, 8)
	 _VolumeExpansion ("Volume Expansion", Range(0.0, 1)) = 0
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "RFX4"="Particle"}
				Blend [SrcMode] [DstMode]
				Lighting On
				Cull Off 
				ZWrite Off
				Offset -1, -1
	SubShader {
		Pass {
				
			Tags{ "LIGHTMODE" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles
			#pragma multi_compile_fog
			#pragma multi_compile BlendAdd BlendAlpha BlendMul BlendMul2
			#pragma multi_compile Clip_OFF Clip_ON Clip_ON_Alpha
			#pragma target 3.0
			
			#include "UnityCG.cginc"
			#include "RFX4_ShaderExtension.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _TintColor;
			float4 _Tiling;
			float _Cutout;
			
			struct appdata_t {
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				#ifdef SOFTPARTICLES_ON
				float4 projPos : TEXCOORD2;
				#endif
			};

			half _VolumeExpansion;

			v2f vert (appdata_t v)
			{
				v2f o;
				v.vertex += v.normal * _VolumeExpansion;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				//o.color.rgb *= ComputeVertexLight(v.vertex, v.normal);

				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

	
			half4 frag (v2f i) : SV_Target
			{
				half4 tex = tex2D(_MainTex, i.texcoord);
				half4 res = 2 * tex * _TintColor;

			#ifdef Clip_ON
				res.a = step(_Cutout, tex.a) * res.a;
			#endif	

			#ifdef Clip_ON_Alpha
				res.a = step(1-i.color.a + _Cutout, tex.a);
				res.rgb *= i.color.rgb;
			#endif	

			#if !defined(Clip_ON_Alpha)
				res *= i.color;
			#endif	

				//res *= i.color;
				res.a = saturate(res.a);

			#ifdef BlendAdd
				UNITY_APPLY_FOG_COLOR(i.fogCoord, res, half4(0,0,0,0)); 
			#endif
			#ifdef BlendAlpha
				UNITY_APPLY_FOG(i.fogCoord, res);
			#endif
			#ifdef BlendMul
				res = lerp(half4(1,1,1,1), res, res.a);
				UNITY_APPLY_FOG_COLOR(i.fogCoord, res, half4(1,1,1,1)); // fog towards white due to our blend mode
			#endif
			#ifdef BlendMul2
				res = lerp(half4(0.5,0.5,0.5,0.5), res, res.a);
				UNITY_APPLY_FOG_COLOR(i.fogCoord, res, half4(0.5,0.5,0.5,0.5)); // fog towards gray due to our blend mode
			#endif
				return res;
			}
			ENDCG 
		}
	}	
}
 CustomEditor "RFX4_CustomMaterialInspectorParticle"
}
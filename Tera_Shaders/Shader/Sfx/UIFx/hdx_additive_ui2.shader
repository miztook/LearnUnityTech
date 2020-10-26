// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TERA/Fx/HDX/ParticlesAdditive_ui2" {
	Properties {
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_ClipArea ("ClipArea (V4)", Vector) = (-99999,-99999,99999,99999)
	}

	Category {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha One
		Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
		BindChannels {
			Bind "Color", color
			Bind "Vertex", vertex
			Bind "TexCoord", texcoord
		}

		SubShader {
			Pass {
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"
				#include "UnityUI.cginc"

				struct appdata_t {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord: TEXCOORD0;
				};

				struct v2f {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 uvmain : TEXCOORD0;
					float4 worldPosition : TEXCOORD1;
				};

				fixed4 _TintColor;
				float4 _MainTex_ST;
				sampler2D _MainTex;
				float4 _ClipArea;

				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					o.uvmain = TRANSFORM_TEX( v.texcoord, _MainTex );
					o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
					return o;
				}

				fixed4 frag( v2f i ) : COLOR
				{
					fixed4 final_color = 2.0f * i.color * _TintColor * tex2D( _MainTex, i.uvmain);
					final_color.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipArea);
					return final_color;
				}
				ENDCG
			}
		}
		// ------------------------------------------------------------------
		// Fallback for older cards and Unity non-Pro
		
		// SubShader {
		// 	Blend DstColor Zero
		// 	Pass {
		// 		Name "BASE"
		// 		SetTexture [_MainTex] {	combine texture }
		// 	}
		// }
	}
}

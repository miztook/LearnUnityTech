Shader "Hidden/Environment/EnvironmentPass"
{
	Properties
	{

	}
	SubShader
	{
		Tags{ 
			"RenderType" = "Transparent" 
			"Queue" = "Transparent" 
			"IgnoreProjector" = "True" 
		}

		Pass
		{
			Name "SHADOWCASTER"
			Tags{
				"LightMode" = "ShadowCaster"
			}

			ZWrite On 
			ZTest LEqual 
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"

            struct v2f {
				V2F_SHADOW_CASTER;
			};
			v2f vert(appdata_base v)
			{
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}
			half4 frag(v2f i) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}

		Pass
		{
			Name "CUTOUTSHADOWCASTER"
			Tags{
					"LightMode" = "ShadowCaster"
				}

			ZWrite On
			ZTest LEqual
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
			fixed _Cutoff;
			struct v2f {
				V2F_SHADOW_CASTER;
				float2 uv : TEXCOORD1;
			};

			float4 _MainTex_ST;

			v2f vert(appdata_base v)
			{
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			sampler2D _MainTex;

			half4 frag(v2f i) : SV_Target
			{
				fixed4 texcol = tex2D(_MainTex, i.uv);
				clip(texcol.a - _Cutoff);
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}	

		Pass
		{
			Name "CAMTRANSSHADOWCASTER"
			Tags{
					"LightMode" = "ShadowCaster"
				}

			ZWrite On
			ZTest LEqual
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"

			struct v2f {
				V2F_SHADOW_CASTER;
				float2 uv : TEXCOORD1;
			};

			float4 _MainTex_ST;

			v2f vert(appdata_base v)
			{
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			sampler2D _MainTex;

			half4 frag(v2f i) : SV_Target
			{
				fixed4 texcol = tex2D(_MainTex, i.uv);
				clip(texcol.a - 0.075);
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}		
	}
}

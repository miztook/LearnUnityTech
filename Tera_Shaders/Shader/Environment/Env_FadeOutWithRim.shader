// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TERA/Environment/FadeoutWithRim" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainPower ("Main Power", Range(0.0, 3)) = 1.5
        _RimPower ("Rim Power", Range(0, 3)) = 0
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
    }
	
	SubShader{
		Tags{
			"IgnoreProjector" = "True"
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}
		Pass{
			Name "FORWARD"

			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
			#pragma target 3.0

			uniform fixed4 _Color;
			uniform fixed _RimPower;
			uniform fixed4 _RimColor;
			uniform fixed _MainPower;
			uniform sampler2D _MainTex; uniform fixed4 _MainTex_ST;

			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord0 : TEXCOORD0;
			};
			struct VertexOutput {
				float4 pos : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
				float4 projPos : TEXCOORD3;
			};
			VertexOutput vert(VertexInput v) {
				VertexOutput o = (VertexOutput)0;
				o.uv0 = v.texcoord0;
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			half4 frag(VertexOutput i) : COLOR
			{
				fixed4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
				i.normalDir = normalize(i.normalDir);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 normalDirection = i.normalDir;
				half Fresnel = (1.0 - max(0, dot(i.normalDir, viewDirection))) * _MainTex_var.r * 1.5;
				half3 emissive = ((_RimColor.rgb*pow(1.0 - max(0, dot(i.normalDir, viewDirection)), _RimPower)*_RimPower) + (Fresnel*_Color.rgb*_MainPower));
				half3 finalColor = emissive;
				return fixed4(finalColor, Fresnel);
			}
			ENDCG
        }
    }
    //FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}

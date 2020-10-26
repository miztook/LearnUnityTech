// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TERA/Fx/Distortadd_4UVScroll" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_NoiseTex ("Distort Texture (RG)", 2D) = "white" {}
	_MainTex ("Alpha (A)", 2D) = "white" {}
	_HeatTime  ("Heat Time", range (-1,1)) = 0
	_ForceX  ("Strength X", range (0,1)) = 0.1
	_ForceY  ("Strength Y", range (0,1)) = 0.1
	_Mask_Tex("_Mask_Tex", 2D) = "white" {}
	_Mask_UVc_Layer2("_Mask_UVc_Layer2", Vector) = (1, 1, 0, 0)
	_Mask_UVc_Layer3("_Mask_UVc_Layer3", Vector) = (1, 1, 0, 0)
	_Mask_UVc_Layer4("_Mask_UVc_Layer4", Vector) = (1, 1, 0, 0)
	_Mask_UVc_Layer12_Speed("_Mask_UVc_Layer12_Speed", Vector) = (0, 0, 0, 0)
	_Mask_UVc_Layer34_Speed("_Mask_UVc_Layer34_Speed", Vector) = (0, 0, 0, 0)
	_AlphaScale("_AlphaScale", range (0,5)) = 1
	_DstBlend("BlendMod",float) = 1
}

Category {
	Tags { "Queue"="Transparent" "RenderType"="Transparent" }
	Blend SrcAlpha [_DstBlend]
	Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
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
#pragma multi_compile_particles
#include "UnityCG.cginc"

struct appdata_t {
	float4 vertex : POSITION;
	fixed4 color : COLOR;
	float2 uv0 : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float2 uv2 : TEXCOORD2;
	float2 uv3 : TEXCOORD3;
};

struct v2f {
	float4 vertex : POSITION;
	fixed4 color : COLOR;
	float4 tc0 : TEXCOORD0;
	float4 tc1 : TEXCOORD1;
};

uniform float4 _TimeEditor;
fixed4 _TintColor;
fixed _ForceX;
fixed _ForceY;
fixed _HeatTime;
float4 _MainTex_ST;
float4 _NoiseTex_ST;
sampler2D _NoiseTex;
sampler2D _MainTex;
 

uniform sampler2D _Mask_Tex;

uniform float4 _Mask_UVc_Layer2;
uniform float4 _Mask_UVc_Layer3;
uniform float4 _Mask_UVc_Layer4;

uniform float4 _Mask_UVc_Layer12_Speed;
uniform float4 _Mask_UVc_Layer34_Speed;

uniform float _AlphaScale;

float2 transform_tex_uv(float2 uv, float4 ST)
{
	return (uv.xy * ST.xy + ST.zw);
}

v2f vert (appdata_t v)
{
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.color = v.color;

//	float4 _Time = _Time + _TimeEditor;
	float2 _mainuv = (v.uv0 + _Time.y*_Mask_UVc_Layer12_Speed.xy);
	float2 _maskuv1 = (v.uv1 + _Time.y*_Mask_UVc_Layer12_Speed.zw);
	float2 _maskuv2 = (v.uv2 + _Time.y*_Mask_UVc_Layer34_Speed.xy);
	float2 _maskuv3 = (v.uv3 + _Time.y*_Mask_UVc_Layer34_Speed.zw);

	o.tc0.xy = TRANSFORM_TEX(v.uv0, _MainTex);
	o.tc0.zw = transform_tex_uv(_maskuv1, _Mask_UVc_Layer2);
	o.tc1.xy = transform_tex_uv(_maskuv2, _Mask_UVc_Layer3);
	o.tc1.zw = transform_tex_uv(_maskuv3, _Mask_UVc_Layer4);

	return o;
}

fixed4 frag( v2f i ) : COLOR
{
	float2 uvmain = i.tc0.xy;
	//noise effect
	fixed4 offsetColor1 = tex2D(_NoiseTex, uvmain + _Time.xz*_HeatTime);
    fixed4 offsetColor2 = tex2D(_NoiseTex, uvmain + _Time.yx*_HeatTime);

	uvmain.x += ((offsetColor1.r + offsetColor2.r) - 1) * _ForceX;
	uvmain.y += ((offsetColor1.r + offsetColor2.r) - 1) * _ForceY;

	float4 _Mask_UVc2_var = tex2D(_Mask_Tex, i.tc0.zw);
	float4 _Mask_UVc3_var = tex2D(_Mask_Tex, i.tc1.xy);
	float4 _Mask_UVc4_var = tex2D(_Mask_Tex, i.tc1.zw);

	fixed4 finalRGBA = 2.0f * i.color * _TintColor * tex2D( _MainTex, uvmain);
	finalRGBA.a *= _Mask_UVc2_var.r * _Mask_UVc3_var.g * _Mask_UVc4_var.b * _AlphaScale;
	return finalRGBA;
}
ENDCG
		}
}
	// ------------------------------------------------------------------
	// Fallback for older cards and Unity non-Pro
	
	SubShader {
		Blend DstColor Zero
		Pass {
			Name "BASE"
			SetTexture [_MainTex] {	combine texture }
		}
	}
}
}

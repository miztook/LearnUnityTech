// Upgrade NOTE: replaced '_Projector' with 'unity_Projector'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "TERA/Fx/Decl/Scroll 1 Layers Sine AlphaBlended" {
Properties {
	_MainTex ("Base layer (RGB)", 2D) = "white" {}
	_ScrollX ("Base layer Scroll speed X", Float) = 1.0
	_ScrollY ("Base layer Scroll speed Y", Float) = 0.0
	_SineAmplX ("Base layer sine amplitude X",Float) = 0.5 
	_SineAmplY ("Base layer sine amplitude Y",Float) = 0.5
	_SineFreqX ("Base layer sine freq X",Float) = 10 
	_SineFreqY ("Base layer sine freq Y",Float) = 10
	_Color("Color", Color) = (1,1,1,1)
	
	_MMultiplier ("Layer Multiplier", Float) = 2.0
		_RangeTex("Range Tex", 2D) = "white" {}

}

	
SubShader {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	
	Blend SrcAlpha OneMinusSrcAlpha
	Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
	
	LOD 100
	
	
	
	CGINCLUDE
	//#pragma exclude_renderers molehill    
	#include "UnityCG.cginc"
	sampler2D _MainTex;
	sampler2D _DetailTex;

	float4 _MainTex_ST;
	float4 _DetailTex_ST;
	
	float _ScrollX;
	float _ScrollY;
	float _MMultiplier;
	
	float _SineAmplX;
	float _SineAmplY;
	float _SineFreqX;
	float _SineFreqY;

	float4 _Color;

	float4x4 unity_Projector;
	sampler2D _RangeTex;

	struct v2f {
		float4 pos : SV_POSITION;
		float4 uv : TEXCOORD0;
		fixed4 color : TEXCOORD1;
	};

	
	v2f vert (appdata_full v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);

		float2 texcoord = mul(unity_Projector, v.vertex);

		o.uv.xy = TRANSFORM_TEX(texcoord.xy,_MainTex) + frac(float2(_ScrollX, _ScrollY) * _Time);
		
		o.uv.x += sin(_Time * _SineFreqX) * _SineAmplX;
		o.uv.y += sin(_Time * _SineFreqY) * _SineAmplY;

		o.uv.zw = texcoord;
		
		o.color = _MMultiplier * _Color * v.color;
		return o;
	}
	ENDCG


	Pass {
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
//		#pragma fragmentoption ARB_precision_hint_fastest		
		fixed4 frag (v2f i) : COLOR
		{
			fixed4 o;
			fixed4 tex = tex2D (_MainTex, i.uv.xy);
			
			o = tex * i.color;

			fixed alpha = tex2D(_RangeTex, i.uv.zw).a;
			o.a *= alpha;
						
			return o;
		}
		ENDCG 
	}	
}
}

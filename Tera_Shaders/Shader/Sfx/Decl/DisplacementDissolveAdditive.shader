// Upgrade NOTE: replaced '_Projector' with 'unity_Projector'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TERA/Fx/Decl/DisplacementDissolveAdditive" {
Properties {
 _TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
 _MainTex ("Main Texture", 2D) = "white" {}
 _DispMap ("Displacement Map (RG)", 2D) = "white" {}
 _DissolveMap ("Dissolve Mask (R)", 2D) = "white" {}



 _DispScrollSpeedX  ("Displacement Map Scroll Speed X", Float) = 0
 _DispScrollSpeedY  ("Displacement Map Scroll Speed Y", Float) = 0
 _DispX  ("Displacement Strength X", Float) = 0
 _DispY  ("Displacement Strength Y", Float) = 0.2

 _DissolveGamma ("Dissolve Gamma", Float) = 1

	 _RangeTex("Range Tex", 2D) = "white" {}
 _FlowSpeed("FlowSpeed", Float) = 1
_FlowSpeed2("FlowSpeed2", Float) = 0

}

Category {
 Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
 Blend SrcAlpha One
 Cull Off Lighting Off ZWrite Off
 BindChannels {
     Bind "Color", color
     Bind "Vertex", vertex
     Bind "TexCoord", texcoord
 }
 
 // ---- Fragment program cards
 SubShader {
     Pass {
     
         CGPROGRAM
         #pragma vertex vert
         #pragma fragment frag
         #pragma fragmentoption ARB_precision_hint_fastest
         #pragma multi_compile_particles
         
         #include "UnityCG.cginc"

         uniform sampler2D _MainTex;
         uniform sampler2D _DissolveMap;
		 uniform sampler2D _DispMap;
         uniform half _DispScrollSpeedX;
         uniform half _DispScrollSpeedY;

		 uniform half _DispX;
         uniform half _DispY;


         uniform fixed4 _TintColor;
		 uniform half _DissolveGamma;

		 float4x4 unity_Projector;
		 sampler2D _RangeTex;

		 uniform fixed _FlowSpeed;
		 uniform fixed _FlowSpeed2;
         
         struct appdata_t {
             float4 vertex : POSITION;
             fixed4 color : COLOR;
			 float2 texcoord : TEXCOORD0;
             //float2 param : TEXCOORD1;
         };

         struct v2f {
             float4 vertex : POSITION;
             fixed4 color : COLOR;
             float2 texcoord : TEXCOORD0;
			 //float2 param : TEXCOORD1;
         }; 
         
         v2f vert (appdata_t v)
         {
             v2f o;
             o.vertex = UnityObjectToClipPos(v.vertex);
             o.color = v.color;
			 o.texcoord = mul(unity_Projector, v.vertex);
			 //o.param = o.texcoord;
             return o;
         }
         fixed4 frag (v2f i) : COLOR
         {
			 fixed alpha = tex2D(_RangeTex, i.texcoord).a;

			 //scroll displacement map.
			 half2 mapoft = half2(_Time.y*_DispScrollSpeedX, _Time.y*_DispScrollSpeedY);

			 //get displacement offset
			 half4 dispColor = tex2D(_DispMap, i.texcoord + mapoft);

			 half2 uvoft = i.texcoord;
		     uvoft.x +=  dispColor.r * _DispX * _FlowSpeed;
			 uvoft.y +=  dispColor.g * _DispY * _FlowSpeed;


			 //NOTE, NOT DISTORT MAIN TEX, DISTORT THE MASK?..
			 //get main color
			 fixed4 mainColor = tex2D(_MainTex, i.texcoord);

			 //get mask , apply displacement.
             fixed4 dissolveColor = tex2D(_DissolveMap, uvoft);
             fixed grayscale = dissolveColor.r;

			 //apply color level to mask
			 fixed phase = _FlowSpeed2;
			 fixed input1 = max(grayscale - phase, 0);
			 fixed input = min(input1 / (1.0 - phase),1);
			 grayscale = lerp(0, 1.0, pow(input, 1.0 / _DissolveGamma));

			 //final
             fixed4 color = 2.0f * i.color * _TintColor * mainColor * grayscale;
			 			 
			 color.a *= alpha;

			 return color;
         }
         ENDCG
     }
 }   
}
}
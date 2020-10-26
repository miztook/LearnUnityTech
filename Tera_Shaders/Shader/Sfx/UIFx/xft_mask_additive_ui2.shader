// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TERA/Fx/HDX/mask-additive_ui2" {
Properties {
 _TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
 _MainTex ("Main Texture", 2D) = "white" {}
 _MaskTex ("Mask (R)", 2D) = "white" {}
 _ScrollTimeX  ("Scroll Speed X", Float) = 0
 _ScrollTimeY  ("Scroll Speed Y", Float) = 0
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
 
 // ---- Fragment program cards
 SubShader {
     Pass {
     
         CGPROGRAM
         #pragma vertex vert
         #pragma fragment frag
         #pragma fragmentoption ARB_precision_hint_fastest
         #pragma multi_compile_particles
         
         #include "UnityCG.cginc"
         #include "UnityUI.cginc"

         sampler2D _MainTex;
         sampler2D _MaskTex;
         half _ScrollTimeX;
         half _ScrollTimeY;
	float4 _ClipArea;
         fixed4 _TintColor;
         
         struct appdata_t {
             float4 vertex : POSITION;
             fixed4 color : COLOR;
             float2 texcoord : TEXCOORD0;
         };

         struct v2f {
             float4 vertex : POSITION;
             fixed4 color : COLOR;
             float2 texcoord : TEXCOORD0;
	     float3 wpos : TEXCOORD1;
         };
         
         v2f vert (appdata_t v)
         {
             v2f o;
             o.vertex = UnityObjectToClipPos(v.vertex);
             o.color = v.color;
             o.texcoord = v.texcoord;
	     o.wpos = mul(unity_ObjectToWorld, v.vertex);
             return o;
         }
         fixed4 frag (v2f i) : COLOR
         {
             half2 uvoft = i.texcoord;
             uvoft.x += _Time.y*_ScrollTimeX;
             uvoft.y += _Time.y*_ScrollTimeY;
             fixed4 offsetColor = tex2D(_MaskTex, uvoft);
             fixed grayscale = offsetColor.r;
             fixed4 mainColor = tex2D(_MainTex, i.texcoord);
	     
             fixed4 final_color = 2.0f * i.color * _TintColor * mainColor * grayscale;

	     final_color.a *= UnityGet2DClipping(i.wpos.xy, _ClipArea);

             return final_color;
         }
         ENDCG
     }
 }   
}
}
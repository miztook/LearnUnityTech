Shader "TERA/Fx/HDX/shining-displacement-additive-sin" {
Properties {
    [Header(Shining1)]
    [HDR] _EffectColor1("EffectColor1",Color) = (1,1,1,1)
    [NoScaleOffset] _ShiningNoise1("1-ShiningNoise(RG) StripeRegion(B) StripeNoise(A)",2D) = "white"{}
    _ShiningTiling1("ShiningTiling1(X1Y1X2Y2)",Vector) = (1,1,1,1)
    _ShiningRange1("ShiningRange1",Range(0.05,0.2)) = 0.1
    _ShiningPow1("ShiningPow1",Float) = 2
    _ShiningSpeed1("ShiningSpeed1",Float) = 0
    _ShiningSpeedX1("ShiningSpeedX1",Float) = 0
    _ShiningSpeedY1("ShiningSpeedY1",Float) = 0
    _BaseStrength1("BaseStrength1",Range(0,0.5)) = 0.1

    [Header(Shining2)]
    [HDR] _EffectColor2("EffectColor2",Color) = (1,1,1,1)
    [NoScaleOffset] _ShiningNoise2("2-ShiningNoise(RG) StripeRegion(B) StripeNoise(A)",2D) = "white"{}
    _ShiningTiling2("ShiningTiling2(X1Y1X2Y2)",Vector) = (1,1,1,1)
    _ShiningRange2("ShiningRange2",Range(0.05,0.2)) = 0.1
    _ShiningPow2("ShiningPow2",Float) = 2
    _ShiningSpeed2("ShiningSpeed2",Float) = 0
    _ShiningSpeedX2("ShiningSpeedX2",Float) = 0
    _ShiningSpeedY2("ShiningSpeedY2",Float) = 0
    _BaseStrength2("BaseStrength2",Range(0,0.5)) = 0.1

    [Header(Displacement)]
     [HDR]_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
    _DispStrength("Strength",Range(0,1)) = 0.5
     _MainTex ("Main Texture", 2D) = "white" {}
     _DispMap ("Displacement Map (RG)", 2D) = "white" {}
     _MainScrollSpeedX  ("Main Map Scroll Speed X", Float) = 0
     _MainScrollSpeedY  ("Main Map Scroll Speed Y", Float) = 0
     _DispX  ("Displacement Strength X", Float) = 0
     _DispY  ("Displacement Strength Y", Float) = 0.2
     _VolumeExpansion ("Volume Expansion", Range(0.0, 1)) = 0
}

Category {
 Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
 Blend SrcAlpha One
 Cull Off Lighting Off ZWrite Off
 Offset -1, -1
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

         uniform float4 _EffectColor1;
         uniform sampler2D _ShiningNoise1;
         uniform float4 _ShiningNoise1_ST;
         uniform float4 _ShiningTiling1;
         uniform float _ShiningPow1;
         uniform float _ShiningSpeed1;
         uniform float _ShiningSpeedX1;
         uniform float _ShiningSpeedY1;
         uniform float _BaseStrength1;
         uniform float _ShiningRange1;

         uniform float4 _EffectColor2;
         uniform sampler2D _ShiningNoise2;
         uniform float4 _ShiningNoise2_ST;
         uniform float4 _ShiningTiling2;
         uniform float _ShiningPow2;
         uniform float _ShiningSpeed2;
         uniform float _ShiningSpeedX2;
         uniform float _ShiningSpeedY2;
         uniform float _BaseStrength2;
         uniform float _ShiningRange2;



         uniform sampler2D _MainTex;
         float4 _MainTex_ST;
         float _DispStrength;
		 uniform sampler2D _DispMap;
		 float4 _DispMap_ST;
         uniform half _DispScrollSpeedX;
         uniform half _DispScrollSpeedY;
         uniform half _MainScrollSpeedX;
         uniform half _MainScrollSpeedY;

		 uniform half _DispX;
         uniform half _DispY;
         //uniform fixed uvswitcher;

         uniform fixed4 _TintColor;

         uniform half _VolumeExpansion;

         
         struct appdata_t {
             float4 vertex : POSITION;
             fixed4 color : COLOR;
             float2 texcoord : TEXCOORD0;
             float4 normal : NORMAL;
         };

         struct v2f {
             float4 vertex : POSITION;
             fixed4 color : COLOR;             
             float4 uv0 : TEXCOORD0;
			 float4 uv1 : TEXCOORD1;
			 
         }; 
         
         v2f vert (appdata_t v)
         {
             v2f o;
             v.vertex += v.normal * _VolumeExpansion;
             o.vertex = UnityObjectToClipPos(v.vertex);
             o.color = v.color;
             o.uv0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
             o.uv0.zw = TRANSFORM_TEX(v.texcoord, _DispMap);
			 o.uv1.xy = v.texcoord;
             return o;
         }
         half4 frag (v2f i) : COLOR
         {

             half4 finalColor = half4(0,0,0,0);

             //////////Shining1
             fixed shiningBase1 = tex2D(_ShiningNoise1, i.uv1.xy * _ShiningTiling1.xy).r;
             fixed shiningBase2 = tex2D(_ShiningNoise1, i.uv1.xy * _ShiningTiling1.xy * float2(1.2,1.2)).r;
             
             fixed shining1 = 1 - saturate(abs((sin(_Time.y * _ShiningSpeed1) + 1) / 2.0 - shiningBase1) / _ShiningRange1);
             fixed shining2 = 1 - saturate(abs((-sin(_Time.y * _ShiningSpeed1 * 1.5) + 1) / 4.0 + 0.1 - shiningBase2) / _ShiningRange1);
             //shining2 = 1;
             fixed shining3 = 1 - saturate(abs((cos(_Time.y * _ShiningSpeed1) + 1) / 2.0 - shiningBase1) / _ShiningRange1);
             fixed shining4 = 1 - saturate(abs((-cos(_Time.y * _ShiningSpeed1 * 1.5) + 1) / 4.0 + 0.1 - shiningBase2) / _ShiningRange1);
             //shining4 = 1;

             fixed shiningBase3 = tex2D(_ShiningNoise1, i.uv1.xy * _ShiningTiling1.xy + _Time.x * float2(_ShiningSpeedX1, _ShiningSpeedY1)).r;
             fixed shiningBase4 = tex2D(_ShiningNoise1, i.uv1.xy * _ShiningTiling1.zw).a;
             fixed shiningBase4Range = tex2D(_ShiningNoise1, i.uv1.xy).b;

             finalColor += pow(shining1 * shining2, _ShiningPow1) * _EffectColor1;
             finalColor += pow(shining3 * shining4, _ShiningPow1) * _EffectColor1;

             finalColor += pow(shiningBase4, _ShiningPow1) * shiningBase3 * _EffectColor1 * _BaseStrength1 * shiningBase4Range;

             finalColor += _EffectColor1 * _BaseStrength1;


             ///////////Shining2
             shiningBase1 = tex2D(_ShiningNoise2, i.uv1.xy * _ShiningTiling2.xy).r;
             shiningBase2 = tex2D(_ShiningNoise2, i.uv1.xy * _ShiningTiling2.xy * float2(1.2, 1.2)).r;

             shining1 = 1 - saturate(abs((sin(_Time.y * _ShiningSpeed2) + 1) / 2.0 - shiningBase1) / _ShiningRange2);
             shining2 = 1 - saturate(abs((-sin(_Time.y * _ShiningSpeed2 * 1.5) + 1) / 4.0 + 0.1 - shiningBase2) / _ShiningRange2);
             shining3 = 1 - saturate(abs((cos(_Time.y * _ShiningSpeed2) + 1) / 2.0 - shiningBase1) / _ShiningRange2);
             shining4 = 1 - saturate(abs((-cos(_Time.y * _ShiningSpeed2 * 1.5) + 1) / 4.0 + 0.1 - shiningBase2) / _ShiningRange2);

             shiningBase3 = tex2D(_ShiningNoise2, i.uv1.xy * _ShiningTiling2.xy + _Time.x * float2(_ShiningSpeedX2, _ShiningSpeedY2)).r;
             shiningBase4 = tex2D(_ShiningNoise2, i.uv1.xy * _ShiningTiling2.zw).a;
             shiningBase4Range = tex2D(_ShiningNoise2, i.uv1.xy).b;

             finalColor += pow(shining1 * shining2, _ShiningPow2) * _EffectColor2;
             finalColor += pow(shining3 * shining4, _ShiningPow2) * _EffectColor2;

             finalColor += pow(shiningBase4, _ShiningPow2) * shiningBase3 * _EffectColor2 * _BaseStrength2 * shiningBase4Range;

             finalColor += _EffectColor2 * _BaseStrength2;


		     ///////////Displacement
			 half2 mapoft = half2(_Time.y*_DispScrollSpeedX, _Time.y*_DispScrollSpeedY);
			 half2 mapoft_main = half2(_Time.y*_MainScrollSpeedX, _Time.y*_MainScrollSpeedY);

			 //get displacement color
			 half4 dispColor = tex2D(_DispMap, i.uv0.zw + mapoft);

			 //get uv oft
             half2 uvoft = i.uv0.xy;
		     uvoft.x +=  dispColor.r  * _DispX * i.uv1.x + mapoft_main.x;
			 uvoft.y +=  dispColor.g  * _DispY * i.uv1.x + mapoft_main.y;
			 //apply displacement
			 fixed4 mainColor = tex2D(_MainTex, uvoft);
             finalColor += 2.0f * i.color * _TintColor * mainColor* _DispStrength/* * mask.r*/;
             return finalColor;
         }
         ENDCG
     }
 }   
}
}
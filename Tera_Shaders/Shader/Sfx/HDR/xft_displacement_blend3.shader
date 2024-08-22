Shader "TERA/Fx/HDX/displacement-blend3layer" {
Properties {
 _VolumeExpansion ("Volume Expansion", Range(0.0, 1)) = 0
 [Header(Maskmap R G B)]
 [Space]
 _MaskTex ("Mask(RGB)", 2D) = "white" {}
 [Header(Masked by Maskmap R channel)]
 _maskuvR_ST("Mask R UV Tilling & Offset", Vector) = (1,1,0,0)
 [HDR]_TintColor1 ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
 _MainTex1 ("Main Texture", 2D) = "white" {}
 _DispMap1 ("Displacement Map (RG)", 2D) = "white" {}
 _ClipValue1  ("Clip Value", Range(0.0, 1.0)) = 0
 _MainScrollSpeedX1  ("Main Map Scroll Speed X", Float) = 0
 _MainScrollSpeedY1 ("Main Map Scroll Speed Y", Float) = 0
 _DispScrollSpeedX1  ("Map Scroll Speed X", Float) = 0
 _DispScrollSpeedY1  ("Map Scroll Speed Y", Float) = 0
 _DispX1  ("Displacement Strength X", Float) = 0
 _DispY1  ("Displacement Strength Y", Float) = 0.2
 [Header(Masked by Maskmap G channel)]
 [Space]
 _maskuvG_ST("Mask G UV Tilling & Offset", Vector) = (1,1,0,0)
 [HDR]_TintColor2 ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
 _MainTex2 ("Main Texture", 2D) = "white" {}
 _DispMap2 ("Displacement Map (RG)", 2D) = "white" {}
 _ClipValue2  ("Clip Value", Range(0.0, 1.0)) = 0
 _MainScrollSpeedX2  ("Main Map Scroll Speed X", Float) = 0
 _MainScrollSpeedY2 ("Main Map Scroll Speed Y", Float) = 0
 _DispScrollSpeedX2  ("Map Scroll Speed X", Float) = 0
 _DispScrollSpeedY2  ("Map Scroll Speed Y", Float) = 0
 _DispX2  ("Displacement Strength X", Float) = 0
 _DispY2  ("Displacement Strength Y", Float) = 0.2
 [Header(Masked by Maskmap B channel)]
 [Space]
 _maskuvB_ST("Mask B UV Tilling & Offset", Vector) = (1,1,0,0)
 [HDR]_TintColor3 ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
 _MainTex3 ("Main Texture", 2D) = "white" {}
 _DispMap3 ("Displacement Map (RG)", 2D) = "white" {}
 [MaterialToggle] uvswitcher ("Use UV Channel2", Float ) = 0
 _ClipValue3  ("Clip Value", Range(0.0, 1.0)) = 0
 _MainScrollSpeedX3  ("Main Map Scroll Speed X", Float) = 0
 _MainScrollSpeedY3 ("Main Map Scroll Speed Y", Float) = 0
 _DispScrollSpeedX3  ("Map Scroll Speed X", Float) = 0
 _DispScrollSpeedY3  ("Map Scroll Speed Y", Float) = 0
 _DispX3  ("Displacement Strength X", Float) = 0
 _DispY3  ("Displacement Strength Y", Float) = 0.2
}

Category {
 Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
 Blend SrcAlpha OneMinusSrcAlpha
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

         uniform sampler2D _MaskTex;
         uniform half4 _maskuvR_ST;
         uniform half4 _maskuvG_ST;
         uniform half4 _maskuvB_ST;
         uniform sampler2D _MainTex1;
         float4 _MainTex1_ST;
		 uniform sampler2D _DispMap1;
		 float4 _DispMap1_ST;
		 uniform fixed _ClipValue1;
         uniform half _DispScrollSpeedX1;
         uniform half _DispScrollSpeedY1;
         uniform half _MainScrollSpeedX1;
         uniform half _MainScrollSpeedY1;
		 uniform half _DispX1;
         uniform half _DispY1;
         uniform fixed4 _TintColor1;

         uniform sampler2D _MainTex2;
         float4 _MainTex2_ST;
		 uniform sampler2D _DispMap2;
		 float4 _DispMap2_ST;
		 uniform fixed _ClipValue2;
         uniform half _DispScrollSpeedX2;
         uniform half _DispScrollSpeedY2;
         uniform half _MainScrollSpeedX2;
         uniform half _MainScrollSpeedY2;
		 uniform half _DispX2;
         uniform half _DispY2;
         uniform fixed4 _TintColor2;

         uniform sampler2D _MainTex3;
         float4 _MainTex3_ST;
		 uniform sampler2D _DispMap3;
		 float4 _DispMap3_ST;
		 uniform fixed _ClipValue3;
         uniform half _DispScrollSpeedX3;
         uniform half _DispScrollSpeedY3;
         uniform half _MainScrollSpeedX3;
         uniform half _MainScrollSpeedY3;
		 uniform half _DispX3;
         uniform half _DispY3;
         uniform fixed4 _TintColor3;
         uniform fixed uvswitcher;
         uniform half _VolumeExpansion;

         
         struct appdata_t {
             float4 vertex : POSITION;
             fixed4 color : COLOR;
             float2 texcoord : TEXCOORD0;
             float2 texcoord1 : TEXCOORD1;
             float4 normal : NORMAL;
         };

         struct v2f {
             float4 vertex : POSITION;
             fixed4 color : COLOR;             
             float4 uv0 : TEXCOORD0;
			 float4 uv1 : TEXCOORD1;
			 float4 uv2 : TEXCOORD3;
			 float4 uv3 : TEXCOORD4;
			 float2 uv4 : TEXCOORD5;
			 float4 param : TEXCOORD2;

         }; 
         
         v2f vert (appdata_t v)
         {
             v2f o;
             v.vertex += v.normal * _VolumeExpansion;
             o.vertex = UnityObjectToClipPos(v.vertex);
             o.color = v.color;
             o.param.zw = lerp(v.texcoord,v.texcoord1,uvswitcher);
             o.uv0.xy = TRANSFORM_TEX(o.param.zw, _MainTex1);
             o.uv0.zw = TRANSFORM_TEX(o.param.zw, _DispMap1);
             o.uv1.xy = TRANSFORM_TEX(o.param.zw, _MainTex2);
             o.uv1.zw = TRANSFORM_TEX(o.param.zw, _DispMap2);
             o.uv2.xy = TRANSFORM_TEX(o.param.zw, _MainTex3);
             o.uv2.zw = TRANSFORM_TEX(o.param.zw, _DispMap3);
             o.uv3.xy = TRANSFORM_TEX(o.param.zw, _maskuvR);
             o.uv3.zw = TRANSFORM_TEX(o.param.zw, _maskuvG);
             o.uv4.xy = TRANSFORM_TEX(o.param.zw, _maskuvB);
//             o.uv1.zw = TRANSFORM_TEX(v.texcoord, _AlphaTex);
			 o.param.xy = v.texcoord;
             return o;
         }
         half4 frag (v2f i) : COLOR
         {
             //get mask;
			 fixed4 maskR = tex2D(_MaskTex, i.uv3.xy);
			 fixed4 maskG = tex2D(_MaskTex, i.uv3.zw);
			 fixed4 maskB = tex2D(_MaskTex, i.uv4.xy);
		     //scroll displacement map.
			 half2 mapoft = half2(_Time.y*_DispScrollSpeedX1, _Time.y*_DispScrollSpeedY1);
			 half2 mapoft_main = half2(_Time.y*_MainScrollSpeedX1, _Time.y*_MainScrollSpeedY1);
//			 half2 mapoft_mask = half2(_Time.y*_MaskScrollSpeedX1, _Time.y*_MaskScrollSpeedY1);
//			 half2 mapoft_Alpha = half2(_Time.y*_AlphaScrollSpeedX, _Time.y*_AlphaScrollSpeedY);
//
			 //get displacement color
			 half4 dispColor = tex2D(_DispMap1, i.uv0.zw + mapoft);

			 //get uv oft
             half2 uvoft = i.uv0.xy;
		     uvoft.x +=  dispColor.r  * _DispX1 * i.param.x + mapoft_main.x;
			 uvoft.y +=  dispColor.g  * _DispY1 * i.param.x + mapoft_main.y;

			 //apply displacement
			 fixed4 mainColorR = tex2D(_MainTex1, uvoft);

			 //scroll displacement map.
			 half2 mapoft2 = half2(_Time.y*_DispScrollSpeedX2, _Time.y*_DispScrollSpeedY2);
			 half2 mapoft_main2 = half2(_Time.y*_MainScrollSpeedX2, _Time.y*_MainScrollSpeedY2);
//			 half2 mapoft_mask = half2(_Time.y*_MaskScrollSpeedX1, _Time.y*_MaskScrollSpeedY1);
//			 half2 mapoft_Alpha = half2(_Time.y*_AlphaScrollSpeedX, _Time.y*_AlphaScrollSpeedY);
//
			 //get displacement color
			 half4 dispColor2 = tex2D(_DispMap2, i.uv1.zw + mapoft2);

			 //get uv oft
             half2 uvoft2 = i.uv1.xy;
		     uvoft2.x +=  dispColor2.r  * _DispX2 * i.param.x + mapoft_main2.x;
			 uvoft2.y +=  dispColor2.g  * _DispY2 * i.param.x + mapoft_main2.y;

			 //apply displacement
			 fixed4 mainColorG = tex2D(_MainTex2, uvoft2);

			 //scroll displacement map.
			 half2 mapoft3 = half2(_Time.y*_DispScrollSpeedX3, _Time.y*_DispScrollSpeedY3);
			 half2 mapoft_main3 = half2(_Time.y*_MainScrollSpeedX3, _Time.y*_MainScrollSpeedY3);
//			 half2 mapoft_mask = half2(_Time.y*_MaskScrollSpeedX1, _Time.y*_MaskScrollSpeedY1);
//			 half2 mapoft_Alpha = half2(_Time.y*_AlphaScrollSpeedX, _Time.y*_AlphaScrollSpeedY);
//
			 //get displacement color
			 half4 dispColor3 = tex2D(_DispMap3, i.uv2.zw + mapoft3);

			 //get uv oft
             half2 uvoft3 = i.uv2.xy;
		     uvoft3.x +=  dispColor3.r  * _DispX3 * i.param.x + mapoft_main3.x;
			 uvoft3.y +=  dispColor3.g  * _DispY3 * i.param.x + mapoft_main3.y;

			 //apply displacement
			 fixed4 mainColorB = tex2D(_MainTex3, uvoft3);

             half4 final_colorR = 2.0f * i.color * _TintColor1 * mainColorR * maskR.r;
//             final_colorR.a = final_colorR.a - _ClipValue1 < 0 ? 0 : final_colorR.a;

             half4 final_colorG = 2.0f * i.color * _TintColor2 * mainColorG * maskG.g;
//             final_colorG.a = final_colorG.a - _ClipValue2 < 0 ? 0 : final_colorG.a;

             half4 final_colorB = 2.0f * i.color * _TintColor3 * mainColorB * maskB.b;
//             final_colorB.a = final_colorB.a - _ClipValue3 < 0 ? 0 : final_colorB.a;

             half4 final_color = final_colorR+final_colorG+final_colorB;
             return final_color;
         }
         ENDCG
     }
 }   
}
}
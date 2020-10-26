Shader "TERA/Fx/HDX/Displacement_Wave" {
    Properties {
        [HDR]_MainColor ("Color", Color) = (1,1,1,1)
        _MainTex ("MainTexture_UVc1", 2D) = "white" {}
        _DispMap ("Displancement Map (RG)", 2D) = "black" {}
        _DispScrollSpeedX ("Displacement Map Scroll Speed X", Float) = 0
        _DispScrollSpeedY ("Displacement Map Scroll Speed Y", Float) = 0
        _DispX("Displacement Strength L1", Float) = 0
        _DispY("Displacement Strength L2", Float) = 0.2
        _ws("Lighted Intensity", Float) = 1
        _wc("Glow Intensity", Float) = 0.25
        _wr("None_Displacment Intensity", Float) = 0.1
		_Mask_UVc_Layer1("_Mask_UVc_Layer1", Vector) = (1, 1, 0, 0)
		_Mask_UVc_Layer12_Speed("_Mask_UVc_Layer12_Speed", Vector) = (0, 0, 0, 0)
        _AlphaScale ("Alpha Scale", Range(0, 5)) = 1
		_DstBlend("_DstBlend", Float) = 1
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
			Blend SrcAlpha [_DstBlend]
            ZWrite Off
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"

            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform half4 _MainColor;
            uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _DispMap;
			uniform float4 _DispMap_ST;
			uniform float _ws;
			uniform float _wc;
			uniform float _wr;
			uniform half _DispScrollSpeedX;
            uniform half _DispScrollSpeedY;

		    uniform half _DispX;
            uniform half _DispY;
			uniform float4 _Mask_UVc_Layer12_Speed;


            uniform float _AlphaScale;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float2 uv3 : TEXCOORD3;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
            };
			float2 transform_tex_uv(float2 uv, float4 ST)
			{
				return (uv.xy * ST.xy + ST.zw);
			}
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;

				float4 timer = _Time + _TimeEditor;
				float2 mainuv = (v.uv0*_Mask_UVc_Layer12_Speed.xy + timer.g*_Mask_UVc_Layer12_Speed.zw);
                o.uv0.zw = TRANSFORM_TEX(mainuv, _MainTex);
				o.uv1.xy = TRANSFORM_TEX(v.uv1.xy, _DispMap);
                o.pos = UnityObjectToClipPos(v.vertex );

                o.uv0.xy = v.uv0;
                return o;
            }
            half4 frag(VertexOutput i) : COLOR {
////// Emissive:
                float4 _MainTexture = tex2D(_MainTex, i.uv0.zw);

//                i.uv0.y = _wc * sin(_wr*_MainTexture.g + _wspeed*_Time.x);
                float4 _mask = tex2D(_MainTex, i.uv0.xy);
                       _mask.a = (_mask.r+_mask.g)*_mask.b;
                half2 mapoft = half2(_Time.y*_DispScrollSpeedX, _Time.y*_DispScrollSpeedY);

			    half4 dispColor = tex2D(_DispMap, i.uv1.xy + mapoft);
			    half power = (1-i.uv0.w)/1;
			          _DispX *= _mask.b * power;
			          _DispY *= _mask.b * power;
			    half4 uvoft = half4(half2(i.uv1.xy),0,0);
		              uvoft.z = (1-_DispX*0.5) + (saturate(dispColor.g) * _DispX);
		              uvoft.w = (1-_DispY*0.5) + (saturate(dispColor.g) * _DispY);
			          uvoft.x = uvoft.y * uvoft.z;
			          uvoft.y *= uvoft.w;
                float4 _disp1 = tex2D(_MainTex, float2(i.uv0.x,uvoft.x));
                float4 _disp2 = tex2D(_MainTex, float2(i.uv0.x,uvoft.y));   
                float alpha = _MainTexture.r + _MainTexture.g;

                half highlighted = _disp1.r * _disp1.g * _ws;
                half glowed = _disp2.g * _wc;
                half nodisplacement = pow(_disp2.g,4) * _wr;
                half3 finalColor = (fixed3(highlighted,highlighted,highlighted) + glowed * _MainColor.rgb) * _mask.a + (nodisplacement*_MainColor.rgb);
                half finalA = (highlighted + glowed)*_mask.a + nodisplacement;
                half4 finalRGBA = half4(finalColor,finalA);

                return finalRGBA;
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
}

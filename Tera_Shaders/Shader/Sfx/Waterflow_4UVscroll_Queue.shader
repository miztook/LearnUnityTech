// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TERA/FX/Waterflow_4UVscrollQueue" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTexture_UVc1 ("MainTexture_UVc1", 2D) = "white" {}
		_Mask_Tex("_Mask_Tex", 2D) = "white" {}
		_Mask_UVc_Layer2("_Mask_UVc_Layer2", Vector) = (1, 1, 0, 0)
		_Mask_UVc_Layer3("_Mask_UVc_Layer3", Vector) = (1, 1, 0, 0)
		_Mask_UVc_Layer4("_Mask_UVc_Layer4", Vector) = (1, 1, 0, 0)
		_Mask_UVc_Layer12_Speed("_Mask_UVc_Layer12_Speed", Vector) = (0, 0, 0, 0)
		_Mask_UVc_Layer34_Speed("_Mask_UVc_Layer34_Speed", Vector) = (0, 0, 0, 0)
        _AlphaScale ("Alpha Scale", Range(0, 5)) = 1
		_DstBlend("_DstBlend", Float) = 1
    }
    SubShader {
        Tags {
            //"IgnoreProjector"="True"
            "Queue"="Transparent-10"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
			Blend SrcAlpha [_DstBlend]
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"

            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform float4 _Color;
            uniform sampler2D _MainTexture_UVc1;
			uniform float4 _MainTexture_UVc1_ST;

            uniform sampler2D _Mask_Tex; 

			uniform float4 _Mask_UVc_Layer2;
			uniform float4 _Mask_UVc_Layer3;
			uniform float4 _Mask_UVc_Layer4;
			
			uniform float4 _Mask_UVc_Layer12_Speed;
			uniform float4 _Mask_UVc_Layer34_Speed;

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
				float2 mainuv = (v.uv0 + timer.g*_Mask_UVc_Layer12_Speed.xy);
				float2 maskuv1 = (v.uv1 + timer.g*_Mask_UVc_Layer12_Speed.zw);
				float2 maskuv2 = (v.uv2 + timer.g*_Mask_UVc_Layer34_Speed.xy);
				float2 maskuv3 = (v.uv3 + timer.g*_Mask_UVc_Layer34_Speed.zw);

                o.uv0.xy = TRANSFORM_TEX(mainuv, _MainTexture_UVc1);
                o.uv0.zw = transform_tex_uv(maskuv1, _Mask_UVc_Layer2);
				o.uv1.xy = transform_tex_uv(maskuv2, _Mask_UVc_Layer3);
				o.uv1.zw = transform_tex_uv(maskuv3, _Mask_UVc_Layer4);
                o.pos = UnityObjectToClipPos(v.vertex );

                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 _MainTexture_UVc1_var = tex2D(_MainTexture_UVc1, i.uv0.xy);
                float3 emissive = (_Color.rgb*_MainTexture_UVc1_var.rgb);
                float3 finalColor = emissive;
				                				
				float4 _Mask_UVc2_var = tex2D(_Mask_Tex, i.uv0.zw);
				float4 _Mask_UVc3_var = tex2D(_Mask_Tex, i.uv1.xy);
                float4 _Mask_UVc4_var = tex2D(_Mask_Tex, i.uv1.zw);

                fixed4 finalRGBA = fixed4(finalColor,(_AlphaScale*(_MainTexture_UVc1_var.a*_Mask_UVc2_var.r*_Mask_UVc3_var.g*_Mask_UVc4_var.b)));

                return finalRGBA;
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
}

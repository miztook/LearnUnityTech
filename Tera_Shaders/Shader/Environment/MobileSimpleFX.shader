Shader "TERA/Environment/MobileSimpleFx" {
    Properties {
        [HDR]_Color ("Color", Color) = (1,1,1,1)
        _MainTex ("MainTexture_UVc1", 2D) = "white" {}
        _Mask_Tex ("MaskTexture for Lightpower_UVc2", 2D) = "white" {}
        _AlphaScale ("Alpha Scale", Range(0, 1)) = 1
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
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fog

            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform float4 _Color;
            uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
            uniform sampler2D _Mask_Tex;
            uniform float4 _Mask_Tex_ST;
            uniform float _AlphaScale;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                UNITY_FOG_COORDS(2)
            };
			float2 transform_tex_uv(float2 uv, float4 ST)
			{
				return (uv.xy * ST.xy + ST.zw);
			}
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = TRANSFORM_TEX(v.uv0, _MainTex);
                o.uv1 = TRANSFORM_TEX(v.uv1, _Mask_Tex);
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }
            half4 frag(VertexOutput i) : COLOR {
////// Emissive:
                float4 _MainTex_var = tex2D(_MainTex, i.uv0.xy);
                float4 mask = tex2D(_Mask_Tex, i.uv1.xy);
                half3 emissive = (_Color.rgb*_MainTex_var.rgb);
                half3 finalColor = emissive;

                half4 finalRGBA = half4(finalColor,(_AlphaScale*(_MainTex_var.a*mask.r)));
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Mobile/Diffuse"
}

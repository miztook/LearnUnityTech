// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
//Note this is for UI only

Shader "TERA/UI/AlphaSplit"
{
    Properties
    {
        [PerRendererData] _MainTex ("Base (RGB), Alpha (A)", 2D) = "white" {}
		_AlphaTex ("Alpha (A)", 2D) = "white" {}

        _ColorMask ("Color Mask", Float) = 15
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

		[Enum(UnityEngine.Rendering.BlendMode)]SrcMode("SrcMode", int) = 1
		[Enum(UnityEngine.Rendering.BlendMode)]DstMode("DstMode", int) = 1
    }
    
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp] 
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
        
        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        //Blend SrcAlpha OneMinusSrcAlpha
		//Blend One OneMinusSrcAlpha
		Blend[SrcMode][DstMode]

        ColorMask [_ColorMask]

        Pass
        {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "UnityUI.cginc"

                struct appdata_t
                {
                    float4 vertex : POSITION;
                    float2 texcoord : TEXCOORD0;
                    fixed4 color : COLOR;
                };
    
                struct v2f
                {
                    float4 pos : SV_POSITION;
                    half2 uv : TEXCOORD0;
					half2 uv2 : TEXCOORD1;
                    float4 worldPosition : TEXCOORD2;
                    fixed4 color : COLOR;
                };

                sampler2D _MainTex;
				//float4 _MainTex_ST;
                sampler2D _AlphaTex;
				float4 _AlphaTex_ST;
				//float4 _AlphaUVScale;

                float4 _ClipRect;
				half4 _UVScale;
                
                v2f vert (appdata_t v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.texcoord;
					//o.uv2 = v.texcoord*_AlphaUVScale.xy+_AlphaUVScale.zw;
					o.uv2=TRANSFORM_TEX(v.texcoord,_AlphaTex);
                    o.worldPosition = v.vertex;
                    o.color = v.color;
				#ifdef UNITY_HALF_TEXEL_OFFSET
                    o.pos.xy += (_ScreenParams.zw-1.0)*float2(-1,1);
				#endif
                    return o;
                }
                
				fixed4 frag (v2f i) : SV_Target
                {
				    fixed4 c = i.color * tex2D(_MainTex, i.uv);
					//c.a *= tex2D(_AlphaTex, i.uv2).r;
                    //c.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
					c.rgb *= i.color.a;
					c *= tex2D(_AlphaTex, i.uv2).r;
					c *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);

                    return c;
                }
                                
            ENDCG
        }
    }
}
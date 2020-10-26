// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TERA/Fx/HDX/DissolveShader_AlphaBlend"
{
    Properties
    {
        [HDR]_DissolveColor("Dissolve Color", Color) = (1.0, 0.0, 0.0, 0.5)
        [HDR]_MainColor("Main Color", Color) = (1.0, 1.0, 1.0, 0.5)
        _MainTex("Main Texture", 2D) = "white" {}
        _DissolveTex("Dissolve Texture (RGBA)", 2D) = "white" {}
        _Transparent("Transparent", Range(0.0, 1.0)) = 0.5
        _DissolveWidth("Dissolve Width", Range(0.001, 1.0)) = 0.1
        _MMultiplier ("lighteness", Float) = 1.0
		_DiffuseStren("Diffuse Strenth", Float) = 1.0
		_DstCull("Backface Cull 0=2Sided 2=1sided", Range(0,2)) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "LightMode"="ForwardBase"
        }

        // Back pass
        pass
        {
            ColorMask RGBA

            Lighting Off
            Cull [_DstCull]
            ZWrite Off
            ZTest On

            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 _DissolveColor;
            float4 _MainColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DissolveTex;
            float4 _DissolveTex_ST;
            float _Transparent;
            float _DissolveWidth;
            float _MMultiplier;
			float _DiffuseStren;

            struct V2F
            {
                float4 pos : POSITION;
                float2 texcoord : TEXCOORD0;
				float4 vertexColor : COLOR;
            };

            V2F vert(appdata_full v)
            {
                V2F o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord = v.texcoord.xy;
				o.vertexColor = v.color;

                return o;
            }

            half4 frag(V2F i) : COLOR
            {
                float4 baseColor = tex2D(_MainTex, i.texcoord * _MainTex_ST.xy + _MainTex_ST.zw);
                float mask = tex2D(_DissolveTex, i.texcoord * _DissolveTex_ST.xy + _DissolveTex_ST.zw).a;
                float w = mask - _Transparent;
                float e = _DissolveWidth * 0.5;
                clip(w - 0.004);

                half4 resultColor = baseColor;
                resultColor.rgb *= _MainColor.rgb * 2.0;
                resultColor.a *= _MainColor.a;
                
                if (w < _DissolveWidth)
                {
                    if (w < e)
                    {
                        float f = w / e;
                        resultColor.rgb += _DissolveColor.rgb * f * 2.0;
                        resultColor.a = f;
                    }
                    else
                    {
                        float f = (_DissolveWidth - w) / e;
                        resultColor.rgb += _DissolveColor.rgb * f * 2.0;
                    }
                }
                return resultColor * i.vertexColor * _DiffuseStren;;
            }

            ENDCG
        }

//        // Front pass
//        pass
//        {
//            ColorMask RGBA
//
//            Lighting Off
//            Cull Back
//            ZWrite On
//            ZTest LEqual
//
//            Blend SrcAlpha One
//
//            CGPROGRAM
//            #pragma vertex vert
//            #pragma fragment frag
//            #include "UnityCG.cginc"
//
//            float4 _DissolveColor;
//            float4 _MainColor;
//            sampler2D _MainTex;
//            float4 _MainTex_ST;
//            sampler2D _DissolveTex;
//            float4 _DissolveTex_ST;
//            float _Transparent;
//            float _DissolveWidth;
//            float _MMultiplier;
//
//            struct V2F
//            {
//                float4 pos : POSITION;
//                float2 texcoord : TEXCOORD0;
//            };
//
//            V2F vert(appdata_full v)
//            {
//                V2F o;
//                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
//                o.texcoord = v.texcoord.xy;
//                return o;
//            }
//
//            half4 frag(V2F i) : COLOR
//            {
//                float4 baseColor = tex2D(_MainTex, i.texcoord * _MainTex_ST.xy + _MainTex_ST.zw);
//                float mask = tex2D(_DissolveTex, i.texcoord * _DissolveTex_ST.xy + _DissolveTex_ST.zw).a;
//                float w = mask - _Transparent;
//                float e = _DissolveWidth * 0.5;
//                clip(w - 0.004);
//
//                half4 resultColor = baseColor;
//                resultColor.rgb *= _MainColor.rgb * _MainColor.a * 2.0*_MMultiplier;
//                if (w < _DissolveWidth)
//                {
//                    if (w < e)
//                    {
//                        float f = w / e;
//                        resultColor.rgb += _DissolveColor.rgb * f * 2.0;
//                        resultColor.a = f;
//                    }
//                    else
//                    {
//                        float f = (_DissolveWidth - w) / e;
//                        resultColor.rgb += _DissolveColor.rgb * f * 2.0;
//                    }
//                }
//                return resultColor;
//            }
//
//            ENDCG
//        }
    }
}

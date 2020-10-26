Shader "TERA/Character/GhostEffect" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainPower ("Main Power", Range(0.0, 3)) = 1.5
        _RimPower ("Rim Power", Range(0, 10)) = 0
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _Alphatex ("Alpha Tex", 2D) = "white" {}
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
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
			ZTest LEqual
//			Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _Color;
            uniform float _RimPower;
            uniform float4 _RimColor;
            uniform float _MainPower;
            uniform float4 _TimeEditor;
            uniform sampler2D _Alphatex; uniform float4 _Alphatex_ST;
			
			struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
				float4 projPos : TEXCOORD3;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
				o.projPos = ComputeScreenPos(o.pos);

				float4 time = _Time + _TimeEditor;
				float2 uvanim = (v.uv0 + time.g*float2(0.3,0));
				o.uv0.xy = TRANSFORM_TEX(uvanim, _Alphatex);
                return o;
            }
            
            fixed4 frag(VertexOutput i) : COLOR {
					i.normalDir = normalize(i.normalDir);
					float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
					float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
					float NdotL = dot(i.normalDir, lightDirection);
//					float3 Ndotv = max(0,dot(i.normalDir, viewDirection));
					float Ndotv = dot(i.normalDir, viewDirection);
					float4 _Alpha = tex2D(_Alphatex,i.uv0.xy);
//					float Fresnel = max(0.01,1.0 - max(0,Ndotv));
					float backcull = Ndotv < 0 ? 0 : 1;
					float Fresnel = 1.0 - max(0,Ndotv);
					      Fresnel *= backcull;
					      Fresnel = max(0.01,Fresnel);
					float3 emissive = ((_RimColor.rgb*pow(1.0 - Ndotv, _RimPower)*saturate(_RimPower))) * _Alpha.r + (Fresnel*_Color.rgb*_MainPower);
					       emissive += _RimColor * Fresnel * 0.5;
					float3 finalColor = max(0.001,emissive);
//					       finalColor = backcull;
					return fixed4(finalColor, Fresnel);

            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
}

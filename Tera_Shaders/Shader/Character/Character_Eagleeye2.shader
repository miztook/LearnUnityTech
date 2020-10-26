Shader "TERA/Character/Godeye" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0, 20)) = 1.5
        _RimColor ("Rim Color", Color) = (1,1,1,1)
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
			Cull back
                                  
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _Color;
            uniform float _RimPower;
            uniform float4 _RimColor;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 vcolor : COLOR0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
				float4 projPos : TEXCOORD2;
				float4 vcolor : COLOR0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
				o.projPos = ComputeScreenPos(o.pos);
				o.vcolor = v.vcolor;
                return o;
            }
            half4 frag(VertexOutput i) : COLOR {
					i.normalDir = normalize(i.normalDir);
					float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
					float3 normalDirection = i.normalDir;
					float Ndotv = max(0, dot(i.normalDir, viewDirection));
					float Fresnel = pow(max(0,1.0 - Ndotv), _RimPower*2);
					float add = (Ndotv+Fresnel*0.5)*i.vcolor.a;
					float3 emissive = lerp(0.3,_RimColor.rgb*pow(1.0 - Ndotv, _RimPower),0.5) + _Color.rgb*add;//(Fresnel*_Color.rgb*1.5);
					float3 finalColor = max(0.001,emissive);
					return half4(finalColor, saturate(Fresnel+i.vcolor.a*0.5 + add*0.5)*pow(i.vcolor.a,2));
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
}

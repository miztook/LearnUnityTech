Shader "TERA/Environment/Fadeable" {

Properties {
	_MainColor ("Top Color" ,Color) = (1,1,1,1)
	_SubColor ("Botton Color", Color) = (1,1,1,1)
	_MainTex ("Textuer", 2D) = "black" {}
	_Transition ("Transition", range(0,1)) = 0
}

SubShader {
	Tags {"Queue"="Geometry+11" "IgnoreProjector"="True" "RenderType"="Transparent"}
	Lighting Off
	ZWrite Off
	ZTest LEqual

	Pass {
	    Name "Base"
	    Blend SrcAlpha OneMinusSrcAlpha
	    Fog {mode Off}

	        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

			uniform fixed4 _MainColor;
			uniform fixed4 _SubColor;
			uniform sampler2D _MainTex;
			uniform fixed4 _MainTex_ST;
			uniform fixed _Transition;

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord1 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD3;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.uv0 = v.texcoord1;
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            half4 frag(VertexOutput i) : COLOR {
                i.uv0.x = saturate(i.uv0.x);
                float hg1 = i.uv0.x > 0.4 ? 1 : (i.uv0.x/0.4);
                float hg2 = i.uv0.x > (1-0.4) ? ((1-i.uv0.x)/0.4) : 1;
                float hg = hg1*hg2;
                half4 diffuse = lerp(_SubColor,_MainColor,i.uv0.y) * lerp(_SubColor,fixed4(1,1,1,1),hg);
                half4 finalRGBA = half4(diffuse.rgb, (1-_Transition)*tex2D(_MainTex,i.uv0.xy).a);
                return finalRGBA;
            }
            ENDCG
	     }
    }
    FallBack "Mobile/Diffuse"
}

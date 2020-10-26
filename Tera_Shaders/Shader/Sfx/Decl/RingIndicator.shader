Shader "TERA/Fx/Decl/RingIndicator" {
	Properties {
		_MainTex ("MainTex", 2D) = "white" {}
		[HDR]_MainColor("BaseColor", Color) = (1, 1, 1, 1)
		_OuterRadius("OuterRadius", Range(0,0.49)) = 0.49
		_InnerRadius("InnerRadius", Range(0,0.48)) = 0
		_WihteEdgeLength("WihteEdgeLength", float) = 0
		_EdgeColor("EdgeColor", Color) = (1, 1, 1, 1)
		[MaterialToggle] _Use1tex ("Use MainTex as AddTex",float) = 0
		_AddTex ("AddTex", 2D) = "white" {}
		[HDR]_AddColor("WarnningColor", Color) = (1, 1, 1, 0)
		_MainScaler("AddEffectScaler", Range(0,1)) = 1
	}
	Subshader {
		Tags {"Queue"="Transparent"}
            Pass {
			ZWrite Off
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			Offset -1, -1

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			
			struct v2f {
				float4 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 pos : SV_POSITION;
			};
			
			float4x4 unity_Projector;
			uniform half _OuterRadius;
			uniform half _InnerRadius;
			uniform half _WihteEdgeLength;
			
			v2f vert (float4 vertex : POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos (vertex);
				o.uv = mul (unity_Projector, vertex);
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _AddTex;
			fixed4 _EdgeColor;
			fixed4 _MainColor;
			fixed4 _AddColor;
			fixed _MainScaler;
			uniform int _Use1tex;
			
			fixed4 frag (v2f i) : SV_Target
			{
				i.uv = UNITY_PROJ_COORD(i.uv);				
				float2 uvPos = i.uv - float2(0.5, 0.5);
				float l = length(uvPos);
				fixed4 mainTex = tex2Dproj(_MainTex, i.uv);
				fixed4 mainColor = mainTex * _MainColor;
				half uvscaler = (1-_MainScaler)*10;
				i.uv.x = (0.5+((i.uv.x-0.5)*(1+uvscaler)));
			    i.uv.y = (0.5+((i.uv.y-0.5)*(1+uvscaler)));
			    fixed4 addTex = lerp(tex2D(_AddTex,i.uv),tex2D(_MainTex, i.uv),_Use1tex);
			    fixed3 addColor = addTex.rgb * _AddColor.rgb * addTex.a * _AddColor.a;
				half edgefix = _WihteEdgeLength*0.5;
				half outerclip = l > (_OuterRadius+edgefix) ? 0 : 1;
				half innerclip = l < (_InnerRadius-edgefix) ? 0 : 1;
                half inneredge = l > (_InnerRadius+edgefix) ? 0 : 1;
                half outeredge = l < (_OuterRadius-edgefix) ? 0 : 1;
                half inedge = innerclip*inneredge;
                half outedge = outerclip*outeredge;
                half edgerange = inedge+outedge;
                mainColor = lerp(mainColor,_EdgeColor,edgerange);
				fixed4 final_color = fixed4(0,0,0,0);
				       final_color.rgb = mainColor.rgb + addColor;		
				       final_color.a = mainColor.a*outerclip*innerclip;
				UNITY_APPLY_FOG_COLOR(i.fogCoord, final_color, fixed4(1, 1, 1, 1));
				return final_color;
			}
			ENDCG
		}
	}
}

Shader "TERA/Fx/HDX/ParticleOffset3" {
Properties {
    [HDR]_TintColor ("Color", Color) = (0.5,0.5,0.5,1)
    _MainTex ("MainTex", 2D) = "white" {}
    [MaterialToggle] _Invert ("Invert", Float ) = 0
    [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
	Blend SrcAlpha OneMinusSrcAlpha
	ColorMask RGB
	Cull Off Lighting Off ZWrite Off

	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile_particles
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			uniform float4 _TintColor;
            uniform fixed _Invert;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float4 texcoord : TEXCOORD0;
				float3 custom : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float4 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				#ifdef SOFTPARTICLES_ON
				float4 projPos : TEXCOORD2;
				#endif
				float3 custom : TEXCOORD3;
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			float4 _MainTex_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				#ifdef SOFTPARTICLES_ON
				o.projPos = ComputeScreenPos (o.vertex);
				COMPUTE_EYEDEPTH(o.projPos.z);
				#endif
				o.color = v.color * _TintColor;
				
				o.texcoord = v.texcoord;
				o.texcoord.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);

                o.custom.x = v.custom.x;
                o.custom.y = v.custom.y;
                o.custom.z = v.custom.z;

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			sampler2D_float _CameraDepthTexture;
			float _InvFade;
			
			half4 frag (v2f i) : SV_Target
			{
				#ifdef SOFTPARTICLES_ON
				float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
				float partZ = i.projPos.z;
				float fade = saturate (_InvFade * (sceneZ-partZ));
				i.color.a *= fade;
				#endif

				float2 uv = i.texcoord.xy;

				if (_MainTex_ST.x > 0)
				{
					uv.x = clamp(uv.x * i.custom.z - (i.custom.z - 1) * (_Invert ? (1 - i.texcoord.w) : i.texcoord.w), 0, 1);
				}
				else if (_MainTex_ST.x < 0)
				{
					uv.x = clamp(uv.x * i.custom.z + (i.custom.z - 1) * (_Invert ? (1 - i.texcoord.w) : i.texcoord.w), -1, 0);
				}

				float column = i.custom.x;
				float row = i.custom.y;

				float cellX = uv.x / column;
                float cellY = uv.y / row;

				//int idx = floor((1 / i.texcoord.z) * i.texcoord.w) * (i.custom.x * i.custom.y);
				int idx = floor(i.texcoord.w * (i.custom.x * i.custom.y));
				//idx = 0;
				int row_idx = (idx / column);
				int column_idx = idx - row_idx * column;
				row_idx = ceil(row - 1) - row_idx;

				uv.x = cellX + column_idx / column;
                uv.y = cellY + row_idx / row;
				
				half4 col = 2.0f * i.color * tex2D(_MainTex, uv);
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG 
		}
	}	
}
}

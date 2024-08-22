Shader "TERA/UI/Blur" {
Properties {
	_MainTex ("", 2D) = "" {}
	_BlurOffsets("", Vector) = (1,1,1,-1)
}
Subshader {
	ZTest Always Cull Off ZWrite Off Fog { Mode Off }

CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	half4 _MainTex_TexelSize;
	half4 _BlurOffsets;
ENDCG

	// -- BlurPass
	Pass	//0
	{
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }      

		CGPROGRAM
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma vertex vert
		#pragma fragment frag
	  
		#include "UnityCG.cginc"
		struct v2f {
			float4 pos : POSITION;
			half2 uv : TEXCOORD0;
			half2 taps[4] : TEXCOORD1; 
		};

		v2f vert( appdata_img v )
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);

			o.uv = v.texcoord;

			//o.uv = v.texcoord - _BlurOffsets.xy * _MainTex_TexelSize.xy; // hack, _BlurOffsets corresponding to the offsets set by scripts.
			o.taps[0] = o.uv + _MainTex_TexelSize.xy * _BlurOffsets.xy;
			o.taps[1] = o.uv - _MainTex_TexelSize.xy * _BlurOffsets.xy;
			o.taps[2] = o.uv + _MainTex_TexelSize.xy * _BlurOffsets.zw;
			o.taps[3] = o.uv - _MainTex_TexelSize.xy * _BlurOffsets.zw;
			return o;
		}
		half4 frag(v2f i) : COLOR {
			half4 color = tex2D(_MainTex, i.taps[0]);
			color += tex2D(_MainTex, i.taps[1]);
			color += tex2D(_MainTex, i.taps[2]);
			color += tex2D(_MainTex, i.taps[3]);
			return half4(color.rgb * 0.25, 1);
		}
		ENDCG
	}

	//Pass	//1
	//{
	//	CGPROGRAM
	//	#pragma vertex vert
	//	#pragma fragment frag

	//	#include "UnityCG.cginc"

	//	struct appdata
	//	{
	//		float4 vertex : POSITION;
	//		float2 uv : TEXCOORD0;
	//	};

	//	struct v2f
	//	{
	//		float2 uv : TEXCOORD0;
	//		float4 vertex : SV_POSITION;
	//	};

	//	v2f vert(appdata v)
	//	{
	//		v2f o;
	//		o.vertex = UnityObjectToClipPos(v.vertex);
	//		o.uv = v.uv;
	//		return o;
	//	}

	//	// From https://github.com/Unity-Technologies/PostProcessing/
	//	// blob/v2/PostProcessing/Shaders/Builtins/DiskKernels.hlsl
	//	static const int kernelSampleCount = 16;
	//	static const float2 kernel[kernelSampleCount] = {
	//		float2(0, 0),
	//		float2(0.54545456, 0),
	//		float2(0.16855472, 0.5187581),
	//		float2(-0.44128203, 0.3206101),
	//		float2(-0.44128197, -0.3206102),
	//		float2(0.1685548, -0.5187581),
	//		float2(1, 0),
	//		float2(0.809017, 0.58778524),
	//		float2(0.30901697, 0.95105654),
	//		float2(-0.30901703, 0.9510565),
	//		float2(-0.80901706, 0.5877852),
	//		float2(-1, 0),
	//		float2(-0.80901694, -0.58778536),
	//		float2(-0.30901664, -0.9510566),
	//		float2(0.30901712, -0.9510565),
	//		float2(0.80901694, -0.5877853),
	//	};
	//	float3 _DepthOfFieldParamter;

	//	half4 frag(v2f i) : SV_Target
	//	{
	//		half3 color = 0;
	//		for (int k = 0; k < kernelSampleCount; k++) {
	//			float2 o = kernel[k] * _DepthOfFieldParamter.z;
	//				o *= _MainTex_TexelSize.xy * _BlurOffsets.x;
	//			color += tex2D(_MainTex, i.uv + o).rgb;
	//		}
	//		color *= 1.0 / kernelSampleCount;
	//		return half4(color, 1);
	//	}
	//	ENDCG
	//}

}

Fallback off
}

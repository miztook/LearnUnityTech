Shader "Hidden/PostProcessing/BloomHD"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		// Pass 0: get bright
		Pass
		{
			CGPROGRAM
			
			#pragma multi_compile _ UNITY_COLORSPACE_GAMMA
			#include "BloomHD.cginc"
			
			#pragma vertex vert
			#pragma fragment frag_filter
			
			ENDCG
		}
		// Pass 1: get bright
		Pass
		{
			CGPROGRAM

			#pragma multi_compile _ UNITY_COLORSPACE_GAMMA
			#include "BloomHD.cginc"

			#pragma vertex vert
			#pragma fragment frag_flickerfilter

			ENDCG
		}
		// Pass 2: downsampler
		Pass
		{
			CGPROGRAM

			#include "BloomHD.cginc"

			#pragma vertex vert
			#pragma fragment frag_downsampler
			
			ENDCG
		}
		// Pass 3: downsampler
		Pass
		{
			CGPROGRAM
	
			#include "BloomHD.cginc"
	
			#pragma vertex vert
			#pragma fragment frag_flickerdownsampler
	
			ENDCG
		}
		// Pass 4: upsampler
		Pass
		{
			CGPROGRAM

			#include "BloomHD.cginc"

			#pragma vertex vert
			#pragma fragment frag_upsampler
			
			ENDCG
		}
		
		// Pass 5: blend
		Pass
		{
			CGPROGRAM
			
			#pragma multi_compile _ UNITY_COLORSPACE_GAMMA
			#include "BloomHD.cginc"

			#pragma vertex vert
			#pragma fragment frag_blend

			ENDCG
		}

		// Pass 6: final
		Pass
		{
			CGPROGRAM

			#pragma multi_compile _ UNITY_COLORSPACE_GAMMA
			#include "BloomHD.cginc"

			#pragma vertex vert
			#pragma fragment frag_final

			ENDCG
		}
	}
}

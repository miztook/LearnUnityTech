Shader "TERA/Fx/HDX/shining-additive" {
Properties {
    [HDR] _EffectColor("EffectColor",Color) = (1,1,1,1)
    //[HDR] _EffectColor2("EffectColor2",Color) = (1,1,1,1)
    [NoScaleOffset] _ShiningNoise("ShiningNoise(RG) StripeRegion(B) StripeNoise(A)",2D) = "white"{}
    _ShiningTiling("ShiningTiling(X1Y1X2Y2)",Vector) = (1,1,1,1)
    _ShiningRange("ShiningRange",Range(0.05,0.2)) = 0.1
    _ShiningPow("ShiningPow",Float) = 2
    _ShiningSpeed("ShiningSpeed",Float) = 0
    _ShiningSpeedX("ShiningSpeedX",Float) = 0
    _ShiningSpeedY("ShiningSpeedY",Float) = 0
    _BaseStrength("BaseStrength",Range(0,0.5)) = 0.1
}

Category {
 Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
 Blend SrcAlpha One
 Cull Off Lighting Off ZWrite Off
 Offset -1, -1
 BindChannels {
     Bind "Color", color
     Bind "Vertex", vertex
     Bind "TexCoord", texcoord
 }
 
 // ---- Fragment program cards
 SubShader {
     Pass {
     
         CGPROGRAM
         #pragma vertex vert
         #pragma fragment frag
         //#pragma fragmentoption ARB_precision_hint_fastest
         //#pragma multi_compile_particles
         
         #include "UnityCG.cginc"


         uniform float4 _EffectColor; 
         uniform float4 _EffectColor2; 
         uniform float4 _ShiningMask_ST;
         uniform sampler2D _ShiningNoise;
         uniform float4 _ShiningNoise_ST;
         uniform float4 _ShiningTiling;
         uniform float4 _ShiningColor;
         uniform float _ShiningPow;
         uniform float _ShiningSpeed;
         uniform float _ShiningSpeedX;
         uniform float _ShiningSpeedY;
         uniform float _BaseStrength;
         uniform float _ShiningRange;

         
         struct appdata_t {
             float4 vertex : POSITION;
             float2 texcoord : TEXCOORD0;
             float4 normal : NORMAL;
         };

         struct v2f {
             float4 vertex : POSITION;          
             float4 uv : TEXCOORD0;
         }; 
         
         v2f vert (appdata_t v)
         {
             v2f o;
             o.vertex = UnityObjectToClipPos(v.vertex);
             o.uv.xy = v.texcoord;
             o.uv.zw = TRANSFORM_TEX(v.texcoord, _ShiningMask);
             return o;
         }
         half4 frag(v2f i) : COLOR
         {
             half4 finalColor = half4(0,0,0,0);

             //fixed shining = tex2D(_ShiningMask, i.uv.zw).r;
             fixed shiningBase1 = tex2D(_ShiningNoise, i.uv.xy * _ShiningTiling.xy).r;
             fixed shiningBase2 = tex2D(_ShiningNoise, i.uv.xy * _ShiningTiling.xy * float2(1.2,1.2)).r;
             //shining1 = 1- saturate(abs(frac(_Time.y* _ShiningSpeedX) - shining1) /0.1);
             fixed shining1 = 1 - saturate(abs((sin(_Time.y * _ShiningSpeed) + 1) / 2.0 - shiningBase1) / _ShiningRange);
             fixed shining2 = 1 - saturate(abs((-sin(_Time.y * _ShiningSpeed * 1.5) + 1) / 4.0 + 0.1 - shiningBase2) / _ShiningRange);
             fixed shining3 = 1 - saturate(abs((cos(_Time.y * _ShiningSpeed) + 1) / 2.0 - shiningBase1) / _ShiningRange);
             fixed shining4 = 1 - saturate(abs((-cos(_Time.y * _ShiningSpeed * 1.5) + 1) / 4.0 + 0.1 - shiningBase2) / _ShiningRange);

             fixed shiningBase3 = tex2D(_ShiningNoise, i.uv.xy * _ShiningTiling.xy + _Time.x * float2(_ShiningSpeedX, _ShiningSpeedY)).r;
             fixed shiningBase4 = tex2D(_ShiningNoise, i.uv.xy * _ShiningTiling.zw).a;
             fixed shiningBase4Range = tex2D(_ShiningNoise, i.uv.xy).b;

             finalColor += pow(shining1 * shining2, _ShiningPow) * _EffectColor ;
             finalColor += pow(shining3 * shining4, _ShiningPow) * _EffectColor ;

             finalColor += pow(shiningBase4, _ShiningPow) * shiningBase3 * _EffectColor * _BaseStrength * shiningBase4Range;

             finalColor += _EffectColor  * _BaseStrength;

             //finalColor.a = smoothstep(0,1,finalColor.a);

             return finalColor;
         }
         ENDCG
     }
 }   
}
}
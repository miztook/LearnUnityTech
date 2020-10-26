Shader "TERA/UI/SimpleCamReflectionbyAUQASCamera" {
    Properties {
        _DepthTex ("Depth Texture", 2D) = "white" {}
        [NoScaleOffset]_NormalTexture ("Normal Texture", 2D) = "white" {}
        _NormalTiling ("Normal Tiling", Float ) = 1
        _BaseColor ("Deep Water Color", Color) = (0.07843138,0.3921569,0.7843137,1)
//        _ShallowWaterColor ("Shallow Water Color", Color) = (0.4411765,0.9537525,1,1)
//        _Fade ("Shallow-Deep-Fade", Float ) = 3.1
        [HideInInspector]_ReflectionTexture1 ("Reflection Tex", 2D) = "white" {}
        [MaterialToggle] _UseReflections ("Enable Reflections", Float ) = 0
        _Reflectionintensity ("Reflection intensity", Range(0, 1)) = 0.5
        _Distortion ("Distortion", Range(0, 2)) = 0.3
        _Refraction ("Refraction", Range(0, 5)) = 0.5
        _WaveSpeed ("Wave Speed", Float ) = 40
        _WaveSpeed2 ("Wave Speed2", Float ) = 0
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
            Ztest LEqual
            ColorMask RGBA
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11_9x 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform float4 _TimeEditor;
            uniform float4 _BaseColor;
            uniform sampler2D _ReflectionTexture1; uniform float4 _ReflectionTexture1_ST;
            uniform float _Reflectionintensity;
            uniform sampler2D _DepthTex; uniform float4 _DepthTex_ST;
            uniform sampler2D _NormalTexture; uniform float4 _NormalTexture_ST;
            uniform float _Refraction;
            uniform float _WaveSpeed;
            uniform float _WaveSpeed2;
            uniform float _Distortion;
            uniform float _NormalTiling;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 posWorld : TEXCOORD2;
                float3 normalDir : TEXCOORD3;
                float3 tangentDir : TEXCOORD4;
                float3 bitangentDir : TEXCOORD5;
                float4 screenPos : TEXCOORD6;
                float4 projPos : TEXCOORD7;
                UNITY_FOG_COORDS(8)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                o.projPos = ComputeScreenPos (o.pos);
                //COMPUTE_EYEDEPTH(o.projPos.z);
                o.screenPos = o.pos;
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                i.screenPos = float4( i.screenPos.xy / i.screenPos.w, 0, 0 );
                i.screenPos.y *= _ProjectionParams.x;
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
/////// Vectors:
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float _rotator_ang = 1.2;//1.5708;
                float _rotator_spd = 1.0;
                float _rotator_cos = cos(_rotator_spd*_rotator_ang);
                float _rotator_sin = sin(_rotator_spd*_rotator_ang);
                float2 _rotator_piv = float2(0.5,0.5);
                float2 _rotator = (mul(i.uv0-_rotator_piv,float2x2( _rotator_cos, -_rotator_sin, _rotator_sin, _rotator_cos))+_rotator_piv);
                float2 _division1 = _NormalTiling;
                float4 _timer = _Time + _TimeEditor;
                float3 _multiplier3 = (float3((_WaveSpeed/_division1),0.0)*_timer.r);
                float2 _multiplier2 = ((_rotator+_multiplier3)*_division1);
                float3 _texture1 = UnpackNormal(tex2D(_NormalTexture,TRANSFORM_TEX(_multiplier2, _NormalTexture)));
                float2 _multiplier1 = ((i.uv0+(_multiplier3*_WaveSpeed2))*_division1);
                float3 _texture2 = UnpackNormal(tex2D(_NormalTexture,TRANSFORM_TEX(_multiplier1, _NormalTexture)));
                float3 _subtractor = (_texture1.rgb-_texture2.rgb);
                float _Refract = lerp(0.05,_Refraction*1.5,pow(max(0,dot(i.normalDir,viewDirection)),1.5));
                float3 normalLocal = lerp(float3(0,0,1),(_texture1+_texture2),_Refract);
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals      
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 _halfDirection = normalize(viewDirection-lightDirection);
                float4 depth = saturate(tex2D(_DepthTex,i.uv1));
////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float ref = max(0,dot(reflect(-lightDirection,normalDirection),viewDirection));
/////// Diffuse:

                float3 directDiffuse = fixed3(1,1,1);
                float3 indirectDiffuse = float3(0,0,0);
                float2 _componentMask = _subtractor.rg;
                float2 _remap = ((i.screenPos.rg+(float2(_componentMask.r,_componentMask.g)*_Distortion))*0.5+0.5);
                float4 _ReflectionTexture1_var = tex2D(_ReflectionTexture1,TRANSFORM_TEX(_remap, _ReflectionTexture1)) * (_Reflectionintensity+0.25);
                fixed _finalA = _ReflectionTexture1_var.a * depth.r*0.75;
                float3 diffuse = _ReflectionTexture1_var.rgb;
/// Final Color:
                float3 finalColor = diffuse;
                fixed4 finalRGBA = fixed4(finalColor,_finalA);
//                       finalRGBA = fixed4(float3(depth.r,depth.r,depth.r),1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
}

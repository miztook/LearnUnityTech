Shader "TERA/Environment/MobileWaterBicolored" {
    Properties {
        _DepthTex ("Depth Texture", 2D) = "white" {}
        [NoScaleOffset]_NormalTexture ("Normal Texture", 2D) = "white" {}
        _NormalTiling ("Normal Tiling", Float ) = 1
        _LightDiradj ("Light Direction Adjust", Vector) = (0,0,0,0)
        _DeepWaterColor ("Deep Water Color", Color) = (0.07843138,0.3921569,0.7843137,1)
        _ShallowWaterColor ("Shallow Water Color", Color) = (0.4411765,0.9537525,1,1)
        [HideInInspector]_ReflectionTex ("Reflection Tex", 2D) = "white" {}
        [MaterialToggle] _UseReflections ("Enable Reflections", Float ) = 0
        _Reflectionintensity ("Reflection intensity", Range(0, 1)) = 0.5
        _Distortion ("Distortion", Range(0, 2)) = 0.3
        _Specular ("Specular1", Float ) = 1
        _Specular1 ("Specular2", Float ) = 1
        _SpecularColor ("Specular Color", Color) = (0.5,0.5,0.5,1)
        _Gloss ("Gloss", Float ) = 0.8
        _LightWrapping ("Light Wrapping", Float ) = 1.5
        _Refraction ("Refraction", Range(0, 5)) = 0.5
        _WaveSpeed ("Wave Speed", Float ) = 40
        _WaveSpeed2 ("Wave Speed2", Float ) = 0
        [Header(Shore Wave and Foam)]
        _foamwaver ("Shore Wave Texture",2D) = "black" {}
        _foamspeed ("Shore Wave Speed", Float) = 0.1
        _foamrange ("Shore Wave Range", Range(0,1)) = 0
        _foamnoise ("Shore Wave Turbulence", Range(0,1) ) = 0.2
        _foamVisibility ("Foam Visibility", Range(0, 5)) = 0
        _foamtex ("Foam Texture",2D) = "black" {}
        _foamtilling("Foam Tilling", Float) = 1
        _foamColor ("Foam Color", Color) = (0.5,0.5,0.5,1)
        _foamtexspeed ("Foam Speed", Float ) = 1
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
            ZWrite Off
            Ztest LEqual
            ColorMask RGB
            
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
            uniform half4 _LightDiradj;
            uniform float4 _TimeEditor;
            uniform fixed4 _DeepWaterColor;
            uniform fixed4 _ShallowWaterColor;
            uniform sampler2D _ReflectionTex; uniform fixed4 _ReflectionTex_ST;
            uniform float _Reflectionintensity;
            uniform fixed _UseReflections;
            uniform float _Specular;
            uniform float _Specular1;
            uniform float _Gloss;
            uniform float _LightWrapping;
            uniform sampler2D _DepthTex; uniform fixed4 _DepthTex_ST;
            uniform sampler2D _NormalTexture; uniform fixed4 _NormalTexture_ST;
            uniform float _Refraction;
            uniform float _WaveSpeed;
            uniform float _WaveSpeed2;
            uniform float _Distortion;
            uniform fixed4 _SpecularColor;
            uniform float _NormalTiling;

            uniform sampler2D _foamwaver;
            uniform sampler2D _foamtex; uniform fixed4 _foamtex_ST;
            uniform fixed _foamstr;
            uniform fixed _foamspeed;
            uniform fixed _foamrange;
            uniform fixed _foamtilling;
            uniform fixed _foamVisibility;
            uniform fixed _foamBlend;
            uniform float4 _FoamColor;
            uniform fixed _foamtexspeed;
            uniform fixed _foamnoise;
            uniform fixed4 _ReflectionColor;

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
//                float4 projPos : TEXCOORD7;
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
                half3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
//                o.projPos = ComputeScreenPos (o.pos);
//                COMPUTE_EYEDEPTH(o.projPos.z);
                o.screenPos = o.pos;
                return o;
            }
            half4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                i.screenPos = float4( i.screenPos.xy / i.screenPos.w, 0, 0 );
                i.screenPos.y *= _ProjectionParams.x;
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
/////// Vectors:
                half3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
//                half _rotator_ang = 1.5708;
                half _rotator_ang = -1.5708;
                half _rotator_spd = 1.0;
//                half _rotator_cos = cos(_rotator_spd*_rotator_ang);
//                half _rotator_sin = sin(_rotator_spd*_rotator_ang);
                half _rotator_cos = cos(-1.5708);
                half _rotator_sin = sin(-1.5708);
                half2 _rotator_piv = float2(0.5,0.5);
//                half2 _rotator = (mul(i.uv0-_rotator_piv,float2x2( _rotator_cos, -_rotator_sin, _rotator_sin, _rotator_cos))+_rotator_piv);
                half2 _rotator = i.uv0.xy;// - _rotator_piv;
                      _rotator = float2(((_rotator.x*_rotator_cos) - (_rotator.y*_rotator_sin)),((_rotator.x*_rotator_sin) + (_rotator.y*_rotator_cos)));
                half2 _division1 = half2(_NormalTiling,_NormalTiling);
                half4 _timer = _Time;// + _TimeEditor;
//                half3 _multiplier3 = (float3((_WaveSpeed/_division1),0.0)*_timer.r);
//                half2 _multiplier3 = (_division1*_timer.r);
                half2 _multiplier3 = (float2(_WaveSpeed/_division1)*_timer.r);
//                half2 _multiplier3 = (float2(float2(_WaveSpeed,_WaveSpeed)/_division1)*_timer.r);
//                half2 _multiplier10 = _multiplier3 * float2(-_WaveSpeed*0.5,_WaveSpeed*0.5);
                half2 _multiplier2 = (i.uv0+(_multiplier3*float2(-_WaveSpeed,_WaveSpeed)*0.5))*_division1;

//                half2 _multiplier2 = ((_rotator+_multiplier3)*_division1);
//                half2 _multiplier2 = ((i.uv0*0.5+_multiplier3*_WaveSpeed)*_division1);
//                half2 _multiplier2 = ((float2(i.uv0.y,i.uv0.x)*0.5+_multiplier3*_WaveSpeed)*_division1);

//                      _multiplier2 = lerp(_multiplier2,((i.uv0*0.5+_multiplier3*_WaveSpeed)*_division1),_Test1);
//                      _multiplier2 = lerp(_multiplier2,((i.uv0+_multiplier10)*_division1),_Test1);

                half3 _texture1 = UnpackNormal(tex2D(_NormalTexture,TRANSFORM_TEX(_multiplier2, _NormalTexture)));
                half2 _multiplier1 = ((i.uv0+(_multiplier3*_WaveSpeed2))*_division1);
                half3 _texture2 = UnpackNormal(tex2D(_NormalTexture,TRANSFORM_TEX(_multiplier1, _NormalTexture)));
                half3 _subtractor = (_texture1.rgb-_texture2.rgb);
                half _Refract = lerp(0.05,_Refraction*1.5,pow(max(0,dot(i.normalDir,viewDirection)),1.5));
                float3 normalLocal = lerp(float3(0,0,1),(_texture1+_texture2),_Refract);
//                float3 normalLocal = lerp(float3(0,0,1),(_texture2),_Refract);
//                float3 normalLocal = (_texture1+_texture2);//
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals      
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
//                float3 lightDir = normalize(float3(_WorldSpaceLightPos0.x,_LightDiradj.z,_WorldSpaceLightPos0.z));
                half3 lightDir = normalize(float3(_WorldSpaceLightPos0.x+_LightDiradj.x,_LightDiradj.z,_WorldSpaceLightPos0.z+_LightDiradj.y));
                float3 lightDir1 = normalize(float3(_WorldSpaceLightPos0.x+_LightDiradj.x,_LightDiradj.w,_WorldSpaceLightPos0.z+_LightDiradj.y));
                float3 lightDir2 = normalize(float3(viewDirection.x+0.5,lightDirection.y/3,viewDirection.z+0.5));
                fixed3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDir);
                float3 viewangle = normalize(viewDirection-normalDirection);
//                float3 halfDirection = normalize(viewDirection+lightDirection);
                half4 depth = tex2D(_DepthTex,i.uv1);
//                half waterdepth = pow(saturate(depth.r*_DepthTransparency),_ShoreFade)*saturate(depth.r*_ShoreTransparency);
                half waterdepth = saturate(depth.g);
////// Lighting:
                fixed attenuation = 1;
                half3 attenColor = attenuation * _LightColor0.xyz;

///////// Gloss:
                half specPow = exp2( _Gloss * 2);
                half specp = exp2( _Gloss * 7+1 );
                half roughness = max(0.001, 1-pow(_Gloss,1.3));
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float Ndotva = max(0,dot(viewangle,lightDir1));
                float ref = max(0,dot(reflect(-lightDirection,normalDirection),viewDirection));
//                      ref = max(0,dot(reflect(-lightDir1,normalDirection),viewDirection));
                float hfsp = pow(roughness,1) / (pow((1 + (-1+pow(roughness,2))*pow(Ndotva,1)),2));
                half3 specularColor = _SpecularColor.rgb * _LightColor0.rgb;//lerp(UNITY_LIGHTMODEL_AMBIENT.rgb,_LightColor0.rgb,NdotL);
                half spec1 = pow(Ndoth,specPow) * _Specular * pow((1-Ndotv),1.5);
                     spec1 = clamp(spec1,0,(spec1*0.5)) * UNITY_LIGHTMODEL_AMBIENT.rgb;
                half spec2 = pow(Ndoth,specp) * _Specular1;
                half spec3 = pow(ref,specp) * _Specular1*1.5;
                half spec4 = pow(Ndotva,specp) * _Specular1;
                half3 directSpecular = spec1 + spec2 + spec3;
//                       directSpecular = spec4;
                half3 specular = saturate(directSpecular * specularColor);
/////// Foam
                _foamrange = saturate(_foamrange);

                half foamend = depth.b > _foamrange ? 1 : depth.b*(1/_foamrange);
                half foamstart = saturate(1-foamend);
                half foamrange = foamend * foamstart;
                half foamintensity = 1 - saturate(depth.b);
                     foamintensity = foamintensity - _timer.g * _foamspeed + normalDirection.r*_foamnoise;
//                     foamintensity *= normalDirection.r*_foamnoise;
                half foamgradient = saturate(tex2D(_foamwaver,float2(foamintensity,normalDirection.g)).r * foamrange);

                half2 _division2 = float2(_foamtilling,_foamtilling);
                half2 _multiplier7 = (float2(_foamtexspeed/_division2)*_timer.r);
//                half2 _multiplier5 = ((_rotator+_multiplier7)*_division2);
                half2 _multiplier5 = ((i.uv0+_multiplier7*float2(-_foamtexspeed,_foamtexspeed)*0.5)*_division2);
                half4 _texture3 = tex2D(_foamtex,TRANSFORM_TEX(_multiplier5, _foamtex));
                half2 _multiplier6 = ((i.uv0+_multiplier7)*_division2);
                half4 _texture4 = tex2D(_foamtex,TRANSFORM_TEX(_multiplier6, _foamtex));
                half3 _multiplier4 = saturate((_texture3.rgb-_texture4.rgb));
                half3 foam = saturate(foamgradient*_multiplier4*10*_foamVisibility);
/////// Diffuse:
                half3 w = float3(_LightWrapping,_LightWrapping,_LightWrapping)*0.5; // Light wrapping
                half3 NdotLWrap = NdotL * ( 1.0 - w );
                half3 forwardLight = max(float3(0.0,0.0,0.0), NdotLWrap + w );
                half3 directDiffuse = forwardLight * attenColor;
                half3 indirectDiffuse = float3(0,0,0);
                       indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
//                half3 _power = pow(saturate(max(_DeepWaterColor.rgb,(_ShallowWaterColor.rgb*(saturate(depth/_ShallowDeepBlend)*-1.0+1.0)))),_Fade);
                half3 watercolor = lerp(_ShallowWaterColor.rgb,_DeepWaterColor.rgb,depth.r);
                half2 _componentMask = _subtractor.rg;
                half2 _remap = ((i.screenPos.rg+(float2(_componentMask.r,_componentMask.g)*_Distortion))*0.5+0.5);
                half4 _ReflectionTex_var = tex2D(_ReflectionTex,TRANSFORM_TEX(_remap, _ReflectionTex)) * NdotL;
//                float frsnl = pow((1-Ndotv),2) * _Reflectionintensity;
                half frsnl = clamp(pow((1-Ndotv),1),0.04,1.5) * _Reflectionintensity * waterdepth;
                     frsnl = saturate(pow((1-Ndotv),2) * _Reflectionintensity * waterdepth);
                half3 reflectioncolor = lerp(_ReflectionColor.rgb,_ReflectionTex_var.rgb,_UseReflections);
                half3 diffuseColor = lerp(watercolor,reflectioncolor,frsnl);
                half3 diffuse = (directDiffuse + indirectDiffuse);
                       diffuse = lerp(diffuse,half3(1,1,1),frsnl*1.25) * diffuseColor;
                       diffuse = saturate(diffuse);
                       waterdepth = saturate(lerp(waterdepth,foamgradient,foamgradient) + foamgradient*(0.5*_foamVisibility));
/// Final Color:
                half3 finalColor = diffuse + foam + specular;
//                      finalColor = normalDirection;
                half4 finalRGBA = half4(finalColor,waterdepth);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Mobile/Diffuse"
}
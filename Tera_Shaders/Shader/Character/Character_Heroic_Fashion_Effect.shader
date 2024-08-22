Shader "TERA/Character/Heroic_Fashion_Effect" {
    Properties {
        _BaseRGBA ("Base(RGBA)", 2D) = "white" {}
        _SkinDeGamma ("Skin Gamma Correction", float) = 0.75
        _SkinColor ("Skin Color Custom", Color) = (0,0.667,0.667,1)
        _se ("Skin Emission", Range(0,2)) = 0.3
        _Skinenv ("Skin Edge Color", Color) = (0.855,0.568,0.5255,1)
        _Normalmap ("Normalmap", 2D) = "bump" {}
        _SpecularmapRGBA ("Specularmap(RGBA)", 2D) = "white" {}
        _SpecularIntensity ("Specular Intensity", Range(0, 2)) = 1
        _gloss("Gloss Correction",Range(0,5)) = 0
        _ReflectionIntensity ("Reflection Intensity", Range(0, 5)) = 1
        _lf ("lf", Range(0,2)) = 1
        _MatMask ("Mat Mask(RGB)(R_Skin)(G_Reflection)(B_Flake)", 2D) = "black" {}
		_FlakeColor1 ("Flake Color 1", Color) = (1,1,1,1)
        _FlakeColor2 ("Flake Color 2", Color) = (1,1,1,1)
        [Header(RimEffect)]
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0, 5)) = 0

        [Header(Emission)]
        _EmissionMap("EmissionMap",2D) = "black"{}
        //[HDR]_EmissionColor("EmissionColor",Color) = (1,1,1,1)

        [Header(Effect)]
        _EffectMixTex("EffectMixTex",2D) = "black"{}
        _StreamerRange("StreamerRange",Range(0.01,0.5)) = 0.1
        [HDR]_EffectColor("EffectColor",Color) = (1,1,1,1)
        _StreamerSpeed("StreamerSpeed",Float) = 0.1
        //_ShiningMask("ShiningMask(R)",2D) = "black"{}
        //[NoScaleOffset]_ShiningNoise("ShiningNoise(RG)",2D) = "white"{}
        //_ShiningTiling("ShiningTiling(X1Y1X2Y2)",Vector) = (1,1,1,1)
        ////[HDR]_ShiningColor("ShiningColor",Color) = (1,1,1,1)
        ////[MaterialToggle]_ShiningIdensity("ShiningIdensity",Float) = 1
        //_ShiningPow("ShiningPow",Float) = 2
        //_ShiningSpeed("ShiningSpeed",Float) = 0
        //_ShiningSpeedX("ShiningSpeedX",Float) = 0
        //_ShiningSpeedY("ShiningSpeedY",Float) = 0

    }
    SubShader {
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest-50"
            "DisableBatching"="True"
        }
        LOD 600
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            ZWrite On
            
            CGPROGRAM
            #pragma vertex vert_tera_pbr
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
//            #include "UniqueShadow_ShadowSample.cginc"
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityStandardUtils.cginc"
            #include "TeraPBRLighting.cginc"
            #pragma multi_compile_UNIQUE_SHADOW UNIQUE_SHADOW_LIGHT_COOKIE
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0

            uniform float4 _LightColor0;
            uniform sampler2D _BaseRGBA;
			uniform float4 _BaseRGBA_TexelSize;
			uniform float4 _BaseRGBA_ST;
            uniform float _RimPower;
            uniform fixed4 _RimColor;
            uniform fixed4 _SkinColor;
            uniform fixed4 _Skinems;
            uniform fixed _lf;
            uniform fixed _se;

            uniform fixed4 _FlakeColor1;
            uniform fixed4 _FlakeColor2;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform sampler2D _Brdfmap; uniform float4 _Brdfmap_ST;
            uniform float _SpecularIntensity;
            uniform fixed4 _Skinenv;
            uniform fixed _SkinDeGamma;
            uniform float _ReflectionIntensity;

            uniform sampler2D _EmissionMap;
            uniform float4 _EmissionMap_ST;
            //uniform float4 _EmissionColor;
            
            uniform sampler2D _EffectMixTex;
            uniform float4 _EffectMixTex_ST;
            uniform float _StreamerRange;
            uniform float4 _EffectColor;
            uniform float _StreamerSpeed;
            
            //uniform sampler2D _ShiningMask;
            //uniform float4 _ShiningMask_ST;
            //uniform sampler2D _ShiningNoise;
            //uniform float4 _ShiningNoise_ST;
            //uniform float4 _ShiningTiling;
            //uniform float4 _ShiningColor;
            //uniform float _ShiningPow;
            //uniform float _ShiningSpeed;
            //uniform float _ShiningSpeedX;
            //uniform float _ShiningSpeedY;

           // float _ShiningIdensity;

            half4 frag(V2f_TeraPBR i) : COLOR {
////// Textures:
//#if defined(HERO_ADDITION_ON)
//				float2 additiontex_uv;
//				float4 additiontex_rect;
//
//				additiontex_rect.x = (_AdditionOffset.x / _BaseRGBA_TexelSize.z);
//				additiontex_rect.y = (_AdditionOffset.y / _BaseRGBA_TexelSize.w);
//				additiontex_rect.z = (_AdditionOffset.z / _BaseRGBA_TexelSize.z);
//				additiontex_rect.w = (_AdditionOffset.w / _BaseRGBA_TexelSize.w);
//
//				fixed2 additiontex_size;
//				additiontex_size.x = _AdditionOffset.z - _AdditionOffset.x;
//				additiontex_size.y = _AdditionOffset.w - _AdditionOffset.y;
//
//				additiontex_uv.x = (_BaseRGBA_TexelSize.z / additiontex_size.x) * (i.uv0.x - additiontex_rect.x);
//				additiontex_uv.y = (_BaseRGBA_TexelSize.w / additiontex_size.y) * (i.uv0.y - additiontex_rect.y);
//
//				fixed2 inrange;
//				inrange.x = i.uv0.x >= additiontex_rect.x && i.uv0.x <= additiontex_rect.z ? 1 : 0;
//				inrange.y = i.uv0.y >= additiontex_rect.y && i.uv0.y <= additiontex_rect.w ? 1 : 0;
//				inrange.x += inrange.y;
//#endif
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                fixed4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));

                

                fixed3 _flake1 = lerp(fixed3(1.0,1.0,1.0),_FlakeColor1.rgb,_MatMask_var.b);
                fixed3 _flake2 = lerp(fixed3(1.0,1.0,1.0),_FlakeColor2.rgb,_MatMask_var.a);
                fixed equiprange = max(0,1-_MatMask_var.r);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                       _SpecularmapRGBA_var.rgb *= _flake1 * _flake2;
                half specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
////#if defined(HERO_ADDITION_ON)
////				fixed4 combied_color = inrange.x > 1.5 ? tex2D(_AdditionTex, additiontex_uv) : fixed4(0, 0, 0, 0);
////				_BaseRGBA_var.rgb = combied_color.a * combied_color.rgb + (1 - combied_color.a) * _BaseRGBA_var.rgb;
////				fixed4 combied_spcolor = inrange.x > 1.5 ? tex2D(_AdditionSpecular, additiontex_uv) : fixed4(0, 0, 0, 0);
////				_SpecularmapRGBA_var.rgb = combied_color.a * combied_spcolor.rgb + (1 - combied_color.a) * _SpecularmapRGBA_var.rgb;
////#endif
                
// GeometryData:
				i.normalDir = normalize(i.normalDir);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap, TRANSFORM_TEX(i.uv0, _Normalmap)));
				float3 normalLocal = _Normalmap_var.rgb;
////#if defined(HERO_ADDITION_ON)
////				float3 combied_normal = inrange.x > 1.5 ? UnpackNormal(tex2D(_AdditionNormal, additiontex_uv)) : float3(0, 0, 0);
////				normalLocal = combied_color.a * combied_normal.rgb + (1 - combied_color.a) * normalLocal.rgb;
////#endif
				float3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals
				float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 ahalfDirection = normalize(viewDirection-lightDirection);
                float3 lightDir = normalize(float3(_WorldSpaceLightPos0.x,0,_WorldSpaceLightPos0.z));
                float3 halfDir = normalize(viewDirection+lightDir);
                float3 charSunDirection = normalize(_SunDirchar1.xyz);
                fixed3 lightColor = _LightColor0.rgb;
////// Lighting:
                half shadowatten = UNITY_SHADOW_ATTENUATION(i, i.posWorld);
                half attenuation = lerp(shadowatten,1,_MatMask_var.r);
///////// Gloss:
                half glossq = _SpecularmapRGBA_var.a * equiprange;
                half glossk = _SpecularmapRGBA_var.a * _MatMask_var.r;
				half gloss = saturate(glossq+glossk);
///// SkinColor:
                half3 _skincolor = ColorCstmGamma(_BaseRGBA_var.rgb,_SkinColor.rgb,_MatMask_var.r,_SkinDeGamma);
                half3 _skinspcolor = ColorCstm(_SpecularmapRGBA_var.rgb.rgb,_SkinColor.rgb,_MatMask_var.r);
                half3 baseRGBA = _BaseRGBA_var.rgb * equiprange + _skincolor;
                       baseRGBA *= _flake1 * _flake2;
///// Lightness:
                half lightpower = ((lightColor.r*0.299)+(lightColor.g*0.587)+(lightColor.b*0.114));
                half emispower = saturate(lightpower);
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float Ndotah = max(0,dot(ahalfDirection,normalDirection));
                float Ndothd = dot(normalDirection,halfDir);
                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL);
                float NdotSunchar = max(0,dot(charSunDirection,normalDirection) * NdotV);
//                fixed3 attenColor = lightpower*_MatMask_var.r + lightColor*equiprange;//lerp(lerp(shadowatten,attenuation,shs),1,_MatMask_var.r) * lightColor;//
                float3 attenColor = lerp(attenuation,1,_MatMask_var.r) * lightColor;
                       attenuation *= NdotL;
                half3 sh = AmbientColorGradient(normalDirection);
                half shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,fixed3(shval,shval,shval),NdotL);
                half3 IBL = ImageBasedLighting(gloss,viewReflectDirection);
                      IBL *= _ReflectionIntensity * sh;
                fixed pie = 3.1415926535;
                half3 zis = Frsn(Ndotv,gloss,IBL,equiprange)*(attenuation*0.5+0.5);
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
////// Specular:
                float spGGX = SpecularGGXWithHeadLight(pie, gloss, _MatMask_var.r, max(Ndothd,Ndoth), Ndotv, NdotV, NdotL,_NdotL);
                half3 sPc_skin = Specularskin(gloss, max(Ndothd,Ndoth), 0, spGGX, NdotL, attenColor, Ndotv, _MatMask_var.r, Ndotl, _skinspcolor, specmncrm);
//                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,IBL,equiprange,sPc_skin,0);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,lightColor,IBL,equiprange,sPc_skin,0);
                      specular *= i.pl * _SpecularIntensity;
/////// Diffuse:
                half scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);
                half3 scattering = scatter * _Skinems * 0.5;
                float NdotLq = min(shadowatten,NdotL) * 0.8 * equiprange;
                half3 NdotLs = SkinLighting1(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_se,scatter,Ndoth,lightColor) * _MatMask_var.r;
//                half3 NdotLs = SkinLighting3(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_se,lightColor,Ndotv) * _MatMask_var.r;
//                half3 NdotLs = fixed3(1,1,1);
                half3 diffuse = CalculateDiffuseAddonf(NdotLs,NdotLq,0,attenColor,sh,baseRGBA,NdotSunchar,_MatMask_var.r);
//////// Emissive:
                fixed3 emission = baseRGBA * _MatMask_var.g;
/// Final Color:
                half reflerp = reflp(_SpecularmapRGBA_var.rgb,pie)*equiprange;
                half3 finalColor = FinalColor(diffuse,specular,reflerp,_Rim,zis)+emission;

///Emission
                finalColor += tex2D(_EmissionMap, i.uv0) * _EffectColor;

///Streamer:
                fixed4 streamRange= tex2D(_EffectMixTex, TRANSFORM_TEX(i.uv0, _EffectMixTex));
                //streamRange = pow(streamRange, 1 / 2.2);
                
                fixed streamer = 1-saturate(abs((1-frac(_Time.y * _StreamerSpeed))-streamRange.a)/ _StreamerRange);
                finalColor += streamer * streamRange.r * _EffectColor* streamRange.rgb;
                
                //fixed streamer = 1-saturate(abs((1-frac(_Time.y * _StreamerSpeed))-streamRange.b)/ _StreamerRange);
                //finalColor += streamer * streamRange.r * _EffectColor/** streamRange.rgb*/;

//////////Shining
//
//                //fixed shining = tex2D(_ShiningTex, TRANSFORM_TEX(i.uv1, _ShiningTex)).r;
//                fixed shining = tex2D(_ShiningMask, TRANSFORM_TEX(i.uv0, _ShiningMask)).r;
//                fixed shiningBase1 = tex2D(_ShiningNoise, i.uv0 * _ShiningTiling.xy).r;
//                fixed shiningBase2 = tex2D(_ShiningNoise, i.uv0 * _ShiningTiling.xy * float2(1.2,1.2)).r;
//                //shining1 = 1- saturate(abs(frac(_Time.y* _ShiningSpeedX) - shining1) /0.1);
//                fixed shining1 = 1- saturate(abs((sin(_Time.y * _ShiningSpeed)+1)/2.0- shiningBase1) /0.1);
//                fixed shining2 = 1- saturate(abs((-sin(_Time.y * _ShiningSpeed*1.5)+1)/4.0+0.1 - shiningBase2) /0.1);
//                fixed shining3 = 1- saturate(abs((cos(_Time.y * _ShiningSpeed)+1)/2.0- shiningBase1) /0.1);
//                fixed shining4 = 1- saturate(abs((-cos(_Time.y * _ShiningSpeed*1.5)+1)/4.0+0.1 - shiningBase2) /0.1);
//                
//                fixed shiningBase3 = tex2D(_ShiningNoise, i.uv0 * _ShiningTiling.xy + _Time.x*float2( _ShiningSpeedX, _ShiningSpeedY)).r;
//                fixed shiningBase4 = tex2D(_ShiningNoise, i.uv0 * _ShiningTiling.zw).a;
//
//                finalColor += pow(shining1* shining2, _ShiningPow) * _EffectColor * shining*1.5;
//                finalColor += pow(shining3* shining4, _ShiningPow) * _EffectColor * shining*1.5;
//
//                finalColor += pow(shiningBase4, _ShiningPow)* shiningBase3  * _EffectColor * shining*0.1;
//
//                finalColor += _EffectColor * shining * 0.01;

                half4 finalRGBA = half4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }

    SubShader {
        
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest-50"
            "DisableBatching"="True"
        }
        LOD 400
        Pass {
            Name "CHARACTERFORWARDGGXFLAKE"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            CGPROGRAM
            #pragma vertex vert_tera_pbrsimple
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
//            #include "UniqueShadow_ShadowSample.cginc"
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityStandardUtils.cginc"
            #include "TeraPBRLighting.cginc"
//            #pragma multi_compile_UNIQUE_SHADOW UNIQUE_SHADOW_LIGHT_COOKIE
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0

            uniform float4 _LightColor0;
            uniform sampler2D _BaseRGBA;
			uniform float4 _BaseRGBA_TexelSize;
			uniform float4 _BaseRGBA_ST;
            uniform float _RimPower;
            uniform fixed4 _RimColor;
            uniform fixed4 _SkinColor;
            uniform fixed _se;
            uniform fixed4 _FlakeColor1;
            uniform fixed4 _FlakeColor2;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform float _SpecularIntensity;
            uniform float _ReflectionIntensity;
            uniform fixed4 _Skinenv;
            uniform fixed _SkinDeGamma;

            uniform fixed _skinpoint;
            uniform fixed _lf;
            uniform fixed4 _Skinems;
            uniform float _gloss;
            uniform sampler2D _Brdfmap; uniform float4 _Brdfmap_ST;
            uniform float _SkinDirpow;
            uniform float _brdfrange;
            uniform fixed4 _TransmissionColor;
			uniform fixed4 _TransmissionRangeAdj;
			uniform fixed _TransmissionPointPower;
			uniform fixed _TransmissionRange;
            
            uniform sampler2D _EmissionMap;
            uniform float4 _EmissionMap_ST;
            //uniform float4 _EmissionColor;

            uniform sampler2D _EffectMixTex;
            uniform float4 _EffectMixTex_ST;
            uniform float _StreamerRange;
            uniform float4 _EffectColor;
            uniform float _StreamerSpeed;

            half4 frag(V2f_TeraPBRSimple i) : COLOR {
// GeometryData:
				i.normalDir = normalize(i.normalDir);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap, TRANSFORM_TEX(i.uv0, _Normalmap)));
				float3 normalLocal = _Normalmap_var.rgb;
				float3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals
				float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 charSunDirection = normalize(_SunDirchar1.xyz);
                float3 lightDir = normalize(float3(_WorldSpaceLightPos0.x,0,_WorldSpaceLightPos0.z));
                float3 halfDir = normalize(viewDirection+lightDir);
                float3 lightColor = _LightColor0.rgb;
////// Textures:
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                fixed4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed3 _flake1 = lerp(fixed3(1.0,1.0,1.0),_FlakeColor1.rgb,_MatMask_var.b);
                fixed3 _flake2 = lerp(fixed3(1.0,1.0,1.0),_FlakeColor2.rgb,_MatMask_var.a);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                       _SpecularmapRGBA_var.rgb *= _flake1 * _flake2;
                fixed equiprange = max(0,1-_MatMask_var.r);
                half specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
                half3 attenColor = lightColor;
///////// Gloss:
                half glossq = _SpecularmapRGBA_var.a * equiprange;
                half glossk = _SpecularmapRGBA_var.a * _MatMask_var.r;
				half gloss = saturate(glossq+glossk);
///// SkinColor:
                half3 _skincolor = ColorCstmGamma(_BaseRGBA_var.rgb,_SkinColor.rgb,_MatMask_var.r,_SkinDeGamma);
                half3 _skinspcolor = ColorCstm(_SpecularmapRGBA_var.rgb.rgb,_SkinColor.rgb,_MatMask_var.r);
                half3 baseRGBA = _BaseRGBA_var.rgb * equiprange;
                      baseRGBA *= _flake1 * _flake2;
                      baseRGBA += _skincolor;
///// Lightness:
                half lightpower = ((lightColor.r*0.299)+(lightColor.g*0.587)+(lightColor.b*0.114));
                half emispower = clamp(lightpower,0.0,1.0);
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float Ndothd = dot(normalDirection,halfDir);
                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL);
                float NdotSunchar = max(0,dot(charSunDirection,normalDirection) * NdotV);
                half3 sh = AmbientColorGradient(normalDirection);
                half shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,fixed3(shval,shval,shval),NdotL);
                fixed pie = 3.1415926535;
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
////// Specular:
                float spGGX = SpecularGGX(pie, gloss, _MatMask_var.r, max(Ndothd,Ndoth), NdotV, NdotL);
                half3 sPc_skin = Specularskin(gloss, max(Ndothd,Ndoth), _lf, spGGX, NdotL, attenColor, Ndotv, _MatMask_var.r, Ndotl, _skinspcolor, specmncrm);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,0,equiprange,sPc_skin,0);
                       specular *= _SpecularIntensity;
/////// Diffuse:
                float NdotLq = NdotL * 0.8 * equiprange;
//                half3 NdotLs = SkinLighting1(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_se,0,Ndoth) * _MatMask_var.r;
                half3 NdotLs = SkinLighting2(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_se,lightColor,Ndoth) * _MatMask_var.r;
                float scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);
                half3 diffuse = CalculateDiffuseAddonf(NdotLs,NdotLq,0,attenColor,sh,baseRGBA,NdotSunchar,_MatMask_var.r);
//////// Emissive:
//                float3 emission = baseRGBA * _MatMask_var.a;
/// Final Color:
                half reflerp = reflp(_SpecularmapRGBA_var.rgb,pie);
                     reflerp *= equiprange;
                half3 finalColor = FinalColor(diffuse,specular,reflerp,_Rim,0);

                ///Emission
                finalColor += tex2D(_EmissionMap, i.uv0) * _EffectColor;

                ///Streamer:
                fixed4 streamRange = tex2D(_EffectMixTex, TRANSFORM_TEX(i.uv0, _EffectMixTex));
                fixed streamer = 1 - saturate(abs((1 - frac(_Time.y * _StreamerSpeed)) - streamRange.a) / _StreamerRange);
                finalColor += streamer * streamRange.r * _EffectColor * streamRange.rgb;


                half4 finalRGBA = half4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }

    SubShader {
        
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest-50"
            "DisableBatching"="True"
        }
        LOD 200

        UsePass "Hidden/Character/CharacterPass/CHARACTERFORWARDBASEFLAKE"
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }
//    FallBack "Diffuse"
}
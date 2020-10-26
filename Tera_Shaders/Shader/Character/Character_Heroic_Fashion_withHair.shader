Shader "TERA/Character/Heroic_Fashion_withHair" {
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
        [Header(HairParameters)]
        _boundary ("Light Boundary", Range(-1,1)) = 0
        _HairColorCustom ("Hair Color Custom", Color) = (1,1,1,1)
        contraction ("Scatter Contraction", Range(0,60)) = 20
        feedback ("Scatter Bias", Range(0,0.5)) = 0.05
        scattercolor ("Scatter Color", Color) = (0.5,0.5,0.5,1)
        _SpecularInt ("Specular Intensity", Range(0, 2)) = 0.75
        _ReflectionIntensity ("Reflection Intensity", Range(0, 1)) = 0
        _AnisoDir ("Aniso Light Direction", Vector) = (0, 1, 0, 0)
        _Glossiness ("Aniso Gloss lv1", Range(0,1)) = 0.5
        aspc1 ("Aniso Specular Intensity Lv1", Range(0,5)) = 1
        _AnisoOffset2 ("Aniso Offset Lv1", Range(-2,2)) = 0
        _Glossiness2 ("Aniso Gloss lv2", Range(0,1)) = 0.5
        aspc2 ("Aniso Specular Intensity Lv2", Range(0,5)) = 1
        _AnisoOffset ("Aniso Offset Lv2", Range(-2,2)) = 0
        [Header(RimEffect)]
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0, 5)) = 0
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

            uniform fixed4 _HairColorCustom;
            uniform fixed _SpecularInt;
            uniform fixed _boundary;
            uniform float contraction;
            uniform float feedback;
            uniform fixed4 scattercolor;
            uniform float4 _AnisoDir;
            uniform float _AnisoOffset;
            uniform float _AnisoOffset2;
            uniform float _spread1;
            uniform float _spread2;
            uniform float aspc1;
            uniform float aspc2;
            uniform float _Glossiness;
            uniform float _Glossiness2;

            uniform sampler2D _shiftmap;
            uniform float4 _shiftmap_ST;
            uniform sampler2D _tc;
            uniform fixed4 _tc_ST;

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
				float3 tangentfixer = UnpackNormal(tex2D(_tc,TRANSFORM_TEX(i.uv0, _tc)));
                float3 tangentshifter = normalize(mul(normalLocal+tangentfixer.rgb, tangentTransform ));
				float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 ahalfvec = normalize(_AnisoDir.xyz + halfDirection);
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
//                half3 _skincolor = ColorCstmGamma(_BaseRGBA_var.rgb,_SkinColor.rgb,_MatMask_var.r,_SkinDeGamma);
//                half3 _skinspcolor = ColorCstm(_SpecularmapRGBA_var.rgb.rgb,_SkinColor.rgb,_MatMask_var.r);
                half3 baseRGBA = _BaseRGBA_var.rgb * equiprange;// + _skincolor;
                      baseRGBA *= _flake1 * _flake2;
///// Lightness:
                half lightpower = ((lightColor.r*0.299)+(lightColor.g*0.587)+(lightColor.b*0.114));
                half emispower = saturate(lightpower);
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
                float _Ndotl = max(0, dot( normalDirection, -lightDirection )*0.5+0.5);
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float Ndotah = max(0,dot(ahalfDirection,normalDirection));
                float Ndothd = dot(normalDirection,halfDir);
                float NdotA = max(0,dot(tangentshifter,ahalfvec));
                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL);
                float NdotSunchar = max(0,dot(charSunDirection,normalDirection) * NdotV);
                half3 CCparam = RGBtoHSV(_HairColorCustom.rgb);
                half CCsatfix = CCparam.y*0.75;
                half CCvalue = ((_HairColorCustom.r*0.299)+(_HairColorCustom.g*0.587)+(_HairColorCustom.b*0.114));
                fixed3 _haircolor = ColorCstm(_BaseRGBA_var.rgb,_HairColorCustom.rgb,_MatMask_var.r);
                fixed3 _hairspcolor = ColorCstm(_SpecularmapRGBA_var.rgb,_HairColorCustom.rgb,_MatMask_var.r);
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
                fixed3 specularColor = max(_hairspcolor,0.25) * _MatMask_var.r;
                half dsmask = SpecAniso2(max(0,dot(i.normalDir,ahalfvec)), _AnisoOffset2, _Glossiness, 8, (aspc1+CCsatfix)*0.25);
                half3 SpHair = SpecAniso2(NdotA, _AnisoOffset2, _Glossiness, 128, (aspc1+CCsatfix));
                      SpHair += SpecAniso2(NdotA, _AnisoOffset, _Glossiness2, 128, aspc2);
                      SpHair += dsmask*2*(1-SpHair+CCsatfix);
                      SpHair *= specularColor * attenColor * i.pl * (NdotA * 0.6 + 0.4);
                      SpHair *= lerp(1,0.35,CCvalue);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,lightColor,IBL,equiprange,SpHair,0);
                      specular *= i.pl * _SpecularIntensity;
/////// Diffuse:
//                half scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);
//                half3 scattering = scatter * _Skinems * 0.5;
                float NdotLq = min(shadowatten,NdotL) * 0.8 * equiprange;
                half3 diffuse = CalculateDiffuseAddonf(0,NdotLq,0,attenColor,sh,baseRGBA,NdotSunchar,_MatMask_var.r);
                      diffuse += CalculateHairDiffuse(NdotL,Ndotl,_Ndotl,Ndotv,_HairColorCustom.rgb,attenColor,_haircolor,_MatMask_var.r,CCparam.y,CCvalue);
                      diffuse += Scattering(Ndotv, contraction, feedback,_MatMask_var.r) * IBL;
//////// Emissive:
                fixed3 emission = baseRGBA * _MatMask_var.g;
/// Final Color:
                half reflerp = reflp(_SpecularmapRGBA_var.rgb,pie)*equiprange;
                half3 finalColor = FinalColor(diffuse,specular,reflerp,_Rim,zis)+emission;

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

            uniform fixed4 _HairColorCustom;
            uniform fixed _SpecularInt;
            uniform fixed _boundary;
            uniform float contraction;
            uniform float feedback;
            uniform fixed4 scattercolor;
            uniform float4 _AnisoDir;
            uniform float _AnisoOffset;
            uniform float _AnisoOffset2;
            uniform float _spread1;
            uniform float _spread2;
            uniform float aspc1;
            uniform float aspc2;
            uniform float _Glossiness;
            uniform float _Glossiness2;

            uniform sampler2D _shiftmap;
            uniform float4 _shiftmap_ST;
            uniform sampler2D _tc;
            uniform fixed4 _tc_ST;

            half4 frag(V2f_TeraPBRSimple i) : COLOR {
// GeometryData:
				i.normalDir = normalize(i.normalDir);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap, TRANSFORM_TEX(i.uv0, _Normalmap)));
				float3 normalLocal = _Normalmap_var.rgb;
				float3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals
				float3 tangentfixer = UnpackNormal(tex2D(_tc,TRANSFORM_TEX(i.uv0, _tc)));
                float3 tangentshifter = normalize(mul(normalLocal+tangentfixer.rgb, tangentTransform ));
				float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 ahalfvec = normalize(_AnisoDir.xyz + halfDirection);
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
                half3 CCparam = RGBtoHSV(_HairColorCustom.rgb);
                half CCsatfix = CCparam.y*0.75;
                half CCvalue = ((_HairColorCustom.r*0.299)+(_HairColorCustom.g*0.587)+(_HairColorCustom.b*0.114));
                fixed3 _haircolor = ColorCstm(_BaseRGBA_var.rgb,_HairColorCustom.rgb,_MatMask_var.r);
                fixed3 _hairspcolor = ColorCstm(_SpecularmapRGBA_var.rgb,_HairColorCustom.rgb,_MatMask_var.r);
                half3 baseRGBA = _BaseRGBA_var.rgb * equiprange;
                      baseRGBA *= _flake1 * _flake2;
///// Lightness:
                half lightpower = ((lightColor.r*0.299)+(lightColor.g*0.587)+(lightColor.b*0.114));
                half emispower = clamp(lightpower,0.0,1.0);
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
                float _Ndotl = max(0, dot( normalDirection, -lightDirection )*0.5+0.5);
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float Ndothd = dot(normalDirection,halfDir);
                float NdotA = max(0,dot(tangentshifter,ahalfvec));
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
                fixed3 specularColor = max(_hairspcolor,0.25) * _MatMask_var.r;
                half dsmask = SpecAniso2(max(0,dot(i.normalDir,ahalfvec)), _AnisoOffset2, _Glossiness, 8, (aspc1+CCsatfix)*0.25);
                half3 SpHair = SpecAniso2(NdotA, _AnisoOffset2, _Glossiness, 128, (aspc1+CCsatfix));
                      SpHair += SpecAniso2(NdotA, _AnisoOffset, _Glossiness2, 128, aspc2);
                      SpHair += dsmask*2*(1-SpHair+CCsatfix);
                      SpHair *= specularColor * attenColor * i.pl * (NdotA * 0.6 + 0.4);
                      SpHair *= lerp(1,0.35,CCvalue);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,0,equiprange,SpHair,0);
                       specular *= _SpecularIntensity;
/////// Diffuse:
                half NdotLq = NdotL * 0.8 * equiprange;
//                half3 scattering = scatter * _Skinems * 0.5;
                half3 diffuse = CalculateDiffuseAddonf(0,NdotLq,0,attenColor,sh,baseRGBA,NdotSunchar,_MatMask_var.r);
                      diffuse += CalculateHairDiffuse(NdotL,Ndotl,_Ndotl,Ndotv,_HairColorCustom.rgb,attenColor,_haircolor,_MatMask_var.r,CCparam.y,CCvalue);
                      diffuse += Scattering(Ndotv, contraction, feedback,_MatMask_var.r) * sh*0.25;
//////// Emissive:
                fixed3 emission = baseRGBA * _MatMask_var.g;
/// Final Color:
                half reflerp = reflp(_SpecularmapRGBA_var.rgb,pie);
                     reflerp *= equiprange;
                half3 finalColor = FinalColor(diffuse,specular,reflerp,_Rim,0);
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

        Pass {
            Name "CHARACTERFORWARDBASEFLAKE"
            Tags {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert_tera_simple
            #pragma fragment frag3
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityStandardUtils.cginc"
            #include "TeraPBRLighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0

            uniform fixed4 _LightColor0;
            uniform sampler2D _BaseRGBA;
			uniform float4 _BaseRGBA_TexelSize;
			uniform float4 _BaseRGBA_ST;
            uniform fixed _RimPower;
            uniform fixed4 _RimColor;
            uniform fixed4 _SkinColor;
            uniform fixed4 _FlakeColor1;
            uniform fixed4 _FlakeColor2;
            uniform fixed4 _Skinenv;
            uniform fixed _SkinDeGamma;
            uniform fixed4 _HairColorCustom;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;

            half4 frag3(V2f_TeraSimple i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap,TRANSFORM_TEX(i.uv0, _Normalmap)));
                float3 normalLocal = _Normalmap_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 attenColor = _LightColor0.xyz;
////// Textures:
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                fixed4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed3 _flake1 = lerp(fixed3(1.0,1.0,1.0),_FlakeColor1.rgb,_MatMask_var.b);
                fixed3 _flake2 = lerp(fixed3(1.0,1.0,1.0),_FlakeColor2.rgb,_MatMask_var.a);
                fixed equiprange = max(0,1-_MatMask_var.r);
                fixed3 _haircolor = ColorCstm(_BaseRGBA_var.rgb,_HairColorCustom.rgb,_MatMask_var.r);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                half gloss = _SpecularmapRGBA_var.a;
////// Specular:
                half NdotL = max(0, dot( normalDirection, lightDirection ));
                half Ndotv = max(0, dot( normalDirection, viewDirection ));
                half NdotV = max(0,1 - Ndotv);
                half _NdotL = max(0, dot( normalDirection, -lightDirection ));
                half _Ndotl = max(0, dot( normalDirection, -lightDirection )*0.5+0.5);
                half Ndotl = max(0,1 - NdotL);
                half Ndoth = max(0,dot(halfDirection,normalDirection));
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
                half3 sh = AmbientColorGradient(normalDirection);
                half shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,fixed3(shval,shval,shval),NdotL);
                half spGGX = SpecularGGX(3.1415926, gloss, _MatMask_var.r, Ndoth, NdotV, NdotL);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,0,1,0,0);
/////// Diffuse:
                half3 diffuse = (NdotL * attenColor + 0.7 * sh) * _BaseRGBA_var.rgb * _flake1 * _flake2 * equiprange;
                      diffuse += CalculateHairDiffuse(NdotL,Ndotl,_Ndotl,Ndotv,_HairColorCustom.rgb,attenColor,_haircolor,_MatMask_var.r,0.8,0.8);
/// Final Color:
                half3 finalColor = diffuse + specular + _Rim;
                       finalColor = max(0,finalColor);
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }
//    FallBack "Diffuse"
}
Shader "TERA/Character/NPC_VIP" {
    Properties {
        _BaseRGBA ("Base(RGBA)", 2D) = "white" {}
        _Normalmap ("Normalmap", 2D) = "bump" {}
        _Skinems ("Skin Ambient Bounce", Color) = (1,1,1,1)
        _Skinfb ("Female Skin Feedback", Range(0,0.5)) = 0.2
        _SkinDirpow ("Skin Bounce", Range(0, 0.5)) = 0
        _Skinenv ("Skin Edge Color", Color) = (0.855,0.568,0.5255,1)
        _SpecularmapRGBA ("Specularmap(RGBA)", 2D) = "white" {}
        _gloss ("gloss", Range(0,5)) = 0
        _SpecularIntensity ("Specular Intensity", Range(0, 2)) = 1
        _ReflectionIntensity ("Reflection Intensity", Range(0, 5)) = 1
        _MatMask ("Mask(RGBA)(Skin)(Reflection)(Eye)(Emission)", 2D) = "red" {}
        _EmissionColor ("Emission Color", Color) = (1,1,1,1)
        _headlight ("Head Lighting Intensity", Range(0,1)) = 0.5
        _AnisoDir ("Hair Aniso Light Direction", Vector) = (0, 1, 0, 0)
        _Glossiness ("Aniso Gloss lv1", Range(0,1)) = 0.5
        aspc1 ("Aniso Specular Intensity Lv1", Range(0,5)) = 1
        _AnisoOffset2 ("Aniso Offset Lv1", Range(-2,2)) = 0
        _Glossiness2 ("Aniso Gloss lv2", Range(0,1)) = 0.5
        aspc2 ("Aniso Specular Intensity Lv2", Range(0,5)) = 1
        _AnisoOffset ("Aniso Offset Lv2", Range(-2,2)) = 0
        [Header(RimEffect)]
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0, 5)) = 0
        //DeathEffect
        [Header(DeathEffect)]
        _DeathParamters("DeathEffectParamters(X:Min,Y:Max,Z:exp,W:add)", Vector) = (0.01,0.07,5,0.3)
		_FactorTex("FactorTex", 2D) = "white" {}
		_SinceLevelLoadedTime("_SinceLevelLoadedTime", float) = 0
		_DeathDuration("_DeathDuration", float) = 0
		_DeathColor("_DeathColor", Color) = (1,1,1,1)

    }
    SubShader {
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest"
            "DisableBatching"="True"
        }
        LOD 600
        Pass {
            Name "NPCVIPFORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Zwrite On
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert_tera_pbr
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityStandardUtils.cginc"
            #include "TeraPBRLighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0

            uniform sampler2D _BaseRGBA; uniform float4 _BaseRGBA_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform half _SpecularIntensity;
            uniform half _ReflectionIntensity;
            uniform fixed4 _Flakecolor1;
            uniform fixed4 _Skinems;
            uniform fixed  _Skinfb;
            uniform fixed _gloss;
            uniform fixed4 _EmissionColor;
            uniform fixed4 _RimColor;
            uniform fixed _RimPower;
            uniform float4 _AnisoDir;
            uniform float _AnisoOffset;
            uniform float _AnisoOffset2;
            uniform float _spread1;
            uniform float _spread2;
            uniform float aspc1;
            uniform float aspc2;
            uniform float _Glossiness;
            uniform float _Glossiness2;
            uniform fixed _headlight;
            uniform float _SkinDirpow;
            uniform fixed4 _Skinenv;
//            uniform fixed4 _TransmissionColor;
//			uniform fixed _ssspower;
			uniform sampler2D _tc;
            uniform fixed4 _tc_ST;

            uniform float4 _LightColor0;

			sampler2D _FactorTex;
			float4 _FactorTex_ST;
			float _SinceLevelLoadedTime;
			float _DeathDuration;
			fixed4 _DeathColor;
			fixed4 _DeathParamters;

            half4 frag(V2f_TeraPBR i) : COLOR {
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
                float3 lightDir = normalize(float3(_WorldSpaceLightPos0.x,0,_WorldSpaceLightPos0.z));
                float3 halfDir = normalize(viewDirection+lightDir);
////// Lighting:
                float3 attenColor = _LightColor0.rgb;

////// Textures:
                float4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                float4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                half4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                _headlight *= _MatMask_var.r;
                fixed equiprange = max(0,1-_MatMask_var.r);
                fixed hairrange = _MatMask_var.b > 0.5 ? 1.0 : 0.0;
                fixed eyeRange = _MatMask_var.b < 0.5 ? _MatMask_var.b : 0.0;
                      eyeRange = saturate(eyeRange*10);
                float3 specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
///////// Gloss:
                float glossq = min(1,((_SpecularmapRGBA_var.a+_gloss)/(1+_gloss))) * equiprange;
                float glossk = _SpecularmapRGBA_var.a * _MatMask_var.r;
				float gloss = saturate(glossq+glossk);
///// SkinColor:
                float3 _skincolor = _BaseRGBA_var.rgb * _MatMask_var.r;
                float3 _skinspcolor = _SpecularmapRGBA_var.rgb * _MatMask_var.r;
                float3 baseRGBA = (_BaseRGBA_var.rgb*(equiprange-hairrange));
                fixed3 hairc = _BaseRGBA_var.rgb * hairrange;
                fixed3 hairsc = _SpecularmapRGBA_var.rgb * hairrange;
                       baseRGBA += _skincolor+hairc;
///// Lightness:
                float lightpower = ((attenColor.r*0.299)+(attenColor.g*0.587)+(attenColor.b*0.114));
                float emispower = clamp(lightpower,0.0,1.0);
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float NdotA = max(0,dot(tangentshifter,ahalfvec));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float Ndothd = max(0,dot(normalDirection,halfDir));
                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL);
                fixed pie = 3.1415926535;
                half3 sh = AmbientColorGradient(normalDirection);
                half shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,fixed3(shval,shval,shval),NdotL);
                float3 IBL = ImageBasedLighting(gloss,viewReflectDirection);
                       IBL *= 0.5 * sh;
                float3 zis = Frsn(Ndotv,gloss,IBL,equiprange);
                float3 _Rim = Rim(NdotV,_RimPower,_RimColor);

                float3 CCparam = RGBtoHSV(hairc);
                half CCsatfix = CCparam.y*0.75;
                half CCvalue = ((hairc.r*0.299)+(hairc.g*0.587)+(hairc.b*0.114));

////// Specular:
                float spGGX = SpecularGGXSimplefiedWithHeadLight(pie, gloss, _MatMask_var.r, max(Ndothd,Ndoth), Ndotv, NdotL,_NdotL);
                float3 sPc_skin = Specularskin(gloss, max(Ndothd,Ndoth), 0, spGGX, NdotL, attenColor, Ndotv, _headlight, Ndotl, _skinspcolor, specmncrm);
                      aspc1 = clamp(aspc1,0,2);
                float dsmask = SpecAniso2(max(0,dot(i.normalDir,ahalfvec)), _AnisoOffset2, _Glossiness, 8, (aspc1+CCsatfix)*0.25);
                float sPc_hair = SpecAniso2(NdotA, _AnisoOffset2, _Glossiness, 128, (aspc1+CCsatfix));
                      sPc_hair += SpecAniso2(NdotA, _AnisoOffset, _Glossiness2, 128, aspc2);
                      sPc_hair += dsmask*2*(1-sPc_hair+CCsatfix);
                      sPc_hair *= hairrange*lerp(1,0.35,CCvalue);
                      sPc_hair = max(0.04,sPc_hair);
                float3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX*(1-hairrange),gloss,attenColor,IBL,equiprange,sPc_skin,sPc_hair);
                       specular *= i.pl * _SpecularIntensity;
/////// Diffuse:
                float NdotLq = NdotL * 0.75 * equiprange;
                float scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);
                half3 NdotLs = LightingforSkin(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_SkinDirpow,scatter)*_MatMask_var.r;
                half3 diffuse = CalculateDiffusevvip(NdotLs,NdotLq,attenColor,sh,baseRGBA,equiprange);
                float3 eye = Eyenpc(_BaseRGBA_var.rgb,_MatMask_var,emispower,NdotL,Ndotv,sh);
//////// Emissive:
                float3 emission = baseRGBA * _MatMask_var.g;
/// Final Color:
                float reflerp = reflp(_SpecularmapRGBA_var.rgb,pie);
                      reflerp *= equiprange - hairrange;

//                float3 finalColor = FinalColor(diffuse,specular,reflerp,_Rim,zis);
                float3 finalColor = diffuse + specular*0.8 + _Rim + zis;
                       finalColor *= (1-eyeRange);
                       finalColor += eye;
                       finalColor += emission;
                half4 finalRGBA = half4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
				 //disappear effect
				 //originally we need to disable z write
                finalRGBA = Disappear(_FactorTex,_FactorTex_ST,_DeathDuration,_SinceLevelLoadedTime,_DeathParamters,_DeathColor,finalRGBA,i.uv0.xy);
                return finalRGBA;
            }
            ENDCG
        }
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }

    SubShader {
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest"
            "DisableBatching"="True"
        }
        LOD 400
        Pass {
            Name "NPCVIPFORWARDSIMPLE"
            Tags {
                "LightMode"="ForwardBase"
            }
            Zwrite On
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert_tera_pbr
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityStandardUtils.cginc"
            #include "TeraPBRLighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0

            uniform sampler2D _BaseRGBA; uniform float4 _BaseRGBA_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform half _SpecularIntensity;
            uniform half _ReflectionIntensity;
            uniform fixed4 _Flakecolor1;
            uniform fixed4 _Skinems;
            uniform fixed  _Skinfb;
            uniform fixed _gloss;
            uniform fixed4 _EmissionColor;
            uniform fixed4 _RimColor;
            uniform fixed _RimPower;
            uniform float4 _AnisoDir;
            uniform float _AnisoOffset;
            uniform float _AnisoOffset2;
            uniform float _spread1;
            uniform float _spread2;
            uniform float aspc1;
            uniform float aspc2;
            uniform float _Glossiness;
            uniform float _Glossiness2;
            uniform fixed _headlight;
            uniform float _SkinDirpow;
            uniform fixed4 _Skinenv;

            uniform float4 _LightColor0;

			sampler2D _FactorTex;
			float4 _FactorTex_ST;
			float _SinceLevelLoadedTime;
			float _DeathDuration;
			fixed4 _DeathColor;
			fixed4 _DeathParamters;

            half4 frag(V2f_TeraPBR i) : COLOR {
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
////// Lighting:

                float3 attenColor = _LightColor0.rgb;

////// Textures:
                float4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                float4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                half4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                _headlight *= _MatMask_var.r;
                fixed equiprange = max(0,1-_MatMask_var.r);
                fixed hairrange = _MatMask_var.b > 0.5 ? 1.0 : 0.0;
                fixed eyeRange = _MatMask_var.b < 0.5 ? _MatMask_var.b : 0.0;
                      eyeRange = saturate(eyeRange*10);
                float3 specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
///////// Gloss:
                float glossq = min(1,((_SpecularmapRGBA_var.a+_gloss)/(1+_gloss))) * equiprange;
                float glossk = _SpecularmapRGBA_var.a * _MatMask_var.r;
				float gloss = saturate(glossq+glossk);
///// SkinColor:
                float3 _skincolor = _BaseRGBA_var.rgb * _MatMask_var.r;
                float3 _skinspcolor = _SpecularmapRGBA_var.rgb * _MatMask_var.r;
                float3 baseRGBA = (_BaseRGBA_var.rgb*equiprange);
                       baseRGBA += _skincolor;
///// Lightness:
                float lightpower = ((attenColor.r*0.299)+(attenColor.g*0.587)+(attenColor.b*0.114));
                float emispower = clamp(lightpower,0.0,1.0);
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL);
                float _Ndotl = max(0,1 - _NdotL);
                half3 sh = AmbientColorGradient(normalDirection);
                half shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,fixed3(shval,shval,shval),NdotL);
                float3 _Rim = Rim(NdotV,_RimPower,_RimColor);

////// Specular:
                float spGGX = SpecularGGXSimplefied(3.1415926535, gloss, _MatMask_var.r, Ndoth, NdotV, NdotL);
                float3 sPc_skin = Specularskin(gloss, Ndoth, 0, spGGX, NdotL, attenColor, Ndotv, _headlight, Ndotl, _skinspcolor, specmncrm);
                float sPc_hair = SpecAniso(_AnisoDir, viewDirection, normalDirection, _AnisoOffset2, _Glossiness, 8, aspc1);
//                      sPc_hair += SpecAniso(_AnisoDir, viewDirection, normalDirection, _AnisoOffset, _Glossiness2, 8, aspc2);
                      sPc_hair *= hairrange;
                float3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX*(1-hairrange),gloss,attenColor,0,equiprange,sPc_skin,sPc_hair);
                       specular *= i.pl * _SpecularIntensity;
/////// Diffuse:
                float NdotLq = NdotL * 0.75 * equiprange;
                float scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);
                half3 NdotLs = LightingforSkin(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_SkinDirpow,scatter)*_MatMask_var.r;
                half3 diffuse = CalculateDiffusevvip(NdotLs,NdotLq,attenColor,sh,baseRGBA,equiprange);            
                float3 eye = Eyenpc(_BaseRGBA_var.rgb,_MatMask_var,emispower,NdotL,Ndotv,sh);
//////// Emissive:
                float3 emission = baseRGBA * _MatMask_var.g;
/// Final Color:
                float3 finalColor = diffuse + specular + _Rim;
                       finalColor *= (1-eyeRange);
                       finalColor += eye;
                       finalColor += emission;
                half4 finalRGBA = half4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
				 //disappear effect
				 //originally we need to disable z write
                finalRGBA = Disappear(_FactorTex,_FactorTex_ST,_DeathDuration,_SinceLevelLoadedTime,_DeathParamters,_DeathColor,finalRGBA,i.uv0.xy);
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
            Name "CHARACTERNOSKINFORWARDBASE"
            Tags {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert_tera_simple
            #pragma fragment frag4
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityStandardUtils.cginc"
            #include "TeraPBRLighting.cginc"
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
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;

            half4 frag4(V2f_TeraSimple i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap,TRANSFORM_TEX(i.uv0, _Normalmap)));
                float3 normalLocal = _Normalmap_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Textures:
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                half gloss = _SpecularmapRGBA_var.a;
                half4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed eyerange = saturate(_MatMask_var.g*10);
                half NdotV = max(0,1 - dot( i.normalDir, viewDirection ));
                half Ndoth = max(0,dot(halfDirection,normalDirection));
                half NdotL = max(0, dot( normalDirection, lightDirection ));
                     NdotL = lerp(NdotL*0.5+0.5,1,eyerange);
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
                half spGGX = SpecularGGX(3.1415926, gloss, _MatMask_var.r, Ndoth, NdotV, NdotL);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,_LightColor0.rgb,0,1,0,0);
/// Final Color:
                half3 finalColor = (NdotL * _LightColor0.rgb + 0.5)*_BaseRGBA_var.rgb + specular + _Rim;
                      finalColor = max(0,finalColor);
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }
}

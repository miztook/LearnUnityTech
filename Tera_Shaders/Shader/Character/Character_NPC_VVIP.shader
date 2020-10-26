Shader "TERA/Character/NPC_VVIP" {
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
        _lf ("lf", Range(0,2)) = 0
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
            Name "NPCVVIPPBRFORWARD"
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
            uniform fixed4 _lf;
            uniform fixed4 _Flakecolor3;
            uniform fixed4 _EmissionColor;
            uniform fixed4 _RimColor;
            uniform fixed _RimPower;
            uniform float4 _AnisoDir;
            uniform fixed _AnisoOffset;
            uniform fixed _AnisoOffset2;
            uniform fixed _spread1;
            uniform fixed _spread2;
            uniform fixed aspc1;
            uniform fixed aspc2;
            uniform fixed _Glossiness;
            uniform fixed _Glossiness2;
            uniform fixed _headlight;
            uniform fixed _SkinDirpow;
            uniform fixed4 _Skinenv;
            uniform fixed4 _TransmissionColor;
			uniform fixed _ssspower;
			uniform sampler2D _tc;
            uniform fixed4 _tc_ST;
            uniform float4 _LightColor0;

			sampler2D _FactorTex;
			float4 _FactorTex_ST;
			half _SinceLevelLoadedTime;
			half _DeathDuration;
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
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                fixed4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                _headlight *= _MatMask_var.r;
                fixed equiprange = max(0,1-_MatMask_var.r);
                fixed hairrange = _MatMask_var.b > 0.5 ? 1 : 0;
                fixed nohair = 1-hairrange;
                fixed eyeRange = _MatMask_var.b < 0.5 ? _MatMask_var.b : 0;
                      eyeRange = saturate(eyeRange*10);
                half3 specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
///////// Gloss:
                half glossq = min(1,((_SpecularmapRGBA_var.a+_gloss)/(1+_gloss))) * equiprange;
                half glossk = _SpecularmapRGBA_var.a * _MatMask_var.r;
				half gloss = saturate(glossq+glossk);
///// SkinColor:
                half3 _skincolor = _BaseRGBA_var.rgb * _MatMask_var.r;
                half3 _skinspcolor = _SpecularmapRGBA_var.rgb * _MatMask_var.r;
                half3 baseRGBA = (_BaseRGBA_var.rgb*equiprange);
                      baseRGBA += _skincolor;
                half3 haircolor = _BaseRGBA_var.rgb * hairrange;
                half3 CCparam = RGBtoHSV(haircolor);
                half CCsatfix = CCparam.y;
                half CCvalue = ((haircolor.r*0.299)+(haircolor.g*0.587)+(haircolor.b*0.114));
///// Lightness:
                half lightpower = ((attenColor.r*0.299)+(attenColor.g*0.587)+(attenColor.b*0.114));
                half emispower = clamp(lightpower,0.0,1.0);
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float Ndothd = max(0,dot(normalDirection,halfDir));
                float NdotA = max(0,dot(tangentshifter,ahalfvec));
                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL);
                fixed pie = 3.1415926535;
                half3 sh = AmbientColorGradient(normalDirection);
                half shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,fixed3(shval,shval,shval),NdotL);
                half3 IBL = ImageBasedLightingNPC(gloss,viewReflectDirection);
                      IBL *= 0.5 * sh;
                half3 zis = Frsn(Ndotv,gloss,IBL,equiprange);
//                half3 zis = Frsn(Ndotv,gloss,IBL,equiprange)*(NdotL*0.5+0.5);
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);

////// Specular:
                half spGGX = SpecularGGXWithHeadLight(pie, gloss, _MatMask_var.r, max(Ndothd,Ndoth), Ndotv, NdotV, NdotL,_NdotL)*(1-hairrange);
                half3 sPc_skin = Specularskin(gloss, max(Ndothd,Ndoth), _lf, spGGX, NdotL, attenColor, Ndotv, _headlight, Ndotl, _skinspcolor, specmncrm);
                half dsmask = SpecAniso2(max(0,dot(i.normalDir,ahalfvec)), _AnisoOffset2, _Glossiness, 8, (saturate(aspc1)+CCsatfix)*0.25);
                half sPc_hair = SpecAniso2(NdotA, _AnisoOffset2, _Glossiness, 128, (aspc1+CCsatfix));
                     sPc_hair += SpecAniso2(NdotA, _AnisoOffset, _Glossiness2, 128, aspc2);
                     sPc_hair += dsmask*2*(1-sPc_hair+CCsatfix);
                     sPc_hair *= hairrange*lerp(1,0.35,CCvalue);
                     sPc_hair = max(0.04,sPc_hair);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,IBL*nohair*sh,equiprange,sPc_skin,sPc_hair);
                       specular *= i.pl * _SpecularIntensity;
/////// Diffuse:
                half scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);
                half3 scattering = scatter * _Skinems * 0.5;
//                half NdotLq = LightingWithHeadLight(NdotL, Ndotv, _headlight) * equiprange;
                half NdotLq = NdotL  * NdotL* 0.8 * equiprange;
                half3 NdotLs = LightingforSkin(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_SkinDirpow,scatter)*_MatMask_var.r;
                half3 diffuse = CalculateDiffusevvip(NdotLs,NdotLq,attenColor,sh,baseRGBA,equiprange)*nohair;
                      diffuse += CalculateHairDiffuse(NdotL,Ndotl,_NdotL,Ndotv,haircolor,attenColor,haircolor,hairrange,CCparam.y,CCvalue)*hairrange;
                      diffuse += Scattering(Ndotv, 20, 0.05,hairrange) * (IBL*gloss)*(1-_MatMask_var.r);
                half3 eye = Eyenpc(_BaseRGBA_var.rgb,_MatMask_var,emispower,NdotL,Ndotv,sh);
//////// Emissive:
                half3 emission = baseRGBA * _MatMask_var.g;
/// Final Color:
                half reflerp = reflp(_SpecularmapRGBA_var.rgb,pie);
                     reflerp *= equiprange*nohair;
                half3 finalColor = FinalColor(diffuse,specular,reflerp,_Rim,zis);
                      finalColor *= 1-eyeRange;
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
            uniform fixed4 _lf;
            uniform fixed4 _Flakecolor3;
            uniform fixed4 _EmissionColor;
            uniform fixed4 _RimColor;
            uniform fixed _RimPower;
            uniform float4 _AnisoDir;
            uniform fixed _AnisoOffset2;
            uniform fixed aspc1;
            uniform fixed _Glossiness;
            uniform fixed _headlight;
            uniform fixed _SkinDirpow;
            uniform fixed4 _Skinenv;
            uniform fixed4 _TransmissionColor;
			uniform fixed _ssspower;
			uniform sampler2D _tc;
            uniform fixed4 _tc_ST;
            uniform float4 _LightColor0;

			sampler2D _FactorTex;
			float4 _FactorTex_ST;
			fixed _SinceLevelLoadedTime;
			fixed _DeathDuration;
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
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 ahalfvec = normalize(_AnisoDir.xyz + halfDirection);
                float3 lightDir = normalize(float3(_WorldSpaceLightPos0.x,0,_WorldSpaceLightPos0.z));
                float3 halfDir = normalize(viewDirection+lightDir);
                float3 attenColor = _LightColor0.rgb;
////// Textures:
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                fixed4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                _headlight *= _MatMask_var.r;
                fixed equiprange = max(0,1-_MatMask_var.r);
                fixed hairrange = _MatMask_var.b > 0.5 ? 1 : 0;
                fixed eyeRange = _MatMask_var.b < 0.5 ? _MatMask_var.b : 0;
                      eyeRange = saturate(eyeRange*10);
                half3 specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
///////// Gloss:
                half glossq = min(1,((_SpecularmapRGBA_var.a+_gloss)/(1+_gloss))) * equiprange;
                half glossk = _SpecularmapRGBA_var.a * _MatMask_var.r;
				half gloss = saturate(glossq+glossk);
///// SkinColor:
                half3 _skincolor = _BaseRGBA_var.rgb * _MatMask_var.r;
                half3 _skinspcolor = _SpecularmapRGBA_var.rgb * _MatMask_var.r;
                half3 baseRGBA = (_BaseRGBA_var.rgb*equiprange);
                       baseRGBA += _skincolor;
                half3 haircolor = _BaseRGBA_var.rgb * hairrange;
                half3 CCparam = RGBtoHSV(haircolor);
                half CCsatfix = CCparam.y;
                half CCvalue = ((haircolor.r*0.299)+(haircolor.g*0.587)+(haircolor.b*0.114));
///// Lightness:
                half lightpower = ((attenColor.r*0.299)+(attenColor.g*0.587)+(attenColor.b*0.114));
                half emispower = clamp(lightpower,0.0,1.0);
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float Ndothd = max(0,dot(normalDirection,halfDir));
                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL);
                half3 sh = AmbientColorGradient(normalDirection);
                half shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,fixed3(shval,shval,shval),NdotL);
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
////// Specular:
                half spGGX = SpecularGGX(3.1415926535, gloss, _MatMask_var.r, max(Ndothd,Ndoth), NdotV, NdotL);
                half3 sPc_skin = Specularskin(gloss, max(Ndothd,Ndoth), _lf, spGGX, NdotL, attenColor, Ndotv, _headlight, Ndotl, _skinspcolor, specmncrm);
                half3 sPc_hair = SpecAniso2(max(0,dot(tangentshifter,ahalfvec)), _AnisoOffset2, _Glossiness, 128, (aspc1+CCsatfix));
                      sPc_hair *= hairrange;
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX*(1-hairrange),gloss,attenColor,0,equiprange,sPc_skin,sPc_hair);
                      specular *= i.pl * _SpecularIntensity;
/////// Diffuse:
                half NdotLq = LightingWithHeadLight(NdotL, Ndotv, _headlight) * equiprange;
                half3 NdotLs = LightingforSkin(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_SkinDirpow,0)*_MatMask_var.r;

                half3 diffuse = CalculateDiffusevvip(NdotLs,NdotLq,attenColor,sh,baseRGBA,equiprange)*(1-hairrange);
                      diffuse += CalculateHairDiffuseNPC(NdotL,Ndotl,_NdotL,Ndotv,attenColor,haircolor,hairrange,CCparam.y,CCvalue);        
                half3 eye = Eyenpc(_BaseRGBA_var.rgb,_MatMask_var,emispower,NdotL,Ndotv,sh);
//////// Emissive:
                half3 emission = baseRGBA * _MatMask_var.g;
/// Final Color:
                half3 finalColor = diffuse + specular + _Rim;
                       finalColor *= 1-eyeRange;
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
            uniform fixed4 _Skinenv;
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
                float3 attenColor = _LightColor0.xyz;
////// Textures:
                float4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                half4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed eyerange = saturate(_MatMask_var.g*10);
                fixed3 baseRGBA = _BaseRGBA_var.rgb * max(0,1-_MatMask_var.r);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                half gloss = _SpecularmapRGBA_var.a;
                fixed3 _skincolor = _BaseRGBA_var.rgb * _MatMask_var.r;
                half NdotL = max(0, dot( normalDirection, lightDirection ));
                     
                half NdotV = max(0,1 - dot( normalDirection, viewDirection ));
                half _NdotL = max(0, dot( normalDirection, -lightDirection ));
                half Ndoth = max(0,dot(halfDirection,normalDirection));
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
                half3 sh = AmbientColorGradient(normalDirection);
                half shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,fixed3(shval,shval,shval),NdotL);
                half spGGX = SpecularGGX(3.1415926, gloss, _MatMask_var.r, Ndoth, NdotV, NdotL);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,0,1,0,0);
/////// Diffuse:
                half3 diffuse = SkinLightingSimple(NdotL,_NdotL,shval,_Skinenv.rgb,_LightColor0.rgb)*_skincolor;
                      NdotL = lerp(NdotL*0.5+0.5,1,eyerange);
                      diffuse += (NdotL * attenColor + 0.7 * sh) * baseRGBA;
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
    //FallBack "Diffuse"
}

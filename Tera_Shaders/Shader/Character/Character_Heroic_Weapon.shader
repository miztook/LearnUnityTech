Shader "TERA/Character/Heroic_WeaponWing" {
    Properties {
        _BaseRGBA ("Base(RGBA)", 2D) = "white" {}
        _Normalmap ("Normalmap", 2D) = "bump" {}
        _SpecularmapRGBA ("Specularmap(RGBA)", 2D) = "white" {}
        _SpecularIntensity ("Specular Intensity", Range(0, 2)) = 1.5
        _gloss("Gloss Correction",Range(0,5)) = 0
        _ReflectionIntensity ("Reflection Intensity", Range(0, 1)) = 1
        _Pl("PointLight Intensity", Range(0,1)) = 1
        _MatMask ("Mat Mask(RGB)(R_Skin)(G_Reflection)(B_Flake)", 2D) = "black" {}
        _FlakeColor1 ("Flake Color 1", Color) = (1,1,1,1)
        _FlakeColor2 ("Flake Color 2", Color) = (1,1,1,1)
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0, 5)) = 0
        _headlight ("Head Lighting Intensity", Range(0,1)) = 0.5
        _Clip ("Alpha Clip", float) = 0.5
    }
    SubShader {
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest-50"
            "DisableBatching"="True"
        }
        LOD 600
        Pass {
            Name "CHARACTERWINGFORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }

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
            uniform float4 _LightColor0;
            uniform sampler2D _BaseRGBA; uniform float4 _BaseRGBA_ST;
            uniform fixed _Pl;
            uniform fixed _RimPower;
            uniform fixed4 _RimColor;
            uniform fixed4 _FlakeColor1;
            uniform fixed4 _FlakeColor2;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform fixed _SpecularIntensity;
            uniform fixed _ReflectionIntensity;
            uniform half _gloss;
            uniform fixed _headlight;
            uniform fixed _Clip;
            uniform float4 _SunDirchar;
            half4 frag(V2f_TeraPBR i) : COLOR {
////// Textures:
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - _Clip);
                half3 baseRGBA = _BaseRGBA_var.rgb;
                half4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed equiprange = max(0,1-_MatMask_var.r);
                fixed3 _flake1 = lerp(fixed3(1.0,1.0,1.0),_FlakeColor1.rgb,_MatMask_var.b);
                fixed3 _flake2 = lerp(fixed3(1.0,1.0,1.0),_FlakeColor2.rgb,_MatMask_var.a);
                       baseRGBA *= _flake1 * _flake2;
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                       _SpecularmapRGBA_var.rgb *= _flake1 * _flake2;
                half3 specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));    
// GeometryData:
				i.normalDir = normalize(i.normalDir);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap, TRANSFORM_TEX(i.uv0, _Normalmap)));
				float3 normalLocal = _Normalmap_var.rgb;
				float3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals
				float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightDir = normalize(float3(_WorldSpaceLightPos0.x,0,_WorldSpaceLightPos0.z));
                float3 charSunDirection = normalize(_SunDirchar.xyz);
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 halfDir = normalize(viewDirection+lightDir);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                half attenuation = UNITY_SHADOW_ATTENUATION(i, i.posWorld);
                half3 attenColor = attenuation * _LightColor0.xyz;

///////// Gloss:
				half gloss = min(1,((_SpecularmapRGBA_var.a+_gloss)/(1+_gloss)));
				half plmncrm = dot(i.pl,float3(0.3,0.59,0.11));
///// Lightness:
                half lightpower = ((lightColor.r*0.299)+(lightColor.g*0.587)+(lightColor.b*0.114));
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float Ndothd = dot(normalDirection,halfDir);

                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL);
                float NdotSunchar = max(0,dot(charSunDirection,normalDirection)*NdotV);
                fixed pie = 3.1415926535;
                half3 sh = AmbientColorGradient(normalDirection);
                      sh = lerp(sh,dot(sh,float3(0.3,0.59,0.11)),NdotL);
                half3 IBL = ImageBasedLighting(gloss,viewReflectDirection);
                       IBL *= sh * _ReflectionIntensity;
                half3 zis = Frsn(Ndotv,gloss,IBL,equiprange);
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);

////// Specular:
                half spGGX = SpecularGGX(pie, gloss, _MatMask_var.r, max(Ndothd,Ndoth), NdotV, NdotL);
                half shGGX = SpecularGGXofHeadLight(pie, gloss, Ndotv, Ndotl);
                half svGGX = SpecularGGX(pie, gloss, 0, Ndotv, NdotV, NdotL);
                half3 specular = CalculateSpecularWW(_SpecularmapRGBA_var.rgb,spGGX,shGGX,gloss,attenColor,IBL,NdotL);
                       specular *= i.pl*_Pl;
                       specular *= _SpecularIntensity;
/////// Diffuse:
                half NdotLq = LightingWithHeadLightWW(NdotL,Ndotl,Ndotv,0.4,gloss);
                half3 diffuse = CalculateDiffuseAddon(0,NdotLq,0,attenColor,sh,baseRGBA,NdotSunchar);
////// Emissive:
                half3 emission = baseRGBA * _MatMask_var.g;
/// Final Color:
                half3 reflerp = reflp(_SpecularmapRGBA_var.rgb,pie);
                half3 finalColor = FinalColor(diffuse,specular,reflerp,_Rim,zis);
                      finalColor += emission;
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
            Name "CHARACTERWEAPONFORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
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
            uniform float4 _LightColor0;
            uniform sampler2D _BaseRGBA; uniform float4 _BaseRGBA_ST;
            uniform fixed _Pl;
            uniform fixed _RimPower;
            uniform fixed4 _RimColor;
            uniform fixed4 _FlakeColor1;
            uniform fixed4 _FlakeColor2;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform fixed _SpecularIntensity;
            uniform fixed _ReflectionIntensity;
            uniform half _gloss;
            uniform fixed _headlight;

            half4 frag(V2f_TeraPBR i) : COLOR {
////// Textures:
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                fixed3 baseRGBA = _BaseRGBA_var.rgb;
                half4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed equiprange = max(0,1-_MatMask_var.r);
                fixed3 _flake1 = lerp(fixed3(1.0,1.0,1.0),_FlakeColor1.rgb,_MatMask_var.b);
                fixed3 _flake2 = lerp(fixed3(1.0,1.0,1.0),_FlakeColor2.rgb,_MatMask_var.a);
                       baseRGBA *= _flake1 * _flake2;
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                       _SpecularmapRGBA_var.rgb *= _flake1 * _flake2;
                half3 specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));    
// GeometryData:
				i.normalDir = normalize(i.normalDir);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap, TRANSFORM_TEX(i.uv0, _Normalmap)));
				float3 normalLocal = _Normalmap_var.rgb;
				float3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals
				float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightDir = normalize(float3(_WorldSpaceLightPos0.x,0,_WorldSpaceLightPos0.z));
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 halfDir = normalize(viewDirection+lightDir);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation =1;
                half3 attenColor = attenuation * _LightColor0.xyz;

///////// Gloss:
				half gloss = min(1,((_SpecularmapRGBA_var.a+_gloss)/(1+_gloss)));
///// Lightness:
                half lightpower = ((lightColor.r*0.299)+(lightColor.g*0.587)+(lightColor.b*0.114));
                half NdotL = max(0, dot( normalDirection, lightDirection ));
                half Ndotv = max(0, dot( normalDirection, viewDirection ));
                half Ndoth = max(0,dot(halfDirection,normalDirection));
                half Ndothd = dot(normalDirection,halfDir);
                half NdotV = max(0,1 - Ndotv);
                half Ndotl = max(0,1 - NdotL);
                fixed pie = 3.1415926535;
                half3 sh = AmbientColorGradient(normalDirection);
                      sh = lerp(sh,dot(sh,float3(0.3,0.59,0.11)),NdotL);
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
////// Specular:
                half spGGX = SpecularGGX(pie, gloss, 0, max(Ndothd,Ndoth), NdotV, NdotL);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,0,equiprange,0,0);
                       specular *= i.pl*_Pl;
                       specular *= _SpecularIntensity;
/////// Diffuse:
                half3 diffuse = CalculateDiffuse(0,(NdotL*0.8+0.1),0,attenColor,sh,baseRGBA);
////// Emissive:
                half3 emission = baseRGBA * _MatMask_var.g;
/// Final Color:
                half3 finalColor = diffuse+specular+_Rim;
                       finalColor += emission;
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
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                half gloss = _SpecularmapRGBA_var.a;
////// Specular:
                half NdotL = max(0, dot( normalDirection, lightDirection ));
                half NdotV = max(0,1 - dot( normalDirection, viewDirection ));
                half Ndoth = max(0,dot(halfDirection,normalDirection));
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
                half3 sh = AmbientColorGradient(normalDirection);
                half shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,fixed3(shval,shval,shval),NdotL);
                half spGGX = SpecularGGX(3.1415926, gloss, _MatMask_var.r, Ndoth, NdotV, NdotL);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,0,1,0,0);
/////// Diffuse:
                half3 diffuse = (NdotL * attenColor + 0.7) * _BaseRGBA_var.rgb * _flake1 * _flake2;
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
}

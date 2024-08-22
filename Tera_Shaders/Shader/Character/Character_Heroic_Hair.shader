Shader "TERA/Character/Heroic_Hair" {
    Properties {
        _BaseRGBA ("Base(RGBA)", 2D) = "white" {}
        _boundary ("Light Boundary", Range(-1,1)) = 0
        _Normalmap ("Normalmap", 2D) = "bump" {}
        _HairColorCustom ("Hair Color Custom", Color) = (1,1,1,1)
        _shcolor ("Ambient Color", Color) = (1,1,1,1)
        contraction ("Scatter Contraction", Range(0,60)) = 20
        feedback ("Scatter Bias", Range(0,0.5)) = 0.05
        scattercolor ("Scatter Color", Color) = (0.5,0.5,0.5,1)
        _SpecularmapRGBA ("Specularmap(RGBA)", 2D) = "white" {}
        _SpecularInt ("Specular Intensity", Range(0, 2)) = 0.75
        _ReflectionIntensity ("Reflection Intensity", Range(0, 1)) = 0
        _AnisoDir ("Aniso Light Direction", Vector) = (0, 1, 0, 0)
        _Glossiness ("Aniso Gloss lv1", Range(0,1)) = 0.5
        aspc1 ("Aniso Specular Intensity Lv1", Range(0,5)) = 1
        _AnisoOffset2 ("Aniso Offset Lv1", Range(-2,2)) = 0
        _Glossiness2 ("Aniso Gloss lv2", Range(0,1)) = 0.5
        aspc2 ("Aniso Specular Intensity Lv2", Range(0,5)) = 1
        _AnisoOffset ("Aniso Offset Lv2", Range(-2,2)) = 0
        _MatMask ("Mat Mask(RGB)(R_Hair)(G_Reflection)(B_Accessory)", 2D) = "black" {}
        _headlight ("Head Lighting Intensity", Range(0,1)) = 0.5
        _Dstcull ("Cull Type 0=off 1=back 2=front",int) = 2
        [Header(RimEffect)]
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0, 5)) = 0

        _gloss ("tester", Range(0,1)) = 0
    }
    SubShader {
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest-50"
            "DisableBatching"="True"
             }
        LOD 600
        Pass {
            Name "FORWARDFront"
            Tags {
                "LightMode"="ForwardBase"
            }
            Cull Back
            
            CGPROGRAM
            #pragma vertex vert_tera_pbr
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
//            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
			#include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityStandardUtils.cginc"
            #include "TeraPBRLighting.cginc"

            uniform float4 _LightColor0;
            uniform sampler2D _BaseRGBA; uniform float4 _BaseRGBA_ST;
            uniform float _RimPower;
            uniform fixed4 _RimColor;
            uniform fixed4 _HairColorCustom;
            uniform fixed4 _shcolor;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform fixed _boundary;
            uniform float contraction;
            uniform float feedback;
            uniform fixed4 scattercolor;
            uniform fixed _headlight;
            uniform fixed _SpecularInt;
            uniform fixed _ReflectionIntensity;
            uniform float4 _AnisoDir;
            uniform float _AnisoOffset;
            uniform float _AnisoOffset2;
            uniform float _spread1;
            uniform float _spread2;
            uniform float aspc1;
            uniform float aspc2;
            uniform float _Glossiness;
            uniform float _Glossiness2;

            uniform fixed _gloss;

            uniform float4 _SunDirchar;

            uniform sampler2D _shiftmap;
            uniform float4 _shiftmap_ST;
            uniform sampler2D _tc;
            uniform fixed4 _tc_ST;

//            uniform int _spchk;
//            uniform int sks;
//            uniform int _iblchk;
//            uniform int _difchk;
//            uniform int _ndachk;
//            uniform int _colchk;

            half4 frag(V2f_TeraPBR i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDir = normalize(i.posWorld.xyz - _WorldSpaceCameraPos.xyz);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap,TRANSFORM_TEX(i.uv0, _Normalmap)));
                float3 normalLocal = _Normalmap_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 tangentfixer = UnpackNormal(tex2D(_tc,TRANSFORM_TEX(i.uv0, _tc)));
                float3 tangentshifter = normalize(mul(normalLocal+tangentfixer.rgb, tangentTransform ));
                float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 ahalfvec = normalize(_AnisoDir.xyz + halfDirection);
                float3 SunDirection = normalize(_SunDir.xyz);
                float3 charSunDirection = normalize(_SunDirchar.xyz);
                float3 halfsunchar = normalize(viewDirection+charSunDirection);
////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                fixed4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed nohair = 1-_MatMask_var.r;
                fixed4 spcolor = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                float gloss = spcolor.a;
//                float3 tangentshift = UnpackNormal(tex2D(_shiftmap,TRANSFORM_TEX(i.uv1, _shiftmap)));
////// Specular:
                float NdotL = max(0, dot(normalDirection, lightDirection));
                float _NdotL = max(0, dot( normalDirection, -lightDirection )*0.5+0.5);
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float NdotV = max(0,1 - Ndotv);
                float HdotSunchar = max(0,dot(halfsunchar,normalDirection));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float NdotA = max(0,dot(tangentshifter,ahalfvec));
//                float NdotA = max(0,dot(i.normalDir+tangentshift,ahalfvec));
                float Ndota = max(0,dot(normalDirection,ahalfvec));
                float Ndotl = max(0,1 - NdotL); 
                float3 NdotSunchar = max(0,dot(charSunDirection,normalDirection)) * _SunColorchar.rgb * _SunColorchar.a*0;
                half3 CCparam = RGBtoHSV(_HairColorCustom.rgb);
                half CCsatfix = CCparam.y*0.75;
                half CCvalue = ((_HairColorCustom.r*0.299)+(_HairColorCustom.g*0.587)+(_HairColorCustom.b*0.114));
                fixed3 _haircolor = ColorCstm(_BaseRGBA_var.rgb,_HairColorCustom.rgb,_MatMask_var.r);
                fixed3 _hairspcolor = ColorCstm(spcolor.rgb,_HairColorCustom.rgb,_MatMask_var.r);
                half3 sh = AmbientColorGradient(normalDirection);// * (pow(NdotL,0.7)*0.5+0.5);
                      sh *= lerp((pow(NdotL,0.7)*0.5+0.5),1,_gloss);
                half3 IBL = ImageBasedLighting(gloss,viewReflectDirection);
                      IBL *= _ReflectionIntensity * sh;
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);


//                half _rotator_ang = 1.5708;
//                half _rotator_ang = 1.5708;
//                half _rotator_spd = 1.0;
//                half _rotator_cos = cos(_rotator_spd*_rotator_ang);
//                half _rotator_sin = sin(_rotator_spd*_rotator_ang);
//                half2 _rotator_piv = float2(0.5,0.5);
//                half2 _rotator = (mul(float2(NdotA,0)-_rotator_piv,float2x2( _rotator_cos, -_rotator_sin, _rotator_sin, _rotator_cos))+_rotator_piv);

                fixed3 baseRGBA = _BaseRGBA_var.rgb * nohair;
                fixed3 specularColor = max(_hairspcolor,0.25) * _MatMask_var.r;
                half dsmask = SpecAniso2(max(0,dot(i.normalDir,ahalfvec)), _AnisoOffset2, _Glossiness, 8, (aspc1+CCsatfix)*0.25);
                half3 directSpecular = SpecAniso2(NdotA, _AnisoOffset2, _Glossiness, 128, (aspc1+CCsatfix));
                      directSpecular += SpecAniso2(NdotA, _AnisoOffset, _Glossiness2, 128, aspc2);
                      directSpecular += dsmask*2*(1-directSpecular+CCsatfix);
                      directSpecular *= specularColor * attenColor * i.pl * (NdotA * 0.6 + 0.4);
                      directSpecular *= lerp(1,0.35,CCvalue);
//                      directSpecular += SpecularGGX(3.1415926535897, gloss, 1, Ndoth, NdotV, NdotL) * nohair * spcolor.rgb;
                half3 specular = directSpecular * _SpecularInt;
/////// Diffuse:                       
                half3 diffuse = CalculateHairDiffuse(NdotL,Ndotl,_NdotL,Ndotv,_HairColorCustom.rgb,attenColor,_haircolor,_MatMask_var.r,CCparam.y,CCvalue);
                      diffuse += Scattering(Ndotv, contraction, feedback,_MatMask_var.r) * IBL;
                      diffuse += ((NdotL*0.7+Ndotl*0.2) + sh) * baseRGBA;

/// Final Color:
                half3 finalColor = diffuse + specular + _Rim;
                      finalColor = saturate(finalColor);
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }

        Pass {
            Name "FORWARDHAIRBack"
            Tags {
                "LightMode"="ForwardBase"
            }
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert_tera_pbr
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma target 3.0
			#include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityStandardUtils.cginc"
            #include "TeraPBRLighting.cginc"

            uniform float4 _LightColor0;
            uniform sampler2D _BaseRGBA; uniform float4 _BaseRGBA_ST;
            uniform float _RimPower;
            uniform fixed4 _RimColor;
            uniform fixed4 _HairColorCustom;
            uniform fixed4 _shcolor;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform fixed _boundary;
            uniform float contraction;
            uniform float feedback;
            uniform fixed4 scattercolor;
            uniform float4 _AnisoDir;
            uniform int _Dstcull;

            uniform float4 _SunDirchar;

            uniform sampler2D _shiftmap;
            uniform float4 _shiftmap_ST;
            uniform sampler2D _tc;
            uniform fixed4 _tc_ST;

            half4 frag(V2f_TeraPBR i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap,TRANSFORM_TEX(i.uv0, _Normalmap)));
                float3 normalLocal = _Normalmap_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 tangentfixer = UnpackNormal(tex2D(_tc,TRANSFORM_TEX(i.uv0, _tc)));
                float3 tangentshifter = normalize(mul(normalLocal+tangentfixer.rgb, tangentTransform ));
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 ahalfvec = normalize(_AnisoDir.xyz + halfDirection);
                float3 SunDirection = normalize(_SunDir.xyz);
                float3 charSunDirection = normalize(_SunDirchar.xyz);
////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                fixed4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
//                clip(_BaseRGBA_var.a - 0.5);
                clip(_MatMask_var.r*min(_Dstcull+1,1)*_BaseRGBA_var.a-0.5);
////// Specular:
                float NdotL = max(0, dot(normalDirection, lightDirection));
                float _NdotL = max(0, dot( normalDirection, -lightDirection )*0.5+0.5);
                float NdotA = max(0,dot(tangentshifter,ahalfvec)); 
                half3 NdotSunchar = max(0,dot(charSunDirection,normalDirection)) * _SunColorchar.rgb * _SunColorchar.a*0;
                half3 _haircolor = ColorCstm(_BaseRGBA_var.rgb,_HairColorCustom.rgb,_MatMask_var.r);
                half3 sh = lerp(fixed3(0.5,0.5,0.5),AmbientColorGradient(normalDirection),0.5);
/////// Diffuse:                       
                half3 directDiffuse = (NdotL*0.6+0.2) * saturate(attenColor);
                half3 indirectDiffuse = _haircolor * _MatMask_var.r * (sh*(1+(1-NdotA)*_boundary));
                half3 diffuse = (directDiffuse + NdotSunchar + indirectDiffuse) * _haircolor * _haircolor;
/// Final Color:
                half3 finalColor = max(0,diffuse);
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
//        UsePass "Hidden/Character/CharacterPass/FORWARDHAIRBACK"
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
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert_tera_pbr
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
			#include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityStandardUtils.cginc"
            #include "TeraPBRLighting.cginc"

            uniform float4 _LightColor0;
            uniform sampler2D _BaseRGBA; uniform float4 _BaseRGBA_ST;
            uniform float _RimPower;
            uniform fixed4 _RimColor;
            uniform fixed4 _HairColorCustom;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform float contraction;
            uniform float feedback;
            uniform fixed4 scattercolor;
            uniform fixed _SpecularInt;
            uniform fixed _ReflectionIntensity;
            uniform float4 _AnisoDir;
            uniform float _AnisoOffset;
            uniform float _AnisoOffset2;
            uniform float _spread1;
            uniform float _spread2;
            uniform float aspc1;
            uniform float aspc2;
            uniform float _Glossiness;
            uniform float _Glossiness2;
            uniform sampler2D _tc;
            uniform fixed4 _tc_ST;

            half4 frag(V2f_TeraPBR i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDir = normalize(i.posWorld.xyz - _WorldSpaceCameraPos.xyz);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap,TRANSFORM_TEX(i.uv0, _Normalmap)));
                float3 normalLocal = _Normalmap_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 tangentfixer = UnpackNormal(tex2D(_tc,TRANSFORM_TEX(i.uv0, _tc)));
                float3 tangentshifter = normalize(mul(normalLocal+tangentfixer.rgb, tangentTransform ));
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 ahalfvec = normalize(_AnisoDir.xyz + halfDirection);
////// Lighting:
                fixed attenuation = 1;
                fixed3 attenColor = attenuation * _LightColor0.xyz;
                half3 sh = AmbientColorGradient(normalDirection);
///////// Gloss:
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                fixed4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed4 spcolor = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                half gloss = spcolor.a;
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float NdotA = max(0,dot(tangentshifter,ahalfvec));
                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL); 
                half3 CCparam = RGBtoHSV(_HairColorCustom.rgb);
                half CCsatfix = CCparam.y*0.75;
                half CCvalue = ((_HairColorCustom.r*0.299)+(_HairColorCustom.g*0.587)+(_HairColorCustom.b*0.114));
                half plmncrm = max(0,dot(i.pl,float3(0.3,0.59,0.11)));
                half3 _haircolor = ColorCstm(_BaseRGBA_var.rgb,_HairColorCustom.rgb,_MatMask_var.r);
                half3 _hairspcolor = ColorCstm(spcolor.rgb,_HairColorCustom.rgb,_MatMask_var.r);
                fixed nohair = max(0,1-_MatMask_var.r);

                half3 specularColor = max(_hairspcolor,0.25) * _MatMask_var.r;
                half3 dsmask = SpecAniso2(max(0,dot(i.normalDir,ahalfvec)), _AnisoOffset2, _Glossiness, 8, (aspc1+CCsatfix)*0.25);
                half3 directSpecular = SpecAniso2(NdotA, _AnisoOffset2, _Glossiness, 128, (aspc1+CCsatfix));
                      directSpecular += SpecAniso2(NdotA, _AnisoOffset, _Glossiness2, 128, aspc2);
                      directSpecular += dsmask*2*(1-directSpecular+CCsatfix);
                      directSpecular *= specularColor * attenColor * i.pl * (NdotA * 0.6 + 0.4);
                      directSpecular *= lerp(1,0.35,CCvalue);
                half3 specular = directSpecular * _SpecularInt;
/////// Diffuse:                       
                half3 diffuse = CalculateHairDiffuse(NdotL,Ndotl,_NdotL,Ndotv,_HairColorCustom.rgb,attenColor,_haircolor,_MatMask_var.r,CCparam.y,CCvalue);
                      diffuse += Scattering(Ndotv, contraction, feedback,_MatMask_var.r) * sh*0.25;
                      diffuse += ((NdotL*0.7+Ndotl*0.2) + sh) * _BaseRGBA_var.rgb * nohair;
/// Final Color:
                half3 finalColor = diffuse + specular;
                       finalColor = max(0,finalColor);
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        UsePass "Hidden/Character/CharacterPass/FORWARDHAIRBACK"
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
            Name "CHARACTERFORWARDHAIRBASE"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            CGPROGRAM
            #pragma vertex vert_tera_simple
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "TeraPBRLighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0

            uniform half4 _LightColor0;
            uniform sampler2D _BaseRGBA;
			uniform float4 _BaseRGBA_TexelSize;
			uniform float4 _BaseRGBA_ST;
			uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform half _RimPower;
            uniform fixed4 _RimColor;
            uniform fixed4 _HairColorCustom;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;

            half4 frag(V2f_TeraSimple i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap,TRANSFORM_TEX(i.uv0, _Normalmap)));
                float3 normalLocal = _Normalmap_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 attenColor = _LightColor0.xyz;
////// Textures:
                half4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                half4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                half3 _haircolor = ColorCstm(_BaseRGBA_var.rgb,_HairColorCustom.rgb,_MatMask_var.r);
                half3 CCparam = RGBtoHSV(_HairColorCustom.rgb);
                half CCvalue = ((_HairColorCustom.r*0.299)+(_HairColorCustom.g*0.587)+(_HairColorCustom.b*0.114));
                half3 nohair = max(0,1-_MatMask_var.r) * _BaseRGBA_var.rgb;
                half NdotL = max(0, dot( normalDirection, lightDirection ));
                half NdotV = max(0,1 - dot( normalDirection, viewDirection ));
                half _Ndotl = max(0, dot( normalDirection, -lightDirection )*0.5+0.5);
                half Ndotl = max(0,1 - NdotL);
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
/////// Diffuse:
                half3 diffuse = (NdotL * attenColor + lerp(0.6,0.3,NdotL)) * nohair;
                      diffuse += CalculateHairDiffuse(NdotL,Ndotl,_Ndotl,NdotV,_HairColorCustom.rgb,attenColor,_haircolor,_MatMask_var.r,CCparam.y,CCvalue);
/// Final Color:
                half3 finalColor = diffuse + _Rim;
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

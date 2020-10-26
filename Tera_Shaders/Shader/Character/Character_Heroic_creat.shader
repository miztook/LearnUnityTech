Shader "TERA/Character/Heroic_Create" {
    Properties {
        _BaseRGBA ("Base(RGBA)", 2D) = "white" {}
        _SkinDeGamma ("Skin Gamma Correction", float) = 0.75
        _SkinColor ("Skin Color Custom", Color) = (0,0.667,0.667,1)
        _se ("Skin Emission", Range(0,2)) = 0.3
        _Skinenv ("Skin Edge Color", Color) = (0.855,0.568,0.5255,1)
        _Normalmap ("Normalmap", 2D) = "bump" {}
        _SpecularmapRGBA ("Specularmap(RGBA)", 2D) = "white" {}
        _SpecularIntensity ("Specular Intensity", Range(0, 2)) = 1
        _ReflectionIntensity ("Reflection Intensity", Range(0, 5)) = 1
        _lf ("lf", Range(0,2)) = 1
        _MatMask ("Mat Mask(RGB)(R_Skin)(G_Reflection)(B_Flake)", 2D) = "black" {}       
        _headlight ("Head Lighting Intensity", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest-50"
            "DisableBatching"="True"
        }
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
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0

            uniform float4 _LightColor0;
            uniform sampler2D _BaseRGBA;
			uniform float4 _BaseRGBA_TexelSize;
			uniform float4 _BaseRGBA_ST;
            uniform fixed4 _SkinColor;
            uniform fixed4 _Skinems;
            uniform fixed _lf;
            uniform fixed _se;
            uniform fixed _skinpoint;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform fixed4 _SunColor;
            uniform float4 _SunDirchar;
            uniform float _SpecularIntensity;
            uniform fixed _SkinDeGamma;
            uniform fixed4 _Skinenv;
            uniform float _ReflectionIntensity;
            uniform fixed _headlight;

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
                float3 charSunDirection = normalize(_SunDirchar.xyz);
                float3 halfsunchar = normalize(viewDirection+charSunDirection);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                half attenuation = UNITY_SHADOW_ATTENUATION(i, i.posWorld);
////// Textures:
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                half4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                _headlight *= _MatMask_var.r;
                fixed equiprange = max(0,1-_MatMask_var.r);
                half3 specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
///////// Gloss:
                half glossq = _SpecularmapRGBA_var.a * equiprange;
                half glossk = _SpecularmapRGBA_var.a * _MatMask_var.r;
				half gloss = saturate(glossq+glossk);
///// SkinColor:
                half3 _skincolor = ColorCstmGamma(_BaseRGBA_var.rgb,_SkinColor.rgb,_MatMask_var.r,_SkinDeGamma);
                half3 _skinspcolor = ColorCstm(_SpecularmapRGBA_var.rgb.rgb,_SkinColor.rgb,_MatMask_var.r);
                half3 baseRGBA = _BaseRGBA_var.rgb * equiprange + _skincolor;
///// Lightness:
                half lightpower = ((lightColor.r*0.299)+(lightColor.g*0.587)+(lightColor.b*0.114));
                half emispower = clamp(lightpower,0.0,1.0);
                float NdotL = max(0, dot(normalDirection, lightDirection));
                float _NdotL = max(0, dot(normalDirection, -lightDirection));
                float Ndotv = max(0, dot(normalDirection, viewDirection));
                float Ndoth = max(0,dot(halfDirection,normalDirection));                
                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL);
                float NdotSunchar = max(0,dot(charSunDirection,normalDirection));// * NdotV);
                float HdotSunchar = max(0,dot(halfsunchar,normalDirection));
                half3 attenColor = lerp(lightColor,lightpower,_MatMask_var.r);// * (attenuation*0.4+0.6);
                half3 sh = AmbientColorGradient(normalDirection);
                half3 shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,shval,saturate(NdotL + Ndotv));
                half3 IBL = ImageBasedLighting(gloss,viewReflectDirection);
                       IBL *= _ReflectionIntensity * sh;
                fixed pie = 3.1415926535;
                half3 zis = Frsn(Ndotv,gloss,IBL,equiprange);
////// Specular:
                half spGGX = SpecularGGX(pie, gloss, _MatMask_var.r, Ndoth, NdotV, NdotL);
                half spGGXadd1 = SpecularGGX(pie, gloss, 1, HdotSunchar, NdotV, NdotSunchar);
                half spGGXadd2 = SpecularGGX(pie, gloss, 1, NdotSunchar, NdotV, NdotSunchar)*equiprange;
                half3 sPc_skin = Specularskin(gloss, Ndoth, 0, spGGX, NdotL, attenColor, Ndotv, _headlight, Ndotl, _skinspcolor, specmncrm);
                half3 specular = CalculateSpecularCreate(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,IBL,equiprange,sPc_skin,spGGXadd1);
                       specular *= i.pl * _SpecularIntensity;
/////// Diffuse:
                half NdotLq = LightingWithHeadLight(NdotL, Ndotv, _headlight) * equiprange;
                half scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);
                half3 scattering = scatter * _Skinems * 0.5;
//                half3 NdotLs = SkinLighting1(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_se,scatter,Ndoth) * _MatMask_var.r;
                half3 NdotLs = LightingforSkin(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_se,scatter) * _MatMask_var.r;
                half3 scat = lerp(fixed3(1,1,1),_Skinenv.rgb,exp2(-(Ndotv*Ndotv*8)));
                       sh *= lerp(fixed3(1,1,1),(NdotLs+scat)*0.5,_MatMask_var.r);
                half3 diffuse = CalculateDiffuseAddonCreat1(NdotLs,NdotLq,0,attenColor,sh,baseRGBA,spGGXadd2,equiprange);
//////// Emissive:
//                float3 emission = baseRGBA * _MatMask_var.a;
/// Final Color:
                half reflerp = reflp(_SpecularmapRGBA_var.rgb,pie);
                     reflerp *= equiprange;
                half3 finalColor = FinalColor(diffuse,specular,reflerp,fixed3(0,0,0),zis);
                half4 finalRGBA = half4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }

        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }
}

Shader "TERA/Character/Heroic_Face_Create" {
        Properties {
        _BaseRGBA ("Base(RGBA)", 2D) = "grey" {}
        _SkinDeGamma ("Skin Gamma Correction", float) = 0.75
        _SkinColor ("Skin Color Custom", Color) = (0,0.667,0.667,1)
        _se ("Skin Emission", Range(0,2)) = 0.3
        _Skinenv ("Skin Edge Color", Color) = (0.855,0.568,0.5255,1)
        _Eyecolor ("Eye color Custom", Color) = (0,0.667,0.667,1)
        _Normalmap ("Normalmap", 2D) = "bump" {}
        _SpecularmapRGBA ("Specularmap(RGBA)", 2D) = "white" {}
        _SpecularIntensity ("Specular Intensity", Range(0, 2)) = 1.5
        _MatMask ("Mat Mask(RGB)(R_Skin)(G_Eye)(B_null)(A_Transmision)", 2D) = "red" {}
        _headlight ("HeadLighting", Range(0,1)) = 0

//        [MaterialToggle]sw("testswitch",Float) = 0
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
            Zwrite On
            
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
            uniform fixed4 _SkinColor;
            uniform fixed4 _Eyecolor;

            uniform float _gloss;
            uniform float _lf;
            uniform fixed _se;
            uniform half _headlight;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform float4 _SunDirchar;
            uniform fixed _SpecularIntensity;
            uniform fixed _SkinAmbientBounce;
            uniform fixed _SkinDeGamma;
            uniform fixed4 _Skinenv;
            uniform int sw;
//            uniform sampler2D _tc;
//            uniform fixed4 _tc_ST;

            half4 frag(V2f_TeraPBR i) : COLOR {
/////// Texture:
                float4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                float4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                float4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
// Geometrydata:
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap, TRANSFORM_TEX(i.uv0, _Normalmap)));
//                float3 _Normalmap_var1 = UnpackNormal(tex2Dlod(_Normalmap, float4(TRANSFORM_TEX(i.uv0, _Normalmap),0,4)));
//                float3 normmpbase1 = UnpackNormal(tex2Dlod(_Normalmap, float4(TRANSFORM_TEX(i.uv0, _Normalmap),0,0)));
//                float3 normmpbase2 = UnpackNormal(tex2Dlod(_Normalmap, float4(TRANSFORM_TEX(i.uv0, _Normalmap),0,1)));
//                float3 normmpbase3 = UnpackNormal(tex2Dlod(_Normalmap, float4(TRANSFORM_TEX(i.uv0, _Normalmap),0,2)));
//                float3 normmpbase4 = UnpackNormal(tex2Dlod(_Normalmap, float4(TRANSFORM_TEX(i.uv0, _Normalmap),0,4)));
//                float3 _Normalmap_var = (normmpbase1*256);
//                       _Normalmap_var += (normmpbase2*128);
//                       _Normalmap_var += (normmpbase3*64);
//                       _Normalmap_var += (normmpbase4*32);
//                       _Normalmap_var /= 480;
                float3 normalLocal = _Normalmap_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
//                float3 tangentfixer = UnpackNormal(tex2D(_tc,TRANSFORM_TEX(i.uv0, _tc)));
//                float3 tangentshifter = normalize(mul(_Normalmap_var1, tangentTransform ));
                float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightDir = normalize(float3(_WorldSpaceLightPos0.x,0,_WorldSpaceLightPos0.z));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 charSunDirection = normalize(_SunDirchar.xyz);
                float3 halfsunchar = normalize(viewDirection+charSunDirection);
////// Lighting:

///// Lightness:
                float lightpower = ((lightColor.r*0.299)+(lightColor.g*0.587)+(lightColor.b*0.114));
                float emispower = saturate(lightpower);
                float NdotL = max(0, dot(normalDirection, lightDirection));
                float NdotLD = max(0, dot( normalDirection, lightDir ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
//                      _NdotL = smoothstep(0,1,_NdotL);
//                float _NdotL = max(0, dot( tangentshifter, -lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float NdotSunchar = max(0,dot(charSunDirection,normalDirection));
                float HdotSunchar = max(0,dot(halfsunchar,normalDirection));
                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL);
                half3 sh = AmbientColorGradient(normalDirection);
                half3 shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,shval,saturate(NdotL + Ndotv));
                half3 attenColor = lerp(lightColor,lightpower,_MatMask_var.r);// * lightColor;
///////// Gloss:
                half gloss = _SpecularmapRGBA_var.a;
                     gloss = saturate(((_SpecularmapRGBA_var.a+_gloss)/(1+_gloss)));
                fixed pie = 3.1415926535;
                fixed _lf = 1.0f;
///// SkinColor:
                half3 _skincolor = ColorCstmGamma(_BaseRGBA_var.rgb,_SkinColor.rgb,_MatMask_var.r,_SkinDeGamma);
                half3 _skinspcolor = ColorCstm(_SpecularmapRGBA_var.rgb.rgb,_SkinColor.rgb,_MatMask_var.r);
////// Specular:
                half3 specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
                half spGGX = SpecularGGX(pie, gloss, _MatMask_var.r, Ndoth, NdotV, NdotL);
//                half spGGXadd1 = SpecularGGX(pie, gloss, 1, HdotSunchar, NdotV, NdotSunchar);
                half spGGXadd2 = SpecularGGX(pie, gloss, 1, NdotSunchar, NdotV, NdotSunchar)*(1-_MatMask_var);
                half3 specColor = Specularskin(gloss, Ndoth, 0, spGGX, NdotL, attenColor, Ndotv, _headlight, Ndotl, _skinspcolor, specmncrm);
                half3 directSpecular = attenColor * specColor;
                half3 specular = directSpecular * _SpecularIntensity * i.pl;

/////// Diffuse:
                half scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);                       
//                half3 NdotLs = SkinLighting1(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_se,scatter,Ndoth) * _MatMask_var.r;
                half3 NdotLs = LightingforSkin(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_se,scatter) * _MatMask_var.r;
                half3 scat = lerp(fixed3(1,1,1),_SpecularmapRGBA_var.rgb,exp2(-(Ndotv*Ndotv*8)));
                       sh *= lerp(fixed3(1,1,1),(NdotLs+scat)*0.5,_MatMask_var.r);
                half3 diffuse = CalculateDiffuseAddonCreat1(NdotLs,0,0,attenColor,sh,_skincolor,spGGXadd2,0);
///// Eye Color:
                half3 _EyeColor = ColorCstm(_BaseRGBA_var.rgb,_Eyecolor.rgb,_MatMask_var.g);
                half3 eye = Eye(_EyeColor,_MatMask_var,emispower,NdotLD,Ndotv,sh);
/// Final Color:
                half3 finalColor = diffuse + specular;
                      finalColor *= _MatMask_var.r;
                      finalColor += eye;
                      finalColor = max(0,finalColor);
                half4 finalRGBA = half4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }
}


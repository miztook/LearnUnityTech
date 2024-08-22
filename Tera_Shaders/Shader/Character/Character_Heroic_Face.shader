Shader "TERA/Character/Heroic_Face" {
        Properties {
        _BaseRGBA ("Base(RGBA)", 2D) = "grey" {}
        _SkinDeGamma ("Skin Gamma Correction", float) = 0.75
        _SkinColor ("Skin Color Custom", Color) = (0,0.667,0.667,1)
        _se ("Skin Emission", Range(0,2)) = 0.3
        _Skinenv ("Skin Edge Color", Color) = (0.855,0.568,0.5255,1)
        _Eyecolor ("Eye color Custom", Color) = (0,0.667,0.667,1)
        _Normalmap ("Normalmap", 2D) = "bump" {}
        _Normalscale ("Normalscale", Range(1,5)) = 1
        _SpecularmapRGBA ("Specularmap(RGBA)", 2D) = "white" {}
        _SpecularIntensity ("Specular Intensity", Range(0, 2)) = 1.5
        _MatMask ("Mat Mask(RGB)(R_Skin)(G_Eye)(B_null)(A_Transmision)", 2D) = "red" {}
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
        LOD 400
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
//	        #include "3rd/UniqueShadows/Features/UniqueShadow/UniqueShadow_ShadowSample.cginc"
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
            uniform fixed _RimPower;
            uniform fixed4 _RimColor;
            uniform fixed4 _SkinColor;
            uniform fixed4 _Eyecolor;
            uniform fixed _se;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform fixed _SpecularIntensity;
            uniform fixed _SkinDeGamma;
            uniform fixed4 _Skinenv;

            half4 frag(V2f_TeraPBR i) : COLOR {
/////// Texture:
                float4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                float4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                float4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed noskin = saturate(_MatMask_var.g*10)+_MatMask_var.r;
// Geometrydata:
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 viewDir = normalize(float3(viewDirection.x,0,viewDirection.z));
                float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap, TRANSFORM_TEX(i.uv0, _Normalmap)));
                float3 normalLocal = _Normalmap_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightDir = normalize(float3(_WorldSpaceLightPos0.x,0,_WorldSpaceLightPos0.z));
                fixed3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 halfDir = normalize(viewDirection+lightDir);
                float3 charSunDirection = normalize(_SunDirchar1.xyz);
                float3 halfsunchar = normalize(viewDirection+charSunDirection);

////// Lighting:
//                float attenuation = LIGHT_ATTENUATION(i);
//                half attenuation = 1;
///// Lightness:
                float lightpower = ((lightColor.r*0.299)+(lightColor.g*0.587)+(lightColor.b*0.114));
                float emispower = saturate(lightpower);
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float Ndoti = max(0, dot( i.normalDir, lightDirection ));
                float NdotLD = max(0, dot( normalDirection, lightDir ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
//                float Ndotah = max(0,dot(ahalfDirection,normalDirection));
                float Ndothd = dot(normalDirection,halfDir);
                float NdotV = 1 - Ndotv;
                float Ndotl = 1 - NdotL;
                float NdotSunchar = max(0,dot(charSunDirection,normalDirection)*NdotV);
                half3 sh = AmbientColorGradient(normalDirection);
                half shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,shval,NdotL);
                half3 attenColor = lightColor;
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
///////// Gloss:
                half gloss = _SpecularmapRGBA_var.a;
                fixed pie = 3.1415926535;
                fixed pie2 = pie/2;
///// SkinColor:
                half3 _skincolor = ColorCstmGamma(_BaseRGBA_var.rgb,_SkinColor.rgb,_MatMask_var.r,_SkinDeGamma);
                half3 _skinspcolor = ColorCstm(_SpecularmapRGBA_var.rgb,_SkinColor.rgb,_MatMask_var.r) + (_SpecularmapRGBA_var.rgb*saturate(_MatMask_var.g*10));
////// Specular:
                half3 specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
                half spGGX = SpecularGGX(pie, gloss, _MatMask_var.r, max(Ndothd,Ndoth), NdotV, NdotL);
                half3 specColor = Specularskin(gloss, max(Ndothd,Ndoth), 0, spGGX, NdotL, attenColor, Ndotv, 1, Ndotl, _skinspcolor, specmncrm);
                half3 directSpecular = attenColor * specColor;
                half3 specular = directSpecular * _SpecularIntensity * i.pl;
/////// Diffuse:

                half scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);
                half3 NdotLs = SkinLighting1(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_se,scatter,Ndoth,lightColor) * _MatMask_var.r;
                half3 diffuse = CalculateDiffuseAddonf(NdotLs,0,0,attenColor,sh,_skincolor,NdotSunchar,_MatMask_var.r);
///// Eye Color:
                half3 _EyeColor = ColorCstm(_BaseRGBA_var.rgb,_Eyecolor.rgb,_MatMask_var.g);
                half3 eye = Eye(_EyeColor,_MatMask_var,emispower,NdotLD,Ndotv,sh);
/// Final Color:
                half3 finalColor = diffuse;
                      finalColor *= _MatMask_var.r;
                      finalColor += specular;
                      finalColor += eye + _Rim;
                      finalColor = max(0,finalColor);
                fixed4 finalRGBA = half4(finalColor,1);
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

        UsePass "Hidden/Character/CharacterPass/CHARACTERFORWARDBASEFACE"
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }
    //FallBack "Diffuse"
}

Shader "TERA/Character/Character_Heroic2" {
    Properties {
        _BaseRGBA ("Base(RGBA)", 2D) = "white" {}
        _SkinColor ("Skin Color Custom", Color) = (0,0.667,0.667,1)
        _Skinems ("Skin Ambient Bounce", Color) = (1,1,1,1)
        _SkinDirpow ("Skin Bounce", Range(0, 1)) = 0.3
        _se ("Skin Emission", Range(0,2)) = 0.3
        _Skinenv ("Skin Edge Color", Color) = (0.855,0.568,0.5255,1)
        _Normalmap ("Normalmap", 2D) = "bump" {}
        _SpecularmapRGBA ("Specularmap(RGBA)", 2D) = "white" {}
        _SpecularIntensity ("Specular Intensity", Range(0, 2)) = 1
        _gloss("Gloss Correction",Range(0,5)) = 0
        _ReflectionIntensity ("Reflection Intensity", Range(0, 5)) = 1
        _lf ("lf", Range(0,2)) = 1
        _MatMask ("Mat Mask(RGB)(R_Skin)(G_Reflection)(B_Flake)", 2D) = "black" {}
        _Brdfmap ("Brdfmap", 2D) = "white" {}
        _brdfrange("Brdfmap Effective Range", Range(0,1)) = 0
        _skinpoint("Skin PointLight Intensity", Range(0,1)) = 1
        _OriginOffset ("Origin Position Offset", Vector) = (0, 0.125, 0)
        _TransmissionColor ("TransmissionColor ", Color) = (0.25,0,0,1)
		_TransmissionPointPower("TransmissionPointPower", Range(0, 1)) = 0.25
		_TransmissionRange("TransmissionRange", Range(-1, 1)) = 0
        Notouch("Rim&DeathEffect", Range(0,1)) = 0
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0, 5)) = 0
        [Header(RimEffect)]
        [MaterialToggle] shs ("Shadowswitcher",float) = 0
    }
    SubShader {
        
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest-50"
            "DisableBatching"="True"
        }
        LOD 600
        Pass {
            Name "CHARACTERFORWARDPBR"
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
            uniform sampler2D _BaseRGBA;
			uniform float4 _BaseRGBA_TexelSize;
			uniform float4 _BaseRGBA_ST;
            uniform float _RimPower;
            uniform fixed4 _RimColor;
            uniform fixed4 _SkinColor;
            uniform fixed4 _Skinems;
            uniform fixed _lf;
            uniform fixed _se;
            uniform fixed _skinpoint;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform sampler2D _Brdfmap; uniform float4 _Brdfmap_ST;
            uniform float _SpecularIntensity;
            uniform float _SkinDirpow;
            uniform float _gloss;
            uniform float _brdfrange;
            uniform float _ReflectionIntensity;
            uniform fixed4 _Skinenv;
            uniform int shs;

            uniform fixed4 _TransmissionColor;
			uniform fixed4 _TransmissionRangeAdj;
			uniform fixed _TransmissionPointPower;
			uniform fixed _TransmissionRange;

            half4 frag(V2f_TeraPBR i) : COLOR {
// GeometryData:
				i.normalDir = normalize(i.normalDir);
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap, TRANSFORM_TEX(i.uv0, _Normalmap)));
				float3 normalLocal = _Normalmap_var.rgb;
				float3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals
//				float3 blurrednormal = lerp(normalDirection,i.originNormal,0.5);//*i.vcolor.a);
				float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 ahalfDirection = normalize(viewDirection-lightDirection);
                float3 lightDir = normalize(float3(_WorldSpaceLightPos0.x,0,_WorldSpaceLightPos0.z));
                float3 halfDir = normalize(viewDirection+lightDir);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = 1;
////// Textures:
                float4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                float4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                half4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed equiprange = max(0,1-_MatMask_var.r);
                float3 specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
                
                float3 attenColor = lerp(attenuation,1,_MatMask_var.r) * lightColor;
///////// Gloss:
                float glossq = min(1,((_SpecularmapRGBA_var.a+_gloss)/(1+_gloss))) * equiprange;
                float glossk = _SpecularmapRGBA_var.a * _MatMask_var.r;
				float gloss = saturate(glossq+glossk);
///// SkinColor:
                float3 _skincolor = ColorCstm(_BaseRGBA_var.rgb,_SkinColor.rgb,_MatMask_var.r);
                float3 _skinspcolor = ColorCstm(_SpecularmapRGBA_var.rgb.rgb,_SkinColor.rgb,_MatMask_var.r);
                float3 baseRGBA = _BaseRGBA_var.rgb * equiprange;
                       baseRGBA += _skincolor;
///// Lightness:
                float lightpower = ((lightColor.r*0.299)+(lightColor.g*0.587)+(lightColor.b*0.114));
                float emispower = clamp(lightpower,0.0,1.0);
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float NdotLD = max(0, dot( normalDirection, lightDir ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float Ndotah = max(0,dot(ahalfDirection,normalDirection));
                float mrref = max(0,dot(reflect(-lightDirection,normalDirection),viewDirection));
                float LdotH = max(0.0,dot(lightDirection, halfDirection));
                float Ndothd = dot(normalDirection,halfDir);
                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL);
                float _Ndotl = max(0,1 - _NdotL);
                float3 sh = AmbientColorGradient(normalDirection);
                half shval = dot(sh,float3(0.3,0.59,0.11));
                       sh = lerp(sh,dot(sh,float3(0.3,0.59,0.11)),NdotL);
                float3 IBL = ImageBasedLighting(gloss,viewReflectDirection);
                       IBL *= _ReflectionIntensity * sh;
                fixed pie = 3.1415926535;
                float3 zis = Frsn(Ndotv,gloss,IBL,equiprange);
                float3 _Rim = Rim(NdotV,_RimPower,_RimColor);
////// Specular:
                float spGGX = SpecularGGXWithHeadLight(pie, gloss, _MatMask_var.r, max(Ndothd,Ndoth), Ndotv, NdotV, NdotL,_NdotL);
                float3 sPc_skin = Specularskin(gloss, max(Ndothd,Ndoth), _lf, spGGX, NdotL, attenColor, Ndotv, _MatMask_var.r, Ndotl, _skinspcolor, specmncrm);
                float3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,IBL,equiprange,sPc_skin,0);
                specular *= i.pl * _SpecularIntensity;
/////// Diffuse:
                float NdotLq = NdotL * 0.8 * equiprange;
                       NdotL = max(-_brdfrange, NdotL);
                float3 NdotLs = LightingbyBRDFmap(_Brdfmap, NdotL, Ndotv, Ndotl, _brdfrange, 0.5, 1, _SkinDirpow) * _MatMask_var.r;
//                       NdotLs = SkinLighting(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_se,scatter);
                float T = Transmission(Ndotv,_TransmissionRange);
                float scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);
                float3 scattering = scatter * _Skinems * 0.5;
                float3 sssadd = _MatMask_var.b * (T*_MatMask_var.r+Ndotl) * _TransmissionColor.rgb*0.5;
                float3 diffuse = CalculateDiffuse(NdotLs,NdotLq,scattering,attenColor,sh,baseRGBA) * lerp(i.pl,1,_skinpoint);
                diffuse = lerp(diffuse,_skincolor*(1+_se*NdotL),NdotL*_MatMask_var.r);
                diffuse += sssadd;
//////// Emissive:
//                float3 emission = baseRGBA * _MatMask_var.a;
/// Final Color:
                float reflerp = reflp(_SpecularmapRGBA_var.rgb,pie);
                reflerp *= equiprange;
                half3 finalColor = FinalColor(diffuse,specular,reflerp,_Rim,zis);

                      finalColor = saturate((NdotL*0.5+0.5)*(1-_NdotL));
//                      finalColor = Ndotl*NdotV;
                      half wraping = Ndotl*NdotV;

//                      half3 wrapcol = lerp(fixed3(1,1,1),_Skinenv.rgb,NdotV);
//                      half3 wrap = lerp(fixed3(1,1,1),wrapcol,NdotL);
                      half3 wrapcol = lerp(fixed3(1,1,1),_Skinenv.rgb,wraping);
             half3 wrap = saturate(lerp(fixed3(1,1,1),wrapcol,_NdotL));
             half3 vrapcol = lerp(fixed3(1,1,1),_Skinenv.rgb,NdotV);
             half3 vrap = lerp(fixed3(1,1,1),vrapcol,NdotL);
                   wrap *= vrap;
                      finalColor = vrap;
//                      finalColor = SkinLighting(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_se,scatter);
//                      finalColor = pow(finalColor,2.02);
//                      finalColor = NdotL;
//                      finalColor = lerp(NdotL,finalColor,shs);


                half4 finalRGBA = half4(max(0.001,finalColor),1);
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

        UsePass "Hidden/Character/CharacterPass/CHARACTERFORWARDGGX"
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }

    SubShader {
        
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest-50"
            "DisableBatching"="True"
             }
        LOD 200

        UsePass "Hidden/Character/CharacterPass/CHARACTERFORWARDBASE"
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }
    //FallBack "Diffuse"
}
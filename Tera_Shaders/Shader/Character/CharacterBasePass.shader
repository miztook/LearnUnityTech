Shader "Hidden/Character/CharacterPass"
{
	Properties
	{
		
	}
	SubShader
	{
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest-50"
            "DisableBatching"="True"
        }

        Pass {
            Name "CHARACTERFORWARDGGX"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            CGPROGRAM
            #pragma vertex vert_tera_pbrsimple
            #pragma fragment frag1
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
            uniform fixed4 _Skinems;
            uniform fixed _lf;
            uniform fixed _se;
            uniform fixed _skinpoint;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform fixed _ReflectionIntensity;
            uniform fixed _SpecularIntensity;
            uniform fixed4 _Skinenv;
            uniform fixed _SkinDeGamma;
            uniform fixed _gloss;

            half4 frag1(V2f_TeraPBRSimple i) : COLOR {
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
                float3 lightDir = normalize(float3(_WorldSpaceLightPos0.x,0,_WorldSpaceLightPos0.z));
                float3 charSunDirection = normalize(_SunDirchar1.xyz);
                float3 halfDir = normalize(viewDirection+lightDir);
                float3 lightColor = _LightColor0.rgb;
////// Textures:
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                fixed4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed equiprange = max(0,1-_MatMask_var.r);
                half specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
                fixed3 attenColor = lightColor;
///////// Gloss:
                half glossq = min(1,((_SpecularmapRGBA_var.a+_gloss)/(1+_gloss))) * equiprange;
                half glossk = _SpecularmapRGBA_var.a * _MatMask_var.r;
				half gloss = saturate(glossq+glossk);
///// SkinColor:
                half3 _skincolor = ColorCstmGamma(_BaseRGBA_var.rgb,_SkinColor.rgb,_MatMask_var.r,_SkinDeGamma);
                half3 _skinspcolor = ColorCstm(_SpecularmapRGBA_var.rgb.rgb,_SkinColor.rgb,_MatMask_var.r);
                half3 baseRGBA = _BaseRGBA_var.rgb * equiprange;
                      baseRGBA += _skincolor;
///// Lightness:
                half lightpower = ((lightColor.r*0.299)+(lightColor.g*0.587)+(lightColor.b*0.114));
                half emispower = clamp(lightpower,0.0,1.0);
                half NdotL = max(0, dot( normalDirection, lightDirection ));
                half _NdotL = max(0, dot( normalDirection, -lightDirection ));
                half Ndotv = max(0, dot( normalDirection, viewDirection ));
                half Ndoth = max(0,dot(halfDirection,normalDirection));
                half Ndothd = dot(normalDirection,halfDir);
                half NdotV = max(0,1 - Ndotv);
                half Ndotl = max(0,1 - NdotL);
                half NdotSunchar = max(0,dot(charSunDirection,normalDirection) * NdotV);
                half3 sh = AmbientColorGradient(normalDirection);
                half shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,fixed3(shval,shval,shval),NdotL);
                fixed pie = 3.1415926535;
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
////// Specular:
                half spGGX = SpecularGGX(pie, gloss, _MatMask_var.r, max(Ndothd,Ndoth), NdotV, NdotL);
                half3 sPc_skin = Specularskin(gloss, max(Ndothd,Ndoth), _lf, spGGX, NdotL, attenColor, Ndotv, _MatMask_var.r, Ndotl, _skinspcolor, specmncrm);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,0,equiprange,sPc_skin,0);
                      specular *= _SpecularIntensity;
/////// Diffuse:
                half NdotLq = NdotL * 0.8 * equiprange;
                half3 scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);
                half3 NdotLs = SkinLighting1(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_se,scatter,Ndoth,lightColor) * _MatMask_var.r;
                half3 diffuse = CalculateDiffuseAddonf(NdotLs,NdotLq,0,attenColor,sh,baseRGBA,NdotSunchar,_MatMask_var.r);
//////// Emissive:
//                float3 emission = baseRGBA * _MatMask_var.a;
/// Final Color:
                half3 finalColor = diffuse + specular + _Rim;
                half4 finalRGBA = half4(max(0,finalColor),1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }

        Pass {
            Name "CHARACTERFORWARDGGXRAINBOW"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            CGPROGRAM
            #pragma vertex vert_tera_pbrsimple
            #pragma fragment frag1
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
            uniform fixed4 _Skinems;
            uniform fixed _lf;
            uniform fixed _se;
            uniform fixed _skinpoint;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform fixed _ReflectionIntensity;
            uniform fixed _SpecularIntensity;
            uniform fixed4 _Skinenv;
            uniform fixed _SkinDeGamma;
            uniform fixed _gloss;

            half4 frag1(V2f_TeraPBRSimple i) : COLOR {
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
                float3 lightDir = normalize(float3(_WorldSpaceLightPos0.x,0,_WorldSpaceLightPos0.z));
                float3 charSunDirection = normalize(_SunDirchar1.xyz);
                float3 halfDir = normalize(viewDirection+lightDir);
                float3 lightColor = _LightColor0.rgb;
////// Textures:
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                fixed4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed equiprange = max(0,1-_MatMask_var.r);
                half specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
                fixed3 attenColor = lightColor;
///////// Gloss:
                half glossq = min(1,((_SpecularmapRGBA_var.a+_gloss)/(1+_gloss))) * equiprange;
                half glossk = _SpecularmapRGBA_var.a * _MatMask_var.r;
				half gloss = saturate(glossq+glossk);
///// SkinColor:
                half3 _skincolor = ColorCstmGamma(_BaseRGBA_var.rgb,_SkinColor.rgb,_MatMask_var.r,_SkinDeGamma);
                half3 _skinspcolor = ColorCstm(_SpecularmapRGBA_var.rgb.rgb,_SkinColor.rgb,_MatMask_var.r);
                half3 baseRGBA = _BaseRGBA_var.rgb * equiprange;
                      baseRGBA += _skincolor;
///// Lightness:
                half lightpower = ((lightColor.r*0.299)+(lightColor.g*0.587)+(lightColor.b*0.114));
                half emispower = clamp(lightpower,0.0,1.0);
                half NdotL = max(0, dot( normalDirection, lightDirection ));
                half _NdotL = max(0, dot( normalDirection, -lightDirection ));
                half Ndotv = max(0, dot( normalDirection, viewDirection ));
                half Ndoth = max(0,dot(halfDirection,normalDirection));
                half Ndothd = dot(normalDirection,halfDir);
                half NdotV = max(0,1 - Ndotv);
                half Ndotl = max(0,1 - NdotL);
                half NdotSunchar = max(0,dot(charSunDirection,normalDirection) * NdotV);
                half3 sh = AmbientColorGradient(normalDirection);
                half shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,fixed3(shval,shval,shval),NdotL);
                fixed pie = 3.1415926535;
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
                half3 _rainbow = RainbowColorGrdt(_Time);
////// Specular:
                half spGGX = SpecularGGX(pie, gloss, _MatMask_var.r, max(Ndothd,Ndoth), NdotV, NdotL);
                     _SpecularmapRGBA_var.rgb = lerp(_SpecularmapRGBA_var.rgb,_rainbow,_MatMask_var.b);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,0,1,0,0);
                      specular *= _SpecularIntensity;
/////// Diffuse:
                half NdotLq = NdotL * 0.8;
                      _BaseRGBA_var.rgb = lerp(_BaseRGBA_var.rgb,_rainbow,_MatMask_var.b);
                half3 scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);
                half3 NdotLs = SkinLighting1(NdotL,_NdotL,shval,_Skinenv.rgb,Ndotl,NdotV,_se,scatter,Ndoth,lightColor) * _MatMask_var.r;
                     
                half3 diffuse = CalculateDiffuseAddonf(NdotLs,NdotLq,0,attenColor,sh,baseRGBA,NdotSunchar,_MatMask_var.r);
//////// Emissive:
//                float3 emission = baseRGBA * _MatMask_var.a;
/// Final Color:
                half3 finalColor = diffuse + specular + _Rim;
//                finalColor = NdotLs;
                half4 finalRGBA = half4(max(0,finalColor),1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }

        Pass {
            Name "CHARACTERFORWARDBASERAINBOW"
            Tags {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert_tera_simple
            #pragma fragment frag2
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
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform fixed4 _Skinenv;
            uniform fixed _SkinDeGamma;

            half4 frag2(V2f_TeraSimple i) : COLOR {
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
                half3 _rainbow = RainbowColorGrdt(_Time);
                fixed4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed equiprange = max(0,1-_MatMask_var.r);
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                fixed3 _skincolor = ColorCstmGamma(_BaseRGBA_var.rgb,_SkinColor.rgb,_MatMask_var.r,_SkinDeGamma);
                       _BaseRGBA_var.rgb = lerp(_BaseRGBA_var.rgb,_rainbow,_MatMask_var.b);
                
//                clip(_BaseRGBA_var.a - 0.5);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                half gloss = _SpecularmapRGBA_var.a;
///// Lightness:
                half NdotL = max(0, dot( normalDirection, lightDirection ));
                half NdotV = max(0,1 - dot( normalDirection, viewDirection ));
                half _NdotL = max(0, dot( normalDirection, -lightDirection ));
                half Ndoth = max(0,dot(halfDirection,normalDirection));
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
                half3 sh = AmbientColorGradient(normalDirection);
                half shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,fixed3(shval,shval,shval),NdotL);
////// Specular:
                half spGGX = SpecularGGX(3.1415926, gloss, _MatMask_var.r, Ndoth, NdotV, NdotL);
                     _SpecularmapRGBA_var.rgb = lerp(_SpecularmapRGBA_var.rgb,_rainbow,_MatMask_var.b);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,0,1,0,0);
//                      specular *= _SpecularIntensity;
/////// Diffuse:
                half3 diffuse = (NdotL * attenColor + 0.7 * sh) * _BaseRGBA_var.rgb * equiprange;
                      diffuse += SkinLightingSimple(NdotL,_NdotL,shval,_Skinenv.rgb,_LightColor0.rgb)*_skincolor;
/// Final Color:
                half3 finalColor = diffuse + specular + _Rim;
                      finalColor = max(0,finalColor);
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
                }
            ENDCG
        }

        Pass {
            Name "FORWARDHAIRBACK"
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

            uniform fixed4 _LightColor0;
            uniform sampler2D _BaseRGBA; uniform float4 _BaseRGBA_ST;
            uniform fixed _RimPower;
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
                fixed attenuation = 1;
                fixed3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                fixed4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
//                clip(_BaseRGBA_var.a - 0.5);
                clip(_MatMask_var.r*min(_Dstcull+1,1)-0.5);
////// Specular:
                half NdotL = max(0, dot(normalDirection, lightDirection));
                half _NdotL = max(0, dot( normalDirection, -lightDirection )*0.5+0.5);
                half NdotA = max(0,dot(tangentshifter,ahalfvec)); 
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

        Pass {
            Name "CHARACTERFORWARDBASE"
            Tags {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert_tera_simple
            #pragma fragment frag2
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
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform fixed4 _Skinenv;
            uniform fixed _SkinDeGamma;

            half4 frag2(V2f_TeraSimple i) : COLOR {
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
                fixed4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed equiprange = max(0,1-_MatMask_var.r);
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                fixed3 _skincolor = ColorCstmGamma(_BaseRGBA_var.rgb,_SkinColor.rgb,_MatMask_var.r,_SkinDeGamma);
                clip(_BaseRGBA_var.a - 0.5);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                half gloss = _SpecularmapRGBA_var.a;
////// Specular:
                half NdotL = max(0, dot( normalDirection, lightDirection ));
				NdotL = lerp(NdotL*0.5 + 0.5, NdotL,equiprange);
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
                half3 diffuse = (NdotL * attenColor + 0.7 * sh) * _BaseRGBA_var.rgb * equiprange;
                      diffuse += SkinLightingSimple(NdotL,_NdotL,shval,_Skinenv.rgb,_LightColor0.rgb)*_skincolor;
/// Final Color:
                half3 finalColor = diffuse + specular + _Rim;
                       finalColor = max(0,finalColor);
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }

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
                fixed3 _skincolor = ColorCstmGamma(_BaseRGBA_var.rgb,_SkinColor.rgb,_MatMask_var.r,_SkinDeGamma);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                half gloss = _SpecularmapRGBA_var.a;
////// Specular:
                half NdotL = max(0, dot( normalDirection, lightDirection ));
                     NdotL = lerp(NdotL*0.5+0.5,NdotL,equiprange);
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
                half3 diffuse = (NdotL * attenColor + 0.7 * sh) * _BaseRGBA_var.rgb * _flake1 * _flake2 * equiprange;
                      diffuse += SkinLightingSimple(NdotL,_NdotL,shval,_Skinenv.rgb,_LightColor0.rgb)*_skincolor;
/// Final Color:
                half3 finalColor = diffuse + specular + _Rim;
                       finalColor = max(0,finalColor);
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }

        Pass {
            Name "CHARACTERFORWARDBASEFACE"
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
            uniform fixed4 _Skinenv;
            uniform fixed _SkinDeGamma;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;

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
                float4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                half4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed eyerange = saturate(_MatMask_var.g*10);
                fixed3 baseRGBA = _BaseRGBA_var.rgb * max(0,1-_MatMask_var.r);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                half gloss = _SpecularmapRGBA_var.a;
                fixed3 _skincolor = ColorCstmGamma(_BaseRGBA_var.rgb,_SkinColor.rgb,_MatMask_var.r,_SkinDeGamma);
                half NdotL = max(0, dot( normalDirection, lightDirection ));
                     NdotL = lerp(NdotL*0.5+0.5,1,eyerange);
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
                half3 diffuse = (NdotL * attenColor + 0.7 * sh) * baseRGBA;
                      diffuse += SkinLightingSimple(NdotL,_NdotL,shval,_Skinenv.rgb,_LightColor0.rgb)*_skincolor;
/// Final Color:
                half3 finalColor = diffuse + specular + _Rim;
                      finalColor = max(0,finalColor);
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }

        Pass {
            Name "CHARACTERNOLIGHTBASE"
            Tags {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert_tera_simple
            #pragma fragment frag5
            #define UNITY_PASS_FORWARDBASE
            #include "TeraPBRLighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0

            uniform sampler2D _BaseRGBA;
			uniform float4 _BaseRGBA_TexelSize;
			uniform float4 _BaseRGBA_ST;
            uniform fixed _RimPower;
            uniform fixed4 _RimColor;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;

            half4 frag5(V2f_TeraSimple i) : COLOR {
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
                half NdotV = max(0,1 - dot( i.normalDir, viewDirection ));
                half Ndoth = max(0,dot(halfDirection,normalDirection));
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
//                half3 SP = pow(_SpecularmapRGBA_var.a,8) * _SpecularmapRGBA_var.rgb;
                half3 SP = pow(Ndoth,_SpecularmapRGBA_var.a*64) * _SpecularmapRGBA_var.rgb;
/// Final Color:
                half3 finalColor = _BaseRGBA_var.rgb + SP + _Rim;
                       finalColor = max(0,finalColor);
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }

        Pass
        {
            Name "CHARACTERSHADOWCASTER"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform sampler2D _BaseRGBA; uniform float4 _BaseRGBA_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            half4 frag(VertexOutput i) : COLOR {
                fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }

        Pass
		{
			Name "CHARACTEROUTLINE"

			Cull Front
			CGPROGRAM
			#pragma vertex vert_outline
			#pragma fragment fragoutl
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			uniform sampler2D _BaseRGBA;
			uniform fixed4 _BaseRGBA_ST;

			struct appdata_outline
			{
				float4 vertex : POSITION;
				float4 normal: NORMAL;
				float2 texcoord0 : TEXCOORD0;
			};

			struct v2f_outline
			{
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				//float4 expand : TEXCOORD1;
			};

//			float _Width;
			fixed4 _OutlineColor = fixed4(1,0,0,1);

			
			v2f_outline vert_outline (appdata_outline v)
			{
				v2f_outline o = (v2f_outline)0;
				o.uv0 = v.texcoord0;
//
//				if (_Width == 0)
//					_Width = 2;

				float3 cameraForwardWorld = mul((float3x3)unity_CameraToWorld, float3(0, 0, 1));
				float3 cameraForwardObject = mul((float3x3)unity_WorldToObject, cameraForwardWorld);

				float3 tangent = cross(cameraForwardObject, v.normal);
				float3 projectedNormal = cross(cameraForwardObject, tangent);

				projectedNormal = normalize(-projectedNormal) * 5 * length(mul(unity_ObjectToWorld, v.vertex) - _WorldSpaceCameraPos) / max(_ScreenParams.x, _ScreenParams.y);

				//o.expand = float4(projectedNormal, 0);
				//v.vertex += o.expand;

				o.vertex = UnityObjectToClipPos(v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 fragoutl (v2f_outline i) : SV_Target
			{
				fixed4 col = fixed4(1,0,0,1);
				fixed4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}


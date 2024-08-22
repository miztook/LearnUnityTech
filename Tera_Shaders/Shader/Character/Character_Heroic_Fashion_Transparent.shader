Shader "TERA/Character/Heroic_Fashion_Transparent" {
    Properties {
        _BaseRGBA ("Base(RGBA)", 2D) = "white" {}
        _Normalmap ("Normalmap", 2D) = "bump" {}
        _SpecularmapRGBA ("Specularmap(RGBA)", 2D) = "white" {}
        _SpecularIntensity ("Specular Intensity", Range(0, 2)) = 1
        _gloss("Gloss Correction",Range(0,5)) = 0
        _ReflectionIntensity ("Reflection Intensity", Range(0, 5)) = 1
        _lf ("lf", Range(0,2)) = 1
        _MatMask ("Mat Mask(RGB)(R_Skin)(G_Reflection)(B_Flake)", 2D) = "black" {}
        _skinpoint("Skin PointLight Intensity", Range(0,1)) = 1
        [Header(RimEffect)]
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0, 5)) = 0
        [Header(FlakeColor)]
        _FlakeColor1 ("Flake Color 1", Color) = (1,1,1,1)
        _FlakeColor2 ("Flake Color 2", Color) = (1,1,1,1)
		// Addition
//		_AdditionTex("Addition Diffuse Tex", 2D) = "white" {}
//		_AdditionNormal("Addition Normal Tex", 2D) = "white" {}
//		_AdditionSpecular("Addition Specular Tex", 2D) = "white" {}
//		_AdditionOffset("Addition Tex Offset", Vector) = (0, 0, 1, 1)
    }
    SubShader {
        Tags {
            "IgnorProjector"="True"
//            "Queue"="AlphaTest-45"
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "DisableBatching"="True"
        }
        LOD 600
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            ZWrite On
            ZTest LEqual
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha
            
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

            uniform fixed4 _LightColor0;
            uniform sampler2D _BaseRGBA;
			uniform float4 _BaseRGBA_TexelSize;
			uniform float4 _BaseRGBA_ST;
            uniform float _RimPower;
            uniform fixed4 _RimColor;
            uniform fixed _lf;
//            uniform fixed _skinpoint;
            uniform fixed4 _FlakeColor1;
            uniform fixed4 _FlakeColor2;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform half _SpecularIntensity;
            uniform half _ReflectionIntensity;

//			uniform sampler2D _AdditionTex;
//			uniform sampler2D _AdditionNormal;
//			uniform sampler2D _AdditionSpecular;
//			uniform float4 _AdditionOffset;

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
                clip(_BaseRGBA_var.a - 0.05);
                half4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed3 _flake1 = lerp(fixed3(1.0,1.0,1.0),_FlakeColor1.rgb,_MatMask_var.b);
                fixed3 _flake2 = lerp(fixed3(1.0,1.0,1.0),_FlakeColor2.rgb,_MatMask_var.a);
                fixed equiprange = max(0,1-_MatMask_var.r);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                       _SpecularmapRGBA_var.rgb *= _flake1 * _flake2;
                half3 specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
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
				float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 ahalfDirection = normalize(viewDirection-lightDirection);
                float3 lightDir = normalize(float3(_WorldSpaceLightPos0.x,0,_WorldSpaceLightPos0.z));
                float3 halfDir = normalize(viewDirection+lightDir);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                half attenuation = 1;
                half3 attenColor = lerp(attenuation,1,_MatMask_var.r) * lightColor;
///////// Gloss:
				half gloss = _SpecularmapRGBA_var.a;
///// SkinColor:
                half3 baseRGBA = _BaseRGBA_var.rgb * equiprange;
                      baseRGBA *= _flake1 * _flake2;
///// Lightness:
                half lightpower = ((lightColor.r*0.299)+(lightColor.g*0.587)+(lightColor.b*0.114));
                half emispower = clamp(lightpower,0.0,1.0);
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float NdotLD = max(0, dot( normalDirection, lightDir ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float Ndothd = dot(normalDirection,halfDir);
                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL);
                half3 sh = AmbientColorGradient(normalDirection);
                half3 shval = dot(sh,float3(0.3,0.59,0.11));
                      sh = lerp(sh,shval,NdotL);
                half3 IBL = ImageBasedLighting(gloss,viewReflectDirection);
                       IBL *= _ReflectionIntensity * sh;
                fixed pie = 3.1415926535;
                half3 zis = Frsn(Ndotv,gloss,IBL,equiprange);
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
////// Specular:
                half spGGX = SpecularGGXWithHeadLight(pie, gloss, _MatMask_var.r, max(Ndothd,Ndoth), Ndotv, NdotV, NdotL,_NdotL);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,IBL,equiprange,0,0);
                       specular *= i.pl * _SpecularIntensity;
/////// Diffuse:
                half NdotLq = NdotL * 0.8 * equiprange;
                half scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);
                half3 diffuse = CalculateDiffuse(0,NdotLq,0,attenColor,sh,baseRGBA) * equiprange;
//////// Emissive:
                half3 emission = baseRGBA * _MatMask_var.a;
/// Final Color:
                half reflerp = reflp(_SpecularmapRGBA_var.rgb,pie)*equiprange;
                half3 finalColor = FinalColor(diffuse,specular,reflerp,_Rim,zis);
                half4 finalRGBA = half4(finalColor,_BaseRGBA_var.a+scatter);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        
        Pass
        {
            Name "CHARACTERTRANSSHADOWCASTER"
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
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }

        SubShader {
        
        Tags {
            "IgnorProjector"="True"
            "Queue"="AlphaTest-45"
            "RenderType"="Transparent"
            "DisableBatching"="True"
        }
        LOD 400
        Pass {
            Name "CHARACTERFORWARDGGXFLAKETRANS"
            Tags {
                "LightMode"="ForwardBase"
            }
            ZWrite On
            ZTest LEqual
            Cull Back
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

            uniform fixed4 _LightColor0;
            uniform sampler2D _BaseRGBA;
			uniform float4 _BaseRGBA_TexelSize;
			uniform float4 _BaseRGBA_ST;
            uniform float _RimPower;
            uniform fixed4 _RimColor;
            uniform fixed _lf;
//            uniform fixed _skinpoint;
            uniform fixed4 _FlakeColor1;
            uniform fixed4 _FlakeColor2;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform float _SpecularIntensity;
            uniform float _ReflectionIntensity;

//			uniform sampler2D _AdditionTex;
//			uniform sampler2D _AdditionNormal;
//			uniform sampler2D _AdditionSpecular;
//			uniform float4 _AdditionOffset;

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
                clip(_BaseRGBA_var.a - 0.05);
                half4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                fixed3 _flake1 = lerp(fixed3(1.0,1.0,1.0),_FlakeColor1.rgb,_MatMask_var.b);
                fixed3 _flake2 = lerp(fixed3(1.0,1.0,1.0),_FlakeColor2.rgb,_MatMask_var.a);
                fixed equiprange = max(0,1-_MatMask_var.r);
                fixed4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                       _SpecularmapRGBA_var.rgb *= _flake1 * _flake2;
                half3 specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
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
				float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 lightDir = normalize(float3(_WorldSpaceLightPos0.x,0,_WorldSpaceLightPos0.z));
                float3 halfDir = normalize(viewDirection+lightDir);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                fixed attenuation = 1;
                half3 attenColor = lerp(attenuation,1,_MatMask_var.r) * lightColor;

///////// Gloss:
				half gloss = _SpecularmapRGBA_var.a;
///// SkinColor:
                half3 baseRGBA = _BaseRGBA_var.rgb * equiprange;
                      baseRGBA *= _flake1 * _flake2;
///// Lightness:
                half lightpower = ((lightColor.r*0.299)+(lightColor.g*0.587)+(lightColor.b*0.114));
                half emispower = clamp(lightpower,0.0,1.0);
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float NdotLD = max(0, dot( normalDirection, lightDir ));
                float _NdotL = max(0, dot( normalDirection, -lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float Ndothd = dot(normalDirection,halfDir);
                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL);
                half3 sh = AmbientColorGradient(normalDirection);
                      sh = lerp(sh,dot(sh,float3(0.3,0.59,0.11)),NdotL);
                half3 IBL = ImageBasedLighting(gloss,viewReflectDirection);
                      IBL *= _ReflectionIntensity * sh;
                fixed pie = 3.1415926535;
                half3 zis = Frsn(Ndotv,gloss,IBL,equiprange);
                half3 _Rim = Rim(NdotV,_RimPower,_RimColor);
////// Specular:
                half spGGX = SpecularGGX(pie, gloss, _MatMask_var.r, max(Ndothd,Ndoth), NdotV, NdotL);
                half3 specular = CalculateSpecular(_SpecularmapRGBA_var.rgb,spGGX,gloss,attenColor,IBL,equiprange,0,0);
                      specular *= i.pl * _SpecularIntensity;
/////// Diffuse:
                half NdotLq = NdotL * 0.8 * equiprange;
                half scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);
                half3 diffuse = CalculateDiffuse(0,NdotLq,0,attenColor,sh,baseRGBA) * equiprange;
//////// Emissive:
                half3 emission = baseRGBA * _MatMask_var.a;
/// Final Color:
                half reflerp = reflp(_SpecularmapRGBA_var.rgb,pie)*equiprange;
                half3 finalColor = FinalColor(diffuse,specular,reflerp,_Rim,zis);
                half4 finalRGBA = half4(finalColor,_BaseRGBA_var.a+scatter);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }

    SubShader {
        
        Tags {
            "IgnorProjector"="True"
            "Queue"="AlphaTest-45"
            "RenderType"="Transparent"
            "DisableBatching"="True"
        }
        LOD 200

                Pass {
            Name "CHARACTERFORWARDBASEFLAKETRANSPARENT"
            Tags {
                "LightMode"="ForwardBase"
            }
            ZWrite On
            ZTest LEqual
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha
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
/// Final Color:
                half3 finalColor = diffuse + specular + _Rim;
                       finalColor = max(0,finalColor);
                       finalColor = diffuse;
                fixed4 finalRGBA = fixed4(finalColor,_BaseRGBA_var.a);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }
    //FallBack "Diffuse"
}
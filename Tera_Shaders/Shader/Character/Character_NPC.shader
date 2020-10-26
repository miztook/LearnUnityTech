Shader "TERA/Character/NPC" {
    Properties {
        _BaseRGBA ("Base(RGBA)", 2D) = "white" {}
        _Skinems ("Skin Ambient Bounce", Color) = (1,1,1,1)
        _Normalmap ("Normalmap", 2D) = "bump" {}
        _SpecularmapRGBA ("Specularmap(RGBA)", 2D) = "white" {}
        _SpecularIntensity ("Specular Intensity", Range(0, 2)) = 1
        _headlight ("Head Lighting Intensity", Range(0,1)) = 0.25
        _Mmask ("Mask(RGB)(Color1)(Color2)(Color3)", 2D) = "black" {}
        _Brdfmap ("Brdfmap", 2D) = "white" {}
        _brdfmod("Brdfmap Range", Range(0,1)) = 0.5
        _brdfrange("Brdfmap Effective Range", Range(0,1)) = 0
        _Flakecolor1 ("Flakecolor1", Color) = (1,1,1,1)
        _Flakecolor2 ("Flakecolor2", Color) = (1,1,1,1)
        _Flakecolor3 ("Flakecolor3", Color) = (1,1,1,1)
        _EmissionColor ("Emission Color", Color) = (1,1,1,1)
        Notouch("Rim&DeathEffect", Range(0,1)) = 0
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0, 5)) = 0
        //DeathEffect
		_FactorTex("FactorTex", 2D) = "white" {}
		_SinceLevelLoadedTime("_SinceLevelLoadedTime", float) = 0
		_DeathDuration("_DeathDuration", float) = 0
		_DeathColor("_DeathColor", Color) = (1,1,1,1)
		_DeathParamters("_DeathParamters(X:Min,Y:Max,Z:exp,W:add)", Vector) = (0.01,0.07,5,0.3)
    }
    SubShader {
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest+50"
            "DisableBatching"="True"
        }
        LOD 400
        Pass {
            Name "CHARACTERFORWARDSPECULAR"
            Tags {
                "LightMode"="ForwardBase"
            }
            Zwrite On
			Blend SrcAlpha OneMinusSrcAlpha
            
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
            uniform fixed4 _RimColor;
            uniform fixed _RimPower;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform fixed _MainLightIntensity;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform fixed _SpecularIntensity;
            uniform sampler2D _Mmask; uniform float4 _Mmask_ST;
            uniform sampler2D _Brdfmap; uniform float4 _Brdfmap_ST;
            uniform float _brdfrange;
            uniform float _brdfmod;
            uniform fixed _headlight;
            uniform fixed4 _Skinems;
            uniform fixed4 _Flakecolor1;
            uniform fixed4 _Flakecolor2;
            uniform fixed4 _Flakecolor3;
            uniform fixed4 _EmissionColor;

			sampler2D _FactorTex;
			float4 _FactorTex_ST;
			float _SinceLevelLoadedTime;
			float _DeathDuration;
			fixed4 _DeathColor;
			fixed4 _DeathParamters;

            half4 frag(V2f_TeraPBR i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap,TRANSFORM_TEX(i.uv0.xy, _Normalmap)));
                float3 normalLocal = _Normalmap_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
////// Textures:
                float4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                float4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                half4 _MatMask_var = tex2D(_Mmask,TRANSFORM_TEX(i.uv0, _Mmask));
                fixed equiprange = max(0,1-_MatMask_var.r);
                float3 specmncrm = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11));
///////// Gloss:
                float gloss = _SpecularmapRGBA_var.a;
                float specPow = exp2( gloss * 7.0+1.0);
                float3 sh = AmbientColorGradient(normalDirection);
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float NdotV = max(0,1 - Ndotv);
                float Ndotl = max(0,1 - NdotL);
                float3 _Rim = Rim(NdotV,_RimPower,_RimColor);
                float3 _flake1 = lerp(1,_Flakecolor1.rgb,_MatMask_var.r);
                float3 _flake2 = lerp(1,_Flakecolor1.rgb,_MatMask_var.g);
                float3 _flake3 = lerp(1,_Flakecolor1.rgb,_MatMask_var.b);
                float3 specularColor = (((_SpecularmapRGBA_var.rgb*(_flake1*_flake2*_flake3))*dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11))*_SpecularIntensity*2));
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularColor;
                float3 specular = directSpecular;
/////// Diffuse:
                float3 NdotLs = LightingbyBRDFmap(_Brdfmap, NdotL, Ndotv, Ndotl, _brdfrange, _brdfmod, _headlight, 0.1) * _MatMask_var.r;
                float NdotLq = LightingWithHeadLight(NdotL, Ndotv, _headlight) * equiprange;
                float scatter = Scattering(Ndotv, 10, 0.05,_MatMask_var.r);
                float3 scattering = scatter * _Skinems * 0.5;
                float3 diffuse = CalculateDiffuse(NdotLs,NdotLq,scattering,attenColor,sh,_BaseRGBA_var.rgb);
////// Emissive:
                float3 emissive = (_EmissionColor.rgb*_MatMask_var.a);
/// Final Color:
                float3 finalColor = diffuse + specular + emissive + _Rim;
                       finalColor = max(0,finalColor);
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);

				// disappear effect
				// originally we need to disable z write
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
        UsePass "Hidden/Character/CharacterPass/CHARACTERNOLIGHTBASE"
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }
    //FallBack "Diffuse"
}

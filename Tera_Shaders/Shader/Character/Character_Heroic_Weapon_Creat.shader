Shader "TERA/Character/Heroic_Weapon_Creat" {
    Properties {
        _BaseRGBA ("Base(RGBA)", 2D) = "white" {}
        _Normalmap ("Normalmap", 2D) = "bump" {}
        _SpecularmapRGBA ("Specularmap(RGBA)", 2D) = "white" {}
        _SpecularIntensity ("Specular Intensity", Range(0, 2)) = 1.5
        _ReflectionIntensity ("Reflection Intensity", Range(0, 1)) = 1
        _MatMask ("Mat Mask(RGB)(R_Skin)(G_Reflection)(B_Flake)", 2D) = "black" {}
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0, 5)) = 0
        _FakeLightColor ("Fake Light Color", Color) = (1,1,1,1)
        _FakeLight ("Fake Light Intensity", Range(0,2)) = 0
    }
    SubShader {
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest-50"
            "DisableBatching"="True"
        }
             Zwrite On
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityStandardUtils.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _BaseRGBA; uniform float4 _BaseRGBA_ST;
            uniform fixed _RimPower;
            uniform fixed4 _RimColor;
            uniform sampler2D _MatMask; uniform float4 _MatMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _SpecularmapRGBA; uniform float4 _SpecularmapRGBA_ST;
            uniform fixed _SpecularIntensity;
            uniform fixed _ReflectionIntensity;
            uniform fixed4 _FakeLightColor;
			uniform fixed _FakeLight;

            uniform samplerCUBE _EnvMap;
            uniform float4 _SunDir2;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
                UNITY_FOG_COORDS(8)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            half4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap,TRANSFORM_TEX(i.uv0, _Normalmap)));
                float3 normalLocal = _Normalmap_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float4 _BaseRGBA_var = tex2D(_BaseRGBA,TRANSFORM_TEX(i.uv0, _BaseRGBA));
                clip(_BaseRGBA_var.a - 0.5);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 blightdir = normalize(_SunDir2.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float3 fakeDirection = normalize(viewDirection+blightdir);
////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float Ndotb = max(0, dot( normalDirection, blightdir ));
                float bdoth = max(0, dot( normalDirection, fakeDirection ));
                float Ndotv = max(0, dot( normalDirection, viewDirection ));
                float Ndoth = max(0,dot(halfDirection,normalDirection));
                float mrref = max(0,dot(reflect(-lightDirection,normalDirection),viewDirection));
///////// Gloss:
                float4 _SpecularmapRGBA_var = tex2D(_SpecularmapRGBA,TRANSFORM_TEX(i.uv0, _SpecularmapRGBA));
                float gloss = _SpecularmapRGBA_var.a;
                float encsv = 1-gloss;
                float sp1 = exp2( gloss * 5.0 + 1.0);
                float sp2 = gloss * 512;
                float sp4 = gloss * 256;
////// Specular:
                float4 _MatMask_var = tex2D(_MatMask,TRANSFORM_TEX(i.uv0, _MatMask));
                float3 specintst = dot(_SpecularmapRGBA_var.rgb,float3(0.3,0.59,0.11)) * _SpecularmapRGBA_var.rgb * _SpecularIntensity;
                float3 specularColor_lowf = pow(Ndoth,sp1);
                float3 specularColor_highf = 3 * (pow(Ndoth,sp2)+pow(mrref,sp4));
                float3 specularboost = Ndotv + 1;
                float3 specColor = (specularColor_lowf+specularColor_highf) * specintst;
                float3 fakeSpecColor = ((pow(bdoth,sp1)*0.5)+(pow(bdoth,sp2)+pow(bdoth,sp4))) * specintst;
                float3 directSpecular = attenColor * specColor;
                       directSpecular += _FakeLightColor * _FakeLight * fakeSpecColor;
                       directSpecular *= specularboost;
                float3 specular = directSpecular;
/////// Diffuse:
                float3 directDiffuse = ((NdotL*0.8)+0.2) * attenColor;
                       directDiffuse += _FakeLightColor.rgb * Ndotb;
                float3 _fresnel = pow(1.0-Ndotv,7.0) * 0.5 * encsv;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += (texCUBElod(_EnvMap, half4(normalDirection, 10))) * (0.5 + _fresnel) * _MatMask_var.g;
                indirectDiffuse += ShadeSHPerPixel(normalDirection, half3(0, 0, 0),half3(0, 0, 0)) * encsv;
                //float3 _rim = pow(1.0-max(0,dot(i.normalDir, viewDirection)),_RimPower) * _RimColor.rgb * _RimPower;
                float3 reflectionpower = lerp(fixed3(1.0,1.0,1.0),(1.5*(texCUBE(_EnvMap,viewReflectDirection).rgb*_ReflectionIntensity)),_MatMask_var.g);
                float3 diffuseColor = (_fresnel+(_BaseRGBA_var.rgb*reflectionpower));
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse + specular;
                half4 finalRGBA = half4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }
    //FallBack "Diffuse"
}

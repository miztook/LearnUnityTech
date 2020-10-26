Shader "TERA/Character/ShadowCaster" {
    Properties {
    _BaseRGBA ("Base(RGBA)", 2D) = "white" {}
    }
    SubShader {
        
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest-50"
            "DisableBatching"="True"
        }
        UsePass "Hidden/Character/CharacterPass/CHARACTERSHADOWCASTER"
    }
}

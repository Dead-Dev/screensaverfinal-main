Shader "Custom/tree"
{
    Properties
    {
       _TexturaPrincipal ("Texture", 2D) = "white"{}
       _CorMoveVento("CorMoveVento", Range(0,1)) = 0.5
       _VentoMovimento("VentoMovimento", Range(-0.5, 0.5)) = 0.5 
       _VentoAdd("VentoAdd", Range(-1,1)) = 0.5 //sensitivo demais
    }

    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline"="UniversalRenderPipeline"}
        LOD 100 //Level of Detail

        Pass
        {
            HLSLPROGRAM 
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            //declara
            float _CorMoveVento;
            float _VentoMovimento; 
            float _VentoAdd; 

            texture2D _TexturaPrincipal;
            SamplerState sampler_TexturaPrincipal;

                        struct Attributes
                        {
                            float4 position : POSITION;
                            half2 uv : TEXCOORD0;
                            half3 normal : NORMAL; 
                            half4 color : COLOR;
                        };

                        struct Varying
                        {
                            float4 positionVAR : SV_POSITION;
                            half2 uvVAR : TEXCOORD0;
                            half4 color : COLOR0;
                        }; 
            
            Varying vert(Attributes Input) 
            {
                Varying Output; 

                    float3 position = Input.position.xyz;
                    float oscilation = _VentoAdd - (cos(_Time.w) * _VentoMovimento * Input.position.y);

                        if(Input.color.y > _CorMoveVento)
                        {
                            position += Input.normal * oscilation;
                        }

                    Output.positionVAR = TransformObjectToHClip(position); //posicao do vertex na cena
                    Output.uvVAR = Input.uv;

                    Light l = GetMainLight();
                    float intensity = dot(l.direction, TransformObjectToWorldNormal(Input.normal));
                    Output.color = Input.color * intensity; 

                    return Output; 
            }

            float4 frag (Varying Input) : SV_TARGET 
            {
                half4 color = Input.color;
                    if(Input.color.y > _CorMoveVento) 
                    {
                        color = _TexturaPrincipal.Sample(sampler_TexturaPrincipal, Input.uvVAR);
                    }
                    return color;   
            }
            ENDHLSL

        }
    }
}

///}
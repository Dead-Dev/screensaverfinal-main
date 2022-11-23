Shader "Custom/RUSTED"
{
    Properties
    {
        _Metal ("Metal", 2D) = "white" {}
        _Rust ("Rust", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Pass
        {
               HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

                texture2D _Metal;
                SamplerState sampler_Metal;
                texture2D _Rust;
                SamplerState sampler_Rust;

                struct Attributes
                {
                    //:POSITION é uma diretiva de pós compilação
                    float4 position : POSITION;
                    float2 uv : TEXCOORD0;
                    half3 normal : NORMAL;
                    half4 color : COLOR;
                };
                  
                  struct Varyings
                {
                    float4 positionVAR : SV_POSITION;
                    half2 uvVAR : TEXCOORD0;
                    half4 color : COLOR0;

                    half3 normalVAR : NORMAL;

                    float4 worldPositionVAR : TEXCOORD1;
                };

                Varyings vert(Attributes Input)
                {
                    Varyings Output;

                    float3 position = Input.position.xyz;

                    
                    Output.positionVAR = TransformObjectToHClip(position);

                    Output.uvVAR = Input.uv;
                    Output.normalVAR = Input.normal;// = position

                     //(não é textura)
                    Output.color = Input.color;

                    Output.worldPositionVAR = mul(unity_ObjectToWorld, Input.position); //var...var never changes...

                    return Output;

                } 
                float4 frag(Varyings Input) : SV_TARGET
                {
                     half4 color = Input.color; 
                     float3 localPOS = Input.worldPositionVAR - mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz;

                     if(localPOS.y>0.25){
                         color = _Rust.Sample(sampler_Rust, Input.uvVAR);
                     }
                     else{
                         color = _Metal.Sample(sampler_Metal, Input.uvVAR);
                     }

                     Light l = GetMainLight();
                     float intensity = dot(l.direction, TransformObjectToWorldNormal(Input.normalVAR));

                     return color * intensity;

                     
                }
                
                ENDHLSL
        }
                
    }
}

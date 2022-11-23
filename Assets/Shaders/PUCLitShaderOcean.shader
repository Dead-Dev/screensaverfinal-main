Shader "PUCLitShaderOcean"
{
   Properties
    {
        _TexPrincipal ("Texture", 2D) = "white" {}
        _NormalTex("Normal", 2D) = "white" {}
        _Forca("Forca", Range(-2,2)) = 1
        
        _MarCor("MarCor", Color) = (1, 1, 1, 1)
        _MarAmp("MarAmp", float) = 1
        _MarSize("MarSize", float) = 10
        _MarSpeedo("MarSpeedo", float) = 1
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100
            Pass
            {
                HLSLPROGRAM
                    #pragma vertex vert
                    #pragma fragment frag
                    #include  "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                    #include  "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

               
                texture2D _TexPrincipal;
                SamplerState sampler_TexPrincipal;
                float4 _TexPrincipal_ST;
                texture2D _NormalTex;

                SamplerState sampler_NormalTex;
                float _Forca;
                
                float4 _MarCor;
                float _MarAmp;
                float _MarSize;
                float _MarSpeedo;
                

                struct Attributes
                {
                    float4 position :POSITION;
                    half2 uv       :TEXCOORD0;
                    half3 normal : NORMAL;
                    half4 color : COLOR;
                };
            
                struct Varyings 
                {
                    float4 positionVAR :SV_POSITION;
                    half2 uvVAR       : TEXCOORD0;
                    half3 normalVar : NORMAL;
                    half4 colorVar : COLOR0;
                };

                Varyings vert(Attributes Input)
                {
                    Varyings Output;
                    float3 position = Input.position.xyz;

                    //wave position
                    float length = 2 * 3.14159265f / _MarSize;
                    float oscillation = length * (position.x - _MarSpeedo * _Time.y);
                    position.x += cos(oscillation) * _MarAmp;
                    position.y += sin(oscillation) * _MarAmp;
                    
                    float3 tangent = normalize(float3(1 - length * _MarAmp * sin(oscillation),
                                               length * _MarAmp * cos(oscillation), 0));
                    float3 normal = float3(-tangent.y, tangent.x, 0);

                    Output.positionVAR = TransformObjectToHClip(position);
                    Output.uvVAR = (Input.uv * _TexPrincipal_ST.xy + _TexPrincipal_ST.zw);
                    Output.colorVar = _MarCor;

                    Output.normalVar = TransformObjectToWorldNormal(normal);

                    return Output;
                }

                half4 frag(Varyings Input) :SV_TARGET
                { //turtorial + ajuda fyi
                    half4 color = Input.colorVar;
                    
                    Light l = GetMainLight();

                   half4 normalmap = _NormalTex.Sample(sampler_NormalTex, half2(_Time.x+Input.uvVAR.x, Input.uvVAR.y))*2-1;
                   half4 normalmap2 = _NormalTex.Sample(sampler_NormalTex, half2( Input.uvVAR.x, _Time.x + Input.uvVAR.y)) * 2 - 1;
                  
                   normalmap *= normalmap2;
                   float intensity = dot(l.direction, Input.normalVar+ normalmap.xzy* _Forca);

                    color *= _TexPrincipal.Sample(sampler_TexPrincipal, Input.uvVAR);
                    color *= intensity;
                    return color;
                }

            ENDHLSL
        }
    }
}

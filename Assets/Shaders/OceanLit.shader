Shader "OceanLit"
{
    Properties
    {
        _TexPrincipal("Texture", 2D) = "white" {}
        _NormalTex("Normal", 2D) = "white" {}
        _Force("Force", Range(-2,2)) = 1 

        _OceanCor("OceanCor", Color) = (1,1,1,1)
        _OAmpt("OAmpt", float) = 1 
        _Osize("Osize", float) = 10
        _OSpeed("OSpeed", float) = 1

        _OTile("OTile", Vector) = (1,1,0,0)
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
                    #include  "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                    #include  "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

                
                texture2D _TexPrincipal;
                SamplerState sampler_TexPrincipal;
                float4 _TexPrincipal_ST;
                texture2D _NormalTex; 

                SamplerState sampler_NormalTex; 
                float _Forca; 

                float4 _OceanCor;
                float  _OAmpt; 
                float  _Osize;
                float  _OSpeed;

                float2 _OTile;

                float2 Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset)
                {
                    return UV * Tiling + Offset;
                }

                struct Attributes
                {
                    float4 position : SV_POSITION;
                    half2 uvVAR    : TEXCOORD0;
                    half3 normalVar : NORMAL; 
                    half4 colorVar : COLOR0;
                };

                struct Varyings 
                {
                    float4 positionVAR : SV_POSITION;
                    float4 locpositionVAR : COLOR1;
                    half2 uvVAR       : TEXCOORD0;
                    half3 normalVAR : NORMAL;
                    half4 colorVAR : COLOR0;
                };

                Varyings vert(Attributes Input)
                {
                     Varyings Output;


                    float3 position = Input.position.xyz;
                    float length = 2 * 3.14159265f / _Osize;
                    float oscillation = length * (position.x - _OSpeed * _Time.y);
                    //position.x += cos(oscillation) * _MarAmp;
                    position.y += sin(oscillation) * _OAmpt;
                    
                    float3 tangent = normalize(float3(1 - length * _OAmpt * sin(oscillation),
                                               length * _OAmpt * cos(oscillation), 0));
                    float3 normal = float3(-tangent.y, tangent.x, 0);

                    Output.positionVAR = TransformObjectToHClip(position);
                    Output.uvVAR = (Input.uvVAR * _TexPrincipal_ST.xy + _TexPrincipal_ST.zw);
                    Output.uvVAR = Unity_TilingAndOffset_float(Output.uvVAR, _OTile.xy, float2(0,0));
                    Output.colorVAR = _OceanCor;

                    Output.normalVAR = TransformObjectToWorldNormal(normal);

                    return Output;
                }

                half4 frag(Varyings Input) :SV_TARGET
                {
                    half4 color = Input.colorVAR;
                    
                    Light l = GetMainLight();

                    half4 normalmap= _NormalTex.Sample(sampler_NormalTex, Input.uvVAR) * 2 - 1;

                    float intensity = dot(l.direction, Input.normalVAR + normalmap.xzy * _Forca);//+ normalmap.xzy* _Forca);

                    color *= _TexPrincipal.Sample(sampler_TexPrincipal, Input.uvVAR);
                    color *= clamp(0, 1, intensity);

                    return color;
                }   
            ENDHLSL    
        }
    }
}
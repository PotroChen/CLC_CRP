#ifndef CUSTOM_META_PASS_INCLUDED
#define CUSTOM_META_PASS_INCLUDED

//unity引擎通过metapass来烘焙间接漫反射光，写了metapass的材质才能在烘焙的时候影响其他问题
#include "../ShaderLibrary/Surface.hlsl"
#include "../ShaderLibrary/Shadows.hlsl"
#include "../ShaderLibrary/Light.hlsl"
#include "../ShaderLibrary/BRDF.hlsl"

struct Attributes
{
    float3 positionOS : POSITION;
    float2 baseUV : TEXCOORD0;
    float2 lightMapUV : TEXCOORD1;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 baseUV : VAR_BASE_UV;
};

bool4 unity_MetaFragmentControl;
float unity_OneOverOutputBoost;
float unity_MaxOutputValue;

Varyings MetaPassVertex(Attributes input)
{
    Varyings output;
    //下面的三行代码不太懂，为啥把光照贴图的UV坐标赋给positionOS.xy?
    input.positionOS.xy = input.lightMapUV * unity_LightmapST.xy + unity_LightmapST.zw;
    input.positionOS.z = input.positionOS.z > 0.0 ? FLT_MIN : 0.0;
    output.positionCS = TransformWorldToHClip(input.positionOS);
    output.baseUV = TransformBaseUV(input.baseUV);
    return output;
}

float4 MetaPassFragment(Varyings input) : SV_TARGET
{
    InputConfig config = GetInputConfig(input.baseUV);
    float4 base = GetBase(config);
    Surface surface;
    ZERO_INITIALIZE(Surface, surface);
    surface.color = base.rgb;
    BRDF brdf = GetBRDF(surface);
    float4 meta = 0.0;
    if (unity_MetaFragmentControl.x)//unity传入的flag，控制间接光的开启（烘焙）
    {
        meta = float4(brdf.diffuse, 1.0);
        meta.rgb += brdf.specular * brdf.roughness * 0.5;
        meta.rgb = min(
			PositivePow(meta.rgb, unity_OneOverOutputBoost), unity_MaxOutputValue
		);   
    }
    else if (unity_MetaFragmentControl.y)//unity传入的flag，控制自发光的开启（烘焙）
    {
        meta = float4(GetEmission(config), 1.0);
    }

    return meta;
}

#endif
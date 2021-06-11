#ifndef CUSTOM_SHADOW_CASTER_PASS_INCLUDED
#define CUSTOM_SHADOW_CASTER_PASS_INCLUDED

struct Attributes {
	float3 positionOS : POSITION;
	float2 baseUV : TEXCOORD0;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings { 
	float4 positionCS : SV_POSITION;
	float2 baseUV : VAR_BASE_UV;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

bool _ShadowPancaking;

Varyings ShadowCasterPassVertex (Attributes input)
{
	Varyings output;
	UNITY_SETUP_INSTANCE_ID(input);
	UNITY_TRANSFER_INSTANCE_ID(input, output);
	float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
	output.positionCS = TransformWorldToHClip(positionWS);

    output.baseUV = TransformBaseUV(input.baseUV);

	//正交视图将顶点位置Clamp到near和far没问题
	//透视视图将顶点位置Clamp和near和far会使阴影失真
	//开启ShadowPancaking时,是正交视图。
	//关闭ShadowPancaking时,是透视视图。
	//所以我们只有开启ShadowPancaking时才Clamp
    if (_ShadowPancaking)
    {
		//将clipSpace的z保持在near的前面，防止该物体投射的影子被裁剪掉
#if UNITY_REVERSED_Z
		output.positionCS.z =
			min(output.positionCS.z, output.positionCS.w * UNITY_NEAR_CLIP_VALUE);
#else
        output.positionCS.z =
			max(output.positionCS.z, output.positionCS.w * UNITY_NEAR_CLIP_VALUE);
#endif
    }

	return output;
}

void  ShadowCasterPassFragment (Varyings input) 
{
	UNITY_SETUP_INSTANCE_ID(input);
    ClipLOD(input.positionCS.xy, unity_LODFade.x);
	
    InputConfig config = GetInputConfig(input.baseUV);
    float4 base = GetBase(config);

	#if defined(_SHADOWS_CLIP)
		clip(base.a - GetCutoff(config));
	#elif defined(_SHADOWS_DITHER)
		float dither = InterleavedGradientNoise(input.positionCS.xy, 0);
		clip(base.a - dither);
	#endif
}

#endif
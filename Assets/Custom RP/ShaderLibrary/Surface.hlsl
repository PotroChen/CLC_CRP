#ifndef CUSTOM_SURFACE_INCLUDED
#define CUSTOM_SURFACE_INCLUDED

struct Surface {
	float3 position;
	float3 normal;
    float3 interpolatedNormal; //经过顶点函数的normalWS插值的法线(没有受法线贴图影响)
	float3 viewDirection;
	float depth;
	float3 color;
	float alpha;
	float metallic;
    float occlusion;
	float smoothness;
    float fresnelStrength;
    float dither; //抖动(仿色)
};

#endif
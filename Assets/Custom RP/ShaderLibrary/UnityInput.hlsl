#ifndef CUSTOM_UNITY_INPUT_INCLUDED
#define CUSTOM_UNITY_INPUT_INCLUDED

CBUFFER_START(UnityPerDraw)//每次DrawCall应用层传进来的信息
	float4x4 unity_ObjectToWorld;
	float4x4 unity_WorldToObject;
	float4 unity_LODFade;
	real4 unity_WorldTransformParams;

	real4 unity_LightData;
	real4 unity_LightIndices[2];

	float4 unity_ProbesOcclusion;//ShadowMask储存在LightProbe的数据存放在这里
	float4 unity_SpecCube0_HDR;

	float4 unity_LightmapST;
	float4 unity_DynamicLightmapST;

	/*用于光照探针的采集，
	代表了多项式的分量unity_SH* , *是A,B或C中的一个，
	A和B又对应了r,g,b三个变量*/
	float4 unity_SHAr;
	float4 unity_SHAg;
	float4 unity_SHAb;
	float4 unity_SHBr;
	float4 unity_SHBg;
	float4 unity_SHBb;
	float4 unity_SHC;

	float4 unity_ProbeVolumeParams;
	float4x4 unity_ProbeVolumeWorldToObject;
	float4 unity_ProbeVolumeSizeInv;
	float4 unity_ProbeVolumeMin;
CBUFFER_END

float4x4 unity_MatrixVP;
float4x4 unity_MatrixV;
float4x4 glstate_matrix_projection;
float3 _WorldSpaceCameraPos;

#endif
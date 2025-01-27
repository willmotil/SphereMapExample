﻿
// TextureCubeDrawEffect

// https://www.geeks3d.com/20141201/how-to-rotate-a-vertex-by-a-quaternion-in-glsl/


#if OPENGL
#define SV_POSITION POSITION
#define VS_SHADERMODEL vs_3_0
#define PS_SHADERMODEL ps_3_0
#else
#define VS_SHADERMODEL vs_4_0
#define PS_SHADERMODEL ps_4_0
#endif

matrix World;
matrix View;
matrix Projection;
float3 CameraPosition;
int testValue1;


Texture TextureA; // primary texture.
sampler TextureSamplerA = sampler_state
{
    texture = <TextureA>;
    //magfilter = LINEAR; //minfilter = LINEAR; //mipfilter = LINEAR; //AddressU = mirror; //AddressV = mirror; 
};

TextureCube CubeMap;
samplerCUBE CubeMapSampler = sampler_state
{
    texture = <CubeMap>;
    //magfilter = Linear;
    //minfilter = Linear;
    //mipfilter = Linear;
    AddressU = clamp;
    AddressV = clamp;
};

//____________________________________
// structs
//____________________________________


struct PNTVertexShaderInput
{
    float4 Position : POSITION0;
    float3 Normal : NORMAL0;
    float2 TextureCoordinate : TEXCOORD0;
};

struct PNTVertexShaderOutput
{
    float4 Position : SV_POSITION;
    float3 Position3D : TEXCOORD1;
    float3 Normal3D : TEXCOORD2;
    float2 TextureCoordinate : TEXCOORD0;
};

struct PTVertexShaderInput
{
    float4 Position : POSITION0;
    float3 Normal : NORMAL0;
    float2 TextureCoordinate : TEXCOORD0;
};

struct PTVertexShaderOutput
{
    float4 Position : SV_POSITION;
    float3 Position3D : TEXCOORD1;
    float3 Normal3D : TEXCOORD2;
    float2 TextureCoordinate : TEXCOORD0;
};


//____________________________________
// shaders and technique  RenderCubeMap
//____________________________________

PNTVertexShaderOutput RenderCubeMapVS(in PNTVertexShaderInput input)
{
    PNTVertexShaderOutput output;
    float4x4 vp = mul(View, Projection);
    float4 pos = mul(input.Position, World);
    float4 norm = mul(input.Normal, World);
    output.Position = mul(pos, vp);
    output.Position3D = pos.xyz;
    output.Normal3D = norm.xyz;
    output.TextureCoordinate = input.TextureCoordinate;
    return output;
}

float4 RenderCubeMapPS(PNTVertexShaderOutput input) : COLOR
{
    //float4 baseColor = tex2D(TextureSamplerDiffuse, input.TextureCoordinate); 
    ////clip(baseColor.a - .01f); // just straight clip super low alpha.
    //float3 P = input.Position3D;
    //float3 N = normalize(input.Normal3D.xyz);
    //float3 V = normalize(CameraPosition - input.Position3D);
    //float NdotV = max(0.0, dot(N, V));
    //float3 R = 2.0 * NdotV * N - V;

    //float4 envMapColor = texCUBElod(CubeMapSampler, float4(R, testValue1));
    //return float4(envMapColor.rgb, 1.0f);

    float3 N = normalize(input.Normal3D.xyz);
    float4 envMapColor = texCUBElod(CubeMapSampler, float4(N, testValue1));
    return float4(envMapColor.rgb, 1.0f);
}

technique RenderCubeMap
{
    pass P0
    {
        VertexShader = compile VS_SHADERMODEL
            RenderCubeMapVS();
        PixelShader = compile PS_SHADERMODEL
            RenderCubeMapPS();
    }
};


//____________________________________
// shaders and technique  RenderSphereWithCubeMap
//____________________________________

PNTVertexShaderOutput RenderSphereWithCubeMapVS(in PNTVertexShaderInput input)
{
    PNTVertexShaderOutput output;

    float dist = texCUBElod(CubeMapSampler, float4(input.Position.xyz, 0)).r + 1.01f;
    float4 pos = input.Position;
    float4 posDeformation = normalize( pos ) * dist  * 2.0f;
    pos.rgb = pos.rgb + posDeformation;
    pos = mul(pos, World);


    float4x4 vp = mul(View, Projection);
    //float4 pos = mul(input.Position, World);
    float4 norm = mul(input.Normal, World);

    output.Position = mul(pos, vp);
    output.Position3D = pos.xyz;
    output.Normal3D = norm.xyz;
    output.TextureCoordinate = input.TextureCoordinate;
    return output;
}

PNTVertexShaderOutput RenderSphereWithCubeMapCpuDataVS(in PNTVertexShaderInput input)
{
    PNTVertexShaderOutput output;

    //float dist = texCUBElod(CubeMapSampler, float4(input.Position.xyz, 0)).r + 1.01f;
    //float4 pos = input.Position;
    //float4 posDeformation = normalize(pos) * dist * 2.0f;
    //pos.rgb = pos.rgb + posDeformation;
    //pos = mul(pos, World);


    float4x4 vp = mul(View, Projection);
    float4 wpos = mul(input.Position, World);
    float4 norm = mul(input.Normal, World);

    output.Position3D = wpos.xyz;
    output.Position = mul(wpos, vp);
    output.Normal3D = norm.xyz;
    output.TextureCoordinate = input.TextureCoordinate;
    return output;
}

float4 RenderSphereWithCubeMapPS(PNTVertexShaderOutput input) : COLOR
{
    //float4 baseColor = tex2D(TextureSamplerDiffuse, input.TextureCoordinate); 
    ////clip(baseColor.a - .01f); // just straight clip super low alpha.
    //float3 P = input.Position3D;
    //float3 N = normalize(input.Normal3D.xyz);
    //float3 V = normalize(CameraPosition - input.Position3D);
    //float NdotV = max(0.0, dot(N, V));
    //float3 R = 2.0 * NdotV * N - V;

    //float4 envMapColor = texCUBElod(CubeMapSampler, float4(R, testValue1));
    //return float4(envMapColor.rgb, 1.0f);

    //float3 N = normalize(input.Normal3D.xyz);

    float3 P = normalize(input.Position3D);
    float4 envMapColor = texCUBElod(CubeMapSampler, float4(P, testValue1));
    //return float4(envMapColor.rgb, 1.0f);

    float3 center = World._41_42_43;
    float dis = (length(input.Position3D.xyz - center) - 25.0f) / 4.0f;
    return float4( envMapColor.r * dis , envMapColor.r , dis , 1.0f );
}

technique RenderSphereWithCubeMap
{
    pass P0
    {
        VertexShader = compile VS_SHADERMODEL
            RenderSphereWithCubeMapVS();
        PixelShader = compile PS_SHADERMODEL
            RenderSphereWithCubeMapPS();
    }
};

technique RenderSphereWithCubeMapCpuData
{
    pass P0
    {
        VertexShader = compile VS_SHADERMODEL
            RenderSphereWithCubeMapCpuDataVS();
        PixelShader = compile PS_SHADERMODEL
            RenderSphereWithCubeMapPS();
    }
};



//____________________________________
// shaders and technique  QuadDraw
//____________________________________

PNTVertexShaderOutput VertexShaderQuadDraw(PNTVertexShaderInput input)
{
    PNTVertexShaderOutput output;
    float4x4 vp = mul(View, Projection);
    float4 pos = mul(input.Position, World);
    float4 norm = mul(input.Normal, World);
    output.Position = mul(pos, vp);
    output.Position3D = pos.xyz;
    output.Normal3D = norm.xyz;
    output.TextureCoordinate = input.TextureCoordinate;
    return output;
}
float4 PixelShaderQuadDraw(PNTVertexShaderOutput input) : COLOR
{
    float4 color = tex2D(TextureSamplerA, input.TextureCoordinate); // *input.Color;
    return color;
}

technique QuadDraw
{
    pass P0
    {
        VertexShader = compile VS_SHADERMODEL
            VertexShaderQuadDraw();
        PixelShader = compile PS_SHADERMODEL
            PixelShaderQuadDraw();
    }
}
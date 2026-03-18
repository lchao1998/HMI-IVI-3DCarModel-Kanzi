#version 100

#define USE_TANGENT_SPACE (KANZI_SHADER_USE_NORMALMAP_TEXTURE || KANZI_SHADER_USE_MORPH_TARGET_TANGENTS)
#if USE_TANGENT_SPACE
varying mediump vec3 vTangent;
varying mediump vec3 vBinormal;
#endif

uniform highp mat4 kzProjectionCameraWorldMatrix;
uniform highp mat4 kzWorldMatrix;
uniform highp mat4 kzNormalMatrix;
uniform highp vec4 kzViewPosition;

varying mediump vec3 vNormal;
varying mediump vec3 vViewDirection;

#if KANZI_SHADER_MORPH_TARGET_COUNT <= 1

attribute vec3 kzPosition;
attribute vec3 kzNormal;
#if USE_TANGENT_SPACE
attribute vec4 kzTangent;
#if KANZI_SHADER_USE_EXPLICIT_BINORMALS
attribute vec3 kzBinormal;
#endif
#endif

#else // KANZI_SHADER_MORPH_TARGET_COUNT <= 1

#if KANZI_SHADER_USE_MORPH_DATA_TEXTURE

uniform sampler2D kzMorphDataTexture;
uniform highp int kzMorphDataPositionOffset;
#if KANZI_SHADER_USE_MORPH_TARGET_NORMALS
uniform highp int kzMorphDataNormalOffset;
#else // KANZI_SHADER_USE_MORPH_TARGET_NORMALS
attribute vec3 kzMorphTarget0Normal;
#endif // KANZI_SHADER_USE_MORPH_TARGET_NORMALS
#if USE_TANGENT_SPACE
#if KANZI_SHADER_USE_MORPH_TARGET_TANGENTS
uniform highp int kzMorphDataTangentOffset;
#else // KANZI_SHADER_USE_MORPH_TARGET_TANGENTS
attribute vec4 kzMorphTarget0Tangent;
#endif // KANZI_SHADER_USE_MORPH_TARGET_TANGENTS
#endif // USE_TANGENT_SPACE
uniform highp int kzMorphDataSize;
uniform mediump int kzMorphIndices[KANZI_SHADER_MORPH_TARGET_COUNT];

#else // KANZI_SHADER_USE_MORPH_DATA_TEXTURE

attribute vec3 kzMorphTarget0Position;
attribute vec3 kzMorphTarget1Position;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 2
attribute vec3 kzMorphTarget2Position;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 3
attribute vec3 kzMorphTarget3Position;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 4
attribute vec3 kzMorphTarget4Position;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 5
attribute vec3 kzMorphTarget5Position;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 6
attribute vec3 kzMorphTarget6Position;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 7
attribute vec3 kzMorphTarget7Position;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 8
attribute vec3 kzMorphTarget8Position;
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 8
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 7
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 6
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 5
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 4
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 3
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 2

attribute vec3 kzMorphTarget0Normal;
#if KANZI_SHADER_USE_MORPH_TARGET_NORMALS
attribute vec3 kzMorphTarget1Normal;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 2
attribute vec3 kzMorphTarget2Normal;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 3
attribute vec3 kzMorphTarget3Normal;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 4
attribute vec3 kzMorphTarget4Normal;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 5
attribute vec3 kzMorphTarget5Normal;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 6
attribute vec3 kzMorphTarget6Normal;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 7
attribute vec3 kzMorphTarget7Normal;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 8
attribute vec3 kzMorphTarget8Normal;
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 8
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 7
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 6
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 5
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 4
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 3
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 2
#endif // KANZI_SHADER_USE_MORPH_TARGET_NORMALS

#if USE_TANGENT_SPACE
attribute vec4 kzMorphTarget0Tangent;
#if KANZI_SHADER_USE_MORPH_TARGET_TANGENTS
attribute vec4 kzMorphTarget1Tangent;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 2
attribute vec4 kzMorphTarget2Tangent;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 3
attribute vec4 kzMorphTarget3Tangent;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 4
attribute vec4 kzMorphTarget4Tangent;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 5
attribute vec4 kzMorphTarget5Tangent;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 6
attribute vec4 kzMorphTarget6Tangent;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 7
attribute vec4 kzMorphTarget7Tangent;
#if KANZI_SHADER_MORPH_TARGET_COUNT > 8
attribute vec4 kzMorphTarget8Tangent;
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 8
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 7
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 6
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 5
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 4
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 3
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 2
#endif // KANZI_SHADER_USE_MORPH_TARGET_TANGENTS
#endif // USE_TANGENT_SPACE

#endif // KANZI_SHADER_USE_MORPH_DATA_TEXTURE

uniform mediump float kzMorphWeights[KANZI_SHADER_MORPH_TARGET_COUNT];

#endif // KANZI_SHADER_MORPH_TARGET_COUNT <= 1

#if KANZI_SHADER_USE_BASECOLOR_TEXTURE || KANZI_SHADER_USE_NORMALMAP_TEXTURE
attribute vec2 kzTextureCoordinate0;
varying mediump vec2 vTexCoord;
uniform mediump vec2 TextureOffset;
uniform mediump vec2 TextureTiling;
#endif

#if KANZI_SHADER_SKINNING_BONE_COUNT 
attribute vec4 kzWeight;
attribute vec4 kzMatrixIndices;
uniform highp vec4 kzMatrixPalette[KANZI_SHADER_SKINNING_BONE_COUNT*3]; 
#endif

#if KANZI_SHADER_NUM_DIRECTIONAL_LIGHTS
uniform mediump vec3 DirectionalLightDirection[KANZI_SHADER_NUM_DIRECTIONAL_LIGHTS];
varying mediump vec3 vDirectionalLightDirection[KANZI_SHADER_NUM_DIRECTIONAL_LIGHTS];
#endif

#if KANZI_SHADER_NUM_POINT_LIGHTS
uniform mediump vec3 PointLightPosition[KANZI_SHADER_NUM_POINT_LIGHTS];
varying mediump vec3 vPointLightDirection[KANZI_SHADER_NUM_POINT_LIGHTS];
#endif

#if KANZI_SHADER_NUM_SPOT_LIGHTS
uniform mediump vec3 SpotLightPosition[KANZI_SHADER_NUM_SPOT_LIGHTS];
varying mediump vec3 vSpotLightDirection[KANZI_SHADER_NUM_SPOT_LIGHTS];
#endif

struct PositionData
{
    vec3 position;
    vec3 normal;
#if USE_TANGENT_SPACE
    vec4 tangent;
#endif
};

#if KANZI_SHADER_MORPH_TARGET_COUNT > 1

#if KANZI_SHADER_USE_MORPH_DATA_TEXTURE
mediump vec4 getMorphData(int morphIndex, int vertexIndex)
{
    highp int kzMorphDataTextureWidth = textureSize(kzMorphDataTexture, 0).x;
    highp int positionIndex = morphIndex * kzMorphDataSize + vertexIndex;
    highp int posX = positionIndex % kzMorphDataTextureWidth;
    highp int posY = positionIndex / kzMorphDataTextureWidth;
    return texelFetch(kzMorphDataTexture, ivec2(posX, posY), 0);
}
vec3 getMorphPositionData(int morphIndex, int vertexIndex)
{
    return getMorphData(morphIndex, kzMorphDataPositionOffset + vertexIndex).xyz;
}
#if KANZI_SHADER_USE_MORPH_TARGET_NORMALS
vec3 getMorphNormalData(int morphIndex, int vertexIndex)
{
    return getMorphData(morphIndex, kzMorphDataNormalOffset + vertexIndex).xyz;
}
#endif // KANZI_SHADER_USE_MORPH_TARGET_NORMALS
#if USE_TANGENT_SPACE
#if KANZI_SHADER_USE_MORPH_TARGET_TANGENTS
vec4 getMorphTangentData(int morphIndex, int vertexIndex)
{
    return getMorphData(morphIndex, kzMorphDataTangentOffset + vertexIndex);
}
#endif // KANZI_SHADER_USE_MORPH_TARGET_TANGENTS
#endif // USE_TANGENT_SPACE
#endif // KANZI_SHADER_USE_MORPH_DATA_TEXTURE

PositionData calculateMorphTargetPositionData()
{
    PositionData posData;

    float baseMorphWeight = 1.0;
    for(int it = 1; (it < KANZI_SHADER_MORPH_TARGET_COUNT); ++it)
    {
        baseMorphWeight -= kzMorphWeights[it];
    }
#if KANZI_SHADER_USE_MORPH_DATA_TEXTURE
    posData.position = getMorphPositionData(kzMorphIndices[0], gl_VertexID) * baseMorphWeight;
    for(int it = 1; (it < KANZI_SHADER_MORPH_TARGET_COUNT); ++it)
    {
        posData.position += getMorphPositionData(kzMorphIndices[it], gl_VertexID) * kzMorphWeights[it];
    }
#else // KANZI_SHADER_USE_MORPH_DATA_TEXTURE
    posData.position = kzMorphTarget0Position * baseMorphWeight
                     + kzMorphTarget1Position * kzMorphWeights[1]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 2
                     + kzMorphTarget2Position * kzMorphWeights[2]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 3
                     + kzMorphTarget3Position * kzMorphWeights[3]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 4
                     + kzMorphTarget4Position * kzMorphWeights[4]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 5
                     + kzMorphTarget5Position * kzMorphWeights[5]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 6
                     + kzMorphTarget6Position * kzMorphWeights[6]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 7
                     + kzMorphTarget7Position * kzMorphWeights[7]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 8
                     + kzMorphTarget8Position * kzMorphWeights[8]
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 8
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 7
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 6
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 5
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 4
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 3
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 2
    ;
#endif // KANZI_SHADER_USE_MORPH_DATA_TEXTURE

#if KANZI_SHADER_USE_MORPH_TARGET_NORMALS
#if KANZI_SHADER_USE_MORPH_NORMAL_LIMIT
    baseMorphWeight = max(baseMorphWeight, 0.0);
#endif // KANZI_SHADER_USE_MORPH_NORMAL_LIMIT
#if KANZI_SHADER_USE_MORPH_DATA_TEXTURE
    posData.normal = getMorphNormalData(kzMorphIndices[0], gl_VertexID) * baseMorphWeight;
    for(int it = 1; (it < KANZI_SHADER_MORPH_TARGET_COUNT); ++it)
    {
        posData.normal += getMorphNormalData(kzMorphIndices[it], gl_VertexID) * kzMorphWeights[it];
    }
#else // KANZI_SHADER_USE_MORPH_DATA_TEXTURE
    posData.normal = kzMorphTarget0Normal * baseMorphWeight
                   + kzMorphTarget1Normal * kzMorphWeights[1]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 2
                   + kzMorphTarget2Normal * kzMorphWeights[2]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 3
                   + kzMorphTarget3Normal * kzMorphWeights[3]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 4
                   + kzMorphTarget4Normal * kzMorphWeights[4]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 5
                   + kzMorphTarget5Normal * kzMorphWeights[5]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 6
                   + kzMorphTarget6Normal * kzMorphWeights[6]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 7
                   + kzMorphTarget7Normal * kzMorphWeights[7]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 8
                   + kzMorphTarget8Normal * kzMorphWeights[8]
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 8
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 7
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 6
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 5
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 4
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 3
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 2
    ;
#endif // KANZI_SHADER_USE_MORPH_DATA_TEXTURE
#else // KANZI_SHADER_USE_MORPH_TARGET_NORMALS
    posData.normal = kzMorphTarget0Normal;
#endif // KANZI_SHADER_USE_MORPH_TARGET_NORMALS

#if USE_TANGENT_SPACE

#if KANZI_SHADER_USE_MORPH_TARGET_TANGENTS
#if KANZI_SHADER_USE_MORPH_DATA_TEXTURE
    posData.tangent = getMorphTangentData(kzMorphIndices[0], gl_VertexID);
    posData.tangent.xyz *= baseMorphWeight;
    for(int it = 1; (it < KANZI_SHADER_MORPH_TARGET_COUNT); ++it)
    {
        posData.tangent.xyz += getMorphTangentData(kzMorphIndices[it], gl_VertexID).xyz * kzMorphWeights[it];
    }
#else // KANZI_SHADER_USE_MORPH_DATA_TEXTURE
    posData.tangent.w = kzMorphTarget0Tangent.w;
    posData.tangent.xyz = kzMorphTarget0Tangent.xyz
                        * baseMorphWeight
                        + kzMorphTarget1Tangent.xyz * kzMorphWeights[1]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 2
                        + kzMorphTarget2Tangent.xyz * kzMorphWeights[2]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 3
                        + kzMorphTarget3Tangent.xyz * kzMorphWeights[3]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 4
                        + kzMorphTarget4Tangent.xyz * kzMorphWeights[4]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 5
                        + kzMorphTarget5Tangent.xyz * kzMorphWeights[5]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 6
                        + kzMorphTarget6Tangent.xyz * kzMorphWeights[6]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 7
                        + kzMorphTarget7Tangent.xyz * kzMorphWeights[7]
#if KANZI_SHADER_MORPH_TARGET_COUNT > 8
                        + kzMorphTarget8Tangent.xyz * kzMorphWeights[8]
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 8
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 7
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 6
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 5
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 4
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 3
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 2
    ;
#endif // KANZI_SHADER_USE_MORPH_DATA_TEXTURE

#else // KANZI_SHADER_USE_MORPH_TARGET_TANGENTS

    posData.tangent = kzMorphTarget0Tangent;
#if KANZI_SHADER_USE_MORPH_TARGET_NORMALS
    // orthogonalize base mesh tangent against deformed normal
    posData.tangent.xyz -= posData.normal * dot(posData.normal, posData.tangent.xyz) / dot(posData.normal, posData.normal);
#endif // KANZI_SHADER_USE_MORPH_TARGET_NORMALS

#endif // KANZI_SHADER_USE_MORPH_TARGET_TANGENTS

#endif // USE_TANGENT_SPACE

    return posData;
}

#else // KANZI_SHADER_MORPH_TARGET_COUNT > 1

PositionData calculateSimplePositionData()
{
    PositionData posData;
    posData.position = kzPosition.xyz;
    posData.normal = kzNormal.xyz;
#if USE_TANGENT_SPACE
    posData.tangent = kzTangent;
#endif
    return posData;
}
#endif // KANZI_SHADER_MORPH_TARGET_COUNT > 1

#if KANZI_SHADER_SKINNING_BONE_COUNT
PositionData calculateSkinningPositionData(PositionData posData)
{
    mat4 localToSkinMatrix;
    int i1 = 3 * int(kzMatrixIndices.x);
    int i2 = 3 * int(kzMatrixIndices.y);
    int i3 = 3 * int(kzMatrixIndices.z);
    int i4 = 3 * int(kzMatrixIndices.w);
    vec4 b1 = kzWeight.x * kzMatrixPalette[i1]
            + kzWeight.y * kzMatrixPalette[i2]
            + kzWeight.z * kzMatrixPalette[i3]
            + kzWeight.w * kzMatrixPalette[i4];
    vec4 b2 = kzWeight.x * kzMatrixPalette[i1 + 1]
            + kzWeight.y * kzMatrixPalette[i2 + 1]
            + kzWeight.z * kzMatrixPalette[i3 + 1]
            + kzWeight.w * kzMatrixPalette[i4 + 1];
    vec4 b3 = kzWeight.x * kzMatrixPalette[i1 + 2]
            + kzWeight.y * kzMatrixPalette[i2 + 2]
            + kzWeight.z * kzMatrixPalette[i3 + 2]
            + kzWeight.w * kzMatrixPalette[i4 + 2];
   
    localToSkinMatrix[0] = vec4(b1.xyz, 0.0);
    localToSkinMatrix[1] = vec4(b2.xyz, 0.0);
    localToSkinMatrix[2] = vec4(b3.xyz, 0.0);
    localToSkinMatrix[3] = vec4(b1.w, b2.w, b3.w, 1.0);
    mat4 localToWorldMatrix = kzWorldMatrix * localToSkinMatrix;
      
    posData.position = (localToSkinMatrix * vec4(posData.position.xyz, 1.0)).xyz;
    posData.normal = mat3(localToSkinMatrix) * posData.normal;
    
    return posData;
}
#endif

void main()
{
    precision mediump float;
    
#if KANZI_SHADER_MORPH_TARGET_COUNT > 1
    PositionData posData = calculateMorphTargetPositionData();
#else
    PositionData posData = calculateSimplePositionData();
#endif

#if KANZI_SHADER_SKINNING_BONE_COUNT
    posData = calculateSkinningPositionData(posData);
#endif

    vec4 positionWorld = kzWorldMatrix * vec4(posData.position, 1.0);
    
    vViewDirection = positionWorld.xyz * kzViewPosition.w - kzViewPosition.xyz;
    vNormal = normalize(mat3(kzNormalMatrix) * posData.normal);
    gl_Position = kzProjectionCameraWorldMatrix * vec4(posData.position, 1.0);   

#if KANZI_SHADER_NUM_DIRECTIONAL_LIGHTS
    for (int i = 0; i < KANZI_SHADER_NUM_DIRECTIONAL_LIGHTS; ++i)
    {
        vDirectionalLightDirection[i] = normalize(-DirectionalLightDirection[i]);
    }
#endif

#if KANZI_SHADER_NUM_POINT_LIGHTS
    for (int i = 0; i < KANZI_SHADER_NUM_POINT_LIGHTS; ++i)
    {
        vPointLightDirection[i] = positionWorld.xyz - PointLightPosition[i];
    }
#endif

#if KANZI_SHADER_NUM_SPOT_LIGHTS
    for (int i = 0; i < KANZI_SHADER_NUM_SPOT_LIGHTS; ++i)
    {
        vSpotLightDirection[i] = positionWorld.xyz - SpotLightPosition[i];
    }
#endif

#if USE_TANGENT_SPACE
    vTangent = normalize((kzNormalMatrix * vec4(posData.tangent.xyz, 0.0)).xyz);
#if KANZI_SHADER_USE_EXPLICIT_BINORMALS
    vBinormal = (kzNormalMatrix * vec4(kzBinormal, 0.0)).xyz;
#else
    vBinormal = cross(vNormal, vTangent) * posData.tangent.w;
#endif // KANZI_SHADER_USE_EXPLICIT_BINORMALS
#endif
    
#if KANZI_SHADER_USE_BASECOLOR_TEXTURE || KANZI_SHADER_USE_NORMALMAP_TEXTURE
    vTexCoord = kzTextureCoordinate0 * TextureTiling + TextureOffset;
#endif
}

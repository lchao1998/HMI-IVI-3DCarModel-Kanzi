precision mediump float;

attribute vec3 kzPosition;
attribute vec2 kzTextureCoordinate0;
attribute vec2 kzTextureCoordinate1;
attribute vec4 kzColor0;

uniform highp mat4 kzProjectionCameraWorldMatrix;
uniform vec2 TextureOffset;
uniform vec2 TextureTiling;

uniform mediump vec2 WaveHeight;
uniform mediump vec2 WaveLength;
uniform float WaveCrestOffset;
uniform float WaveCrestOffsetMiddle;
uniform float WaveCrestOffsetLower;
uniform float WaveTime;

varying vec2 vTexCoord;
varying vec2 vTexCoord2;
varying vec4 vColor;

void main()
{
    vTexCoord = (vec2(kzTextureCoordinate0.x,1.0-kzTextureCoordinate0.y) * TextureTiling - TextureOffset);
    vTexCoord2 = vec2(kzTextureCoordinate0.x,1.0-kzTextureCoordinate0.y) ;
    vColor = kzColor0;
    
    vec4 pos = vec4(kzPosition.xyz, 1.0);
    float WaveRange = smoothstep(1.0, 0.7, vTexCoord2.y);
    //Red VColor waves
    pos.z += WaveHeight.y * kzColor0.r * sin(pos.y * WaveLength.y + WaveTime + WaveCrestOffset) * WaveRange;
    pos.z += WaveHeight.x * kzColor0.r * sin(pos.x * WaveLength.x + WaveTime + WaveCrestOffset) * WaveRange;
    //Blue VColor waves
    pos.z += WaveHeight.y * kzColor0.g * sin(pos.y * WaveLength.y + WaveTime + WaveCrestOffsetMiddle) * WaveRange;
    pos.z += WaveHeight.x * kzColor0.g * sin(pos.x * WaveLength.x + WaveTime + WaveCrestOffsetMiddle) * WaveRange;
    //Green VColor waves
    pos.z += WaveHeight.y * kzColor0.b * sin(pos.y * WaveLength.y + WaveTime + WaveCrestOffsetLower) * WaveRange;
    pos.z += WaveHeight.x * kzColor0.b * sin(pos.x * WaveLength.x + WaveTime + WaveCrestOffsetLower) * WaveRange;
    //Scale of flow
    
    gl_Position = kzProjectionCameraWorldMatrix * vec4(pos.xyz, 1.0);
}
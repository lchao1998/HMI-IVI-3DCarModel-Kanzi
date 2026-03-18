#version 300 es
precision mediump float;

uniform highp mat4 kzProjectionCameraWorldMatrix;

in vec3 kzPosition;
in vec2 kzTextureCoordinate0;
uniform mediump vec2 TextureOffset;
uniform mediump vec2 TextureTiling;
uniform float kzTime;        // 时间变量

out vec2 vTexCoord;
void main()
{

    vTexCoord = kzTextureCoordinate0 * TextureTiling + vec2(TextureOffset.x, TextureOffset.y);

    vec3 pos = kzPosition;
      
    //pos.y += 0.001 * sin(pos.z * 100.0 + kzTime) ;
    //pos.y += 0.001 * sin(pos.x * 100.0 + kzTime) ;
    
    //pos.x += 0.015 * sin(pos.z * 20.0 + kzTime) ;
    
    gl_Position = kzProjectionCameraWorldMatrix * vec4(pos, 1.0);
}
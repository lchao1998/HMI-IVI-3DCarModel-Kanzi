#version 300 es
precision mediump float;

in vec3 kzPosition;
in vec2 kzTextureCoordinate0;

uniform highp mat4 kzProjectionCameraWorldMatrix;
uniform mediump vec2 TextureOffset;
uniform mediump vec2 TextureTiling;
uniform float kzTime; // 时间变量

out vec2 vTexCoord; //输出UV坐标
void main()
{

    vTexCoord = kzTextureCoordinate0 * TextureTiling + vec2(TextureOffset.x, TextureOffset.y);

    vec3 pos = kzPosition;
    
    //进行y轴上下方向的偏移
    pos.y += 0.001 * sin(pos.z * 20.0 + kzTime); 
    pos.y += 0.001 * sin(pos.x * 100.0 + kzTime);
    
    //进行y轴上下方向的偏移
    pos.x += 0.02 * sin(pos.z * 15.0 + kzTime);
    
    gl_Position = kzProjectionCameraWorldMatrix * vec4(pos, 1.0);
}
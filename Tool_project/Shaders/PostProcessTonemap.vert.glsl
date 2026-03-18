#version 300 es
precision mediump float;

in vec3 kzPosition;
in vec2 kzTextureCoordinate0;

uniform mediump float kzTime;

uniform highp mat4 kzProjectionCameraWorldMatrix;

out vec2 texcoord;
out vec2 smokecoord;

void main()
{
    texcoord = kzTextureCoordinate0;
    smokecoord = kzTextureCoordinate0 + vec2(kzTime);
    gl_Position = kzProjectionCameraWorldMatrix * vec4(kzPosition, 1.0);
}

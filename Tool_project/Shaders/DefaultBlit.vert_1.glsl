precision mediump float;

attribute vec3 kzPosition;
attribute vec2 kzTextureCoordinate0;
attribute vec3 kzNormal;

uniform highp mat4 kzProjectionCameraWorldMatrix;

varying vec2 vTexCoord;

varying vec3 m_Normal;

varying vec3 m_Position;

void main()
{
    vTexCoord = kzTextureCoordinate0;
    m_Normal = kzNormal;
    m_Position = kzPosition;
    gl_Position = kzProjectionCameraWorldMatrix * vec4(kzPosition, 1.0);
}

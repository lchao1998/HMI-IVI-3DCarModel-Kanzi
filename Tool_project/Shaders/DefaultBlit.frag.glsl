precision mediump float;

uniform sampler2D Texture0;
uniform sampler2D Texture1;
uniform float BlendIntensity;

varying vec2 vTexCoord;

void main()
{
    gl_FragColor = (texture2D(Texture0, vTexCoord) + texture2D(Texture1, vTexCoord)) *BlendIntensity;
}

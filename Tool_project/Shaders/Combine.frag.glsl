precision mediump float;

uniform sampler2D Texture0;
uniform sampler2D Texture1;
uniform sampler2D Texture2;
uniform sampler2D Texture3;

uniform lowp float Pass1Multiplier;
uniform lowp float Pass2Multiplier;
uniform lowp float Pass3Multiplier;
uniform lowp float Pass4Multiplier;

uniform lowp float Intensity;

varying mediump vec2 vTexCoord;

float rgb2luma(vec3 color)
{
	return 0.2126 * color.r + 0.715 * color.g + 0.0722 * color.b;
}

void main()
{
    vec3 color = texture2D(Texture0, vTexCoord).rgb * Pass1Multiplier;
    color += texture2D(Texture1, vTexCoord).rgb * Pass2Multiplier;
    color += texture2D(Texture2, vTexCoord).rgb * Pass3Multiplier;
    color += texture2D(Texture3, vTexCoord).rgb * Pass4Multiplier;
    
    gl_FragColor.rgba = vec4(color, rgb2luma(color));
}
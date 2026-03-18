#version 300 es

precision highp float;       
precision highp sampler2D;
#define DOT_CLIP 0.045
#define FLOAT8MAX 16384.0
#define FLOAT16MAX 32768.0
#define FLOAT32MAX 65504.0
#define saturateMediump(x) min(x, FLOAT32MAX)

in vec3 vNormal;
in vec3 vViewDirection;

#if KANZI_SHADER_USE_BASECOLOR_TEXTURE
in vec2 vTexCoord;
uniform sampler2D Texture;
#endif

#if KANZI_SHADER_NUM_SPOT_LIGHTS || KANZI_SHADER_NUM_POINT_LIGHTS || KANZI_SHADER_NUM_DIRECTIONAL_LIGHTS
in vec3 vSpec;
#endif

uniform samplerCube TextureCube;
uniform vec4        CubemapColor;
uniform highp samplerCube KanziPBR_Tex_Cube_Reflection, KanziPBR_Tex_Cube_Reflection_02;
uniform float BlendIntensity;
uniform mat4 EnvironmentTransform;

vec3 Fresnel(float f0,float c){
    vec3 F0 = vec3(abs ((1.0 - 1.5) / (1.0 + 1.5)));
    F0 = F0 * F0;
    vec3 f = F0 + ((vec3(1.0))-F0) * pow((1.3 * 1.0) - c, 5.0);
    return f;
}

vec3 whitePreservingLumaBasedReinhardToneMapping(vec3 color)
{
    float gamma = 1.0;
	float white = 2.2;
	float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
	float toneMappedLuma = luma * (1. + luma / (white*white)) / (1. + luma);
	color *= toneMappedLuma / luma;
	color = pow(color, vec3(1. / gamma));
	return color;
}

out vec4 outColor;

void main()
{
    vec3 color = vec3(0.0); 
    
#if KANZI_SHADER_USE_BASECOLOR_TEXTURE
    vec4 baseColor = texture2D(Texture, vTexCoord).rgba;
#else
    vec4 baseColor = vec4(1.0);
#endif

    color += baseColor.rgb;

    vec3 V = normalize(vViewDirection);
    vec3 N = normalize(vNormal);
    highp float hNdotV = max(0.045, dot(-V,N));
    highp float NdotV = max(0.045, dot(V,N));

    vec3 f = Fresnel(0.04,hNdotV);
    


#if KANZI_SHADER_NUM_SPOT_LIGHTS || KANZI_SHADER_NUM_POINT_LIGHTS || KANZI_SHADER_NUM_DIRECTIONAL_LIGHTS
    color *= 0.0;
    color += vSpec;
#endif
    

    vec3 R = (EnvironmentTransform * vec4(reflect(V, N), 1.0)).xyz;
    color += texture(KanziPBR_Tex_Cube_Reflection, R).rgb * CubemapColor.rgb;
    color *= clamp(f, 0.2, 0.7);
    float a = clamp(NdotV, 0.0, 0.98);

    outColor = vec4(whitePreservingLumaBasedReinhardToneMapping(saturateMediump(color)), clamp(a + 1. * BlendIntensity, 0.0, 1.0));
    //gl_FragColor = vec4(vec3(NdotV), 1.0);
}
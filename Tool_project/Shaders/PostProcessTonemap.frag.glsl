#version 300 es
precision mediump float;

uniform sampler2D tex;
uniform sampler2D smoke;
in vec2 texcoord;
in vec2 smokecoord;

uniform mediump vec3 kzCameraPosition;

in vec3 kzNormal;

out mediump vec4  fragColor;

#if KANZI_SHADER_USE_EXPOSURE
uniform mediump float Exposure;
#endif

///-------------------------------------------------------------------
/// BEGIN tonemap.glsl

#if KANZI_SHADER_TONEMAP_REINHARD
mediump vec3 Tonemap(highp vec3 color)
{
    return color/(1.0+color);
}

#elif KANZI_SHADER_TONEMAP_LINEAR
uniform float ToneMapLinearScale;
mediump vec3 Tonemap(highp vec3 color)
{
    return color / vec3(ToneMapLinearScale);
}

#elif KANZI_SHADER_TONEMAP_UNCHARTED
vec3 tonemap_uncharted_partial(vec3 color)
{
    const float a = 0.15;
    const float b = 0.50;
    const float c = 0.10;
    const float d = 0.20;
    const float e = 0.02;
    const float f = 0.30;
    return ((color*(a*color+c*b)+d*e)/(color*(a*color+b)+d*f))-e/f;
}

mediump vec3 Tonemap(highp vec3 color)
{
    const float w = 11.2;
    const float exposureBias = 2.0;
    color = tonemap_uncharted_partial(color * exposureBias);

    vec3 whiteScale = 1.0 / tonemap_uncharted_partial(vec3(w));
    return color * whiteScale;
}

#elif KANZI_SHADER_TONEMAP_ACES
mediump vec3 Tonemap(highp vec3 color)
{
    // Note that this is not the real aces curve, but an approximation.
    // True aces curve passes the color through a matrix and some other
    // more expensive calculations. The approximation is common in realtime
    // applications becuase of performance concerns.
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return clamp((color * (a * color + b)) / (color * (c * color + d) + e), 0.0, 1.0);
}
#elif KANZI_SHADER_TONEMAP_FILMIC
// This is the Hejl Richard Filmic tonemap. Note that it produces 
// gamma-corrected values. To handle this, we add a pow(c, 2.2) to
// convert it back to linear.
mediump vec3 Tonemap(highp vec3 color)
{
    color = max(vec3(0), color-0.004);
    color = (color * (6.2*color+0.5))/(color*(6.2*color+1.7)+0.06);
    return pow(color, vec3(2.2));
}
#endif


#define USE_TONEMAP (KANZI_SHADER_TONEMAP_LINEAR | KANZI_SHADER_TONEMAP_REINHARD | KANZI_SHADER_TONEMAP_UNCHARTED | KANZI_SHADER_TONEMAP_ACES | KANZI_SHADER_TONEMAP_FILMIC)


/// END tonemap.glsl
///-------------------------------------------------------------------

#if KANZI_SHADER_USE_GAMMA_CORRECTION
float LinearToSRGB(float src)
{
    if ( src < 0.0031308 )
    {
        return src * 12.92;
    }
    else
    {
        return 1.055 * pow(src, 1.0/2.4) - 0.055;
    }
}

vec3 LinearToSRGB(vec3 src)
{
    return vec3(
        LinearToSRGB(src.r),
        LinearToSRGB(src.g),
        LinearToSRGB(src.b));
}
#endif


void main()
{   
    float fresnel = pow(abs(dot(kzCameraPosition,kzNormal)),1.0);
    float opacity = abs(dot(texture(tex, texcoord).rgb,abs(kzNormal)));
    float mask = smoothstep(abs(dot(texture(smoke, smokecoord).rgb,abs(kzNormal))),0.0,0.5);
    
    vec4 srcColor = vec4(0.7,1.0,0.8,(fresnel*opacity*mask)*.150);
        
    //Only modify rgb channels.
    vec3 color = srcColor.rgb;
    #if KANZI_SHADER_USE_EXPOSURE
    color *= pow(2.0, Exposure);
    #endif

    #if USE_TONEMAP
    color = Tonemap(color);
    #endif

    #if KANZI_SHADER_USE_GAMMA_CORRECTION
    color = LinearToSRGB(color);
    #endif

    // alpha just gets passthrough.
    fragColor = srcColor;
}

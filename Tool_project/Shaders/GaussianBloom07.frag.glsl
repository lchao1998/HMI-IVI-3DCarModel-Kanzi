#version 300 es
precision mediump float;

in vec2 vTexCoord;

uniform sampler2D Texture0;
uniform float kzTextureWidth0;
uniform float kzTextureHeight0;
uniform lowp vec2 BlurDirection;
uniform float BlurRadius;
uniform float BlendIntensity;
uniform float Intensity;

out vec4 outColor;

#if KERNEL_SIZE == 5
const float GAUSSIAN_KERNEL[5] = float[5]
(
	0.153388,
	0.221461,
	0.250301,
	0.221461,
	0.153388
);
#elif KERNEL_SIZE == 7
const float GAUSSIAN_KERNEL[7] = float[7]
(
    0.028116,
    0.102883,
    0.223922,
    0.290156,
    0.223922,
    0.102883,
    0.028116
);
#elif KERNEL_SIZE == 9
const float GAUSSIAN_KERNEL[9] = float[9]
(
	0.028532,
	0.067234,
	0.124009,
	0.179044,
	0.20236,
	0.179044,
	0.124009,
	0.067234,
	0.028532
);
#elif KERNEL_SIZE == 13
const float GAUSSIAN_KERNEL[13] = float[13]
(
	0.009329,
	0.022234,
	0.045248,
	0.078632,
	0.116686,
	0.147866,
	0.160011,
	0.147866,
	0.116686,
	0.078632,
	0.045248,
	0.022234,
	0.009329
);
#elif KERNEL_SIZE == 15
const float GAUSSIAN_KERNEL[15] = float[15]
(
	0.00332,
	0.009267,
	0.022087,
	0.044948,
	0.078109,
	0.115911,
	0.146884,
	0.158949,
	0.146884,
	0.115911,
	0.078109,
	0.044948,
	0.022087,
	0.009267,
	0.00332
);
#endif

vec4 gaussianBlur(mediump vec2 coord, lowp vec2 dir)
{
    vec2 texel = vec2(1.0 / kzTextureWidth0, 1.0 / kzTextureHeight0);
    float hstep = dir.x * texel.x * BlurRadius;
    float vstep = dir.y * texel.y * BlurRadius;
    vec4 sum = vec4(0.0);
    
    for(int i = 0; i < int(GAUSSIAN_KERNEL.length()); i++)
    {
        float pixelOffset = (float(i) - floor(float(GAUSSIAN_KERNEL.length()) * 0.5));
        sum += texture(Texture0, vec2(coord.x + pixelOffset * hstep, coord.y + pixelOffset * vstep)) * GAUSSIAN_KERNEL[i];
    }
    
    return sum * Intensity;    
}

void main()
{
    vec4 retColor = gaussianBlur(vTexCoord, BlurDirection);
    
    outColor = retColor;
}
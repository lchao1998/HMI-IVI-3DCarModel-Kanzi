precision mediump float;

uniform sampler2D Texture;
uniform float BlendIntensity;
uniform float hueShiftAmount;
uniform lowp vec4 Color;
uniform mediump vec4 EdgeFadeX;
uniform mediump vec4 EdgeFadeY;


uniform float time; // Uniform variable to control time
uniform float amplitude; // Uniform variable to control the amplitude of the noise
uniform float frequency; // Uniform variable to control the frequency of the noise
uniform int octaves; // Number of noise octaves
uniform float persistence; // Controls decrease in amplitude

uniform float NoiseAmount; 
uniform float GlowAmount; 
uniform float AdditionalGlowAmount;
uniform float CutOut;

varying vec2 vTexCoord;
varying vec2 vTexCoord2;
varying vec4 vColor;



float rand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u*u*(3.0-2.0*u);

    float res = mix(
        mix(rand(ip), rand(ip + vec2(1.0, 0.0)), u.x),
        mix(rand(ip + vec2(0.0, 1.0)), rand(ip + vec2(1.0, 1.0)), u.x),
        u.y
    );

    return res*res;
}

float fBm(vec2 uv) {
    float total = 0.0;
    float maxAmplitude = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    
    for(int i = 0; i < octaves; i++) {
        total += noise(uv * frequency) * amplitude;
        
        maxAmplitude += amplitude;
        amplitude *= persistence;
        frequency *= 2.0;
    }
    
    return total / maxAmplitude;
}

vec3 rgbToHsv(vec3 rgb) {
    float cmax = max(max(rgb.r, rgb.g), rgb.b);
    float cmin = min(min(rgb.r, rgb.g), rgb.b);
    float delta = cmax - cmin;

    vec3 hsv = vec3(0.0, 0.0, cmax);
    if (delta > 0.0) {
        if (cmax == rgb.r) {
            hsv.x = mod((rgb.g - rgb.b) / delta, 6.0);
        } else if (cmax == rgb.g) {
            hsv.x = (rgb.b - rgb.r) / delta + 2.0;
        } else {
            hsv.x = (rgb.r - rgb.g) / delta + 4.0;
        }
        hsv.x /= 6.0;
        if (cmax > 0.0) {
            hsv.y = delta / cmax;
        }
    }

    return hsv;
}


vec3 hsvToRgb(vec3 hsv) {
    vec3 rgb = vec3(hsv.z);

    if (hsv.y > 0.0) {
        float h = hsv.x * 6.0;
        int i = int(h);
        float f = h - float(i);
        float p = hsv.z * (1.0 - hsv.y);
        float q = hsv.z * (1.0 - hsv.y * f);
        float t = hsv.z * (1.0 - hsv.y * (1.0 - f));

        if (i == 0) {
            rgb = vec3(hsv.z, t, p);
        } else if (i == 1) {
            rgb = vec3(q, hsv.z, p);
        } else if (i == 2) {
            rgb = vec3(p, hsv.z, t);
        } else if (i == 3) {
            rgb = vec3(p, q, hsv.z);
        } else if (i == 4) {
            rgb = vec3(t, p, hsv.z);
        } else {
            rgb = vec3(hsv.z, p, q);
        }
    }

    return rgb;
}


void main()
{    
    vec2 uv = vTexCoord2; // Normalize pixel coordinates to [0, 1]
    float m = smoothstep(0.0,.5,uv.x) * (1.0-smoothstep(0.5,1.0,uv.x)) ;
    
    //Masking
    float m_side = pow(smoothstep(0.0,.5,uv.x) * (1.0-smoothstep(0.5,1.0,uv.x)),0.5);
    float m_top = pow(smoothstep(0.0,0.9,1.0-uv.y),0.8)* pow(smoothstep(0.0,0.2,uv.y),.80);
    
    
    vec2 uv_circle = vec2(vTexCoord2.x*0.2, vTexCoord2.y - 0.3);
    
    float d = length(uv_circle);
    float r = 0.5;
    float c = smoothstep(r,-0.3,d)*CutOut;
    
     float cut_mask = max((1.0-pow(c,4.0)*10.0),0.0);
     
    uv *= frequency; // Apply frequency   
    float n =  pow(fBm(uv - time),1.0); // Compute fBm and shift the noise over time
    vec4 noise = vec4(vec3(max(n-0.0,0.0)), 1.0) * amplitude ;
  
    vec4 tex = texture2D(Texture, vec2(vTexCoord.x + noise.r ,vTexCoord.y + noise.r ));
    float alpha = ((tex.r + tex.b * GlowAmount) + pow(noise.r,2.0) * 5.0) * m_side * m_top * cut_mask ;
    
    
    vec4 col = tex.r * Color ;
    float m_hue = tex.g + pow(tex.b,1.0); //hue shift mask
    
    vec3 hue = col.rgb * (tex.g);
    
     // Convert RGB to HSV
    vec3 hsv = rgbToHsv(hue);

    // Shift the hue component
    hsv.x = mod(hsv.x + hueShiftAmount, 1.0);

    // Convert HSV back to RGB
    vec3 rgb = hsvToRgb(hsv);
    
    vec3 addGlow = max((1.0-pow(vTexCoord2.y,0.1)) * pow(m_side,.5) * m_top * max(Color.rgb - pow(noise.r ,10.0),0.0)  * AdditionalGlowAmount  * (alpha +0.5),0.0) * cut_mask;
     
    vec3 result = col.rgb * (1.0 - (tex.g)) + rgb  + tex.b *0.5;
    
   float edgeFade = smoothstep(EdgeFadeX.x, EdgeFadeX.y, vTexCoord2.x) * smoothstep(EdgeFadeX.z, EdgeFadeX.w, vTexCoord2.x);
    
    edgeFade *= smoothstep(EdgeFadeY.x, EdgeFadeY.y, vTexCoord2.y) * smoothstep(EdgeFadeY.z, EdgeFadeY.w, vTexCoord2.y);
    

   
    
    
    vec3 compose = col.rgb * (1.0 - (m_hue)) + rgb; 
    
    
    
    gl_FragColor = (vec4(compose * alpha, alpha) * edgeFade + vec4(addGlow.rgb,1.0)) * BlendIntensity  ;

}

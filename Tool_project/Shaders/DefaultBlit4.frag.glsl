precision mediump float;

uniform float BlendIntensity;

varying vec2 vTexCoord;

uniform mediump vec3 kzCameraPosition;
varying vec3 m_Normal;
varying vec3 m_Position;
uniform sampler2D Texture;

uniform mediump float kzTime;

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

float fire(vec2 n) {
    return noise(n) + noise(n * 2.1) * .6 + noise(n * 5.4) * .42;
}


void main()
{
    float a = -140.0;

    vec4 m_Color = vec4(0.1,0.1,15.0,(m_Position.y + 150.0)/400.0);
    
    if(m_Position.y > 50.)
    {
        float b = (m_Position.y-50.0)/200.0+1.0;
        m_Color *= b;
    }
    
    //m_Color.a *= abs(dot(kzCameraPosition,m_Normal));
    if(m_Position.y < a)
    {
        m_Color.a = 0.0;
    }
    
    
    vec3 rg = texture2D(Texture, (vTexCoord - (kzTime*0.005))).rgb;
    

 
        
    //vec4 mcolor = vec4(fire(vTexCoord- kzTime*0.1));
    
    gl_FragColor = vec4(vec3(rg.r)*0.5,0.4) * m_Color *BlendIntensity;
       

}

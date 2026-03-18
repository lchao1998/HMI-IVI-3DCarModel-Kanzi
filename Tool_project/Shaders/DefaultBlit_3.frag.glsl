precision mediump float;

uniform float BlendIntensity;

varying vec2 vTexCoord;

uniform mediump vec3 kzCameraPosition;
varying vec3 m_Normal;
varying vec3 m_Position;
uniform sampler2D Texture;
uniform sampler2D Texture1;

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
    float a = -0.9;

    vec4 m_Color = vec4(15.0,15.0,15.0,(m_Position.z + 1.0)/2.0);
    
    if(m_Position.z > 0.)
    {
        float b = (m_Position.z-0.0)/1.0+1.0;
        m_Color.rgb *= b;
    }
    
    //m_Color.a *= abs(dot(kzCameraPosition,m_Normal));
    if(m_Position.z < a)
    {
        m_Color.a = 0.0;
    }    
    
    vec4 color1 = texture2D(Texture1, vTexCoord);
    
    vec3 rg = texture2D(Texture, vec2(vTexCoord.x  - (kzTime*0.05),vTexCoord.y - (kzTime*0.05))).rgb;
    
    gl_FragColor = vec4(vec3(rg)* 0.1,0.5) * m_Color * color1 * BlendIntensity;
       

}
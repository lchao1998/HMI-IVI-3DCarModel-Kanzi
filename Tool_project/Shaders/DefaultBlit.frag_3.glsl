precision mediump float;

uniform float BlendIntensity;

varying vec2 vTexCoord;
uniform mediump vec3 kzCameraPosition;

varying vec3 m_Normal;
varying vec3 m_Position;
uniform sampler2D Texture;
uniform sampler2D Texture1;

uniform mediump float kzTime;
uniform mediump float test;

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
    vec4 m_Color = vec4(15.0,15.0,15.0,0.0);
    
    if(m_Position.z > 0.0)
    {
        float b = (m_Position.z-0.0)/1.0+1.0;
        m_Color.rgb *= b;
    }
    
    if(m_Position.z > 0.8)
    {
        m_Color.a = (m_Position.z-0.8) * 1.0 +0.5;
        
        if(rand(vTexCoord + kzTime*0.000001) < 0.1)
        {
            m_Color.a *= 0.0;
        }
        else
        {
            m_Color.a *= (m_Position.z -0.2) +0.2;
        }
    }
    else if(m_Position.z > 0.7 &&m_Position.z <= 0.8)
    {
        m_Color.a = (m_Position.z-0.7) * 6.0 + 0.05;
        
        if(rand(vTexCoord + kzTime*0.000001) < 0.05)
        {
            m_Color.a *= 0.1;
        }
        else
        {
            m_Color.a *= (m_Position.z -0.7)*4.5 +0.2;
        }
    }
    else if(m_Position.z <= 0.7)
    {
        m_Color.a = (m_Position.z +1.0)/1.35*0.05;
        if(rand(vTexCoord + kzTime*0.000001) < 0.1)
        {                   
            m_Color.a *= 0.0;
        }
        else
        {
            m_Color.a *= 0.0;
        }                    

    }
    else if(m_Position.z < -0.9)
    {
        m_Color.a = 0.0;
    }  
    
    
    vec4 color1 = texture2D(Texture1, vTexCoord);
      
    vec3 color2 = texture2D(Texture, vec2(vTexCoord.x + kzTime*0.01,vTexCoord.y + kzTime*0.01)).rgb;
    

    
    gl_FragColor = vec4(vec3(color2.r)* 0.1,1.0) * m_Color * color1 * BlendIntensity;
    //gl_FragColor = vec4(vec3(fire(vTexCoord + kzTime*0.1)*0.1),1.0) * BlendIntensity;
    
              
}
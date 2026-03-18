precision mediump float;

uniform float BlendIntensity;

varying vec2 vTexCoord;

uniform mediump vec3 kzCameraPosition;
varying vec3 m_Normal;
varying vec3 m_Position;

uniform mediump float kzTime;


void main()
{
    float a = -140.0;

    vec4 m_Color = vec4(0.0,0.0,0.0,(m_Position.y + 150.0)/400.0);
    
    if(m_Position.y > 50.)
    {
        float b = (m_Position.y-50.0)/200.0+0.1;
        m_Color.rgb += b;
    }
    
    //m_Color.a *= abs(dot(kzCameraPosition,m_Normal));
    if(m_Position.y < a)
    {
        m_Color.a = 0.0;
    }  
    
    vec4 mcolor = vec4(0.0);
    //mcolor.a *= abs(dot(kzCameraPosition,m_Normal));
          
    if(m_Position.x < 10.0 && m_Position.x > -10.0 && m_Position.z < 10.0 && m_Position.z > -10.0)
    {
        mcolor = vec4(0.5,0.6,0.6,1.0);
    }

    
    gl_FragColor = mcolor * BlendIntensity;
       

}

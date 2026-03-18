precision mediump float;

uniform float BlendIntensity;

varying vec2 vTexCoord;

uniform mediump vec2 LightAngle;
uniform mediump float LightRange;

uniform mediump float kzTime;

void main()
{    
    vec4 finalColor = vec4(0.85 + (sin(kzTime)/10.0)) * pow(max(dot(normalize(LightAngle),normalize(vec2(vTexCoord.x,vTexCoord.y))),0.),LightRange);
    
    gl_FragColor = finalColor;

}

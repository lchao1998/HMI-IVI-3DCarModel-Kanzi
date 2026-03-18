#version 300 es

precision highp float;

in vec3 kzPosition;
in vec3 kzNormal;

uniform highp mat4 kzProjectionCameraWorldMatrix;
uniform highp mat4 kzWorldMatrix;
uniform highp mat4 kzNormalMatrix;
uniform highp vec3 kzCameraPosition;

#if KANZI_SHADER_USE_BASECOLOR_TEXTURE
in vec2 kzTextureCoordinate0;
out vec2 vTexCoord;
uniform vec2 TextureOffset;
uniform vec2 TextureTiling;
#endif

#if KANZI_SHADER_NUM_DIRECTIONAL_LIGHTS
uniform vec3 DirectionalLightDirection[KANZI_SHADER_NUM_DIRECTIONAL_LIGHTS];
uniform    vec4 DirectionalLightColor     [KANZI_SHADER_NUM_DIRECTIONAL_LIGHTS];
#endif

#if KANZI_SHADER_NUM_POINT_LIGHTS
uniform vec4 PointLightColor[KANZI_SHADER_NUM_POINT_LIGHTS];
uniform vec3 PointLightAttenuation[KANZI_SHADER_NUM_POINT_LIGHTS];
uniform vec3 PointLightPosition[KANZI_SHADER_NUM_POINT_LIGHTS];
#endif

#if KANZI_SHADER_NUM_SPOT_LIGHTS
uniform vec3  SpotLightPosition[KANZI_SHADER_NUM_SPOT_LIGHTS];
uniform vec4  SpotLightColor         [KANZI_SHADER_NUM_SPOT_LIGHTS];
uniform vec3  SpotLightDirection     [KANZI_SHADER_NUM_SPOT_LIGHTS];
uniform vec3  SpotLightConeParameters[KANZI_SHADER_NUM_SPOT_LIGHTS];
uniform vec3  SpotLightAttenuation   [KANZI_SHADER_NUM_SPOT_LIGHTS];
#endif

uniform float BlendIntensity;

out vec3 vViewDirection;
out vec3 vSpec;
out vec3 vNormal; 

void main()
{
    
    gl_Position = kzProjectionCameraWorldMatrix * vec4(kzPosition.xyz, 1.0);  
    vec4 positionWorld = kzWorldMatrix * vec4(kzPosition.xyz, 1.0);
    vViewDirection = positionWorld.xyz - kzCameraPosition;
    vec3 V = normalize(vViewDirection);
    vec4 Norm = kzNormalMatrix * vec4(kzNormal, 0.0);
    vNormal = normalize(Norm.xyz);

    
#if KANZI_SHADER_NUM_DIRECTIONAL_LIGHTS || KANZI_SHADER_NUM_POINT_LIGHTS || KANZI_SHADER_NUM_SPOT_LIGHTS
    int i;
    vec3 L = vec3(1.0, 0.0, 0.0);
    vec3 H = vec3(1.0, 0.0, 0.0);
    float LdotN, NdotH;
    float specular;
    vec3 c;
    float d, attenuation;
    vSpec = vec3(0.0);    
    vec3 pointLightDirection;  
    vec3 spotLightDirection;
#endif   

    
    
#if KANZI_SHADER_NUM_DIRECTIONAL_LIGHTS
    for (i = 0; i < KANZI_SHADER_NUM_DIRECTIONAL_LIGHTS; ++i)
    {
        if(length(DirectionalLightDirection[i])> 0.01)
        {
            L = normalize(-DirectionalLightDirection[i]);
        }
        H = normalize(-V + L);
        LdotN = max(0.0, dot(L, vNormal));
        NdotH = max(0.0, dot(vNormal, H));        
        specular = pow(NdotH, 20.0);
        vSpec += vec3(0.322) * specular * DirectionalLightColor[i].rgb;        
    }
#endif
    
#if KANZI_SHADER_NUM_POINT_LIGHTS
    for (i = 0; i < KANZI_SHADER_NUM_POINT_LIGHTS; ++i)
    {
        pointLightDirection = positionWorld.xyz - PointLightPosition[i];
        L = normalize(-pointLightDirection);
        H = normalize(-V + L);
        LdotN = max(0.0, dot(L, vNormal));
        NdotH = max(0.0, dot(vNormal, H));
        specular = pow(NdotH, 30.0);
        c = PointLightAttenuation[i];
        d = length(pointLightDirection);
        attenuation = 1.0 / max(0.001, (c.x + c.y * d + c.z * d * d));        
        vSpec +=  vec3(0.322) * specular * attenuation * PointLightColor[i].rgb;
        
    }
#endif

#if KANZI_SHADER_NUM_SPOT_LIGHTS
    for (i = 0; i < KANZI_SHADER_NUM_SPOT_LIGHTS; ++i)
    {
        spotLightDirection = positionWorld.xyz - SpotLightPosition[i];
        L = normalize(-spotLightDirection);
        LdotN = dot(L, vNormal);
        
        if(LdotN > 0.0)
        {
            float cosDirection = dot(L, -SpotLightDirection[i]);
            float cosOuter = SpotLightConeParameters[i].x;
            float t = cosDirection - cosOuter;
            if (t > 0.0)
            {
                vec3 H = normalize(-V + L);
                float NdotH = max(0.0, dot(vNormal, H));
                float specular = pow(NdotH, 30.0);
                vec3  c = SpotLightAttenuation[i];
                float d = length(spotLightDirection);
                float denom = (0.01 + c.x + c.y * d + c.z * d * d) * SpotLightConeParameters[i].z;
                float attenuation = min(t / denom, 1.0);
                vSpec += vec3(0.322) * specular * attenuation * SpotLightColor[i].rgb;
            }
        }        
    }    
#endif

    vSpec += vec3(0.0);
    
#if KANZI_SHADER_USE_BASECOLOR_TEXTURE
    vTexCoord = kzTextureCoordinate0 * TextureTiling + TextureOffset;
#endif
}
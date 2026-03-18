precision mediump float;

uniform sampler2D Texture;
uniform float BlendIntensity;
uniform lowp vec4 Ambient;
uniform mediump float kzTime;

varying vec2 vTexCoord;

uniform lowp vec3 BeamPostion;
uniform lowp vec4 BeamColor;
mat3 BeamRotation;

const float NOTHING = -0.1;

const float LIGHT_BASE_W = 0.19;
const float CONE_W = 0.22;

const int MAX_STEPS = 250;
const float MIN_STEP = 0.0052;
const float FAR = 0.3;

const float LIGHT_POW = 2.5;
const float LIGHT_INTENS = 0.25;
const float FLOOR_Y = -0.17;

mat3 rotx(float a) 
{ 
    mat3 rot; 
    rot[0] = vec3(1.0, 0.0, 0.0); 
    rot[1] = vec3(0.0, cos(a), -sin(a)); 
    rot[2] = vec3(0.0, sin(a), cos(a)); 
    return rot; 
}

// noise from iq's hell shader
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D(Texture, (uv)).yx;
	return mix( rg.x, rg.y, f.z ) - 0.5;
} 

float sdCappedCylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

vec2 maplight(vec3 orp)
{
    float t = kzTime * 0.005;
    float minm = 10000.0;
    float mm = 10000.0;
    float hit_ids = 0.0;
    
	    vec3 rp = orp;
	    vec3 _rp = rp;
        rp += BeamPostion;
        rp *= BeamRotation;
        
        float m = sdCappedCylinder(rp, vec2(CONE_W, 1.0));

        float l = -LIGHT_BASE_W + length(rp) * 0.2;
        m -= l;
        float d = dot(rp, vec3(0.0, -1.0, 0.0));
        
        if( m < 0.0 && d >= 0.0)
        {
            vec3 uv = _rp + vec3(t, t, 0.0);
            float n = noise(uv * 10.0) - 0.5;
            
            uv = _rp + vec3(t * 1.2, 0.0, 0.0);
            n += noise(uv * 22.50) * 0.5;

            uv = _rp + vec3(t * 2.0, 0.0, 0.0);
            n += noise(uv * 52.50) * 0.5;
            
            uv = _rp + vec3(t * 2.8, 0.0, 0.0);
            n += noise(uv * 152.50) * 0.25;

            mm = min(n, m);
            mm = min(mm, -0.2);
            hit_ids = 1.0;

        }
        minm = min(abs(m), minm);
    
    if(hit_ids > 0.0)
    {
        return vec2(mm, hit_ids);
    }
    
    return vec2(minm, NOTHING);

}

void colorize(in vec4 fgc, in vec3 pos, in vec4 spotcol, float musiccolor, inout vec4 color)
{
    float flf = inversesqrt(length(pos));
    flf = pow(flf, LIGHT_POW) * LIGHT_INTENS;
    color += fgc * flf * spotcol * musiccolor;
    
}

bool trace(in vec3 ro, in vec3 rd, inout vec4 color)
{
    color = vec4(0.0);
    vec3 rp = ro;
    float h = 0.0;
    float musiccolor = 0.1;
    
    vec4 spcol1 = BeamColor + vec4(0.8, 0.8, 0.8, 0.0);
    
    for (int i = 0; i < MAX_STEPS; ++i)
    {
        rp += rd * max(MIN_STEP, h * 0.5);
        vec2 hp = maplight(rp);
        h = hp.x;
        
        if(rp.z > FAR)
        {
            return false;
        }
        
        if(h < 0.0)
        {
            vec4 fgc = vec4(abs(h * 0.05));
            

            colorize(fgc, (-BeamPostion - rp), spcol1, musiccolor, color); 
           			            
            
            if(rp.y < FLOOR_Y && rp.y > FLOOR_Y - 0.0017)
            {
                vec4 spcol = spcol1;

                color += vec4(0.1, 0.1, 0.1, 0.0) * spcol * musiccolor;
                return true;
            }         
            
            if(rp.y < FLOOR_Y)
            {
                color = vec4(0.0);
                return true;
            }            
        }
    }
    
    return false;
}


void main()
{
    vec2 uv = vTexCoord;
    
    vec2 m = vec2(0.0, 0.0);
    BeamRotation = rotx(m.y);       

    vec3 rd = (vec3(uv - vec2(0.5), 1.0));
    rd = normalize(rd);
    gl_FragColor = vec4(0.0);
    trace(vec3(0.0, 0.0, -1.0), rd, gl_FragColor);
}

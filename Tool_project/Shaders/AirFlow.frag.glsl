#version 300 es
precision mediump float;

in vec2 vTexCoord; //输入UV坐标

uniform float kzTime; // 时间变量
uniform float BlendIntensity; //混合强度

uniform vec4 bgColor; //基础背景颜色
uniform vec4 glowColor; //高光背景颜色
uniform float FlowSpeed; //光束流动速度 : 默认值0.3
uniform sampler2D TextureNoise; // 噪声贴图
uniform bool glowFlag; //点击高亮的标志
uniform float glowFactor; //高亮系数：默认值30
uniform float glowNoise; //高亮噪声显示控制，1：显示碎片化；0：不显示碎片化

out vec4 outColor; //输出最终颜色

// IQ式噪声函数
vec2 hash(vec2 p) {
    p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
    return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise(vec2 p) {
    const float K1 = 0.366025404;
    const float K2 = 0.211324865;
    
    vec2 i = floor(p + (p.x+p.y)*K1);
    vec2 a = p - i + (i.x+i.y)*K2;
    vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0*K2;
    
    vec3 h = max(0.5-vec3(dot(a,a), dot(b,b), dot(c,c)), 0.0);
    vec3 n = h*h*h*h*vec3(dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    
    return dot(n, vec3(70.0));
}

// 生成Y轴长、X轴短的光束
// 参数：uv坐标；光束在x轴的位置；x轴光束宽度；y轴光束长度；流动速度
float beam(vec2 uv, float beamX, float Width, float Length, float speed) {
    float beamY = fract(speed ); //光束Y轴起始位置；由speed的小数部分控制
    
    beamY = mix(beamY, speed + fract(kzTime * FlowSpeed), 1.0 - step(0.5, speed)); //speed小于0.5的光束进行Y轴流动

    // 添加噪声扰动
    vec2 noiseUV = uv * vec2(3.0, 1.0) + sin(kzTime);
    float distortion = noise(noiseUV) * 0.2 * 0.1;
    
    distortion *= 1.0 - ((1.0 - step(0.05, beamX)) + step(0.95, beamX)); //中心位置不进行扰动，保持左右移动一致性
    
    // 光束形状（Y轴长，X轴短）
    float yBeam = smoothstep(beamY - 0.05, beamY, uv.y) - 
                  smoothstep(beamY, beamY + Length, uv.y);
    
    // X轴方向宽度限制（窄光束）
    float xBeam = smoothstep(beamX - Width + distortion, beamX + distortion, uv.x) - 
                  smoothstep(beamX + distortion, beamX + Width + distortion, uv.x);
    
    float beamShape = yBeam * xBeam; // 合并形状
    
    return beamShape;
}

// 计算光束效果的函数
vec3 calculateBeamEffect(vec2 uv) {
    // 添加多道光束
    float beam1 = beam(uv, 0.2, 0.02, 0.2, 0.35) + beam(uv, 0.78, 0.02, 0.1, 0.25); // 边缘光束
    
    float beam2 = beam(uv, 0.05, 0.05, 0.5, 0.3) + beam(uv, 0.45, 0.05, 0.5, 0.3); //左侧淡光束
    
    float beam3 = beam(uv, 0.15, 0.05, 0.5, 0.28) + beam(uv, 0.35, 0.03, 0.5, 0.28); //左侧强光束
    
    float beam4 = beam(uv, 0.15, 0.03, 0.5, 0.32) + beam(uv, 0.35, 0.03, 0.5, 0.32); //左侧最强光束
    
    float beam5 = beam(uv, 1.0, 0.01, 0.3 ,0.2) + beam(uv, 0.5, 0.02, 0.5 ,0.2) + beam(uv, 0.0, 0.01, 0.3 ,0.2) ; //中心强光束
    
    float beam6 = beam(uv, 0.99, 0.1, 0.01 ,0.35) + beam(uv, 0.52, 0.05, 0.01 ,0.35); //中心淡光束
    
    float beam7 = beam(uv, 0.9, 0.03, 0.2 ,0.27) + beam(uv, 0.4, 0.03, 0.5 ,0.27); //中心最强光束

    float beam8 = beam(uv, 0.9, 0.1, 0.3 ,0.2) + beam(uv, 0.6, 0.1, 0.3 ,0.2); //右侧淡光束
    
    float beam9 = beam(uv, 0.9, 0.03, 0.2 ,0.25) + beam(uv, 0.6, 0.03, 0.2 ,0.25); //右侧强光束
    
   
    //底层固定光束
    float beam10 = beam(uv, 0.0, 0.07, 1.0, 0.5) + beam(uv, 0.15, 0.05, 1.0, 0.5) + beam(uv, 1.0, 0.07, 1.0, 0.5) + beam(uv, 0.8, 0.05, 1.0, 0.5) +
                   beam(uv, 0.5, 0.07, 1.0, 0.5) + beam(uv, 0.35, 0.05, 1.0, 0.5) + beam(uv, 0.7, 0.05, 1.0, 0.5); 
    
    vec3 color1 = vec3(5.0); //边缘光束亮度
    vec3 color2 = vec3(0.3); //左侧淡光束亮度
    vec3 color3 = vec3(0.6); //左侧强光束亮度
    vec3 color4 = vec3(1.0); //左侧最强光束亮度
    vec3 color5 = vec3(0.8); //中心强光束亮度
    vec3 color6 = vec3(0.2); //中心淡光束亮度
    vec3 color7 = vec3(0.5); //中心最强光束亮度
    vec3 color8 = vec3(0.5); //右侧淡光束亮度
    vec3 color9 = vec3(1.0); //右侧强光束亮度

    vec3 color10 = vec3(0.8); //底层固定光束亮度
    
    //高亮时改变底层光束宽度以及亮度
    if(glowFlag == true)
    {
        beam10 = beam(uv, 0.0, 0.01, 1.0, 0.5) + beam(uv, 0.15, 0.05, 1.0, 0.5) + beam(uv, 1.0, 0.07, 1.0, 0.5) + beam(uv, 0.8, 0.05, 1.0, 0.5) +
                 beam(uv, 0.5, 0.01, 1.0, 0.5) + beam(uv, 0.35, 0.05, 1.0, 0.5) + beam(uv, 0.7, 0.05, 1.0, 0.5); 
        color10 = vec3(0.2);
    }
        
    // 合并光束强度
    return beam1 * color1 + beam2 * color2 + beam3 * color3 + beam4 * color4 + 
           beam5 * color5 + beam6 * color6 + beam7 * color7 + beam8 * color8 + 
           beam9 * color9 + beam10 * color10;           

}

// 光束效果模糊处理
vec3 blurBeam(vec2 uv) {
    float blurSize = 0.02; // 控制模糊强度
    
    // 高光时增强模糊强度
    if(glowFlag == true)
    {
        blurSize = 0.1; 
    }
    vec3 sum = vec3(0.0);
    const int samples = 9;
    vec2 offsets[samples] = vec2[](
        vec2(-1,-1), vec2(-1,0), vec2(-1,1),
        vec2(0,-1),  vec2(0,0),  vec2(0,1),
        vec2(1,-1),  vec2(1,0),  vec2(1,1)
    );
    float kernel[samples] = float[](
        1.0/16.0, 2.0/16.0, 1.0/16.0,
        2.0/16.0, 4.0/16.0, 2.0/16.0,
        1.0/16.0, 2.0/16.0, 1.0/16.0
    );
    
    for(int i = 0; i < samples; i++) {
        vec2 offset = offsets[i] * blurSize;
        sum += calculateBeamEffect(uv + offset) * kernel[i];
    }
    return sum;
}

void main() {
    vec2 uv = vTexCoord;
    
    vec3 beamEffect = blurBeam(uv); //生成光束
    
    vec3 color = vec3(0.0);
    vec4 noise = texture(TextureNoise, vec2(uv.x,uv.y - kzTime * 0.1));
    color += step(0.8,noise.b); //控制碎片化显示的密度
    
    float alpha1 = pow((1.0 - uv.y) * 1.5,1.0); //底层背景的透明度
    
    float alpha2 = pow((1.0 - uv.y) * 2.0,1.9); //光束区域的透明度
    
    vec4 finalColor = vec4((bgColor.rgb + color * glowNoise) * alpha1 + beamEffect * alpha2 , alpha1); //颜色混合
    
    //高亮显示
    if(glowFlag == true)
    {   
        alpha1 = pow(1.0 - uv.y,2.0);
        alpha2 = pow((1.0 - uv.y) * 2.0,3.0);
        
        finalColor = vec4((glowColor.rgb + color) * alpha1 + beamEffect * alpha2, alpha1) * glowFactor;
    }

    // 最终颜色混合
    outColor =  finalColor * BlendIntensity;  
}
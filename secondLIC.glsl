#include "shared/common.glsl"
#iChannel0 "file://D:/SHADER/LIC.glsl"
#iChannel1 "file://D:/SHADER/edgetangentflow.glsl"
#iChannel2 "file://D:/SHADER/test.png"


#define PI 3.14159265359
#define R iResolution
#define T(u) texture(iChannel0, u).rgb
#define D(u) (texture(iChannel1, u).xy)

float fetchDoG(vec2 pos) {
    vec4 dogSample = texture(iChannel0, pos);
    // Assuming DoG is grayscale; if RGB, average the channels
    return dot(dogSample.rgb, vec3(0.333));
}

vec2 fetchNewDirection(vec2 pos) {
    vec4 dogSample = texture(iChannel1, pos);
    // Assuming DoG is grayscale; if RGB, average the channels
    return normalize(dogSample.xy);
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalize pixel coordinates (0 to 1)
    vec2 uv = fragCoord / iResolution.xy;
    
    // Initialize accumulation variables
    

    float I = 0.0;
    float sum = .0;

    float sigma_m = 1.0;
    float w = gaussian1d(0., sigma_m);

    I += grayScale(T(uv).rgb)*w;
    sum += w;

    vec2 dir = D(uv);
    vec2 where = uv + normalize(dir)/R.xy;
    
    // Trace forward along the flow
    for(float i = 1.0; i < (10.*sigma_m + 1.); i++) {
        w = gaussian1d(i, sigma_m);
        I += grayScale(T(where).rgb)*w;
        sum += w;
        vec2 dir = D(where);
        where += normalize(dir)/R.xy;
    }
    
    // Trace forward along the flow
    dir = D(uv);
    where = uv - normalize(dir)/R.xy;
    for(float i = 1.0; i < (10.*sigma_m + 1.); i++) {
        w = gaussian1d(i, sigma_m);
        I += grayScale(T(where).rgb)*w;
        sum += w;
        vec2 dir = D(where);
        where -= normalize(dir)/R.xy;
    }
    
    // Normalize the accumulated intensity
    //float licValue = dot(I, vec3(1.0));


    //DoG = DoG > threshold ? 1.0 : 1.0+tanh(phi*(DoG-threshold));

    float n = 3.0;
    //I = floor((I*(n-1.0)+0.5))/(n-1.0);
    float threshold = 100.19;
    //I = I > threshold ? 1.0 : 1.0+floor((I*(n-1.0)+0.5))/(n-1.0);
    fragColor = normalize(vec4(vec3(I), 1.0));
    //fragColor = mix(normalize(vec4(vec3(I), 1.0)), vec4(1.0), 0.2);
    //fragColor = mix(fragColor, vec4(0.0), 0.1);
    //fragColor = mix(fragColor, texture(iChannel2, uv), 0.9  );
    //fragColor = vec4(T(uv), 0.0);

}
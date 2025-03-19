#ifdef GL_ES
precision highp float; // Use high precision if necessary
#else
precision mediump float;
#endif

#include "shared/common.glsl"
#iChannel1 "file://D:/SHADER/sobel.glsl"

//vec3 T = vec3(sumGx*sumGx, sumGy*sumGy, sumGx*sumGy);    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalize pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;

    vec2 tex = uv;

    
    //vec4 T = GaussianConvolution2D(iChannel0, uv, iResolution.xy, sigma_c, 9);
    float half_size = ceil(4.*sigma_c);

    vec4 color = vec4(0.0);
    float sum = 0.0;
    for(float i = -half_size; i <= half_size; i++) {
        float offset = float(i);
        float weight = gaussian1d(offset, sigma_c);
        vec2 position = uv + vec2(0., offset) / iResolution.xy;
        color += texture(iChannel1, position) * weight;
        sum += weight;
    }

    fragColor = color/sum;
}


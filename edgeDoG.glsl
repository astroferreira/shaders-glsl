#include "shared/common.glsl"
#iChannel0 "file://D:/SHADER/wat.png"
#iChannel1 "file://D:/SHADER/edgetangentflow.glsl"



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalize pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;

    vec2 tex = uv;

    vec2 eignvec = normalize(texture(iChannel1, uv).xy);
    vec2 normal = (vec2(eignvec.y, -eignvec.x));


    //vec2 eignvec = normalize(vec2(lambda1-T.r*T.r, -T.g));



    // Normalize the blurred images
    float tau = 10.7;
    

    float blur1 = (directional1DGaussianConvolution(iChannel0, uv, iResolution.xy, normal, sigma_e, 21));
    float blur2 = (directional1DGaussianConvolution(iChannel0, uv, iResolution.xy, normal, 1.3*sigma_e, 21));
    
    float threshold = 1.0;

    float phi = 0.9;
    
    //blur1 = blur1 > threshold ? 1.0 : 1.0+tanh(phi*(blur1-threshold));
    //blur2 = blur2 > threshold ? 1.0 : 1.0+tanh(phi*(blur2-threshold));
    
    
    
    // Compute Difference of Gaussians
    float DoG =  ((1.0+tau)*blur1 - tau*blur2);
    //DoG = DoG > threshold ? 1.0 : 0.0;
    //DoG = DoG > threshold ? 1.0 : 1.0+tanh(phi*(DoG-threshold));
    float n = 3.0;
    //DoG = floor((DoG*(n-1.0)+0.5))/(n-1.0);
    //DoG = DoG > threshold ? 1.0 : 1.0+floor((DoG*(n-1.0)+0.5))/(n-1.0);

    //vec4 oneDirection = 

    //fragColor = vec4(vec3(blur1, blur1 ,blur1), 1.0);
    fragColor = mix(vec4(vec3(DoG), 1.0), (texture(iChannel1, uv)), 0.0);
    
    //fragColor = (texture(iChannel0, uv));
}


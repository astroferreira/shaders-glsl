#include "shared/common.glsl"
#iChannel0 "file://D:/SHADER/sobel.glsl"
#iChannel1 "file://D:/SHADER/pat.jpg"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalize pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;

    vec2 tex = uv;

  
    float sigma = 2.4;

    // Normalize the blurred images
    float tau = 200.0;
    float blur1 = grayScale(GaussianConvolution2D(iChannel1, uv, iResolution.xy, sigma, 21).rgb);
    float blur2 = grayScale(GaussianConvolution2D(iChannel1, uv, iResolution.xy, 1.6*sigma, 21).rgb);
    
    float threshold = 0.007;
    float phi = 1.0;

    
    
    // Compute Difference of Gaussians
    float DoG = (1.0+tau)*blur1 - tau*blur2;
    DoG = DoG > threshold ? 1.0 : 1.0+tanh(phi*(DoG-threshold));

    vec4 oneDirection = 

    //fragColor = vec4(vec3(eignvec,1.0), 1.0);
    fragColor = vec4(vec3(DoG), 1.0);
}


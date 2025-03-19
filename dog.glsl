#include "shared/common.glsl"
#iChannel0 "file://D:/SHADER/sobel.glsl"

#ifdef GL_ES
precision mediump float;
#endif


// Gaussian function


// Sobel kernels for edge detection
float kernelX[9] = float[9](
    -1.0,  0.0,  1.0,
    -2.0,  0.0,  2.0,
    -1.0,  0.0,  1.0
);

float kernelY[9] = float[9](
    -1.0, -2.0, -1.0,
     0.0,  0.0,  0.0,
     1.0,  2.0,  1.0
);


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalize pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;
    
    // Texture coordinates
    vec2 tex = uv;
    
    // Define two standard deviations for Gaussian blur
    float sigma1 = 2.4;
    float sigma2 = 2.0*sigma1;
    
    // Kernel size (truncate at 3 sigma)
    int kSize1 = int(ceil(3.0 * sigma1));
    int kSize2 = int(ceil(3.0 * sigma2));
    
    // Initialize sums
    float sum1 = 0.0;
    float sum2 = 0.0;
    float weightSum1 = 0.0;
    float weightSum2 = 0.0;
    
    // Perform Gaussian blur with sigma1
    for(int y = -kSize1; y <= kSize1; y++) {
        for(int x = -kSize1; x <= kSize1; x++) {
            // Calculate the distance from the center
            float distance = length(vec2(x, y));
            float weight = gaussian(distance, sigma1);
            
            // Sample the texture at the offset position
            vec3 color = texture(iChannel0, tex + vec2(x, y) / iResolution.xy).rgb;
            
            // Convert to grayscale using luminance formula
            float gray = dot(color, vec3(0.299, 0.587, 0.114));
            
            sum1 += gray * weight;
            weightSum1 += weight;
        }
    }
    
    // Perform Gaussian blur with sigma2
    for(int y = -kSize2; y <= kSize2; y++) {
        for(int x = -kSize2; x <= kSize2; x++) {
            // Calculate the distance from the center
            float distance = length(vec2(x, y));
            float weight = gaussian(distance, sigma2);
            
            // Sample the texture at the offset position
            vec3 color = texture(iChannel0, tex + vec2(x, y) / iResolution.xy).rgb;
            
            // Convert to grayscale using luminance formula
            float gray = dot(color, vec3(0.299, 0.587, 0.114));
            
            sum2 += gray * weight;
            weightSum2 += weight;
        }
    }
    
    // Normalize the blurred images
    float tau = 0.95;
    float blur1 = (sum1/weightSum1);
    float blur2 = (sum2/weightSum2);
    float threshold = 0.65;
    float phi = 5.0;
    
    blur1 = blur1 > threshold ? 1.0 : 1.0+tanh(phi*(blur1-threshold));
    blur2 = blur2 > threshold ? 1.0 : 1.0+tanh(phi*(blur2-threshold));
    
    
    
    // Compute Difference of Gaussians
    float DoG = (1.0+tau)*blur1 - tau*blur2;
   
    // Output the DoG result as grayscale
    fragColor = vec4(vec3(DoG), 1.0);
}
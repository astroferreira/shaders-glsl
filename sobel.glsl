#include "shared/common.glsl"
#iChannel0 "file://D:/SHADER/wat.png"

#ifdef GL_ES
precision mediump float;
#endif



void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Normalize pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;

    // Define Sobel kernels
    float Gx[9];
    Gx[0] = -1.0; Gx[1] = 0.0; Gx[2] = 1.0;
    Gx[3] = -2.0; Gx[4] = 0.0; Gx[5] = 2.0;
    Gx[6] = -1.0; Gx[7] = 0.0; Gx[8] = 1.0;

    float Gy[9];
    Gy[0] = -1.0; Gy[1] = -2.0; Gy[2] = -1.0;
    Gy[3] = 0.0;  Gy[4] =  0.0; Gy[5] =  0.0;
    Gy[6] = 1.0;  Gy[7] = 2.0;  Gy[8] = 1.0;

    // Calculate texture offsets for the 3x3 neighborhood
    vec2 texOffset = 1.0 / iResolution.xy;

    // Initialize Gx and Gy sums
    float sumGx = 0.0;
    float sumGy = 0.0;

    // Iterate over the 3x3 neighborhood
    int idx = 0;
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            // Offset coordinates
            vec2 offset = uv + vec2(float(x), float(y)) * texOffset;
            offset = clamp(offset, 0.0, 1.0);
            // Sample the DoG value at the offset position
            float gray = grayScale(texture(iChannel0, offset).rgb); // Assuming DoG is in the red channel

            // Apply Sobel kernels
            sumGx += Gx[idx] * gray;
            sumGy += Gy[idx] * gray;


            idx++;
        }
    }

    //float threshold = applyThreshold(sumGx, 0.5);
    
    vec3 T = (vec3(sumGx*sumGx, sumGy*sumGy, sumGx*sumGy));  
    T= clamp(T, 0.0, 1.0);
    // Output the edge as a binary image
    //fragColor = vec4(T, uv);
    fragColor = vec4(T, 1.0);
}

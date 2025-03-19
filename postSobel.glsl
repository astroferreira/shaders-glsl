#include "shared/common.glsl"
#iChannel1 "file://D:/SHADER/LICsecondpass.glsl"
//#iChannel1 "file://D:/SHADER/caveira.png"
#iChannel0 "file://D:/SHADER/wat.png"
//#iChannel1 "file://D:/SHADER/eyes.png"
#ifdef GL_ES
precision mediump float;
#endif

 

void mainImage(out vec4 fragColor, in  vec2 fragCoord)
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
            float gray = grayScale(texture(iChannel1, offset).rgb); // Assuming DoG is in the red channel

            // Apply Sobel kernels
            sumGx += Gx[idx] * gray;
            sumGy += Gy[idx] * gray;


            idx++;
        }
    }

    //float threshold = applyThreshold(sumGx, 0.5);
    
    
    vec3 T = (vec3(sumGx*sumGx, sumGy*sumGy, sumGx*sumGy));  

    //T= clamp(T, 0.0, 1.0);

    float mag = sqrt(sumGy*sumGy + sumGx*sumGx);
    float angle = 0.5*(atan(sumGy,sumGx) / 3.1415) + 0.5;
    //angle = degrees(angle);
    //if (angle <= 0.0) angle += 180.0;
    //angle /= 180.0;

    angle = mag > 2.5 ? angle : -1.0;

    vec3 ANGL = vec3(0.0);
    float angle_quantized = 0.0;
    if (angle > 0.0) {
        if (angle <= 0.035 || angle >= 0.965) {
            angle_quantized = 1.0;
        } 
        if (angle >= 0.465 && angle <= 0.535) {
            angle_quantized = 1.0;
        } 

        if (angle >= 0.225 && angle <= 0.275) {
            angle_quantized = 2.0;
        } 

        if (angle >= 0.725 && angle <= 0.775) {
            angle_quantized = 2.0;
        } 

        if (angle >= 0.035 && angle <= 0.225) {
            angle_quantized = 3.0;
        } 

        if (angle >= 0.775 && angle <=  0.965) {
            angle_quantized = 4.0;
        } 

        if (angle >= 0.535 && angle <=  0.725) {
            angle_quantized = 3.0;
        } 

        if (angle <= 0.465 && angle >= 0.275) {
            angle_quantized = 4.0;
        } 
    }
    //color = vec3(sumGx*sumGx, sumGy*sumGy, 0.0);
        
    //angle = angle > 0.5 ? 1.0 : 0.0;
    // Output the edge as a binary image
    //fragColor = vec4(T, uv);
    fragColor = vec4(vec3(angle_quantized/4.0), 1.0);
}

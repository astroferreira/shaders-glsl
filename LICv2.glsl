
#include "shared/common.glsl"
#iChannel1 "file://D:/SHADER/edgeDoG.glsl"
#iChannel2 "file://D:/SHADER/edgetangentflow.glsl"

#define PI 3.14159265359
#define R iResolution

#ifdef GL_ES
precision mediump float;
#endif

// Define the LIC structure
struct lic_t {
    vec2 p;    // Current position
    vec2 t;    // Previous tangent
    float w;   // Total length
    float dw;  // Length of current step
};


// Step function to advance LIC traversal
void stepf(inout lic_t s, sampler2D tfm, vec2 resolution) {
    vec2 t = normalize(texture(tfm, s.p).xy);
    
    // Ensure the tangent is consistently oriented
    if (dot(t, s.t) < 0.0) t = -t;
    s.t = t;
    
    // Calculate step size with epsilon to prevent division by zero
    float epsilon = 1e-2;
    if (abs(t.x) > abs(t.y)) {
        s.dw = abs((fract(s.p.x) - 0.5 - sign(t.x)) / (t.x + epsilon));
    } else {
        s.dw = abs((fract(s.p.y) - 0.5 - sign(t.y)) / (t.y + epsilon));
    }
    
    // Advance the position
    s.p += t * s.dw / resolution;
    s.w += s.dw;
}



void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    
    float phi = 1.0;
    // Normalize pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;
    
    // Define constants
    float twoSigmaMSquared = 2.0 * sigma_m * sigma_m;
    float halfWidth = 2.0 * sigma_m;
    
    // Initialize LIC intensity
    float H = grayScale(texture(iChannel1, uv).rgb);
    float w = 1.0;
    
    // Initialize LIC structures for forward and backward traversal
    lic_t a, b;
    a.p = b.p = uv;
    a.t = normalize(texture(iChannel2, uv).xy);
    b.t = -a.t;
    a.w = b.w = 0.0;
    
   // Define maximum steps to prevent infinite loops
    int maxSteps = 100;
    float minStep = 1e-4; // Minimum step size to prevent infinite loops

    // Forward traversal
    for(int i = 0; i < maxSteps; i++) {
        if(a.w >= halfWidth)
            break;
        stepf(a, iChannel2, iResolution.xy);
        if(a.dw < minStep)
            break;
        float k = a.dw * exp(-a.w * a.w / twoSigmaMSquared);
        float samples = grayScale(texture(iChannel1, a.p).rgb);
        H += k * samples;
        w += k;
    }

    // Backward traversal
    for(int i = 0; i < maxSteps; i++) {
        if(b.w >= halfWidth)
            break;
        stepf(b, iChannel2, iResolution.xy);
        if(b.dw < minStep)
            break;
        float k = b.dw * exp(-b.w * b.w / twoSigmaMSquared);
        float samples = grayScale(texture(iChannel1, b.p).rgb);
        H += k * samples;
        w += k;
    }
    
    // Normalize the accumulated intensity
    H /= w;
    

    H = H > threshold ? 1.0 : 1.0 + tanh(theta*(H-threshold));
    float H2 = H > 100.10 ? 1.0 : 1.0 + tanh(theta*(H-0.2));
    // Apply edge detection threshold
    //float edge = (H > 0.0) ? 
     //            1.0 : 
      //           2.0 * smoothstep(-2.0, 2.0, phi * H);
    float n = 2.0;
    //H = floor((H*(n-1.0)+0.5))/(n-1.0);
    // Output the final color
    fragColor = vec4(vec3(H), 1.0);
}

#include "shared/common.glsl"
#iChannel0 "file://D:/SHADER/wat.png"
#iChannel1 "file://D:/SHADER/LICv2.glsl"
#iChannel2 "file://D:/SHADER/edgetangentflow.glsl"
#iChannel3 "file://D:/SHADER/hatch.jpg"
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
    float twoSigmaMSquared = 2.0 * sigma_a * sigma_a;
    float halfWidth = 2.0 * sigma_a;
    
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
    
    // Apply edge detection threshold

    
    // Output the final color
    //vec3 inter = mix(vec3(0.0), texture(iChannel1, uv).rgb, H);
    //vec3 inter2 = mix(inter, vec3(1.0), H);
    //fragColor = vec4(mix(texture(iChannel1, uv).rgb, vec3(H), 1.0), 1.0);
    //fragColor = mix(fragColor, vec4(0.0, 0.0, 0.0, 1.0), 0.1);
    //fragColor = mix(vec4(vec3(H), 1.0), texture(iChannel2, uv), 0.7085);
    fragColor = vec4(vec3(H), 1.0);
    fragColor = vec4(mix(fragColor, texture(iChannel0, uv), 0.5));
    //fragColor = vec4(fragColor);
    //fragColor = vec4(inter2, 1.0);
}
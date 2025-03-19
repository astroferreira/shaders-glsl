#include "shared/common.glsl"
#iChannel0 "file://D:/SHADER/horizontal_blur.glsl"

//vec3 T = vec3(sumGx*sumGx, sumGy*sumGy, sumGx*sumGy);    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalize pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;

    vec2 tex = uv;

    float sigma_c = 2.5;
    vec4 T = texture(iChannel0, uv);

    float E = T .x;
    float F = T .z;
    float G = T .y;
    
    float lambda1 = (E+G + sqrt(E*E-2.0*G*E+G*G-4.0*F*F))/2.0;
    float lambda2 = (E+G - sqrt(E*E-2.0*G*E+G*G-4.0*F*F))/2.0;

    vec3 eignvec1 = vec3(F, lambda1-E,  0.0);
    vec3 eignvec2 = vec3(lambda2-G, F , 0.0);
    

    fragColor = vec4(eignvec1, 1.0);
}


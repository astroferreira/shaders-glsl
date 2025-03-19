#include "shared/common.glsl"
#iChannel0 "file://D:/SHADER/horizontal_blur.glsl"

//vec3 T = vec3(sumGx*sumGx, sumGy*sumGy, sumGx*sumGy);    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalize pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;

    vec4 T = texture(iChannel0, uv);
    
    float E = T.x;
    float F = T.z;
    float G = T.y;
    
    float lambda1 = 0.5*(E+G + sqrt((E*E -2.*G*E + G*G + 4.0*F*F)));
    float lambda2 = 0.5*(E+G - sqrt((E*E -2.*G*E + G*G + 4.0*F*F)));

    vec2 eigvec1 = (vec2(F, lambda1 - E));
    vec2 eigvec2 = (vec2(G - lambda2, F));

    // Optional: Handle cases where F is zero to avoid undefined eigenvectors
    if (F == 0.0) {
        eigvec1 = vec2(01.0, 0.0);
        eigvec2 = vec2(0.01, 0.01);
    }
    

    fragColor = vec4((eigvec2), sqrt(lambda2), 1.0);

    //fragColor = vec4(vec3(DoG), 1.0);
}


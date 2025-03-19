#version 130
#define PI 3.14159265359

#ifdef GL_ES
precision highp float; // Use high precision if necessary
#else
precision mediump float;
#endif

uniform sampler2D u_buffer0;
uniform sampler2D u_buffer1;

uniform sampler2D u_tex0;
uniform vec2 u_resolution;

float grayScale(vec3 color) {
    return dot(color*2.0, vec3(0.299, 0.587, 0.114));
}

float gaussian1d(float x, float sigma) {
    float piSigma = sqrt(2.0 * PI) * sigma;
    return exp(- (x * x) / (2.0 * sigma * sigma)) / piSigma;
}

void main(void)
{
    // Normalize pixel coordinates (from 0 to 1)
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;




#if defined ( BUFFER_0 )

        vec3 T = vec3(0.0);
 
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
        vec2 texOffset = 1.0 / u_resolution.xy;

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
                float gray = grayScale(texture(u_tex0, offset).rgb); // Assuming DoG is in the red channel

                // Apply Sobel kernels
                sumGx += Gx[idx] * gray;
                sumGy += Gy[idx] * gray;


                idx++;
            }
        }

        //float threshold = applyThreshold(sumGx, 0.5);
        
        T = (vec3(sumGx*sumGx, sumGy*sumGy, sumGx*sumGy));  
        T= clamp(T, 0.0, 1.0);
        // Output the edge as a binary image
        //fragColor = vec4(T, uv);
        gl_FragColor = vec4(T, 1.0);
#elif defined ( BUFFER_1 )  
        vec4 color = vec4(vec3(0.0), 1.0);
        float sum = 0.0;
        float sigma_c = 10.0;
        float half_size = ceil(4.*sigma_c);

        for(float i = -half_size; i <= half_size; i++) {
            float offset = float(i);
            float weight = gaussian1d(offset, sigma_c);
            vec2 position = uv + vec2(offset, 0.) / u_resolution.xy;
            color += texture(u_buffer0, position) * weight;
            sum += weight;
        }
        gl_FragColor = color/sum;
#endif    
        gl_FragColor = texture(u_buffer0, uv);
}



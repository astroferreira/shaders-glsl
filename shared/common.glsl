
#define PI 3.14159265359

float sigma_c = 5.0;
float sigma_e = 4.5;
float sigma_m = 1.0;
float sigma_a = 1.0;
float threshold = 3.13;
float theta = 10.0;

// Apply threshold to a single value
float applyThreshold(float value, float threshold) {
    return value > threshold ? 1.0 : 0.0;
}

float grayScale(vec3 color) {
    return dot(color*2.0, vec3(0.299, 0.587, 0.114));
}

float gaussian1d(float x, float sigma) {
    float piSigma = sqrt(2.0 * PI) * sigma;
    return exp(- (x * x) / (2.0 * sigma * sigma)) / piSigma;
}

float gaussian2d(float x, float y, float sigma) {
    float twoSigmaSq = 2.0 * sigma * sigma;
    float piSigmaSq = 2.0 * PI * sigma * sigma;
    return exp(- (x * x + y * y) / twoSigmaSq) / piSigmaSq;
}


float vertical_gaussian(sampler2D tex, vec2 uv, vec2 resolution, vec2 direction, float sigma, int kernelSize) {
    int halfSize = kernelSize / 2;
   
    float color = 0.0;
    float sum = 0.0;

    for(int i = -halfSize; i <= halfSize; i++) {
        float offset = float(i);
        float weight = gaussian1d(offset, sigma);
        vec2 samplePos = uv + direction * offset / resolution;
        color += grayScale(texture(tex, samplePos).rgb)  * weight;
        sum += weight;
    }


    return color / sum;
}

float directional1DGaussianConvolution(sampler2D tex, vec2 uv, vec2 resolution, vec2 direction, float sigma, int kernelSize) {
    
    vec2 nabs = abs(direction);
    float ds = 1.0 / max(nabs.x, nabs.y);
    vec2 texSize = vec2(textureSize(tex, 0));
    direction /= texSize;
    
    
    float halfWidth = 2.0 * sigma;
    float color  =  grayScale(texture(tex, uv).rgb) * gaussian1d(0.0, sigma);;
    float sum = gaussian1d(0.0, sigma);;

    for(int i = 1; i <= 500; i++) {
        float d = float(i) * ds;
        if(d > halfWidth) break;
        float weight = gaussian1d(d, sigma);
        //vec2 samplePos = 
        float L0 = grayScale(texture(tex, uv + direction * d).rgb) * weight;
        float L1 = grayScale(texture(tex, uv - direction * d).rgb) * weight;
        color += (L0+L1);
        sum +=  2.*weight;
    }


    return color / sum;
}

vec4 GaussianConvolution2D(sampler2D tex, vec2 uv, vec2 resolution, float sigma, int kernelSize) {
    int halfSize = kernelSize / 2;
   
    vec4 color = vec4(0.0);
    float sum = 0.0;

    for(int y = -halfSize; y <= halfSize; y++) {
        for(int x = -halfSize; x <= halfSize; x++) {
            float offsetX = float(x);
            float offsetY = float(y);
            float weight = gaussian2d(offsetX, offsetY, sigma);
            vec2 samplePos = uv + vec2(offsetX, offsetY) / resolution;
            color += texture(tex, samplePos) * weight;
            sum += weight;
        }
    }

    return color / sum;
}
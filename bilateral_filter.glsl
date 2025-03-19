#iChannel0 "file://D:/SHADER/TS.jpg"
#iChannel1 "file://D:/SHADER/edgetangentflow.glsl"

void mainImage (out vec4 fragColor, in vec2 fragCoord) {
    
    float twoSigmaD2 = 2.1;
    float twoSigmaR2 = 2.1;
    vec2 uv = fragCoord / iResolution.xy;

    vec2 t = normalize(texture(iChannel1, uv).xy);
    vec2 dir = vec2(t.y, -t.x);
    vec2 dabs = abs(dir);
    float ds = 1.0 / ((dabs.x > dabs.y) ? dabs.x : dabs.y);
    //dir /= iResolution.xy;
    vec3 center = texture(iChannel0, uv).rgb;
    vec3 sum = center;
    float norm = 1.0;
    float halfWidth = 2.0 * 2.0;
    
    for (float d = ds; d <= halfWidth; d += ds) {
        vec3 c0 = texture(iChannel0, uv + d * dir).rgb;
        vec3 c1 = texture(iChannel0, uv - d * dir).rgb;
        float e0 = length(c0 - center);
        float e1 = length(c1 - center);
        float kerneld = exp( - d *d / twoSigmaD2 );
        float kernele0 = exp( - e0 *e0 / twoSigmaR2 );
        float kernele1 = exp( - e1 *e1 / twoSigmaR2 );
        norm += kerneld * kernele0;
        norm += kerneld * kernele1;
        sum += kerneld * kernele0 * c0;
        sum += kerneld * kernele1 * c1;
    }
    //sum /= norm;
    fragColor = vec4(sum, 1.0);
}
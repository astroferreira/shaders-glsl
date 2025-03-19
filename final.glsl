#iChannel1 "file://D:/SHADER/LICsecondpass.glsl"


// Step function 


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{

    vec2 uv = fragCoord / iResolution.xy;
    fragColor = texture(iChannel1, uv);
    //fragColor = vec4(inter2, 1.0);
}
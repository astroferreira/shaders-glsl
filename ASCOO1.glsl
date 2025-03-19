#include "shared/common.glsl"
#iChannel1 "file://D:/SHADER/postSobel.glsl"
#iChannel0 "file://D:/SHADER/wat.png"
#iChannel2 "file://D:/SHADER/map.gif"

#define CHAR_SIZE 8.0
#define SPACING 1.0

float scale_factor = 0.50;    // Downscale factor

// Converts a given pixel to grayscale.
float grayscale(vec3 p) {
    return dot(p, vec3(0.299, 0.587, 0.114));
}

// Maps the current position to a downsampled position.
vec2 downsampled_uv(vec2 coord, float d, float scale_factor) {
    // Downscale the coordinates
    coord = coord / scale_factor;
    // Map to downsampled UV coordinates
    return (coord - mod(coord, d)) / (iResolution.xy / scale_factor);
}

// Sobel kernels for edge detection
float kernelX[9] = float[9](
    -1.0,  0.0,  1.0,
    -2.0,  0.0,  2.0,
    -1.0,  0.0,  1.0
);

float kernelY[9] = float[9](
    -1.0, -2.0, -1.0,
     0.0,  0.0,  0.0,
     1.0,  2.0,  1.0
);

vec3 palette[12] = vec3[12](
vec3(0.008,0.039,0.110),
vec3(0.012,0.059,0.153),
vec3(0.016,0.082,0.204),
vec3(0.027,0.110,0.271),
vec3(0.035,0.145,0.345),
vec3(0.047,0.188,0.435),
vec3(0.063,0.235,0.541),
vec3(0.082,0.294,0.663),
vec3(0.102,0.357,0.796),
vec3(0.129,0.431,0.953),
vec3(0.157,0.514,1.000),
vec3(0.188,0.604,1.000)
);

vec3 palette_light[12] = vec3[12](
vec3(0.008,0.035,0.078),
vec3(0.035,0.055,0.125),
vec3(0.078,0.078,0.173),
vec3(0.145,0.110,0.224),
vec3(0.235,0.149,0.271),
vec3(0.353,0.200,0.310),
vec3(0.486,0.267,0.349),
vec3(0.639,0.353,0.388),
vec3(0.792,0.459,0.427),
vec3(0.949,0.596,0.478),
vec3(1.000,0.761,0.549),
vec3(1.000,0.965,0.651)
);


vec3 palette_dark[12] = vec3[12](
  vec3(0.067,0.078,0.055),
vec3(0.078,0.098,0.075),
vec3(0.094,0.118,0.094),
vec3(0.110,0.141,0.118),
vec3(0.125,0.169,0.149),
vec3(0.149,0.200,0.180),
vec3(0.173,0.231,0.220),
vec3(0.200,0.271,0.267),
vec3(0.231,0.306,0.314),
vec3(0.271,0.349,0.365),
vec3(0.314,0.396,0.424),
vec3(0.361,0.443,0.486)
);
// Quantizes the grayscale value and returns the palette index
int getColorIndex(vec3 color) {
    float gray = grayscale(color);
    int colorIndex = int(floor(gray * float(12))); // 12 is the number of colors in the palette
    colorIndex = clamp(colorIndex, 0, 12); // Ensure index is within bounds
    return colorIndex;
}

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

int getColorLightIndex(vec3 color, vec2 uv) {
  
   
    
    // Sample texture and compute grayscale value
    float gray = grayscale(color);
    
   
    // **Color Cycling Modification**
    // Modulate the grayscale value over time to cycle colors
    float cycleSpeed = 0.50; // Adjust speed of color cycling
    float cycle = sin(iTime * cycleSpeed + gray * 6.28318) + 1.4*rand(uv); // 6.28318 ≈ 2π
    
    // Adjust the modulation to affect bright colors more
    float modulation = smoothstep(0.5, 1.0, gray) * cycle * 0.5;
    gray = gray + cycle/8.0;//(rand(100000.0*uv*cycle)-0.25);
    // Modulate the grayscale value
    gray = clamp(gray + modulation, 0.0, 1.0);

    int colorIndex = int(floor(gray * float(12))); // 12 is the number of colors in the palette
    colorIndex = clamp(colorIndex, 0, 11); // Ensure index is within bounds
    return colorIndex;
}

// Define the 8x8 character bitmaps
uint characters[120] = uint[120](
    // Character 0: ' ' (Space)
    0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u,

    // Character 1: '.' (Period)
    0u, 0u, 0u, 0u, 0u, 0u, 24u, 24u,

    // Character 2: ':' (Colon)
    24u, 24u, 0u, 0u, 0u, 0u, 24u, 24u,

    // Character 3: 'c'
    0u, 0u, 60u, 96u, 96u, 96u, 60u, 0u,

    // Character 4: 'o'
    0u, 0u, 60u, 102u, 102u, 102u, 60u, 0u,

    // Character 5: 'P'
    0u, 126u, 102u, 102u, 126u, 96u, 96u, 0u,

    // Character 6: 'O'
    0u, 60u, 102u, 102u, 102u, 102u, 60u, 0u,

    // Character 7: '?'
    60u, 102u, 6u, 12u, 24u, 0u, 24u, 0u,

    // Character 8: '@'
    60u, 102u, 110u, 110u, 110u, 96u, 60u, 0u,

    // Character 9: '■' (Filled Square)
    255u, 255u, 255u, 255u, 255u, 255u, 255u, 255u,

    // Character 10: '_' (Edge Character)
    0u, 0u, 0u, 0u, 0u, 0u, 255u, 255u,

    // Character 11: '/' (Edge Character)
    1u, 2u, 4u, 8u, 16u, 32u, 64u, 128u,

    // Character 12: '' (Edge Character)
    24u, 24u, 24u, 24u, 24u, 24u, 24u, 24u,

    // Character 13: '\' (Edge Character)
    128u, 64u, 32u, 16u, 8u, 4u, 2u, 1u,

    // Character 14: '■' (Repeated for completeness)
    255u, 255u, 255u, 255u, 255u, 255u, 255u, 255u
);

// Returns if the current pixel corresponds to character bounds
float character(int char_index, vec2 local_p) {
    // Check if the pixel is within the character bounds
    if (local_p.x < SPACING || local_p.x >= CHAR_SIZE + (SPACING - 1.0))
        return 0.0;
    if (local_p.y < SPACING || local_p.y >= CHAR_SIZE + (SPACING - 1.0))
        return 0.0;

    // Calculate position within the character bitmap
    int x = int(local_p.x - SPACING);
    int y = int(local_p.y - SPACING);

    // Clamp x and y to valid range
    x = clamp(x, 0, 7);
    y = clamp(y, 0, 7);

    // Get the index in the characters array
    int idx = char_index * 8 + y;

    // Fetch the row data for the character
    uint row = characters[idx];

    // Extract the bit at the specific position
    uint bit = (row >> (7 - x)) & 1u;

    return float(bit);
}

int argmax8(float arr[5]) {
    int maxIndex = 0;
    float maxValue = arr[0];
    for(int i = 0; i < 5; i++) {
        if(arr[i] > maxValue) {
            maxValue = arr[i];
            maxIndex = i;
        }
    }
    return maxIndex;
}

#define HIST_BINS 5
// Main shader function
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float levels_size = 12.0;

    // Compute the output character size (scaled up)
    float OUTPUT_CHAR_SIZE = (CHAR_SIZE + 2.0 * SPACING) * scale_factor;

    // Downsample the UV coordinates
    vec2 oriUv = fragCoord / iResolution.xy;
    vec2 uv = downsampled_uv(fragCoord, CHAR_SIZE + 2.0 * SPACING, scale_factor);

    float blockHist[HIST_BINS];

    for(int i = 0; i < HIST_BINS; i++) {
        blockHist[i] = 0.0;
    }

     // Compute histogram for the block
    for(float y = 0.0; y < CHAR_SIZE; y++) {
        for(float x = 0.0; x < CHAR_SIZE; x++) {
            vec2 texCoord = oriUv + vec2(x, y) / iResolution.xy;
            float brightness = texture(iChannel1, texCoord).r;

            // Assign to a bin
            int bin = int(floor(brightness * float(HIST_BINS - 1)));
            if (bin > 0) blockHist[bin] += 1.0;
        }
    }

    for(int i = 0; i < HIST_BINS; i++) {
        if (blockHist[i] < 10.0) {
            blockHist[i] = 0.0;
        };
        
    }

    int bin_index = argmax8(blockHist);
    float char_map[5];
    char_map[0] = 0.0;
    char_map[1] = 0.25;
    char_map[2] = 0.5;
    char_map[3] = 0.75;
    char_map[4] = 1.0;
     
    float converted = char_map[bin_index];
    // Compute the low-resolution texel size
    vec2 lowResResolution = iResolution.xy / scale_factor;
    vec2 texel = vec2(1.0) / lowResResolution;
    float angles = texture(iChannel0, uv).x;
    float strengh = grayScale(texture(iChannel1, uv).rgb);
    // Compute the Sobel filter on the DoG result
  

    // Edge detection
    float edge_threshold = 0.95; // Adjust this threshold as needed
    bool is_edge = true;

   
    int char_index;

    // Character selection based on edge detection
    if (converted > 0.0) {
        if (converted == 0.5) {
            char_index = 10;
        } else if (converted == 0.75) {
            // Diagonal edge '/'
            char_index = 11;
        } else if (converted == 0.25) {
            char_index = 12;
        } else if (converted == 1.0) {
            // Diagonal edge '\'
            char_index = 13;
        }
    } else {
        // Map the grayscale value to a character index
        vec3 tex = texture(iChannel0, uv).rgb;
        float gray = grayscale(tex);
        char_index = int(floor(gray * levels_size));
        char_index = clamp(char_index, 0, 9); // Ensure index is within bounds
    }

    // Compute the position within the character grid
    vec2 charGridPos = floor(fragCoord.xy / OUTPUT_CHAR_SIZE);
    vec2 charStartPos = charGridPos * OUTPUT_CHAR_SIZE;

    // Compute local position within the character
    vec2 local_p = fragCoord.xy - charStartPos;
    local_p = local_p / scale_factor; // Scale down to match character bitmap coordinates

    // Render the character at the fragment position
    float char_pixel = character(char_index, local_p);

    // Sample the original texture color
    float texColor = grayscale(texture(iChannel0, uv).rgb);

    // Get the color index
    vec3 color = texture(iChannel0, uv).rgb;
    int colorIndex = getColorIndex(color);
    vec3 finalColor = palette_dark[colorIndex];
    if (texColor > 0.00 && texColor < 1.0) {
        int colorIndex = getColorLightIndex(color, uv);
        finalColor = palette[colorIndex];
    } else if (texColor == 1.0) {
        int colorIndex = getColorLightIndex(color, uv);
        finalColor = palette_light[colorIndex];
    }

    if (char_index > 9) {
        finalColor = palette[11];
    }
    
    // **Compute Bloom Effect**

    fragColor = vec4(vec3(converted), 1.0);
    fragColor = vec4(color*char_pixel, 1.0);
}
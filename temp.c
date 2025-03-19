#define CHAR_SIZE 8.0
#define SPACING 1.0

float scale_factor = 0.1;    // Downscale factor

// Converts a given pixel to grayscale.
float grayscale(vec3 p) {
    float gray = dot(p*1.5, vec3(0.299, 0.587, 0.114));
    float contrast = 2.0; // Adjust this value (>1 increases contrast)
    gray = (gray - 0.5) * contrast + 0.5;
    return clamp(gray, 0.0, 1.0);
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

vec3(0.0,0.0,0.0),
vec3(1.0/255.0,1.0/255.0,1.0/255.0),
vec3(20.0/255.0,5.0/255.0,8.0/255.0),
vec3(9.0/255.0,14.0/255.0,31.0/255.0),
vec3(28.0/255.0,38.0/255.0,82.0/255.0),
vec3(33.0/255.0,54.0/255.0,120.0/255.0),
vec3(43.0/255.0,63.0/255.0,124.0/255.0),
vec3(48.0/255.0,78.0/255.0,145.0/255.0),
vec3(58.0/255.0,94.0/255.0,157.0/255.0),
vec3(43.0/255.0,108.0/255.0,176.0/255.0),
vec3(71.0/255.0,116.0/255.0,170.0/255.0),
vec3(85.0/255.0,146.0/255.0,183.0/255.0)

);

// Quantizes the grayscale value and returns the palette index
int getColorIndex(vec3 color) {
    float gray = grayscale(color);
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
    0u, 0u, 0u, 0u, 0u, 0u, 0u, 255u,

    // Character 11: '/' (Edge Character)
    1u, 2u, 4u, 8u, 16u, 32u, 64u, 128u,

    // Character 12: '|' (Edge Character)
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


// Main shader function
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float levels_size = 12.0;

    // Compute the output character size (scaled up)
    float OUTPUT_CHAR_SIZE = (CHAR_SIZE + 2.0 * SPACING) * scale_factor;

    // Downsample the UV coordinates
    vec2 uv = downsampled_uv(fragCoord, CHAR_SIZE + 2.0 * SPACING, scale_factor);

    // Compute the low-resolution texel size
    vec2 lowResResolution = iResolution.xy / scale_factor;
    vec2 texel = vec2(1.0) / lowResResolution;

    // Apply first Gaussian blur (sigma ≈ 1.0)
    float blur1 = 0.0;
    float kernel1[3] = float[3](0.27901, 0.44198, 0.27901);
    for (int y = -1; y <= 1; y++) {
        float weightY = kernel1[y + 1];
        for (int x = -1; x <= 1; x++) {
            float weightX = kernel1[x + 1];
            float weight = weightX * weightY;
            vec2 offset = texel * vec2(float(x), float(y));
            blur1 += weight * grayscale(texture(iChannel0, uv + offset).rgb);
        }
    }

    // Apply second Gaussian blur (sigma ≈ 2.0)
    float blur2 = 0.0;
    float kernel2[3] = float[3](0.106506, 0.786986, 0.106506);
    for (int y = -1; y <= 1; y++) {
        float weightY = kernel2[y + 1];
        for (int x = -1; x <= 1; x++) {
            float weightX = kernel2[x + 1];
            float weight = weightX * weightY;
            vec2 offset = texel * vec2(float(x), float(y));
            blur2 += weight * grayscale(texture(iChannel0, uv + offset).rgb);
        }
    }

    // Compute the Difference of Gaussians
    float DoG = blur1 - blur2;

    // Compute the Sobel filter on the DoG result
    float Gx = 0.0;
    float Gy = 0.0;
    int index = 0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offset = texel * vec2(float(x), float(y));
            float samples = grayscale(texture(iChannel0, uv + offset).rgb);
            Gx += samples * kernelX[index];
            Gy += samples * kernelY[index];
            index++;
        }
    }

    float grad_mag = sqrt(Gx * Gx + Gy * Gy);
    float grad_angle = atan(Gy, Gx);

    // Edge detection
    float edge_threshold = 0.1; // Adjust this threshold as needed
    bool is_edge = grad_mag > edge_threshold;

   
    int char_index;

    // Character selection based on edge detection
    if (is_edge) {
        // Map angle to character
        float angle = degrees(grad_angle);
        if (angle < 0.0) angle += 180.0; // Map angle to [0, 180)

        if ((angle >= 157.5 && angle <= 180.0) || (angle >= 0.0 && angle < 22.5)) {
            // Horizontal edge '_'
            char_index = 10;
        } else if (angle >= 22.5 && angle < 67.5) {
            // Diagonal edge '/'
            char_index = 11;
        } else if (angle >= 67.5 && angle < 112.5) {
            // Vertical edge '|'
            char_index = 12;
        } else if (angle >= 112.5 && angle < 157.5) {
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
    vec3 texColor = texture(iChannel0, uv).rgb;

    // Get the color index
    int colorIndex = getColorIndex(texColor);

    // Set the fragment color based on the palette
    vec3 finalColor = palette[colorIndex];

    // **Compute Bloom Effect**

  
    fragColor = vec4(finalColor * char_pixel, 1.0);
}

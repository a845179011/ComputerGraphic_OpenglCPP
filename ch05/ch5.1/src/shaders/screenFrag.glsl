#version 430 
out vec4 FragColor;

in vec2 TexCoords;

layout(binding=0) uniform sampler2D screenTexture;

void main()
{
    vec3 col = texture(screenTexture, TexCoords).rgb;
    FragColor = vec4(col, 1.0);
} 
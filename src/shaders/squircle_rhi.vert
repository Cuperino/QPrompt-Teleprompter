#version 440

layout(location = 0) in vec4 vertices;
layout(location = 0) out vec2 coords;

layout(std140, binding = 0) uniform buf {
    float t;
    float y_dir;
};

void main()
{
    gl_Position = vertices;
    coords = vertices.xy;
    coords.y *= y_dir;
}

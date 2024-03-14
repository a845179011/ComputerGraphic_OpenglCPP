#version 430

layout(location=0) in vec3 position;
uniform mat4 mv_matrix;
uniform mat4 proj_matrix;
uniform vec4 u_color;
uniform int u_width;
uniform float u_lineWidth;

//out vec4 the_color;
void main(void) 
{
	gl_Position = mv_matrix* vec4(position, 1.0f);
	//the_color = vec4(0.0f, 0.0f, 1.0f, 1.0f);
}
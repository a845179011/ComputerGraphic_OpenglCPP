#version 430

layout(location=0) in vec3 position;
uniform mat4 u_vMat;
uniform mat4 u_mMat;
uniform mat4 u_pMat;
uniform vec4 u_color;
uniform vec2 u_viewportSize;
uniform float u_lineWidth;

//out vec4 the_color;
void main(void) 
{
	mat4 mvMat = u_vMat * u_mMat;
	gl_Position =  mvMat* vec4(position, 1.0f);
	//the_color = vec4(0.0f, 0.0f, 1.0f, 1.0f);
}
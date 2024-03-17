#version 330

layout(location = 0) in vec3 pos;
uniform mat4 u_ProjViewMat;
uniform mat4 u_ModelMat;

void main()
{
	gl_Position = u_ProjViewMat * u_ModelMat * vec4(pos, 1.0f);
}
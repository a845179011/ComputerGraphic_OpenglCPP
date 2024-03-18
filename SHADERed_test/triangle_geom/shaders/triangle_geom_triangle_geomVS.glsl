#version 430

layout(location = 0) in vec3 pos;

uniform mat4 u_vMat;
uniform mat4 u_mMat;
uniform mat4 u_pMat;


void main()
{
	gl_Position = u_pMat * u_vMat * u_mMat * vec4(pos, 1.0f);
}
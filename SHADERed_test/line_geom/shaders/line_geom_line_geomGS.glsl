#version 430

layout(lines) in;
layout(triangle_strip, max_vertices = 4) out;

uniform mat4 u_vMat;
uniform mat4 u_mMat;
uniform mat4 u_pMat;
uniform vec4 u_color;
uniform vec2 u_viewportSize;
uniform float u_lineWidth;

flat out vec3 pt1;
flat out vec3 pt2;
flat out vec3 pt3;
flat out vec3 pt4;

#define PI 3.1415926

mat4 buildRotateZ(float rad)
{
	mat4 zrot = mat4(cos(rad), sin(rad), 0.0, 0.0,
					  -sin(rad), cos(rad), 0.0, 0.0,
					  0.0, 0.0, 1.0, 0.0,
					  0.0, 0.0, 0.0, 1.0);
	return zrot;
}

void testValue(float v, float min, float max)
{
	gl_Position=vec4(0.0f, 0.0f, 0.0f, 1.0f);
	EmitVertex();
	gl_Position=vec4(0.5f, 0.0f, 0.0f, 1.0f);
	EmitVertex();
	gl_Position=vec4(0.5f, 0.5f, 0.0f, 1.0f);
	EmitVertex();
	//gl_Position=vec4(0.0f, 0.5f, 0.0f, 1.0f); // not work?
	//EmitVertex();
	EndPrimitive();
}

void main(void)
{
	vec4 start = gl_in[0].gl_Position;
	vec4 end = gl_in[1].gl_Position;
	vec3 dir = normalize( end.xyz - start.xyz);
	mat4 rMat=buildRotateZ(PI/2.0);
	vec4 normal = rMat*vec4(dir,1.0f);
	float feather = u_lineWidth * (2.0f / u_viewportSize.x);	
	//vec3 p1=start.xyz+feather/2.0f*normal.xyz;
	//vec3 p2=start.xyz-feather/2.0f*normal.xyz;
	//vec3 p3=end.xyz;
	
	//float u_widthf = float(u_width);
	//vec3 p1=vec3(u_widthf/1200.0f);
	//vec3 p2=vec3(u_widthf/1200.0f)+vec3(0.1,0.0,0.0);
	//vec3 p3=vec3(u_widthf/1200.0f)+vec3(0.1,0.1,0.0);
	
	//vec3 p1=vec3(u_pMat*start) + feather/2.0f*normal.xyz;
	//vec3 p2=vec3(u_pMat*start) - feather/2.0f*normal.xyz;
	//vec3 p3=vec3(u_pMat*end) + feather/2.0f*normal.xyz;
	//vec3 p4=vec3(u_pMat*end) - feather/2.0f*normal.xyz;
	
	testValue(0.0, 0.0,0.0);
	
	vec3 p1=vec3(start) + feather/2.0f*normal.xyz;
	vec3 p2=vec3(start) - feather/2.0f*normal.xyz;
	vec3 p3=vec3(end) + feather/2.0f*normal.xyz;
	vec3 p4=vec3(end) - feather/2.0f*normal.xyz;
	
	pt1=p1;
	pt2=p2;
	pt3=p3;
	pt4=p4;
	
	//gl_Position=vec4(p1, 1.0f);
	//EmitVertex();
	//gl_Position=vec4(p2, 1.0f);
	//EmitVertex();
	//gl_Position=vec4(p3, 1.0f);
	//EmitVertex();
	//gl_Position=vec4(p4, 1.0f);
	//EmitVertex();
	//EndPrimitive();
	
}
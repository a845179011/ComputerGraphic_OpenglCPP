#version 430

layout(lines) in;
layout(triangle_strip, max_vertices = 4) out;

uniform mat4 u_vMat;
uniform mat4 u_mMat;
uniform mat4 u_pMat;
uniform vec4 u_color;
uniform vec2 u_viewportSize;
uniform float u_lineWidth;

out vec3 pt1;
out vec3 pt2;
out vec3 pt3;
out vec3 pt4;

#define PI 3.1415926

mat4 buildRotateZ(float rad)
{
	mat4 zrot = mat4(cos(rad), sin(rad), 0.0, 0.0,
					  -sin(rad), cos(rad), 0.0, 0.0,
					  0.0, 0.0, 1.0, 0.0,
					  0.0, 0.0, 0.0, 1.0);
	return zrot;
}

// check whether v is between min and max. is between  get rectangle, less than min get triangle, more than max get pentagon
void testValue(float v, float min, float max)
{
	float w = 0.5f;
	if(v>=min && v<=max)
	{
		// rectangle
		gl_Position=vec4(0.0f, 0.0f, 0.0f, 1.0f);
		EmitVertex();
		gl_Position=vec4(0.0f, -w, 0.0f, 1.0f);
		EmitVertex();
		gl_Position=vec4(w, 0.0f, 0.0f, 1.0f);
		EmitVertex();
		gl_Position=vec4(w, -w, 0.0f, 1.0f); 
		EmitVertex();
		EndPrimitive();
	}
	else if(v<min)
	{
		// triangle
		gl_Position=vec4(0.0f, 0.0f, 0.0f, 1.0f);
		EmitVertex();
		gl_Position=vec4(0.0f, -w, 0.0f, 1.0f);
		EmitVertex();
		gl_Position=vec4(w, 0.0f, 0.0f, 1.0f);
		EmitVertex();
		EndPrimitive();
	}
	else
	{
		// pentagon
		gl_Position = vec4(w/2.0f, w, 0.0f, 1.0f);
		EmitVertex();
		gl_Position = vec4(0.0f, 0.0f, 0.0f, 1.0f);
		EmitVertex();
		gl_Position = vec4(w, 0.0f, 0.0f, 1.0f);
		EmitVertex();
		gl_Position = vec4(0.0f, -w, 0.0f, 1.0f);
		EmitVertex();
		gl_Position = vec4(w,-w,0.0f, 1.0f);
		EmitVertex();
		EndPrimitive();
	}
}

void emitVertices(vec3 p1, vec3 p2, vec3 p3,vec3 p4)
{
	pt1=p1;
	pt2=p2;
	pt3=p3;
	pt4=p4;
}

void main(void)
{
	vec4 start = gl_in[0].gl_Position;
	vec4 end = gl_in[1].gl_Position;
	vec3 dir = normalize( end.xyz - start.xyz);	// in view CS
	//testValue(start.x, 499.0f, 501.f);
	//testValue(start.y, 199,201);
	//testValue(end.x, 499.0f, 501.f);
	//testValue(end.y, 499,501);
	//testValue(dir.x, -0.01f, 0.01);
	//testValue(dir.y, 0.99, 1.01);    //dir=(0.0,1.0)


	mat4 rMat=buildRotateZ(PI/2.0);
	vec4 normal = rMat*vec4(dir,1.0f);	// in view CS
	float feather = u_lineWidth * (2.0f / u_viewportSize.x);	//logical line width in standard CS
	//testValue(normal.x, -1.01, -0.99);
	//testValue(normal.y, -0.01, 0.01);		//normal = (-1.0, 0.0)
	//testValue(u_lineWidth, 49.0, 51.0);
	//testValue(u_viewportSize.x, 817, 819);
	//testValue(u_viewportSize.y, 732, 734);
	//testValue(feather, 0.122,0.123);

	//vec3 p1=start.xyz+feather/2.0f*normal.xyz;
	//vec3 p2=start.xyz-feather/2.0f*normal.xyz;
	//vec3 p3=end.xyz;
	
	//float u_widthf = float(u_width);
	//vec3 p1=vec3(u_widthf/1200.0f);
	//vec3 p2=vec3(u_widthf/1200.0f)+vec3(0.1,0.0,0.0);
	//vec3 p3=vec3(u_widthf/1200.0f)+vec3(0.1,0.1,0.0);
	
	vec3 offset=feather/2.0f*normal.xyz;	
	vec4 proj_start = u_pMat*start;	// in standard CS
	vec4 proj_end = u_pMat*end;
	vec3 p1=vec3(proj_start) + offset;
	vec3 p2=vec3(proj_start) - offset;
	vec3 p3=vec3(proj_end) + offset;
	vec3 p4=vec3(proj_end) - offset;
	//testValue(offset.x, -0.062, -0.061);
	//testValue(offset.y, -0.01, 0.01);
	//testValue(proj_start.x, 0.222, 0.223);
	//testValue(proj_start.y, 0.454, 0.455);
	//testValue(proj_end.x, 0.222, 0.223);
	//testValue(proj_end.y, -0.365, -0.364);
	
	//testValue(0.7, 0.0, 0.5);
	
	// vec3 p1=vec3(start) + feather/2.0f*normal.xyz;
	// vec3 p2=vec3(start) - feather/2.0f*normal.xyz;
	// vec3 p3=vec3(end) + feather/2.0f*normal.xyz;
	// vec3 p4=vec3(end) - feather/2.0f*normal.xyz;
	
	pt1=p1;
	pt2=p2;
	pt3=p3;
	pt4=p4;
	
	// the "triangle_strip" direction is for points in standard([-1,1]) CS,
	// the following code is for no switching Y projection matrix like: glm::ortho(0, width, 0, height)
	// gl_Position=vec4(p1, 1.0f);
	// EmitVertex();
	// gl_Position=vec4(p2, 1.0f);
	// EmitVertex();
	// gl_Position=vec4(p3, 1.0f);
	// EmitVertex();
	// gl_Position=vec4(p4, 1.0f);
	// EmitVertex();
	// EndPrimitive();

	// the following code is for SHADERed, which use glm::ortho(0, width, height, 0). 
	gl_Position=vec4(p1, 1.0f);
	emitVertices(p1,p2,p3,p4);
	EmitVertex();
	gl_Position=vec4(p3, 1.0f);
	emitVertices(p1,p2,p3,p4);
	EmitVertex();
	gl_Position=vec4(p2, 1.0f);
	emitVertices(p1,p2,p3,p4);
	EmitVertex();
	gl_Position=vec4(p4, 1.0f);
	emitVertices(p1,p2,p3,p4);
	EmitVertex();
	EndPrimitive();
	
}

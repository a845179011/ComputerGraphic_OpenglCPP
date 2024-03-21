#version 430

layout(lines) in;
layout(triangle_strip, max_vertices = 4) out;

uniform mat4 u_vMat;
uniform mat4 u_mMat;
uniform mat4 u_pMat;
uniform vec4 u_color;
uniform vec2 u_viewportSize;
uniform float u_lineWidth;
uniform bool u_isSelected;
uniform bool u_isHighlighted;

out vec3 begin; 	// line begin point in standard CS
out vec3 end;
out float width;	// line width in standard CS

#define PI 3.1415926
// antialiasing width, usually 3 pixels
#define ANTIALIASING_WIDTH 5.0f
#define HIGHLIGHT_WIDTH 10.0f

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

void emitVertices(vec3 b, vec3 e, float w)
{
	begin =b;
	end = e;
	width = w;
}

void main(void)
{
	vec4 start_in_view = gl_in[0].gl_Position;
	vec4 end_in_view = gl_in[1].gl_Position;
	vec3 dir = normalize( end_in_view.xyz - start_in_view.xyz);	// in view CS
	//testValue(start.x, -0.01f, 0.01f);
	//testValue(start.y, -0.01f, 0.01f);
	//testValue(end.x, 499.0f, 501.f);
	//testValue(end.y, 499,501);
	//testValue(dir.x, 0.707f, 0.708);
	//testValue(dir.y, 0.707f, 0.708);    //dir=(0.0,1.0)


	mat4 rMat=buildRotateZ(PI/2.0);
	vec4 normal = rMat*vec4(dir,1.0f);	// in view CS
	float feather;
	if(u_isSelected || u_isHighlighted)
	{
		feather = (u_lineWidth + ANTIALIASING_WIDTH + HIGHLIGHT_WIDTH) * (2.0f / u_viewportSize.x);
	}
	else
	{
		feather = (u_lineWidth + ANTIALIASING_WIDTH) * (2.0f / u_viewportSize.x);	//logical line width with antialiasing in standard CS
	}
	 
	
	//testValue(normal.x, -0.708, -0.707);
	//testValue(normal.y, 0.707, 0.708);		//normal = (-0.707, 0.707)
	//testValue(u_lineWidth, 49.0, 51.0);
	//testValue(u_viewportSize.x, 817, 819);
	//testValue(u_viewportSize.y, 732, 734);
	//testValue(feather, 0.244,0.245);

	//vec3 p1=start.xyz+feather/2.0f*normal.xyz;
	//vec3 p2=start.xyz-feather/2.0f*normal.xyz;
	//vec3 p3=end.xyz;
	
	//float u_widthf = float(u_width);
	//vec3 p1=vec3(u_widthf/1200.0f);
	//vec3 p2=vec3(u_widthf/1200.0f)+vec3(0.1,0.0,0.0);
	//vec3 p3=vec3(u_widthf/1200.0f)+vec3(0.1,0.1,0.0);
	
	// for glm::ortho(0, width, height, 0), up is -1, down is 1 in standard (-1,1) CS, 
	// the normal vector should map this CS.
	vec3 normal_in_standard_CS = vec3(normal.x, -normal.y, normal.z);
	vec3 dir_in_standard_CS = vec3(dir.x, -dir.y, dir.z);
	vec3 offset=feather/2.0f*normal_in_standard_CS;	
	vec4 proj_start = u_pMat*start_in_view;	// in standard CS
	vec4 proj_end = u_pMat*end_in_view;
	vec3 s=vec3(proj_start) - dir_in_standard_CS*feather / 2.0f;
	vec3 e=vec3(proj_end) + dir_in_standard_CS*feather / 2.0f;
	float w=feather;
	vec3 p1=s + offset;
	vec3 p2=s - offset;
	vec3 p3=e + offset;
	vec3 p4=e - offset;
	//testValue(offset.x, -0.044, -0.043);
	//testValue(offset.y, -0.044, -0.043);
	
	//testValue(proj_start.x, -0.512, -0.511);
	//testValue(proj_start.y, 0.454, 0.455);
	//testValue(proj_end.x, 0.222, 0.223);
	//testValue(proj_end.y, -0.365, -0.364);
	//testValue(s.x, -0.598, -0.597);
	//testValue(s.y, 0.54, 0.541);
	//testValue(e.x, 0.308, 0.309);
	//testValue(e.y,  -0.451, -0.45);
	
	// vec3 p1=vec3(start) + feather/2.0f*normal.xyz;
	// vec3 p2=vec3(start) - feather/2.0f*normal.xyz;
	// vec3 p3=vec3(end) + feather/2.0f*normal.xyz;
	// vec3 p4=vec3(end) - feather/2.0f*normal.xyz;
	

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
	emitVertices(s, e, w);
	EmitVertex();
	gl_Position=vec4(p3, 1.0f);
	emitVertices(s, e, w);
	EmitVertex();
	gl_Position=vec4(p2, 1.0f);
	emitVertices(s, e, w);
	EmitVertex();
	gl_Position=vec4(p4, 1.0f);
	emitVertices(s, e, w);
	EmitVertex();
	EndPrimitive();
	
}

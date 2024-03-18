#version 430

layout(triangles) in;
//(1)
//layout(line_strip, max_vertices = 12) out;

//layout(lines, max_vertices = 6) out; //'lines' : cannot apply to 'out' 

//(3)
// layout(triangle_strip, max_vertices = 3) out;

//(4)
layout(triangle_strip, max_vertices = 4) out;

void main()
{
	// (1)
	// gl_Position = gl_in[0].gl_Position;
	// EmitVertex();
	// gl_Position = gl_in[1].gl_Position;
	// EmitVertex();
	// EndPrimitive();
	
	// gl_Position = gl_in[1].gl_Position;
	// EmitVertex();
	// gl_Position = gl_in[2].gl_Position;
	// EmitVertex();
	// EndPrimitive();
	
	// gl_Position = gl_in[2].gl_Position;
	// EmitVertex();
	// gl_Position = gl_in[0].gl_Position;
	// EmitVertex();
	// EndPrimitive();
	
	
	
	
	//(3)
	// vec4 center = (gl_in[0].gl_Position + gl_in[1].gl_Position +gl_in[2].gl_Position) / 3.0f;
	// gl_Position = gl_in[0].gl_Position;
	// EmitVertex();
	// gl_Position = gl_in[1].gl_Position;
	// EmitVertex();
	// gl_Position = center;
	// EmitVertex();
	// EndPrimitive();

	//(4)
	vec4 p4 = vec4(gl_in[2].gl_Position.x, gl_in[1].gl_Position.y, 0.0f, 1.0f);
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	gl_Position = gl_in[1].gl_Position;
	EmitVertex();
	gl_Position = gl_in[2].gl_Position;
	EmitVertex();
	gl_Position = p4;
	EmitVertex();
	EndPrimitive();
}
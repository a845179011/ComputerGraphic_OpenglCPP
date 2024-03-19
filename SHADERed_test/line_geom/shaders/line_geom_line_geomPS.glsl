#version 430

out vec4 color;
uniform vec4 u_color;
uniform vec2 u_viewportSize;
uniform float u_lineWidth;

//in vec4 the_color;
in vec3 the_color;

in vec3 pt1;
in vec3 pt2;
in vec3 pt3;
in vec3 pt4;

// check whether v is between min and max. is between  get green, less than min get red, more than max get blue
void check_value(float v, float min, float max)
{
	if(v>=min && v<=max)
	{
		color = vec4(0.0, 1.0, 0.0, 1.0);
	}
	else if(v<min)
	{
		color = vec4(1.0, 0.0, 0.0 ,1.0);
	}
	else
	{
		color = vec4(0.0, 0.0, 1.0, 1.0);
	}
}

void main(void)
{
	
	vec2 c1=vec2( (pt1+pt2)/2.0);
	vec2 c2=vec2( (pt3+pt4)/2.0);
	vec2 cVec=c2-c1;
	vec2 cDir=normalize( cVec);
	//check_value(pt1.x, 0.161, 0.162);
	//check_value(pt1.y, 0.454, 0.455);
	//check_value(pt2.x, 0.283, 0.284);
	//check_value(pt2.y, 0.454, 0.455);
	//check_value(pt3.x, 0.161, 0.162);
	//check_value(pt3.y, -0.365, -0.364);
	//check_value(pt4.x, 0.283, 0.284);
	//check_value(pt4.y, -0.365, -0.364);


	// https://zhuanlan.zhihu.com/p/102068376
	vec4 ndc = vec4( gl_FragCoord.xy/u_viewportSize * 2.0 - 1.0, gl_FragCoord.z * 2.0 - 1.0, 1.0 );
	vec2 aVec=ndc.xy - c1;
	
	//check_value(ndc.x, 0.161, 0.283);
	//check_value(ndc.y, -0.364, 0.454);

	//vec2 aVec=gl_FragCoord.xy-c1;	
	float projLength=dot(cVec, aVec) / length(cVec);
	vec2 projPt=c1+cDir*projLength;
	float dist = distance(projPt, ndc.xy);

	float feather = distance(pt1, pt2);
	float factor = dist * 2.0 / feather;
	//color = vec4(0.0f, 0.0f, 1.0f, 1.0f - factor);
	color = vec4(0.0f, 1.0f - factor, 0.0f, 1.0f);

	//color = u_color + vec4(0.0f, 0.0f, 1.0f, 1.0f - factor);
	//color = u_color + vec4(0.0f, 0.0f, 1.0f, 1.0f - pt1.x);
	//color = (gl_FragCoord.x) * u_color;
	//color = vec4(gl_FragCoord.x/1000.0f, 0.0f, 0.0f, 1.0f);
	//color = vec4(ndc.x, 0.0f, 0.0f, 1.0f);
	//color = vec4(0.0, 0.0f, 1.0f, 1.0f);
	//color = vec4(pt1.x*100.0f, 0.0f, 0.0f, 1.0f);
	
	//color = u_color;
	//color = the_color;
	
	//gl_Color = u_color;
	
	//color = vec4(the_color, 1.0f);
}
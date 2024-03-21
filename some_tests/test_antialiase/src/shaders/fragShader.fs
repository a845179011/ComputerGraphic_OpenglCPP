#version 430

out vec4 color;
uniform vec4 u_color;
uniform int u_width;
uniform int u_height;
uniform float u_lineWidth;

//in vec4 the_color;
in vec3 the_color;
flat in vec3 pt1;
flat in vec3 pt2;
flat in vec3 pt3;
flat in vec3 pt4;

vec4 getColor();

// @验证范围。范围内为绿色，小于范围为红色，大于范围为蓝色
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
	check_value(pt1.y, -0.4, -0.3 );
	vec2 viewport = vec2(u_width, u_height);
	// 计算像素坐标对应的[-1,1]的值。参考：https://zhuanlan.zhihu.com/p/102068376 
	vec4 ndc = vec4( gl_FragCoord.xy/viewport * 2.0 - 1.0, gl_FragCoord.z * 2.0 - 1.0, 1.0 );
	vec2 aVec=ndc.xy - c1;
	
	//vec2 aVec=gl_FragCoord.xy-c1;	//gl_FragCoord为像素坐标
	float projLength=dot(cVec, aVec) / length(cVec);
	vec2 projPt=c1+cDir*projLength;
	//float dist = distance(projPt, gl_FragCoord.xy);
	float dist = distance(projPt, ndc.xy);
	float feather = u_lineWidth * (2.0f / u_width);	
	float factor=dist/(feather*2.0f);
	//color = u_color + vec4(0.0f, 0.0f, 1.0f, 1.0f - factor);
	//color = u_color + vec4(0.0f, 0.0f, 1.0f, 1.0f - pt1.x);
	//color = (gl_FragCoord.x) * u_color;
	//color = vec4(gl_FragCoord.x/1000.0f, 0.0f, 0.0f, 1.0f);
	//color = vec4(ndc.x, 0.0f, 0.0f, 1.0f);
	//color = vec4(0.0, 0.0f, 1.0f, 1.0f);
	//color = vec4(pt1.x*100.0f, 0.0f, 0.0f, 1.0f);
	
	//color = u_color;
	//color = the_color;
	
	color = getColor();
	//gl_Color = u_color;
	
	//color = vec4(the_color, 1.0f);
}
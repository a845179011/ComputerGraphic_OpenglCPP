#version 430

out vec4 color;
uniform mat4 u_vMat;
uniform mat4 u_mMat;
uniform mat4 u_pMat;
uniform vec4 u_color;
uniform vec2 u_viewportSize;
uniform float u_lineWidth;
uniform bool u_isSelected;
uniform bool u_isHighlighted;

in vec3 begin; 	// line begin point 
in vec3 end;
in vec3 offset_vec;

// antialiasing width, usually 3 pixels
#define ANTIALIASING_WIDTH 2.0f
#define HIGHLIGHT_WIDTH 5.0f

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

bool is_point_in_circle(vec2 pt, vec2 center, float radius)
{
	if(distance(pt, center)<=radius)
	{
		return true;
	}
	else 
	{
		return false;
	}
}
void set_color_normal()
{
	vec2 c1=vec2(begin);
	vec2 c2=vec2(end);
	vec2 cDir=normalize( c2-c1);
	// vec2 begin_origin = c1 + cDir*width/2.0f;
	// vec2 end_origin = c2 - cDir*width/2.0f;
	// vec2 cVec=end_origin - begin_origin;

	vec2 cVec = c2-c1;
	float len = length(cVec);
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
	vec4 pos_in_view =inverse(u_pMat)* ndc;
	vec2 aVec=pos_in_view.xy - begin.xy;
	// if(pos_in_view.z<-7)
	// {
	// 	color = vec4(1, 0.0,0.0,1.0);
	// }
	// else
	// {
	// 	color = vec4(0.0, 1.0,0.0,1.0);
	// }
	// return;

	// vec2 aVec=ndc.xy - begin_origin;
	// float ANTIALIASING_WIDTH_in_stanard_CS = ANTIALIASING_WIDTH * (2.0f / u_viewportSize.x);
	
	//check_value(ndc.x, 0.161, 0.283);
	//check_value(ndc.y, -0.364, 0.454);

	float cell00 = u_pMat[0][0];
	float width_in_view_CS = 2.0 / cell00;
	float size_per_pixel = width_in_view_CS / u_viewportSize.x;
	float width = length(offset_vec)*2.0f;
	float projLength=dot(cVec, aVec) / length(cVec);
	float raidus_in = (width - size_per_pixel*ANTIALIASING_WIDTH) / 2.0f;
	float radius = width/2.0f;

	//check_value(raidus_in, 0.0611, 0.0612);
	//check_value(projLength, 0.0, length(cVec));
	//return;

	
	//test
	{
		if(raidus_in <=0)
		{
			color = vec4(0.0,0.0,1.0,1.0);
		}
		else
		{
			color = vec4(0.0,1.0,0.0,1.0);
		}
		return;
	}
	
	vec4 the_color;
	if(u_isSelected)
	{
		the_color = vec4(0.0f, 0.0f, 1.0f, 0.5f);
	}
	else if(u_isHighlighted)
	{
		the_color = vec4(0.2f, 0.2f, 0.2f, 0.5f);
	}
	else
	{
		the_color = u_color;
	}

	// at two side semicircle
	if(projLength<0 || projLength>len)
	{
		vec2 side = begin.xy;
		if(projLength>len)
		{
			side = end.xy;
		}

		if(is_point_in_circle(pos_in_view.xy, side, raidus_in))
		{
			color = the_color;
		}
		else
		{
			float dist = distance(pos_in_view.xy, side);
			float factor = (dist - raidus_in) / (size_per_pixel*ANTIALIASING_WIDTH / 2.0f);
			color = vec4(the_color.xyz *(1.0f - factor), 1.0f);
		}
	}
	// in line
	else
	{
		vec2 projPt=begin.xy + cDir*projLength;
		float dist = distance(projPt, pos_in_view.xy);
		if(dist <= raidus_in)
		{
			color = the_color;
		}
		else
		{
			float factor = (dist - raidus_in) / (size_per_pixel*ANTIALIASING_WIDTH / 2.0f);
			color = vec4(the_color.xyz *(1.0f - factor), 1.0f);
		}
	}
}

void main(void)
{
	set_color_normal();

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
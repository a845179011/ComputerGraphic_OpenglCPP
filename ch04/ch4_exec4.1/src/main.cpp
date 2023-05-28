//说明：四面体

#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include "Utils.h"
#include <Windows.h>

#define numVAOs 1
#define numVBOs 2

float cameraX, cameraY, cameraZ;
float cubeLocX, cubeLocY, cubeLocZ;
GLuint renderingProgram;
GLuint vao[numVAOs];
GLuint vbo[numVBOs];

GLuint mvLoc, projLoc;
int width, height;
float aspect;
glm::mat4 pMat, vMat, mMat, tMat, rMat, mvMat;

struct Point
{
	float x;
	float y;
	float z;
};

void setupVertices()
{
	float height = (float)std::sqrt(3.0) / 2.0;
	Point p1, p2, p3, p4;
	p1.x = -1.0f;
	p1.y = 0.0f;
	p1.z = 0.0f;
	p2.x = 1.0f;
	p2.y = 0.0f;
	p2.z = 0.0f;
	p3.x = 0.0f;
	p3.y = height;
	p3.z = 0.0f;
	p4.x = 0.0f;
	p4.y = 0.0f;
	p4.z = 1.0f;
	float vertextPositions[36] = {
		p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, p4.x, p4.y, p4.z,
		p2.x, p2.y, p2.z, p3.x, p3.y, p3.z, p4.x, p4.y, p4.z,
		p3.x, p3.y, p3.z, p1.x, p1.y, p1.z, p4.x, p4.y, p4.z,
		p1.x, p1.y, p1.z, p3.x, p3.y, p3.z, p2.x, p2.y, p2.z,
	};
	glGenVertexArrays(1, vao);
	glBindVertexArray(vao[0]);
	glGenBuffers(numVBOs, vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertextPositions), vertextPositions, GL_STATIC_DRAW);
}



void init(GLFWwindow* window)
{
	std::string vShaderPathStr = Utils::getCurrentExecuteDir();
	vShaderPathStr.append("\\shaders\\vertShader.glsl");
	std::string fShaderPathStr = Utils::getCurrentExecuteDir();
	fShaderPathStr.append("\\shaders\\fragShader.glsl");
	renderingProgram = Utils::createShaderProgram(vShaderPathStr.c_str(), fShaderPathStr.c_str());
	cameraX = 0.0f;
	cameraY = 0.0f;
	cameraZ = 8.0f;
	cubeLocX = 0.0f;
	cubeLocY = -2.0f;
	cubeLocZ = 0.0f;
	setupVertices();
}

void display(GLFWwindow* window, double currentTime)
{
	glClear(GL_DEPTH_BUFFER_BIT);	//注释会导致每个曲面被清除，从而黑屏（P42）
	glClear(GL_COLOR_BUFFER_BIT);	//注释将永久留下上一步的残影u
	glUseProgram(renderingProgram);
	
	mvLoc = glGetUniformLocation(renderingProgram, "mv_matrix");
	projLoc = glGetUniformLocation(renderingProgram, "proj_matrix");

	glfwGetFramebufferSize(window, &width, &height);
	aspect = (float)width / (float)height;
	pMat = glm::perspective(1.0472f, aspect, 0.1f, 1000.0f);

	tMat = glm::translate(glm::mat4(1.0f),
		glm::vec3(sin(0.35f * currentTime) * 2.0f, cos(0.52f * currentTime) * 2.0f, sin(0.7f * currentTime) * 2.0f));
	rMat = glm::rotate(glm::mat4(1.0f), 1.75f * (float)currentTime, glm::vec3(0.0f, 1.0f, 0.0f));
	rMat = glm::rotate(rMat, 1.75f * (float)currentTime, glm::vec3(1.0f, 0.0f, 0.0f));
	rMat = glm::rotate(rMat, 1.75f * (float)currentTime, glm::vec3(0.0f, 0.0f, 1.0f));
	mMat = tMat * rMat;
	vMat = glm::translate(glm::mat4(1.0f), glm::vec3(-cameraX, -cameraY, -cameraZ));
	mvMat = vMat * mMat;

	glUniformMatrix4fv(mvLoc, 1, GL_FALSE, glm::value_ptr(mvMat));
	glUniformMatrix4fv(projLoc, 1, GL_FALSE, glm::value_ptr(pMat));

	glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
	glEnableVertexAttribArray(0);

	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	glDrawArrays(GL_TRIANGLES, 0, 36);
}

int main()
{
	if (!glfwInit())
	{
		exit(EXIT_FAILURE);
	}
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	GLFWwindow* window = glfwCreateWindow(600, 600, "window 1", NULL, NULL);
	glfwMakeContextCurrent(window);
	if (glewInit() != GLEW_OK)
	{
		exit(EXIT_FAILURE);
	}
	glfwSwapInterval(1);
	init(window);

	while (!glfwWindowShouldClose(window))
	{
		display(window, glfwGetTime());
		glfwSwapBuffers(window);
		glfwPollEvents();
	}
	glfwDestroyWindow(window);
	glfwTerminate();
	exit(EXIT_SUCCESS);
}
//说明：砖纹理的四棱锥

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

GLuint mvLoc, projLoc, tfLoc;
int width, height;
float aspect;
glm::mat4 pMat, vMat, tMat, rMat, mMat, mvMat;
float timeFactor;
GLuint brickTexture;

void setupVertices()
{
	float pyramidPosition[54] = {
	-1.0f, -1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 0.0f,
	1.0f, -1.0f, 1.0f, 1.0f, -1.0f,-1.0f,  0.0f, 1.0f, 0.0f,
	1.0f, -1.0f, -1.0f, -1.0f,-1.0f,-1.0f, 0.0f, 1.0f, 0.0f,
	-1.0f, -1.0f, -1.0f, -1.0f,-1.0f, 1.0f, 0.0f, 1.0f, 0.0f,
	-1.0f, -1.0f, -1.0f, 1.0f,-1.0f ,1.0f,-1.0f,-1.0f, 1.0f,
	1.0f, -1.0f,  1.0f, -1.0f,-1.0f,-1.0f, 1.0f, -1.0f, -1.0f,
	};

	float texCoords[36] = {
		0.0f, 0.0f, 1.0f, 0.0f, 0.5f, 1.0f,		0.0f, 0.0f, 1.0f, 0.0f, 0.5f, 1.0f,
		0.0f, 0.0f, 1.0f, 0.0f, 0.5f, 1.0f,		0.0f, 0.0f, 1.0f, 0.0f, 0.5f, 1.0f,
		0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f,		1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f,
	};
	glGenVertexArrays(1, vao);
	glBindVertexArray(vao[0]);
	glGenBuffers(numVBOs, vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(pyramidPosition), pyramidPosition, GL_STATIC_DRAW);

	glBindBuffer(GL_ARRAY_BUFFER, vbo[1]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(texCoords), texCoords, GL_STATIC_DRAW);
}



void init(GLFWwindow* window)
{
	std::string vShaderPathStr = Utils::getCurrentExecuteDir();
	vShaderPathStr.append("\\shaders\\vertShader.glsl");
	std::string fShaderPathStr = Utils::getCurrentExecuteDir();
	fShaderPathStr.append("\\shaders\\fragShader.glsl");
	renderingProgram = Utils::createShaderProgram(vShaderPathStr.c_str(), fShaderPathStr.c_str());
	std::string fTexturePathStr = Utils::getCurrentExecuteDir();
	fTexturePathStr.append("\\texture\\brick1.png");
	brickTexture = Utils::loadTexture(fTexturePathStr.c_str());
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
	tfLoc = glGetUniformLocation(renderingProgram, "tf");
	projLoc = glGetUniformLocation(renderingProgram, "proj_matrix");

	timeFactor = (float)currentTime;
	glUniform1f(tfLoc, timeFactor);

	glfwGetFramebufferSize(window, &width, &height);
	aspect = (float)width / (float)height;
	pMat = glm::perspective(1.0472f, aspect, 0.1f, 1000.0f);
	vMat = glm::translate(glm::mat4(1.0f), glm::vec3(-cameraX, -cameraY, -cameraZ));
	tMat = glm::translate(glm::mat4(1.0f), glm::vec3(cubeLocX, cubeLocY, cubeLocZ));
	rMat = glm::rotate(glm::mat4(1.0f), 1.75f * (float)currentTime, glm::vec3(0.0f, 1.0f, 0.0f));
	rMat = glm::rotate(rMat, 1.75f * (float)currentTime, glm::vec3(1.0f, 0.0f, 0.0f));
	rMat = glm::rotate(rMat, 1.75f * (float)currentTime, glm::vec3(0.0f, 0.0f, 1.0f));
	mMat = tMat * rMat;
	mvMat = vMat * mMat;

	glUniformMatrix4fv(mvLoc, 1, GL_FALSE, glm::value_ptr(mvMat));
	glUniformMatrix4fv(projLoc, 1, GL_FALSE, glm::value_ptr(pMat));

	glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
	glEnableVertexAttribArray(0);

	glBindBuffer(GL_ARRAY_BUFFER, vbo[1]);
	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, 0);
	glEnableVertexAttribArray(1);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, brickTexture);

	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	glDrawArrays(GL_TRIANGLES, 0, 18);	//18是顶点数
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
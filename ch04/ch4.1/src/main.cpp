//说明：简单红色三角形

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
GLuint renderingProgram;
GLuint vao[numVAOs];


void init(GLFWwindow* window)
{
	std::string vShaderPathStr = Utils::getCurrentExecuteDir();
	vShaderPathStr.append("\\shaders\\vertShader.glsl");
	std::string fShaderPathStr = Utils::getCurrentExecuteDir();
	fShaderPathStr.append("\\shaders\\fragShader.glsl");
	renderingProgram = Utils::createShaderProgram(vShaderPathStr.c_str(), fShaderPathStr.c_str());
	glGenVertexArrays(numVAOs, vao);
	glBindVertexArray(vao[0]);
}
void display(GLFWwindow* window, double currentTime)
{
	glUseProgram(renderingProgram);
	//glPointSize(30.0f);
	glDrawArrays(GL_TRIANGLES, 0, 3);
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
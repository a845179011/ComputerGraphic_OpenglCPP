//说明：测试直线反走样，参考：https://blog.mapbox.com/drawing-antialiased-lines-with-opengl-8766f34192dc

#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <iostream>
#include <fstream>
#include <string>
#include <Windows.h>

#define numVAOs 1
GLuint renderingProgram;
GLuint vao[numVAOs];
GLuint vbo[1];

void printShaderLog(GLuint shader)
{
	int len = 0;
	int chWrittn = 0;
	char* log;
	glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &len);
	if (len > 0)
	{
		log = (char*)malloc(len);
		glGetShaderInfoLog(shader, len, &chWrittn, log);
		std::cout << "Shader Info Log: " << log << std::endl;
		free(log);
	}
}

void printProgramLog(int prog)
{
	int len = 0;
	int chWrittn = 0;
	char* log;
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &len);
	if (len > 0)
	{
		log = (char*)malloc(len);
		glGetProgramInfoLog(prog, len, &chWrittn, log);
		std::cout << "Program Info Log: " << log << std::endl;
		free(log);
	}
}

bool checkOpenGLError()
{
	bool foundError = false;
	int glErr = glGetError();
	while (glErr != GL_NO_ERROR)
	{
		std::cout << "glError: " << glErr << std::endl;
		foundError = true;
		glErr = glGetError();
	}
	return foundError;
}

std::string readShaderSource(const char* filePath)
{
	std::string content;
	std::ifstream fs(filePath, std::ios::in);
	std::string line = "";
	while (!fs.eof())
	{
		std::getline(fs, line);
		content.append(line + "\n");
	}
	fs.close();
	return content;
}

std::string getCurrentExecuteDir()
{
	char path[MAX_PATH];
	GetModuleFileName(NULL, (LPSTR)path, sizeof(path));
	std::string pathStr(path);
	return pathStr.substr(0, pathStr.find_last_of("\\"));
}

GLuint createShaderProgram()
{
	std::string vShaderPathStr = getCurrentExecuteDir();
	vShaderPathStr.append("\\shaders\\vertShader.glsl");
	std::string gShaderPathStr = getCurrentExecuteDir();
	gShaderPathStr.append("\\shaders\\geometryShader.glsl");
	std::string fShaderPathStr = getCurrentExecuteDir();
	fShaderPathStr.append("\\shaders\\fragShader.glsl");
	std::string vShaderStr = readShaderSource(vShaderPathStr.c_str());
	std::string gShaderStr = readShaderSource(gShaderPathStr.c_str());
	std::string fShaderStr = readShaderSource(fShaderPathStr.c_str());
	const char* vshaderSource = vShaderStr.c_str();
	const char* gshaderSource = gShaderStr.c_str();
	const char* fshaderSource = fShaderStr.c_str();

	GLint vertCompiled;
	GLint geometryCompiled;
	GLint fragCompiled;
	GLint linked;

	GLuint vShader = glCreateShader(GL_VERTEX_SHADER);
	GLuint gShader = glCreateShader(GL_GEOMETRY_SHADER);
	GLuint fShader = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(vShader, 1, &vshaderSource, NULL);
	glShaderSource(gShader, 1, &gshaderSource, NULL);
	glShaderSource(fShader, 1, &fshaderSource, NULL);

	glCompileShader(vShader);
	checkOpenGLError();	//检查不出错误？
	glGetShaderiv(vShader, GL_COMPILE_STATUS, &vertCompiled);
	if (vertCompiled != 1)
	{
		std::cout << "vertex compilation failed" << std::endl;
		printShaderLog(vShader);
	}

	glCompileShader(gShader);
	checkOpenGLError();
	glGetShaderiv(gShader, GL_COMPILE_STATUS, &geometryCompiled);
	if (geometryCompiled != 1)
	{
		std::cout << "geometry compilation failed" << std::endl;
		printShaderLog(gShader);
	}

	glCompileShader(fShader);
	checkOpenGLError();
	glGetShaderiv(fShader, GL_COMPILE_STATUS, &fragCompiled);
	if (fragCompiled != 1)
	{
		std::cout << "fragment compilation failed" << std::endl;
		printShaderLog(fShader);
	}

	GLuint vfProgram = glCreateProgram();
	glAttachShader(vfProgram, vShader);
	glAttachShader(vfProgram, gShader);
	glAttachShader(vfProgram, fShader);
	glLinkProgram(vfProgram);
	checkOpenGLError();
	glGetProgramiv(vfProgram, GL_LINK_STATUS, &linked);
	if (linked != 1)
	{
		std::cout << "linking failed" << std::endl;
		printProgramLog(vfProgram);
	}
	return vfProgram;
}

glm::mat4 pMat;
void resizeCallback (GLFWwindow* window, int width, int height)
{
	glViewport(0, 0, width, height);
	pMat = glm::ortho(-width / 2.0f, width / 2.0f, -height / 2.0f, height / 2.0f, -1.0f, 1.0f);
}
void init(GLFWwindow* window)
{
	glfwSetFramebufferSizeCallback(window, resizeCallback);
	
	renderingProgram = createShaderProgram();

	float lineVertexes[] = { 0.0f, -100.0f, 0.0f, 0, 100.0f, 0.0f };

	glGenVertexArrays(numVAOs, vao);
	glBindVertexArray(vao[0]);
	glGenBuffers(1, vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(lineVertexes), lineVertexes, GL_STATIC_DRAW);

}
void display(GLFWwindow* window, double currentTime)
{
	glClear(GL_DEPTH_BUFFER_BIT);	//注释会导致每个曲面被清除，从而黑屏（P42）
	glClear(GL_COLOR_BUFFER_BIT);	//注释将永久留下上一步的残影u
	glUseProgram(renderingProgram);

	GLuint mvLoc = glGetUniformLocation(renderingProgram, "mv_matrix");
	GLuint projLoc = glGetUniformLocation(renderingProgram, "proj_matrix");
	GLuint colorLoc = glGetUniformLocation(renderingProgram, "u_color");
	GLuint widthLoc = glGetUniformLocation(renderingProgram, "u_width");
	GLuint lineWidthLoc = glGetUniformLocation(renderingProgram, "u_lineWidth");
	int width, height;
	glfwGetFramebufferSize(window, &width, &height);
	glViewport(0, 0, width, height);
	//glm::mat4 pMat = glm::ortho(-200.0f, 200.0f, -200.0f, 200.0f, -1.0f, 1.0f);
	pMat = glm::ortho(-width/2.0f, width / 2.0f, -height/2.0f, height / 2.0f, -1.0f, 1.0f);
	glm::mat4 mvMat = glm::mat4(1.0f);
	glUniformMatrix4fv(mvLoc, 1, GL_FALSE, glm::value_ptr(mvMat));
	glUniformMatrix4fv(projLoc, 1, GL_FALSE, glm::value_ptr(pMat));
	glUniform4f(colorLoc, 1.0f, 0.0f, 0.0f, 1.0f);
	glUniform1i(widthLoc, width);
	glUniform1f(lineWidthLoc, 50.0f);

	glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
	glEnableVertexAttribArray(0);

	glDrawArrays(GL_LINES, 0, 2);
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
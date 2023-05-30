#include "utils.h"
#include <iostream>
#include <fstream>
#include <SOIL2/soil2.h>
#include <Windows.h>

void Utils::printShaderLog(GLuint shader)
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

void Utils::printProgramLog(int prog)
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

bool Utils::checkOpenGLError()
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

std::string Utils::readShaderSource(const char* filePath)
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

std::string Utils::getCurrentExecuteDir()
{
	char path[MAX_PATH];
	GetModuleFileName(NULL, (LPSTR)path, sizeof(path));
	std::string pathStr(path);
	return pathStr.substr(0, pathStr.find_last_of("\\"));
}

GLuint Utils::createShaderProgram(const char* vertexShaderPath, const char* flagShaderPath)
{
	//std::string vShaderPathStr = getCurrentExecuteDir();
	//vShaderPathStr.append("\\shaders\\vertShader.glsl");
	//std::string fShaderPathStr = getCurrentExecuteDir();
	//fShaderPathStr.append("\\shaders\\fragShader.glsl");
	//std::string vShaderStr = readShaderSource(vShaderPathStr.c_str());
	//std::string fShaderStr = readShaderSource(fShaderPathStr.c_str());

	std::string vShaderStr = readShaderSource(vertexShaderPath);
	std::string fShaderStr = readShaderSource(flagShaderPath);
	const char* vshaderSource = vShaderStr.c_str();
	const char* fshaderSource = fShaderStr.c_str();

	GLint vertCompiled;
	GLint fragCompiled;
	GLint linked;

	GLuint vShader = glCreateShader(GL_VERTEX_SHADER);
	GLuint fShader = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(vShader, 1, &vshaderSource, NULL);
	glShaderSource(fShader, 1, &fshaderSource, NULL);

	glCompileShader(vShader);
	checkOpenGLError();	//¼ì²é²»³ö´íÎó£¿
	glGetShaderiv(vShader, GL_COMPILE_STATUS, &vertCompiled);
	if (vertCompiled != 1)
	{
		std::cout << "vertex compilation failed" << std::endl;
		printShaderLog(vShader);
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

GLuint Utils::loadTexture(const char* texImagePath)
{
	GLuint textureID = SOIL_load_OGL_texture(texImagePath,
		SOIL_LOAD_AUTO, SOIL_CREATE_NEW_ID, SOIL_FLAG_INVERT_Y);
	if (textureID == 0)
	{
		std::cout << "could not find texture file: " << texImagePath << std::endl;
	}
	return textureID;
}

#ifndef UTILS_H
#define UTILS_H

#include <string>
#include <GL/glew.h>
class Utils
{
public:

	static void printShaderLog(GLuint shader);
	

	static void printProgramLog(int prog);
	

	static bool checkOpenGLError();
	

	static std::string readShaderSource(const char* filePath);
	

	static std::string getCurrentExecuteDir();
	

	static GLuint createShaderProgram(const char* vertexShaderPath, const char* flagShaderPath);

	static GLuint loadTexture(const char* texImagePath);
	
};
#endif //!UTILS_H
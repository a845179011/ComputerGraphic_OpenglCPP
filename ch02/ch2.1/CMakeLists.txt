# 设置cmake 最低版本
cmake_minimum_required (VERSION 3.10)

project(ch2.1)

file(GLOB_RECURSE ALL_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
file(GLOB_RECURSE ALL_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h")

add_executable(${PROJECT_NAME} ${ALL_SOURCES} ${ALL_HEADERS})

# 包含目录
include_directories(${MY_LIBRARIES_DIR}/glfw/include)
include_directories(${MY_LIBRARIES_DIR}/glm-0.9.9.8)
include_directories(${MY_LIBRARIES_DIR}/glew-2.1.0/include)

# 链接
target_link_libraries(${PROJECT_NAME} debug ${MY_LIBRARIES_DIR}/glfw/lib/Debug/glfw3.lib)
target_link_libraries(${PROJECT_NAME} optimized ${MY_LIBRARIES_DIR}/glfw/lib/Release/glfw3.lib)
target_link_libraries(${PROJECT_NAME} debug ${MY_LIBRARIES_DIR}/glew-2.1.0/lib/Debug/x64/glew32d.lib)
target_link_libraries(${PROJECT_NAME} optimized ${MY_LIBRARIES_DIR}/glew-2.1.0/lib/Release/x64/glew32.lib)
target_link_libraries(${PROJECT_NAME} debug ${MY_LIBRARIES_DIR}/SOL2/lib/Debug/soil2-debug.lib)
target_link_libraries(${PROJECT_NAME} optimized ${MY_LIBRARIES_DIR}/SOL2/lib/Release/soil2.lib)
target_link_libraries(${PROJECT_NAME} opengl32.lib)

# 安装
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME})
set(MY_LIBRARIES_DLL_DEBUG ${MY_LIBRARIES_DIR}/glew-2.1.0/bin/Debug/x64/glew32d.dll
)
set(MY_LIBRARIES_DLL_RELEASE ${MY_LIBRARIES_DIR}/glew-2.1.0/bin/Release/x64/glew32.dll)
install(FILES ${MY_LIBRARIES_DLL_DEBUG} DESTINATION ${EXECUTABLE_OUTPUT_PATH}/$<CONFIGURATION> CONFIGURATIONS Debug)
install(FILES ${MY_LIBRARIES_DLL_RELEASE} DESTINATION ${EXECUTABLE_OUTPUT_PATH}/$<CONFIGURATION> CONFIGURATIONS Release)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/shaders/ DESTINATION ${EXECUTABLE_OUTPUT_PATH}/$<CONFIGURATION>/shaders FILES_MATCHING PATTERN "*.*")


# 设置cmake 最低版本
cmake_minimum_required (VERSION 3.10)
# 设置项目名称
project (ComputerGraphic_OpenglCPP)

# Where is the binary should be placed
# set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# 设置 std 和 c++版本为
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 11)

set(MY_LIBRARIES_DIR ${CMAKE_SOURCE_DIR}/libraries) 

# 设置子项目
#add_subdirectory("libraries")
add_subdirectory("ch02")
add_subdirectory("ch03")
add_subdirectory("ch04")
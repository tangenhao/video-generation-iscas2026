cmake_minimum_required(VERSION 3.10)
project(dma_cmodel LANGUAGES C CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED off)
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")

add_library(func SHARED ${PROJECT_SOURCE_DIR}/csrc/interface.cpp)

install(TARGETS func DESTINATION ${PROJECT_SOURCE_DIR}/../c/lib)

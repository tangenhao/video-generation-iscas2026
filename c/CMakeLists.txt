cmake_minimum_required(VERSION 3.10)
project(dma_cmodel LANGUAGES C CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED off)

include_directories(${PROJECT_SOURCE_DIR}/include)

function(compile fname)
  add_executable(${fname} ${fname}.cpp)
  target_link_libraries(${fname} dl)
endfunction()

add_subdirectory(${PROJECT_SOURCE_DIR}/csrc)
function(compile fname)
  add_executable(${fname} ${fname}.cpp)
  target_link_libraries(${fname} dl)
endfunction()

SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/exe)

compile(mha)
compile(mha_simple)
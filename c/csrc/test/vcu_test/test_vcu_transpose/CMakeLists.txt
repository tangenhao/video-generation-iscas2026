function(compile fname)
  add_executable(${fname} ${fname}.cpp)
  target_link_libraries(${fname} dl)
endfunction()

SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/exe)

compile(test_vcu_transpose)
compile(test_vcu_transpose_fp16)
compile(test_vcu_transpose_int8)
compile(test_vcu_transpose_for_rope)
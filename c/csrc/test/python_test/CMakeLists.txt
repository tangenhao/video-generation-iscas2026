function(compile fname)
  add_executable(${fname} ${fname}.cpp)
  target_link_libraries(${fname} dl)
endfunction()

SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/exe)

compile(gemm_sim)
compile(rmsnorm_sim)
compile(softmax_sim)
compile(swish_sim)
compile(llama_block_sim)
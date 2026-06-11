function(compile fname)
  add_executable(${fname} ${fname}.cpp)
  target_link_libraries(${fname} dl)
endfunction()

SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/exe)

compile(test_quant)
compile(test_quant_fuse_mode)
compile(test_quant_fuse_mode_test_psum_1)
compile(test_mul_reducesum_pipeline_fuse)
compile(test_mulrec_addgelu_pipeline_fuse)

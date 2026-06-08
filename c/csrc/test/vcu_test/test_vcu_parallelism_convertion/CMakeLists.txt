function(compile fname)
  add_executable(${fname} ${fname}.cpp)
  target_link_libraries(${fname} dl)
endfunction()

SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/exe)

compile(test_vcu_4bit_convertion)
compile(test_vcu_4bit_convertion_pad_zero)
compile(test_vcu_16bit_convertion)
compile(test_vcu_16bit_convertion_multi_core)
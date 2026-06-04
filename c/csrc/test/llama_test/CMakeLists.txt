function(compile fname)
  add_executable(${fname} ${fname}.cpp)
  target_link_libraries(${fname} dl)
endfunction()

SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/exe)

compile(llama_mlp)
compile(test_llama_mlp_op)
compile(llama_attention)
compile(test_llama_attention_op)
compile(test_llama_block_op)
compile(llama_rope_embedding)
compile(test_rope_embedding_op)

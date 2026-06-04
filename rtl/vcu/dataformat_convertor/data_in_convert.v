module data_in_convert(
  psum_format_tran_in, psum_data_type, resadd_format_tran_in, resadd_para_type, 
  psum_int2fp32_out, psum_fp_to_fp32_out, resadd_int2fp32_out, resadd_fp_to_fp32_out
);

input [31:0]  psum_format_tran_in;
input [1:0]   psum_data_type;
input [31:0]  resadd_format_tran_in;
input [1:0]   resadd_para_type;
output [31:0] psum_int2fp32_out;
output [31:0] psum_fp_to_fp32_out;
output [31:0] resadd_int2fp32_out;
output [31:0] resadd_fp_to_fp32_out;

int2fp32 psum_int2fp32(
  .in_data   ( psum_format_tran_in ),
  .dtype_sel ( psum_data_type      ),
  .out_data  ( psum_int2fp32_out   )   
);

fp_to_fp32 psum_fp_to_fp32(
  .in_data   ( psum_format_tran_in[15:0] ),
  .dtype_sel ( psum_data_type[0]         ),
  .out_data  ( psum_fp_to_fp32_out       )
);

int2fp32 resadd_int2fp32(
  .in_data   ( resadd_format_tran_in ),
  .dtype_sel ( resadd_para_type      ),
  .out_data  ( resadd_int2fp32_out   )   
);

fp_to_fp32 resadd_fp_to_fp32(
  .in_data   ( resadd_format_tran_in[15:0] ),
  .dtype_sel ( resadd_para_type[0]         ),
  .out_data  ( resadd_fp_to_fp32_out       )
);

endmodule





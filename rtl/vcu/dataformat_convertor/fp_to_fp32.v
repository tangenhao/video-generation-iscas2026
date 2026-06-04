module fp_to_fp32(
  in_data, dtype_sel,
  out_data
);

input      [15:0] in_data;
input             dtype_sel;
output reg [31:0] out_data;

wire [31:0] fp16_to_fp32_data_o;
wire [31:0] bf16_to_fp32_data_o;

fp16_to_fp32 u_fp16_to_fp32(
  .fp16(in_data),
  .fp32(fp16_to_fp32_data_o)
);

bf16_to_fp32 u_bf16_to_fp32(
  .bf16(in_data),
  .fp32(bf16_to_fp32_data_o)
);

always@(*)
begin
  case(dtype_sel)
    0: out_data = fp16_to_fp32_data_o;
    1: out_data = bf16_to_fp32_data_o;
    default: out_data = 0;
  endcase
end

endmodule
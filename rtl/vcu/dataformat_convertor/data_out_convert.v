module data_out_convert(
    fpu_out, dtype_sel, 
    result_16b_int, result_8b_int, result_4b_int, 
    fpu_out_fp16_bf16, fpu_out_int
);

    input [31:0] fpu_out;
    input dtype_sel;
    output [15:0] result_16b_int;
    output [7:0] result_8b_int;
    output [3:0] result_4b_int;
    output [15:0] fpu_out_fp16_bf16;
    output [31:0] fpu_out_int;

    fp32_to_int out_fp32_to_int(
        .in_data(fpu_out),
        .out_data(fpu_out_int)
    );

    fp32_to_fp out_fp32_to_fp(
        .in_data(fpu_out),
        .dtype_sel(dtype_sel),
        .out_data(fpu_out_fp16_bf16)
    );

    assign result_16b_int = fpu_out_int[15:0];
    assign result_8b_int =  fpu_out_int[7:0];
    assign result_4b_int =  fpu_out_int[3:0];     

endmodule


module data_out_convert(
    fpu_out_fp16,
    result_8b_int,
    fpu_out_fp16_direct
);

    input [15:0] fpu_out_fp16;
    output [7:0] result_8b_int;
    output [15:0] fpu_out_fp16_direct;

    fp16_to_int8_quant out_fp16_to_int8_quant(
        .in_data(fpu_out_fp16),
        .out_data(result_8b_int)
    );

    assign fpu_out_fp16_direct = fpu_out_fp16;

endmodule

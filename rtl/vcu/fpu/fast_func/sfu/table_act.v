module table_act (
    input [4:0] func,
    input [6:0] index,
    output [54:0] para_act
);
// wire [54:0] para_tanh;
// wire [54:0] para_sigmoid;
wire [54:0] para_silu;
// wire [54:0] para_mish;
wire [54:0] para_gelu;

// table_tanh u_table_tanh (
//     .index(index),
//     .para_tanh(para_tanh)
// );

// table_sigmoid u_table_sigmoid (
//     .index(index),
//     .para_sigmoid(para_sigmoid)
// );

table_silu u_table_silu (
    .index(index),
    .para_silu(para_silu)
);

// table_mish u_table_mish (
//     .index(index),
//     .para_mish(para_mish)
// );

table_gelu u_table_gelu (
    .index(index),
    .para_gelu(para_gelu)
);

// assign para_act = (func == 5'b00001) ? para_tanh :
//                   (func == 5'b00010) ? para_sigmoid :
//                   (func == 5'b00100) ? para_silu :
//                   (func == 5'b01000) ? para_mish :
//                   (func == 5'b10000) ? para_gelu :
//                   55'b0;

assign para_act = (func == 5'b00100) ? para_silu :
                  (func == 5'b10000) ? para_gelu :
                  55'b0;

endmodule
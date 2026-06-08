module adder_71bit(
  a, b,
  o
);

input       [70:0] a;
input       [70:0] b;
output wire [70:0] o;

assign o = a + b;

// wire p_m_0, p_m_1, p_m_2, p_m_3, p_m_4;
// wire g_m_0, g_m_1, g_m_2, g_m_3, g_m_4;
// wire c_16, c_32, c_48, c_64, c_68;

// cla_16bit u_cla_16bit_0(
//   .a(a[15:0]),
//   .b(b[15:0]),
//   .c_0(1'b0),
//   .s(o[15:0]),
//   .p_m(p_m_0),
//   .g_m(g_m_0)
// );

// cla_16bit u_cla_16bit_1(
//   .a(a[31:16]),
//   .b(b[31:16]),
//   .c_0(c_16),
//   .s(o[31:16]),
//   .p_m(p_m_1),
//   .g_m(g_m_1)
// );

// cla_16bit u_cla_16bit_2(
//   .a(a[47:32]),
//   .b(b[47:32]),
//   .c_0(c_32),
//   .s(o[47:32]),
//   .p_m(p_m_2),
//   .g_m(g_m_2)
// );

// cla_16bit u_cla_16bit_3(
//   .a(a[63:48]),
//   .b(b[63:48]),
//   .c_0(c_48),
//   .s(o[63:48]),
//   .p_m(p_m_3),
//   .g_m(g_m_3)
// );

// adder_4bit u_adder_4bit_0(
//   .a(a[67:64]),
//   .b(b[67:64]),
//   .c_0(c_64),
//   .c_4(),
//   .s(o[67:64]),
//   .p_m(p_m_4),
//   .g_m(g_m_4)
// );

// wire p_m_68, p_m_69;
// wire g_m_68, g_m_69;
// wire c_67, c_69;

// assign c_16 = g_m_0 ^ (p_m_0 & 1'b0);
// assign c_32 = g_m_1 ^ (p_m_1 & g_m_0) ^ (p_m_1 & p_m_0 & 1'b0);
// assign c_48 = g_m_2 ^ (p_m_2 & g_m_1) ^ (p_m_2 & p_m_1 & g_m_0) ^ (p_m_2 & p_m_1 & p_m_0 & 1'b0);
// assign c_64 = g_m_3 ^ (p_m_3 & g_m_2) ^ (p_m_3 & p_m_2 & g_m_1) ^ (p_m_3 & p_m_2 & p_m_1 & g_m_0) ^ (p_m_3 & p_m_2 & p_m_1 & p_m_0 & 1'b0);
// assign c_67 = g_m_4 ^ (p_m_4 & g_m_3) ^ (p_m_4 & p_m_3 & g_m_2) ^ (p_m_4 & p_m_3 & p_m_2 & g_m_1) ^ (p_m_4 & p_m_3 & p_m_2 & p_m_1 & g_m_0) ^ (p_m_4 & p_m_3 & p_m_2 & p_m_1 & p_m_0 & 1'b0);
// assign c_68 = g_m_68 ^ (p_m_68 & g_m_4) ^ (p_m_68 & p_m_4 & g_m_3) ^ (p_m_68 & p_m_4 & p_m_3 & g_m_2) ^ (p_m_68 & p_m_4 & p_m_3 & p_m_2 & g_m_1) ^ (p_m_68 & p_m_4 & p_m_3 & p_m_2 & p_m_1 & g_m_0) ^ 0;
// assign c_69 = g_m_69 ^ (p_m_69 & g_m_68) ^ (p_m_69 & p_m_68 & g_m_4) ^ (p_m_69 & p_m_68 & p_m_4 & g_m_3) ^ (p_m_69 & p_m_68 & p_m_4 & p_m_3 & g_m_2) ^ (p_m_69 & p_m_68 & p_m_4 & p_m_3 & p_m_2 & g_m_1) ^ (p_m_69 & p_m_68 & p_m_4 & p_m_3 & p_m_2 & p_m_1 & g_m_0) ^ 0;

// assign p_m_68 = a[68] ^ b[68];
// assign g_m_68 = a[68] & b[68];
// assign p_m_69 = a[69] ^ b[69];
// assign g_m_69 = a[69] & b[69];

// assign o[68] = a[68] ^ b[68] ^ c_67;
// assign o[69] = a[69] ^ b[69] ^ c_68;
// assign o[70] = a[70] ^ b[70] ^ c_69;

endmodule
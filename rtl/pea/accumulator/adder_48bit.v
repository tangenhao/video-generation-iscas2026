module adder_48bit(
  a, b,
  o
);

input wire [47:0] a;
input wire [47:0] b;
output wire [47:0] o;

assign o = a + b;

// wire p_m_0, p_m_1, p_m_2;
// wire g_m_0, g_m_1, g_m_2;
// wire c_16, c_32;

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

// assign c_16 = g_m_0 ^ (p_m_0 & 1'b0);
// assign c_32 = g_m_1 ^ (p_m_1 & g_m_0) ^ (p_m_1 & p_m_0 & 1'b0);

endmodule
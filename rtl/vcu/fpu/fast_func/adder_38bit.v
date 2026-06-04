module adder_38bit(
  a, b,
  o
);

input       [37:0] a;
input       [37:0] b;
output wire [37:0] o;

assign o = a + b;

// wire p_m_0, p_m_1, p_m_36;
// wire g_m_0, g_m_1, g_m_36;
// wire c_16, c_32, c_36;

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


// adder_4bit u_adder_4bit_0(
//   .a(a[35:32]),
//   .b(b[35:32]),
//   .c_0(c_32),
//   .c_4(),
//   .s(o[35:32]),
//   .p_m(p_m_36),
//   .g_m(g_m_36)
// );

// wire  p_m_37;
// wire  g_m_37;
// wire  c_37;

// assign c_16 = g_m_0 ^ (p_m_0 & 1'b0);
// assign c_32 = g_m_1 ^ (p_m_1 & g_m_0) ^ (p_m_1 & p_m_0 & 1'b0);
// assign c_36 = g_m_36 ^ (p_m_36 & g_m_1) ^ (p_m_36 & p_m_1 & g_m_0) ^ (p_m_36 & p_m_1 & p_m_0 & 1'b0);
// assign c_37 = g_m_37 ^ (p_m_37 & g_m_36) ^ (p_m_37 & p_m_36 & g_m_1) ^ (p_m_37 & p_m_36 & p_m_1 & g_m_0)^ (p_m_37 & p_m_36 & p_m_1 & p_m_0 & 1'b0);


// assign p_m_37 = a[37] ^ b[37];
// assign g_m_37 = a[37] & b[37];

// assign o[36] = a[36] ^ b[36] ^ c_36;
// assign o[37] = a[37] ^ b[37] ^ c_37;

endmodule
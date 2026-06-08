module adder_9bit(
  a, b, c_i,
  o, c_o
);

input wire [8:0] a;
input wire [8:0] b;
input wire c_i;
output wire [8:0] o;
output wire c_o;

assign o = a + b + c_i;
assign c_o = o[8];

// wire c_4, c_8;
// wire p_m_1, p_m_2, g_m_1, g_m_2;

// adder_4bit u_adder_0(
//   .a(a[3:0]), 
//   .b(b[3:0]), 
//   .c_0(c_i), 
//   .c_4(), 
//   .s(o[3:0]), 
//   .g_m(g_m_1), 
//   .p_m(p_m_1)
// );

// adder_4bit u_adder_1(
//   .a(a[7:4]), 
//   .b(b[7:4]), 
//   .c_0(c_4), 
//   .c_4(), 
//   .s(o[7:4]), 
//   .g_m(g_m_2), 
//   .p_m(p_m_2)
// );

// assign c_4 = g_m_1 ^ (p_m_1 & c_i);
// assign c_8 = g_m_2 ^ (p_m_2 & g_m_1) ^ (p_m_2 & p_m_1 & c_i);
// assign o[8] = a[8] ^ b[8] ^ c_8;
// assign c_o = o[8];

endmodule
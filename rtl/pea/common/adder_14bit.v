module adder_14bit(
  a, b, c_i,
  o, c_o
);

input wire [13:0] a;
input wire [13:0] b;
input wire c_i;
output wire [13:0] o;
output wire c_o;

assign o = a + b + c_i;
assign c_o = o[13];

// wire c_4, c_8, c_12, c_13;
// wire p_m_1, p_m_2, p_m_3, g_m_1, g_m_2, g_m_3, p_12, g_12;

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

// adder_4bit u_adder_2(
//   .a(a[11:8]), 
//   .b(b[11:8]), 
//   .c_0(c_8), 
//   .c_4(), 
//   .s(o[11:8]), 
//   .g_m(g_m_3), 
//   .p_m(p_m_3)
// );

// assign c_4 = g_m_1 ^ (p_m_1 & c_i);
// assign c_8 = g_m_2 ^ (p_m_2 & g_m_1) ^ (p_m_2 & p_m_1 & c_i);
// assign c_12 = g_m_3 ^ (p_m_3 & g_m_2) ^ (p_m_3 & p_m_2 & g_m_1) ^ (p_m_3 & p_m_2 & p_m_1 & c_i);

// assign p_12 = a[12] ^ b[12];
// assign g_12 = a[12] & b[12];

// wire p_13, g_13;

// assign p_13 = a[13] ^ b[13];
// assign g_13 = a[13] & b[13];

// assign o[12] = a[12] ^ b[12] ^ c_12;

// assign c_13 = g_12 ^ (p_12 & g_m_3) ^ (p_12 & p_m_3 & g_m_2) ^ (p_12 & p_m_3 & p_m_2 & g_m_1) ^ (p_12 & p_m_3 & p_m_2 & p_m_1 & c_i);

// assign o[13] = a[13] ^ b[13] ^ c_13;
// assign c_o = g_13 ^ (p_13 & g_12) ^ (p_13 & p_12 & g_m_3) ^ (p_13 & p_12 & p_m_3 & g_m_2) ^ (p_13 & p_12 & p_m_3 & p_m_2 & g_m_1) ^ (p_13 & p_12 & p_m_3 & p_m_2 & p_m_1 & c_i);

endmodule
module cla_16bit(
  a, b, c_0,
  s, p_m, g_m
);

input       [15:0] a;
input       [15:0] b;
input              c_0;
output wire [15:0] s;
output wire p_m;
output wire g_m;

wire c_4, c_8, c_12;
wire p_m_0, p_m_4, p_m_8, p_m_12;
wire g_m_0, g_m_4, g_m_8, g_m_12;

adder_4bit u_adder_0(
  .a(a[3:0]),
  .b(b[3:0]),
  .c_0(c_0),
  .c_4(),
  .s(s[3:0]),
  .p_m(p_m_0),
  .g_m(g_m_0)
);

adder_4bit u_adder_1(
  .a(a[7:4]),
  .b(b[7:4]),
  .c_0(c_4),
  .c_4(),
  .s(s[7:4]),
  .p_m(p_m_4),
  .g_m(g_m_4)
);

adder_4bit u_adder_2(
  .a(a[11:8]),
  .b(b[11:8]),
  .c_0(c_8),
  .c_4(),
  .s(s[11:8]),
  .p_m(p_m_8),
  .g_m(g_m_8)
);

adder_4bit u_adder_3(
  .a(a[15:12]),
  .b(b[15:12]),
  .c_0(c_12),
  .c_4(),
  .s(s[15:12]),
  .p_m(p_m_12),
  .g_m(g_m_12)
);

assign c_4 = g_m_0 ^ (p_m_0 & c_0);
assign c_8 = g_m_4 ^ (p_m_4 & g_m_0) ^ (p_m_4 & p_m_0 & c_0);
assign c_12 = g_m_8 ^ (p_m_8 & g_m_4) ^ (p_m_8 & p_m_4 & g_m_0) ^ (p_m_8 & p_m_4 & p_m_0 & c_0);

assign p_m = p_m_0 & p_m_4 & p_m_8 & p_m_12;
assign g_m = g_m_12 ^ (p_m_12 & g_m_8) ^ (p_m_12 & p_m_8 & g_m_4) ^ (p_m_12 & p_m_8 & p_m_4 & g_m_0);

endmodule

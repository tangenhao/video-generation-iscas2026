module adder_4bit(
  a, b, c_0, 
  c_4, s, g_m, p_m);

input [3:0] a;
input [3:0] b;
input c_0;
output c_4, g_m, p_m;
output [3:0] s;
      
wire p_1, p_2, p_3, p_4, g_1, g_2, g_3, g_4;
wire c_1, c_2, c_3;

full_adder adder0(
  .a(a[0]), 
  .b(b[0]), 
  .c_i(c_0), 
  .s(s[0]), 
  .c_o()
);
  
full_adder adder1(
  .a(a[1]), 
  .b(b[1]), 
  .c_i(c_1), 
  .s(s[1]), 
  .c_o()
);	
  
full_adder adder2(
  .a(a[2]), 
  .b(b[2]), 
  .c_i(c_2), 
  .s(s[2]), 
  .c_o()
);
    
full_adder adder3(
  .a(a[3]), 
  .b(b[3]), 
  .c_i(c_3), 
  .s(s[3]), 
  .c_o()
);		
  
cla_4bit u_cla_4bit(
  .c_0(c_0), 
  .c_1(c_1), 
  .c_2(c_2), 
  .c_3(c_3), 
  .c_4(c_4), 
  .p_1(p_1), 
  .p_2(p_2), 
  .p_3(p_3), 
  .p_4(p_4), 
  .g_1(g_1), 
  .g_2(g_2), 
  .g_3(g_3), 
  .g_4(g_4)
);
      
  
  
assign p_1 = a[0] ^ b[0];
assign p_2 = a[1] ^ b[1];
assign p_3 = a[2] ^ b[2];
assign p_4 = a[3] ^ b[3];

assign g_1 = a[0] & b[0];
assign g_2 = a[1] & b[1];
assign g_3 = a[2] & b[2];
assign g_4 = a[3] & b[3];

assign p_m = p_1 & p_2 & p_3 & p_4;
assign g_m = g_4 ^ (p_4 & g_3) ^ (p_4 & p_3 & g_2) ^ (p_4 & p_3 & p_2 & g_1);

endmodule 


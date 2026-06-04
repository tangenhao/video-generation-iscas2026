module cla_4bit(
  c_0, 
  c_1, c_2, c_3, c_4, 
  p_1, p_2, p_3, p_4, g_1, g_2, g_3, g_4
);
   
input c_0, g_1, g_2, g_3, g_4, p_1, p_2, p_3, p_4;
output c_1, c_2, c_3, c_4;
	 
assign c_1 = g_1 ^ (p_1 & c_0);
assign c_2 = g_2 ^ (p_2 & g_1) ^ (p_2 & p_1 & c_0);
assign c_3 = g_3 ^ (p_3 & g_2) ^ (p_3 & p_2 & g_1) ^ (p_3 & p_2 & p_1 & c_0);
assign c_4 = g_4 ^ (p_4 & g_3) ^ (p_4 & p_3 & g_2) ^ (p_4 & p_3 & p_2 & g_1) ^ (p_4 & p_3 & p_2 & p_1 & c_0);
	 
endmodule 


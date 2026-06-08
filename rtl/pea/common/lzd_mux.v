module lzd_mux(sel, data1_i, data2_i, data_o);

  parameter N = 2;
  input               sel;
  input     [N-1 : 0] data1_i;
  input     [N-1 : 0] data2_i;
  output    [N-1 : 0] data_o;

  assign data_o = (sel == 1) ? data2_i : data1_i;
endmodule
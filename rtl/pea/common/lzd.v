module lzd(data, zcnt, full);

  parameter W = 32;
  parameter N = 5;

  input     [W-1 : 0]     data;
  output    [N-1 : 0]     zcnt;
  output                  full;

  wire full_n;
  assign full = !full_n;
  lzd_tree #(W, N) u_lzd_tree(data, full_n, zcnt);

endmodule
module lzd_tree(data_i, data_o, cnt_o);
  parameter W = 32;
  parameter N = 5;

  input   [W-1 : 0]                 data_i;
  output                            data_o;
  output  [N-1 : 0]                 cnt_o;

  wire                              left;
  wire                              right;
  wire    [N-2 : 0]                 cnt[1:0];

  generate
    if(N == 1)
    begin : lzd_tree_node
      lzd_node u_node(data_i[1], data_i[0], data_o, cnt_o[0]);
    end
    else
    begin : lzd_tree_subtree
      lzd_tree #(W>>1, N-1) u_tree_left(data_i[W-1:(W>>1)], left, cnt[1]);
      lzd_tree #(W>>1, N-1) u_tree_right(data_i[(W>>1)-1:0], right, cnt[0]);
      lzd_node u_node(left, right, data_o, cnt_o[N-1]);
      lzd_mux #(N-1) u_lzd_mux(cnt_o[N-1], cnt[1], cnt[0], cnt_o[N-2 : 0]);
    end
  endgenerate

endmodule
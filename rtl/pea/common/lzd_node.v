module lzd_node(left_i, right_i, data_o, cnt_o);

  input          left_i;
  input          right_i;
  output         data_o;
  output         cnt_o;

  assign data_o = left_i || right_i;
  assign cnt_o = left_i ^ data_o;

endmodule
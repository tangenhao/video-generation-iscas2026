module fadd_tb();

reg clk, rst_n;
reg valid;
reg [31:0] a, b;
wire [31:0] o;
wire done;

adder_float32_pipeline_stage_1 u_adder_float32_pipeline_stage_1(
  .clk   ( clk   ),
  .rst_n ( rst_n ),
  .valid ( valid ),
  .a     ( a     ),
  .b     ( b     ),
  .o     ( o     ),
  .done  ( done  )
);

initial begin
  clk   = 0;
  rst_n = 0;
  valid = 0;
  a     = 0;
  b     = 0;
  #10 rst_n = 1;
  #10 valid = 1;
  #10 a = 32'h3f800000;
  #10 b = 32'h3f800000;
  #10 valid = 0;
  #10 valid = 1;
  #10 a = 32'h3f800000;
  #10 b = 32'hbf800000;
  #10 valid = 0;
  #10 $finish;
end

always begin
  #5 clk = ~clk;
end

// Dump fsdb
initial begin
  $fsdbDumpfile("fadd_tb.fsdb");
  $fsdbDumpvars(0, fadd_tb);
end

endmodule
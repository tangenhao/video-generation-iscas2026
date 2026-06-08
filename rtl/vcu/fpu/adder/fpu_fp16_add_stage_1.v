module fpu_fp16_add_stage_1(
  clk, rst_n, valid,
  a, b,
  o, done
);

input         clk;
input         rst_n;
input         valid;
input  [15:0] a;
input  [15:0] b;
output [15:0] o;
output        done;

wire [7:0] status;
wire pipe_full;
wire pipe_ovf;
wire push_out_n;
wire pipe_census;

DW_lp_piped_fp_add #(10, 5, 1, 0, 1, 1, 1, 0, 0, 0) u_dw_lp_piped_fp_add (
  .clk         ( clk        ),
  .rst_n       ( rst_n      ),
  .a           ( a          ),
  .b           ( b          ),
  .rnd         ( 3'b000     ),
  .z           ( o          ),
  .status      ( status     ),
  .launch      ( valid      ),
  .launch_id   ( 1'b0       ),
  .pipe_full   ( pipe_full  ),
  .pipe_ovf    ( pipe_ovf   ),
  .accept_n    ( 1'b0       ),
  .arrive      ( done       ),
  .arrive_id   (            ),
  .push_out_n  ( push_out_n ),
  .pipe_census ( pipe_census)
);

endmodule
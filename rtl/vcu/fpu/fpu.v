module fpu(
  clk, rst_n, 
  valid, done, compute_done,
  func_base_highaddr,
  vculut_rvalid, vculut_rready, vculut_raddr, vculut_rdata,
  operation, out,
  
  add_op1, add_op2,
  mul_op1, mul_op2,
  fma_op1, fma_op2, fma_op3,
  fast_func_op1, fast_func_op2,
  srt16_op1, srt16_op2,
  comp_op1, comp_op2, comp_op3, comp_op4,
  bit_op1,
  stream_reduce_valid_wire, stream_reduce_operation, stream_reduce_op1, stream_reduce_op2, stream_reduce_op3, stream_reduce_op4,
  stream_reduce_done, stream_reduce_out,
  stream_fuse_valid_wire, stream_fuse_opcode, stream_fuse_mul_op1, stream_fuse_mul_op2, stream_fuse_add_op_wire,
  stream_fuse_done, stream_fuse_out
);

localparam ADD              = 6'b000001;
localparam MUL              = 6'b000010;
localparam FMA              = 6'b000011;
localparam COMP_GEQ         = 6'b000100;
localparam COMP_LES         = 6'b000101;
localparam DIV              = 6'b000110;
localparam SQRT             = 6'b000111;
localparam SIN              = 6'b001000;
localparam COS              = 6'b001001;
localparam REC              = 6'b001010;
localparam LOG              = 6'b001011;
localparam EXP              = 6'b001100;
localparam RSQRT            = 6'b001101;
localparam REDUCE_SUM       = 6'b010000;
localparam REDUCE_MAX       = 6'b010001;
localparam CONFIG_REG       = 6'b010011;
localparam LOOP             = 6'b010100;
localparam ADD_CONST        = 6'b010101;
localparam MUL_CONST        = 6'b010110;
localparam DIV_CONST        = 6'b010111;
localparam INV              = 6'b011000;
localparam ABS              = 6'b011001;
localparam COPY             = 6'b011010;
localparam FTANH            = 6'b100010;
localparam FSIGMOID         = 6'b100011;
localparam FSIWSH           = 6'b100100;
localparam FMISH            = 6'b100101;
localparam FGELU            = 6'b100110;
localparam CHANGE_PARA      = 6'b100111;
localparam OUTLIER_COMPRESS = 6'b101010;
localparam COMP_GRE         = 6'b101011;
localparam COMP_LEQ         = 6'b101100;
localparam READ_CROSS       = 6'b101101;
localparam STORE_CROSS      = 6'b101110; 

input clk;
input rst_n;
input valid;
input [15:0] add_op1;
input [15:0] add_op2;
input [15:0] mul_op1;
input [15:0] mul_op2;
input [15:0] fma_op1;
input [15:0] fma_op2;
input [15:0] fma_op3;
input [15:0] fast_func_op1;
input [15:0] fast_func_op2;
input [15:0] srt16_op1;
input [15:0] srt16_op2;
input [15:0] comp_op1;
input [15:0] comp_op2;
input [15:0] comp_op3;
input [15:0] comp_op4;
input [15:0] bit_op1;
input [5:0] operation;
input stream_reduce_valid_wire;
input [5:0] stream_reduce_operation;
input [15:0] stream_reduce_op1;
input [15:0] stream_reduce_op2;
input [15:0] stream_reduce_op3;
input [15:0] stream_reduce_op4;
input stream_fuse_valid_wire;
input [5:0] stream_fuse_opcode;
input [15:0] stream_fuse_mul_op1;
input [15:0] stream_fuse_mul_op2;
input [15:0] stream_fuse_add_op_wire;
output [15:0] out;
output done;
output [15:0] stream_reduce_out;
output stream_reduce_done;
output [15:0] stream_fuse_out;
output stream_fuse_done;

// VCULUT
input       [19:0] func_base_highaddr;
output wire        vculut_rvalid;
input              vculut_rready;
output wire [8:0]  vculut_raddr;
input       [63:0] vculut_rdata;
input              compute_done;

wire [15:0] add_out;
wire [15:0] mul_out;
wire [15:0] fma_out;
wire [15:0] fast_func_out;
wire [15:0] srt16_out;
wire [15:0] comp_out;
wire [15:0] bit_out;

wire add_done;
wire mul_done;
wire fma_done;
wire fast_func_done;
wire srt16_done;
wire comp_done;
wire bit_done;
reg [15:0] srt16_out_reg;
reg srt16_done_reg;

wire add_valid;
wire mul_valid;
wire fma_valid;
wire fast_func_valid;
wire srt16_valid;
wire comp_valid;
wire bit_valid;
wire [1:0] srt_16_func;
wire normal_add_fire;
wire normal_mul_fire;
wire stream_fuse_first_add_valid;
wire stream_fuse_first_mul_valid;
wire stream_fuse_add_valid;
wire stream_fuse_fast_func_valid;
wire stream_reduce_add_valid;
wire stream_reduce_comp_valid;
wire add_valid_in;
wire mul_valid_in;
wire fast_func_valid_in;
wire comp_valid_in;
wire [15:0] add_op1_in;
wire [15:0] add_op2_in;
wire [15:0] mul_op1_in;
wire [15:0] mul_op2_in;
wire [15:0] fast_func_op1_in;
wire [15:0] comp_op1_in;
wire [15:0] comp_op2_in;
wire [15:0] comp_op3_in;
wire [15:0] comp_op4_in;
wire [5:0]  comp_operation_in;
wire stream_fuse_first_add;
wire stream_fuse_first_mul;
wire stream_fuse_second_add;
wire stream_fuse_second_fast_func;
wire [15:0] stream_fuse_first_out;
reg [15:0] stream_fuse_add_op_d;
reg [5:0]  stream_fuse_opcode_d;
reg        stream_fuse_add_first_busy;
reg        stream_fuse_mul_busy;
reg        stream_fuse_add_busy;
reg [1:0]  stream_fuse_fast_func_busy_pipe;
reg        stream_reduce_add_busy;
reg        stream_reduce_comp_busy;
reg        normal_add_busy;
reg        normal_mul_busy;
reg        normal_comp_busy;

reg [15:0] stream_fuse_add_op;
reg        stream_fuse_valid ;

reg [5:0] operation_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    operation_reg <= 'd0;
  end
  else begin
    operation_reg <= operation;
  end
end

assign add_valid = (operation_reg == ADD) | (operation_reg == ADD_CONST);
assign mul_valid = (operation_reg == MUL) | (operation_reg == MUL_CONST);
assign fma_valid = (operation_reg == FMA);
assign fast_func_valid = (operation_reg == REC) | 
                         (operation_reg == EXP) | (operation_reg == RSQRT) |
                         (operation_reg == FSIWSH) |  (operation_reg == FGELU) ;
assign srt16_valid = ((operation_reg == DIV) | (operation_reg == SQRT)) | (operation_reg == DIV_CONST);
assign comp_valid = ((operation_reg == COMP_GEQ) | (operation_reg == COMP_LEQ) | (operation_reg == COMP_LES) | (operation_reg == COMP_GRE));
assign bit_valid =  ((operation_reg == INV) | (operation_reg == ABS));

assign out = ( {16{add_valid}} & add_out ) | ( {16{mul_valid}} & mul_out ) | ( {16{fma_valid}} & fma_out ) | ( {16{fast_func_valid}} & fast_func_out ) 
              | ( {16{srt16_valid}} & srt16_out_reg ) | ( {16{comp_valid}} & comp_out ) | ( {16{bit_valid}} & bit_out ) ;

assign srt_16_func = ({2{(operation_reg == DIV) | (operation_reg == DIV_CONST)}} & 2'b01) | ({2{(operation_reg == SQRT)}} & 2'b10);
assign stream_fuse_first_add = (operation_reg == ADD) | (operation_reg == ADD_CONST);
assign stream_fuse_first_mul = (operation_reg == MUL) | (operation_reg == MUL_CONST) | (operation_reg == FMA);
assign stream_fuse_second_add = (stream_fuse_opcode_d == ADD) | (stream_fuse_opcode_d == ADD_CONST);
assign stream_fuse_second_fast_func = (stream_fuse_opcode_d == REC) |
                                      (stream_fuse_opcode_d == EXP) |
                                      (stream_fuse_opcode_d == RSQRT) |
                                      (stream_fuse_opcode_d == FSIWSH) |
                                      (stream_fuse_opcode_d == FGELU);
assign normal_add_fire = valid & add_valid & !stream_fuse_valid_wire & !stream_fuse_add_valid;
assign normal_mul_fire = valid & mul_valid & !stream_fuse_valid_wire;
assign stream_fuse_first_add_valid = stream_fuse_valid_wire & stream_fuse_first_add;
assign stream_fuse_first_mul_valid = stream_fuse_valid_wire & stream_fuse_first_mul;
assign stream_fuse_first_out = stream_fuse_add_first_busy ? add_out : mul_out;
assign stream_fuse_add_valid = ((stream_fuse_add_first_busy & add_done) |
                                (stream_fuse_mul_busy & mul_done)) & stream_fuse_second_add;
assign stream_fuse_fast_func_valid = ((stream_fuse_add_first_busy & add_done) |
                                      (stream_fuse_mul_busy & mul_done)) & stream_fuse_second_fast_func;
assign stream_reduce_add_valid = stream_reduce_valid_wire && (stream_reduce_operation == ADD);
assign stream_reduce_comp_valid = stream_reduce_valid_wire && ((stream_reduce_operation == COMP_GEQ) ||
                                  (stream_reduce_operation == COMP_LEQ) ||
                                  (stream_reduce_operation == COMP_LES) ||
                                  (stream_reduce_operation == COMP_GRE));
assign add_valid_in = normal_add_fire | stream_fuse_first_add_valid | stream_fuse_add_valid | stream_reduce_add_valid;
assign comp_valid_in = (valid & comp_valid) | stream_reduce_comp_valid;
assign mul_valid_in = normal_mul_fire | stream_fuse_first_mul_valid;
assign fast_func_valid_in = (valid & fast_func_valid) | stream_fuse_fast_func_valid;
assign add_op1_in = stream_reduce_add_valid ? stream_reduce_op1 :
                    stream_fuse_add_valid ? stream_fuse_first_out : add_op1;
assign add_op2_in = stream_reduce_add_valid ? stream_reduce_op2 :
                    stream_fuse_add_valid ? stream_fuse_add_op_d : add_op2;
assign mul_op1_in = stream_fuse_valid_wire ? stream_fuse_mul_op1 : mul_op1;
assign mul_op2_in = stream_fuse_valid_wire ? stream_fuse_mul_op2 : mul_op2;
assign fast_func_op1_in = stream_fuse_fast_func_valid ? stream_fuse_first_out : fast_func_op1;
assign comp_op1_in = stream_reduce_comp_valid ? stream_reduce_op1 : comp_op1;
assign comp_op2_in = stream_reduce_comp_valid ? stream_reduce_op2 : comp_op2;
assign comp_op3_in = stream_reduce_comp_valid ? stream_reduce_op3 : comp_op3;
assign comp_op4_in = stream_reduce_comp_valid ? stream_reduce_op4 : comp_op4;
assign comp_operation_in = stream_reduce_comp_valid ? stream_reduce_operation : operation_reg;
assign stream_reduce_done = (stream_reduce_add_busy & add_done) | (stream_reduce_comp_busy & comp_done);
assign stream_reduce_out = ({16{stream_reduce_add_busy}} & add_out) |
                           ({16{stream_reduce_comp_busy}} & comp_out);
assign stream_fuse_done = (stream_fuse_add_busy & add_done) | (stream_fuse_fast_func_busy_pipe[1] & fast_func_done);
assign stream_fuse_out = ({16{stream_fuse_add_busy}} & add_out) |
                         ({16{stream_fuse_fast_func_busy_pipe[1]}} & fast_func_out);
assign done = (normal_add_busy & add_done) | (normal_mul_busy & mul_done) |
              fma_done | fast_func_done | (srt16_done_reg & (~valid)) |
              (normal_comp_busy & comp_done) | bit_done;


always @(posedge clk or negedge rst_n ) begin
  if (!rst_n) begin
    srt16_out_reg <= 'd0;
    srt16_done_reg <= 'd0;
    stream_fuse_add_op_d <= 'd0;
    stream_fuse_opcode_d <= 'd0;
    stream_fuse_add_first_busy <= 1'b0;
    stream_fuse_mul_busy <= 1'b0;
    stream_fuse_add_busy <= 1'b0;
    stream_fuse_fast_func_busy_pipe <= 2'b00;
    stream_reduce_add_busy <= 1'b0;
    stream_reduce_comp_busy <= 1'b0;
    normal_add_busy <= 1'b0;
    normal_mul_busy <= 1'b0;
    normal_comp_busy <= 1'b0;
  end
  else begin
    stream_fuse_add_first_busy <= stream_fuse_first_add_valid;
    stream_fuse_mul_busy <= stream_fuse_first_mul_valid;
    stream_fuse_add_busy <= stream_fuse_add_valid;
    stream_fuse_fast_func_busy_pipe <= {stream_fuse_fast_func_busy_pipe[0], stream_fuse_fast_func_valid};
    stream_reduce_add_busy <= stream_reduce_add_valid;
    stream_reduce_comp_busy <= stream_reduce_comp_valid;
    normal_add_busy <= normal_add_fire;
    normal_mul_busy <= normal_mul_fire;
    normal_comp_busy <= valid & comp_valid;
    if (stream_fuse_valid_wire) begin
      stream_fuse_add_op_d <= stream_fuse_add_op_wire;
      stream_fuse_opcode_d <= stream_fuse_opcode;
    end
    if(srt16_done) begin
      srt16_out_reg  <= srt16_out;
      srt16_done_reg <= 'd1;
    end
    else begin
      if (compute_done) begin
        srt16_out_reg  <= 'd0;
        srt16_done_reg <= 'd0;
      end
      else begin
        srt16_out_reg  <= srt16_out_reg;
        srt16_done_reg <= srt16_done_reg;
      end
    end
  end
end

fpu_fp16_add_stage_1 u_fpu_fp16_add_stage_1(
  .clk     ( clk               ),
  .rst_n   ( rst_n             ), 
	.valid   ( add_valid_in      ), 
	.a       ( add_op1_in        ), 
	.b       ( add_op2_in        ),
  .o       ( add_out           ),
  .done    ( add_done          ) 
);

fpu_fp16_mult_stage_1 u_fpu_fp16_mult_stage_1(
  .clk     ( clk               ),
  .rst_n   ( rst_n             ), 
	.valid   ( mul_valid_in      ), 
	.a       ( mul_op1_in        ), 
	.b       ( mul_op2_in        ),
  .o       ( mul_out           ),
  .done    ( mul_done          ) 
);

wire [31:0] fast_func_fp32_in;
wire [31:0] fast_func_fp32_out;

fp16_to_fp32 u_fast_func_fp16_to_fp32(
  .fp16 ( fast_func_op1_in   ),
  .fp32 ( fast_func_fp32_in  )
);

fp32_to_half u_fast_func_fp32_to_half(
  .in_data  ( fast_func_fp32_out ),
  .out_data ( fast_func_out      )
);

fast_func u_fast_func(
  .clk                 ( clk                     ),
  .rst_n               ( rst_n                   ), 
  .valid               ( fast_func_valid_in      ),
  .opcode              ( stream_fuse_fast_func_valid ? stream_fuse_opcode_d : operation_reg ),
  .din                 ( fast_func_fp32_in       ), 
  .dout                ( fast_func_fp32_out      ), 
  .done                ( fast_func_done          )
  );

compare u_compare(
  .clk       ( clk                ),
  .rst_n     ( rst_n              ), 
  .op1       ( comp_op1_in        ),
  .op2       ( comp_op2_in        ),
  .op3       ( comp_op3_in        ),
  .op4       ( comp_op4_in        ),
  .operation ( comp_operation_in  ),
  .valid     ( comp_valid_in      ),
  .data_out  ( comp_out           ),
  .done      ( comp_done          )   
);

reverse u_reverse(
  .clk      ( clk               ),
  .rst_n    ( rst_n             ),
  .op1      ( bit_op1           ),
  .valid    ( valid & bit_valid ),
  .opration ( operation_reg     ),
  .data_out ( bit_out           ),
  .done     ( bit_done          )
);


endmodule

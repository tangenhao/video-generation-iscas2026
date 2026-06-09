module operator(
  clk, rst_n, 
  vcu_execute_start,
  func_base_highaddr,
  vculut_wvalid, vculut_waddr, vculut_wdata,
  fpu_done, compute_valid, opcode, psum_data, ifmap_data, resadd_data, para_data, 
  operator_out, operator_done, change_para, prefetch, 
  loop_sign, loop_times, ini_addr, end_addr, loop_address,

  stream_reduce_valid, stream_reduce_first, stream_reduce_last, stream_reduce_data,
  stream_reduce_done, stream_reduce_out,
  stream_ewise_valid, stream_ewise_opcode, stream_ewise_psum_data, stream_ewise_ifmap_data, stream_ewise_resadd_data, stream_ewise_para_data,
  stream_ewise_done, stream_ewise_out,

  read_cross_ocgroup, read_cross_ocgroup_flag,
  write_cross_ocgroup, write_cross_ocgroup_flag, write_cross_ocgroup_sram_id, write_cross_ocgroup_dtype
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
localparam REDUCE_MIN       = 6'b010010;
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

parameter DATA_WIDTH         = 16;
parameter PARALLELISM        = 32;
parameter VCUCODE_ADDR_BITS  = 7;

parameter DATA_IN_WIDTH     = 512;
parameter VCUCODE_WIDTH     = 64;
parameter DATA_OUT_WIDTH    = 512;

parameter IDLE       = 4'b0000;
parameter DECODE     = 4'b0001;
parameter COMPUTE    = 4'b0010;
parameter DONE       = 4'b0011;
parameter ACTIVATION = 4'b0100;



parameter REG_NUM = 8;

input                     clk;
input                     rst_n;
input                     vcu_execute_start;
input                     fpu_done;
input                     compute_valid;
input [VCUCODE_WIDTH-1:0] opcode;
input [DATA_IN_WIDTH-1:0] psum_data;
input [DATA_IN_WIDTH-1:0] ifmap_data;
input [DATA_IN_WIDTH-1:0] para_data;
input [DATA_IN_WIDTH-1:0] resadd_data;
input                     stream_reduce_valid;
input                     stream_reduce_first;
input                     stream_reduce_last;
input [DATA_IN_WIDTH-1:0] stream_reduce_data;
output                    stream_reduce_done;
output [DATA_OUT_WIDTH-1:0] stream_reduce_out;
input                     stream_ewise_valid;
input [5:0]               stream_ewise_opcode;
input [DATA_IN_WIDTH-1:0] stream_ewise_psum_data;
input [DATA_IN_WIDTH-1:0] stream_ewise_ifmap_data;
input [DATA_IN_WIDTH-1:0] stream_ewise_resadd_data;
input [DATA_IN_WIDTH-1:0] stream_ewise_para_data;
output                    stream_ewise_done;
output [DATA_OUT_WIDTH-1:0] stream_ewise_out;

input  [19:0] func_base_highaddr;
input         vculut_wvalid;
input  [8:0]  vculut_waddr;
input  [63:0] vculut_wdata;

output wire [DATA_OUT_WIDTH-1:0]     operator_out;
output reg                           operator_done;
output                               change_para;
output                               read_cross_ocgroup;
output                               read_cross_ocgroup_flag;
output                               write_cross_ocgroup;
output                               write_cross_ocgroup_flag;
output      [1:0]                    write_cross_ocgroup_sram_id;
output      [2:0]                    write_cross_ocgroup_dtype;
output                               prefetch;
output                               loop_sign;
output      [31:0]                   loop_times;
output      [VCUCODE_ADDR_BITS-1:0]  ini_addr;
output      [VCUCODE_ADDR_BITS-1:0]  end_addr;
output      [VCUCODE_ADDR_BITS-1:0]  loop_address;

wire [DATA_IN_WIDTH-1:0] add_op1;
wire [DATA_IN_WIDTH-1:0] add_op2;
wire [DATA_IN_WIDTH-1:0] mul_op1;
wire [DATA_IN_WIDTH-1:0] mul_op2;
wire [DATA_IN_WIDTH-1:0] fma_op1;
wire [DATA_IN_WIDTH-1:0] fma_op2;
wire [DATA_IN_WIDTH-1:0] fma_op3;
wire [DATA_IN_WIDTH-1:0] fast_func_op1;
wire [DATA_IN_WIDTH-1:0] fast_func_op2;
wire [DATA_IN_WIDTH-1:0] srt16_op1;
wire [DATA_IN_WIDTH-1:0] srt16_op2;
wire [DATA_IN_WIDTH-1:0] comp_op1;
wire [DATA_IN_WIDTH-1:0] comp_op2;
wire [DATA_IN_WIDTH-1:0] comp_op3;
wire [DATA_IN_WIDTH-1:0] comp_op4;
wire [DATA_IN_WIDTH-1:0] bit_op1;
wire [DATA_IN_WIDTH-1:0] other_op1;

wire [DATA_OUT_WIDTH-1:0] out;
wire [PARALLELISM-1:0] done;
wire [PARALLELISM-1:0] valid_fpu;

reg [3:0] current_state;
reg [3:0] next_state;

wire [5:0]         operation;
wire               config_sign;
wire [5:0]         dst;
wire [REG_NUM-1:0] store_sign;

wire [6:0] source_1;
wire [6:0] source_2;
wire [6:0] source_3;
wire [6:0] source_4;
wire       imm_use_sign;
wire       one_cycle_sign;

wire compute_done;
wire activation_done;
assign compute_done = &done;

wire [PARALLELISM-1:0] vculut_rvalid;
wire [PARALLELISM-1:0] vculut_rready;
wire [63:0]            vculut_rdata[0:PARALLELISM-1];
wire [8:0]             vculut_raddr[0:PARALLELISM-1];

wire                     register_change_sign;
wire [31:0]              config_data;
wire                     copy_sign;
wire                     reduce_sign;
wire                     activation_sign;
wire [6*PARALLELISM-1:0] operation_fpu;
wire [PARALLELISM-1:0]   valid;
reg  [PARALLELISM-1:0]   valid_delay;

wire [5:0]                dst_init;

wire reduce_sum_sign;
wire reduce_max_sign;
wire reduce_min_sign;

reg  compute_valid_reg;

reg [DATA_WIDTH*16-1:0]  stream_l1_data;
reg [DATA_WIDTH*8-1:0]   stream_l2_data;
reg [DATA_WIDTH*4-1:0]   stream_l3_data;
reg [DATA_WIDTH*2-1:0]   stream_l4_data;
reg                      stream_l1_valid;
reg                      stream_l2_valid;
reg                      stream_l3_valid;
reg                      stream_l4_valid;
reg                      stream_l1_first;
reg                      stream_l2_first;
reg                      stream_l3_first;
reg                      stream_l4_first;
reg                      stream_l1_last;
reg                      stream_l2_last;
reg                      stream_l3_last;
reg                      stream_l4_last;
reg                      stream_acc_busy;
reg                      stream_acc_last_pending;
reg [DATA_WIDTH-1:0]     stream_acc_reg;
reg                      stream_done_reg;
reg                      stream_active;
reg                      stream_l1_fire;
reg                      stream_l1_issue_valid;
reg                      stream_l2_issue_valid;
reg                      stream_l3_issue_valid;
reg                      stream_l4_issue_valid;
reg                      stream_sum_issue_valid;
reg                      stream_acc_issue_valid;
reg                      stream_l1_issue_first;
reg                      stream_l2_issue_first;
reg                      stream_l3_issue_first;
reg                      stream_l4_issue_first;
reg                      stream_sum_issue_first;
reg                      stream_l1_issue_last;
reg                      stream_l2_issue_last;
reg                      stream_l3_issue_last;
reg                      stream_l4_issue_last;
reg                      stream_sum_issue_last;
reg [DATA_IN_WIDTH-1:0]  stream_reduce_data_reg;
reg                      stream_reduce_first_reg;
reg                      stream_reduce_last_reg;
wire                     stream_sum_enq;
wire                     stream_acc_start;
wire [DATA_WIDTH-1:0]    stream_acc_value;
wire                     stream_l1_done_fire;
wire                     stream_l2_done_fire;
wire                     stream_l3_done_fire;
wire                     stream_l4_done_fire;
wire                     stream_acc_done_fire;
wire                     stream_ewise_active;
wire                     stream_select;
wire                     stream_ewise_fma;
wire                     stream_reduce_max_op;
wire                     stream_reduce_min_op;
wire                     stream_reduce_max_active;
wire [5:0]               stream_reduce_operation;
wire [REG_NUM-1:0]       stream_reduce_store_sign;
wire [5:0]               stream_operation_fpu;
wire [DATA_IN_WIDTH-1:0] stream_activation_op1;
wire [DATA_IN_WIDTH-1:0] stream_activation_op2;
wire [DATA_IN_WIDTH-1:0] stream_activation_op3;
wire [DATA_IN_WIDTH-1:0] stream_activation_op4;
reg [PARALLELISM-1:0]    stream_fpu_valid;
reg [DATA_IN_WIDTH-1:0]  stream_fpu_op1;
reg [DATA_IN_WIDTH-1:0]  stream_fpu_op2;
reg [DATA_IN_WIDTH-1:0]  stream_fpu_op3;
reg [DATA_IN_WIDTH-1:0]  stream_fpu_op4;
reg [DATA_IN_WIDTH-1:0]  stream_fpu_op1_d;
reg [DATA_IN_WIDTH-1:0]  stream_fpu_op2_d;
reg [DATA_IN_WIDTH-1:0]  stream_fpu_op3_d;
reg [DATA_IN_WIDTH-1:0]  stream_fpu_op4_d;
wire [PARALLELISM-1:0]   stream_fuse_valid;
wire [PARALLELISM-1:0]   stream_fuse_done;
wire [DATA_OUT_WIDTH-1:0] stream_fuse_out;
reg [DATA_OUT_WIDTH-1:0] stream_ewise_out_reg;
reg                      stream_ewise_done_reg;
reg                      stream_ewise_busy;
reg [5:0]                stream_ewise_opcode_reg;
reg                      stream_ewise_valid_d;
reg [2:0]                stream_ewise_busy_pipe;
reg [2:0]                stream_ewise_fma_busy_pipe;
reg [DATA_IN_WIDTH-1:0]  stream_ewise_psum_data_d;
reg [DATA_IN_WIDTH-1:0]  stream_ewise_ifmap_data_d;
reg [DATA_IN_WIDTH-1:0]  stream_ewise_resadd_data_d;
reg [DATA_IN_WIDTH-1:0]  stream_ewise_para_data_d;

assign stream_reduce_done = stream_done_reg;
assign stream_reduce_out = {PARALLELISM{stream_acc_reg}};
assign stream_ewise_done = stream_ewise_done_reg;
assign stream_ewise_out = stream_ewise_out_reg;
assign stream_ewise_fma = stream_ewise_opcode_reg == FMA;
assign stream_reduce_max_op = opcode[5:0] == REDUCE_MAX;
assign stream_reduce_min_op = opcode[5:0] == REDUCE_MIN;
assign stream_reduce_max_active = (stream_reduce_max_op || stream_reduce_min_op) && (stream_active || stream_reduce_valid);
assign stream_reduce_operation = stream_reduce_max_op ? COMP_GEQ : stream_reduce_min_op ? COMP_LES : ADD;
assign stream_operation_fpu = stream_ewise_active ? (stream_ewise_valid ? stream_ewise_opcode : stream_ewise_opcode_reg) : stream_reduce_operation;
assign stream_activation_op1 = stream_reduce_max_active ? stream_fpu_op1_d : stream_fpu_op1;
assign stream_activation_op2 = stream_reduce_max_active ? stream_fpu_op2_d : stream_fpu_op2;
assign stream_activation_op3 = stream_reduce_max_active ? stream_fpu_op3_d : stream_fpu_op3;
assign stream_activation_op4 = stream_reduce_max_active ? stream_fpu_op4_d : stream_fpu_op4;
assign stream_fuse_valid = {PARALLELISM{stream_ewise_valid_d && stream_ewise_fma}};
assign stream_l1_done_fire = stream_l1_issue_valid && &done[15:0];
assign stream_l2_done_fire = stream_l2_issue_valid && &done[23:16];
assign stream_l3_done_fire = stream_l3_issue_valid && &done[27:24];
assign stream_l4_done_fire = stream_l4_issue_valid && &done[29:28];
assign stream_sum_enq = stream_sum_issue_valid && done[30];
assign stream_acc_done_fire = stream_acc_issue_valid && done[31];
assign stream_acc_start = stream_sum_enq && (!stream_acc_busy || stream_acc_done_fire);
assign stream_acc_value = (stream_acc_done_fire && stream_acc_busy) ? out[31*DATA_WIDTH +: DATA_WIDTH] : stream_acc_reg;
assign stream_ewise_active = stream_ewise_valid || stream_ewise_valid_d || stream_ewise_busy || (|stream_ewise_busy_pipe);
assign stream_select = stream_active || stream_reduce_valid || stream_ewise_active;

//FSM----------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    compute_valid_reg <= 'd0;
  end
  else if (fpu_done) begin
    compute_valid_reg <= 'd0;
  end
  else if (compute_valid) begin
    compute_valid_reg <= 1'b1;
  end
  else begin
    compute_valid_reg <= 'd0;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    current_state <= IDLE;
  end
  else if (fpu_done) begin
    current_state <= IDLE;
  end
  else begin
    current_state <= next_state;
  end
end

always @(*) begin
  case(current_state)
    IDLE: begin
      if (compute_valid_reg)
        next_state = DECODE;
      else
        next_state = IDLE;
    end

    DECODE: begin 
      if (loop_sign | compute_done | config_sign | change_para | register_change_sign | read_cross_ocgroup | write_cross_ocgroup)
        next_state =  DONE;
      else if (activation_sign)
        next_state = ACTIVATION;
      else if (reduce_sign)
        next_state = DONE;
      else
        next_state = COMPUTE;
    end

    COMPUTE: begin
      if (compute_done)
        next_state = DONE;
      else
        next_state = COMPUTE;
    end

    ACTIVATION: begin
      if (activation_done)
        next_state = DONE;
      else
        next_state = ACTIVATION;
    end

    DONE: begin
      next_state = IDLE;
    end

    default: begin
      next_state = IDLE;
    end
  endcase
end

genvar activation_i;
generate
  for (activation_i = 0; activation_i < PARALLELISM; activation_i = activation_i + 1) begin : activation_function
    activation_func u_activation(
      .clk                   ( clk                                               ),
      .rst_n                 ( rst_n                                             ),
      .execute_start         ( vcu_execute_start                                 ),
      .done                  ( done[activation_i]                                ),
      .out                   ( out[activation_i*DATA_WIDTH+:DATA_WIDTH]          ),
      .operation_fpu         ( operation_fpu[activation_i*6+:6]                  ),
      .valid_fpu             ( valid_fpu[activation_i]                           ),
      .operation             ( operation                                         ),
      .current_state         ( current_state                                     ),
      .normal_valid          ( valid_delay[activation_i]                         ),
      .stream_select         ( stream_select                                     ),
      .stream_valid          ( stream_fpu_valid[activation_i]                    ),
      .stream_operation      ( stream_operation_fpu                              ),
      .stream_ewise_select   ( stream_ewise_valid_d                              ),
      .stream_reduce_write_valid ( stream_done_reg                               ),
      .stream_reduce_store_sign  ( stream_reduce_store_sign                      ),
      .stream_reduce_result  ( stream_acc_reg                                    ),
      .stream_op1            ( stream_activation_op1[activation_i*DATA_WIDTH+:DATA_WIDTH] ),
      .stream_op2            ( stream_activation_op2[activation_i*DATA_WIDTH+:DATA_WIDTH] ),
      .stream_op3            ( stream_activation_op3[activation_i*DATA_WIDTH+:DATA_WIDTH] ),
      .stream_op4            ( stream_activation_op4[activation_i*DATA_WIDTH+:DATA_WIDTH] ),
      .add_op1               ( add_op1[activation_i*DATA_WIDTH+:DATA_WIDTH]      ),
      .add_op2               ( add_op2[activation_i*DATA_WIDTH+:DATA_WIDTH]      ),
      .mul_op1               ( mul_op1[activation_i*DATA_WIDTH+:DATA_WIDTH]      ),
      .mul_op2               ( mul_op2[activation_i*DATA_WIDTH+:DATA_WIDTH]      ),
      .fma_op1               ( fma_op1[activation_i*DATA_WIDTH+:DATA_WIDTH]      ),
      .fma_op2               ( fma_op2[activation_i*DATA_WIDTH+:DATA_WIDTH]      ),
      .fma_op3               ( fma_op3[activation_i*DATA_WIDTH+:DATA_WIDTH]      ),
      .fast_func_op1         ( fast_func_op1[activation_i*DATA_WIDTH+:DATA_WIDTH]),
      .fast_func_op2         ( fast_func_op2[activation_i*DATA_WIDTH+:DATA_WIDTH]),
      .srt16_op1             ( srt16_op1[activation_i*DATA_WIDTH+:DATA_WIDTH]    ),
      .srt16_op2             ( srt16_op2[activation_i*DATA_WIDTH+:DATA_WIDTH]    ),
      .comp_op1              ( comp_op1[activation_i*DATA_WIDTH+:DATA_WIDTH]     ),
      .comp_op2              ( comp_op2[activation_i*DATA_WIDTH+:DATA_WIDTH]     ),
      .comp_op3              ( comp_op3[activation_i*DATA_WIDTH+:DATA_WIDTH]     ),
      .comp_op4              ( comp_op4[activation_i*DATA_WIDTH+:DATA_WIDTH]     ),
      .bit_op1               ( bit_op1[activation_i*DATA_WIDTH+:DATA_WIDTH]      ),
      .other_op1             ( other_op1[activation_i*DATA_WIDTH+:DATA_WIDTH]    ),
      .fpu_done              ( fpu_done                                          ),
      .next_state            ( next_state                                        ),
      .config_sign           ( config_sign                                       ),
      .store_sign            ( store_sign                                        ),
      .config_data           ( config_data[DATA_WIDTH-1:0]                       ),
      .compute_done          ( compute_done                                      ),
      .copy_sign             ( copy_sign                                         ),
      .source_1              ( source_1                                          ),
      .source_2              ( source_2                                          ),
      .source_3              ( source_3                                          ),
      .source_4              ( source_4                                          ),
      .imm_use_sign          ( imm_use_sign                                      ),
      .imm                   ( opcode[DATA_WIDTH+18:19]                          ),
      .psum_data             ( stream_ewise_valid_d ? stream_ewise_psum_data_d[activation_i*DATA_WIDTH+:DATA_WIDTH] : psum_data[activation_i*DATA_WIDTH+:DATA_WIDTH] ),
      .ifmap_data            ( stream_ewise_valid_d ? stream_ewise_ifmap_data_d[activation_i*DATA_WIDTH+:DATA_WIDTH] : ifmap_data[activation_i*DATA_WIDTH+:DATA_WIDTH] ),
      .para_data             ( stream_ewise_valid_d ? stream_ewise_para_data_d[activation_i*DATA_WIDTH+:DATA_WIDTH] : para_data[activation_i*DATA_WIDTH+:DATA_WIDTH] ),
      .resadd_data           ( stream_ewise_valid_d ? stream_ewise_resadd_data_d[activation_i*DATA_WIDTH+:DATA_WIDTH] : resadd_data[activation_i*DATA_WIDTH+:DATA_WIDTH] ),
      .operator_out          ( operator_out[activation_i*DATA_WIDTH+:DATA_WIDTH] ),
      .register_change_sign  ( register_change_sign                              )
    );
  end
endgenerate

//special operation sign-------------------------------------------------
assign register_change_sign = copy_sign ;

assign operation = opcode[5:0];
assign change_para = (operation == CHANGE_PARA) & (current_state == DECODE);
assign read_cross_ocgroup = (operation == READ_CROSS) & (current_state == DECODE);
assign read_cross_ocgroup_flag = opcode[6] & read_cross_ocgroup;
assign write_cross_ocgroup = (operation == STORE_CROSS) & (current_state == DECODE);
assign write_cross_ocgroup_flag = opcode[6] & write_cross_ocgroup;
assign write_cross_ocgroup_sram_id = opcode[8:7] & {2{write_cross_ocgroup}};
assign write_cross_ocgroup_dtype = opcode[11:9] & {3{write_cross_ocgroup}};
assign prefetch = ((operation != READ_CROSS) && (operation != STORE_CROSS)) && (current_state == DECODE);
assign loop_sign = (operation == LOOP) & (current_state == DECODE);
assign loop_times = opcode[37:6] & {32{(current_state == DECODE)}} & {32{(operation == LOOP)}};
assign ini_addr = opcode[VCUCODE_ADDR_BITS+37 : 38] & {VCUCODE_ADDR_BITS{(current_state == DECODE)}} & {VCUCODE_ADDR_BITS{(operation == LOOP)}};
assign end_addr = opcode[2*VCUCODE_ADDR_BITS+37 : VCUCODE_ADDR_BITS+38] & {VCUCODE_ADDR_BITS{(current_state == DECODE)}} & {VCUCODE_ADDR_BITS{(operation == LOOP)}};
assign loop_address = opcode[3*VCUCODE_ADDR_BITS+37 : 2*VCUCODE_ADDR_BITS+38] & {VCUCODE_ADDR_BITS{(current_state == DECODE)}} & {VCUCODE_ADDR_BITS{(operation == LOOP)}};

assign copy_sign = ((operation == COPY) & (current_state == DECODE));

assign config_sign = (operation == CONFIG_REG) & (current_state == DECODE);

assign config_data = config_sign ? opcode[43:12] : 32'd0;

assign reduce_sum_sign = (operation == REDUCE_SUM);
assign reduce_max_sign = (operation == REDUCE_MAX);
assign reduce_min_sign = (operation == REDUCE_MIN);
assign reduce_sign = reduce_sum_sign | reduce_max_sign | reduce_min_sign;

// DATA SOURCE---------------------------------------------------------------
assign imm_use_sign = (operation == ADD_CONST) | (operation == MUL_CONST) | (operation == DIV_CONST);

assign source_1 = opcode[12:6];
assign source_2 = (operation < 'd7 || operation == COMP_GRE || operation == COMP_LEQ) ? opcode[25:19] : 7'b1111111;
assign source_3 = ((operation == COMP_GEQ) || (operation == COMP_LES) || (operation == COMP_LEQ) || (operation == COMP_GRE) || (operation == FMA)) ? opcode[32:26] : 7'b1111111;
assign source_4 = ((operation == COMP_GEQ) || (operation == COMP_LES) || (operation == COMP_LEQ) || (operation == COMP_GRE)) ? opcode[39:33] : 7'b1111111;

assign one_cycle_sign = ((operation == COMP_GEQ) | (operation == COMP_LES) | (operation == COMP_LEQ) | (operation == COMP_GRE)) & (current_state == DECODE);
assign valid = {PARALLELISM{((((current_state == DECODE) && (~((loop_sign | config_sign | change_para | register_change_sign  | reduce_sign  | read_cross_ocgroup | write_cross_ocgroup))))) 
                | one_cycle_sign )}};

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    valid_delay <= 1'b0;
  end
  else begin
    valid_delay <= valid;
  end
end


assign dst_init = config_sign ? opcode[11:6] : opcode[18:13];
assign dst = dst_init;

genvar store_sign_i;
generate
  for(store_sign_i = 0; store_sign_i < REG_NUM; store_sign_i = store_sign_i+1) begin:store_sign_assign
    assign store_sign[store_sign_i] = (dst == store_sign_i) && (!read_cross_ocgroup) && (!reduce_sign);
    assign stream_reduce_store_sign[store_sign_i] = (dst == store_sign_i) && reduce_sign;
  end
endgenerate

// operator_done---------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    operator_done <= 'd0;
  end
  else if (fpu_done) begin
    operator_done <= 'd0;
  end
  else if (next_state == DONE)begin
    operator_done <= 1'b1;
  end
  else if (operator_done)begin
    operator_done <= 'd0;
  end
  else begin
    operator_done <= 'd0;
  end
end
// FPU INSTANTIATION-----------------------------------------------
genvar fpu_i;
generate
  for(fpu_i = 0; fpu_i < PARALLELISM; fpu_i = fpu_i + 1) begin:fpu_instantiation
    fpu u_fpu(
      .clk                ( clk                                                    ),
      .rst_n              ( rst_n                                                  ),
      .valid              ( valid_fpu[fpu_i]                                       ),
      .compute_done       ( compute_done                                           ),
      .func_base_highaddr ( func_base_highaddr                                     ),
      .add_op1            ( add_op1[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]       ),
      .add_op2            ( add_op2[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]       ),
      .mul_op1            ( mul_op1[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]       ),
      .mul_op2            ( mul_op2[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]       ),
      .fma_op1            ( fma_op1[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]       ),
      .fma_op2            ( fma_op2[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]       ),
      .fma_op3            ( fma_op3[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]       ),
      .comp_op1           ( comp_op1[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]      ),
      .comp_op2           ( comp_op2[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]      ),
      .comp_op3           ( comp_op3[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]      ),
      .comp_op4           ( comp_op4[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]      ),
      .srt16_op1          ( srt16_op1[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]     ),
      .srt16_op2          ( srt16_op2[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]     ),
      .fast_func_op1      ( fast_func_op1[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i] ),
      .fast_func_op2      ( fast_func_op2[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i] ),
      .bit_op1            ( bit_op1[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]       ),
      .stream_fuse_valid_wire  ( stream_fuse_valid[fpu_i]                               ),
      .stream_fuse_mul_op1( fma_op1[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]     ),
      .stream_fuse_mul_op2( fma_op2[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]     ),
      .stream_fuse_add_op_wire ( fma_op3[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i] ),
      .stream_fuse_done   ( stream_fuse_done[fpu_i]                                ),
      .stream_fuse_out    ( stream_fuse_out[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i] ),
      .operation          ( operation_fpu[6*(fpu_i+1)-1 : 6*fpu_i]                ),
      .out                ( out[DATA_WIDTH*(fpu_i+1)-1:DATA_WIDTH*fpu_i]           ),
      .done               ( done[fpu_i]                                            ),
      .vculut_rvalid      ( vculut_rvalid[fpu_i]                                   ),
      .vculut_rready      ( vculut_rready[fpu_i]                                   ),
      .vculut_raddr       ( vculut_raddr[fpu_i]                                    ),
      .vculut_rdata       ( vculut_rdata[fpu_i]                                    )
    );
    end
endgenerate

integer stream_dispatch_i;
always @(*) begin
  stream_fpu_valid   = 'd0;
  stream_fpu_op1 = 'd0;
  stream_fpu_op2 = 'd0;
  stream_fpu_op3 = 'd0;
  stream_fpu_op4 = 'd0;

  if (stream_ewise_valid_d && !stream_ewise_fma) begin
    stream_fpu_valid   = {PARALLELISM{1'b1}};
  end

  if (stream_l1_fire) begin
    for (stream_dispatch_i = 0; stream_dispatch_i < 16; stream_dispatch_i = stream_dispatch_i + 1) begin
      stream_fpu_valid[stream_dispatch_i] = 1'b1;
      stream_fpu_op1[stream_dispatch_i*DATA_WIDTH +: DATA_WIDTH] = stream_reduce_data_reg[(2*stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH];
      stream_fpu_op2[stream_dispatch_i*DATA_WIDTH +: DATA_WIDTH] = stream_reduce_data_reg[(2*stream_dispatch_i+1)*DATA_WIDTH +: DATA_WIDTH];
      stream_fpu_op3[stream_dispatch_i*DATA_WIDTH +: DATA_WIDTH] = stream_reduce_data_reg[(2*stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH];
      stream_fpu_op4[stream_dispatch_i*DATA_WIDTH +: DATA_WIDTH] = stream_reduce_data_reg[(2*stream_dispatch_i+1)*DATA_WIDTH +: DATA_WIDTH];
    end
  end

  if (stream_l1_valid) begin
    for (stream_dispatch_i = 0; stream_dispatch_i < 8; stream_dispatch_i = stream_dispatch_i + 1) begin
      stream_fpu_valid[16+stream_dispatch_i] = 1'b1;
      stream_fpu_op1[(16+stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH] = stream_l1_data[(2*stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH];
      stream_fpu_op2[(16+stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH] = stream_l1_data[(2*stream_dispatch_i+1)*DATA_WIDTH +: DATA_WIDTH];
      stream_fpu_op3[(16+stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH] = stream_l1_data[(2*stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH];
      stream_fpu_op4[(16+stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH] = stream_l1_data[(2*stream_dispatch_i+1)*DATA_WIDTH +: DATA_WIDTH];
    end
  end

  if (stream_l2_valid) begin
    for (stream_dispatch_i = 0; stream_dispatch_i < 4; stream_dispatch_i = stream_dispatch_i + 1) begin
      stream_fpu_valid[24+stream_dispatch_i] = 1'b1;
      stream_fpu_op1[(24+stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH] = stream_l2_data[(2*stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH];
      stream_fpu_op2[(24+stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH] = stream_l2_data[(2*stream_dispatch_i+1)*DATA_WIDTH +: DATA_WIDTH];
      stream_fpu_op3[(24+stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH] = stream_l2_data[(2*stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH];
      stream_fpu_op4[(24+stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH] = stream_l2_data[(2*stream_dispatch_i+1)*DATA_WIDTH +: DATA_WIDTH];
    end
  end

  if (stream_l3_valid) begin
    for (stream_dispatch_i = 0; stream_dispatch_i < 2; stream_dispatch_i = stream_dispatch_i + 1) begin
      stream_fpu_valid[28+stream_dispatch_i] = 1'b1;
      stream_fpu_op1[(28+stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH] = stream_l3_data[(2*stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH];
      stream_fpu_op2[(28+stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH] = stream_l3_data[(2*stream_dispatch_i+1)*DATA_WIDTH +: DATA_WIDTH];
      stream_fpu_op3[(28+stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH] = stream_l3_data[(2*stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH];
      stream_fpu_op4[(28+stream_dispatch_i)*DATA_WIDTH +: DATA_WIDTH] = stream_l3_data[(2*stream_dispatch_i+1)*DATA_WIDTH +: DATA_WIDTH];
    end
  end

  if (stream_l4_valid) begin
    stream_fpu_valid[30] = 1'b1;
    stream_fpu_op1[30*DATA_WIDTH +: DATA_WIDTH] = stream_l4_data[0*DATA_WIDTH +: DATA_WIDTH];
    stream_fpu_op2[30*DATA_WIDTH +: DATA_WIDTH] = stream_l4_data[1*DATA_WIDTH +: DATA_WIDTH];
    stream_fpu_op3[30*DATA_WIDTH +: DATA_WIDTH] = stream_l4_data[0*DATA_WIDTH +: DATA_WIDTH];
    stream_fpu_op4[30*DATA_WIDTH +: DATA_WIDTH] = stream_l4_data[1*DATA_WIDTH +: DATA_WIDTH];
  end

  if (stream_acc_start) begin
    stream_fpu_valid[31] = 1'b1;
    stream_fpu_op1[31*DATA_WIDTH +: DATA_WIDTH] = out[30*DATA_WIDTH +: DATA_WIDTH];
    stream_fpu_op2[31*DATA_WIDTH +: DATA_WIDTH] = stream_sum_issue_first ? {DATA_WIDTH{1'b0}} : stream_acc_value;
    stream_fpu_op3[31*DATA_WIDTH +: DATA_WIDTH] = out[30*DATA_WIDTH +: DATA_WIDTH];
    stream_fpu_op4[31*DATA_WIDTH +: DATA_WIDTH] = stream_sum_issue_first ? {DATA_WIDTH{1'b0}} : stream_acc_value;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    stream_l1_data         <= 'd0;
    stream_l2_data         <= 'd0;
    stream_l3_data         <= 'd0;
    stream_l4_data         <= 'd0;
    stream_l1_valid        <= 1'b0;
    stream_l2_valid        <= 1'b0;
    stream_l3_valid        <= 1'b0;
    stream_l4_valid        <= 1'b0;
    stream_l1_first        <= 1'b0;
    stream_l2_first        <= 1'b0;
    stream_l3_first        <= 1'b0;
    stream_l4_first        <= 1'b0;
    stream_l1_last         <= 1'b0;
    stream_l2_last         <= 1'b0;
    stream_l3_last         <= 1'b0;
    stream_l4_last         <= 1'b0;
    stream_acc_busy        <= 1'b0;
    stream_acc_last_pending<= 1'b0;
    stream_acc_reg         <= {DATA_WIDTH{1'b0}};
    stream_done_reg        <= 1'b0;
    stream_ewise_out_reg   <= 'd0;
    stream_ewise_done_reg  <= 1'b0;
    stream_ewise_busy      <= 1'b0;
    stream_ewise_opcode_reg<= ADD;
    stream_ewise_valid_d   <= 1'b0;
    stream_ewise_busy_pipe <= 3'd0;
    stream_ewise_psum_data_d <= 'd0;
    stream_ewise_ifmap_data_d <= 'd0;
    stream_ewise_resadd_data_d <= 'd0;
    stream_ewise_para_data_d <= 'd0;
    stream_ewise_fma_busy_pipe <= 3'd0;
    stream_fpu_op1_d  <= 'd0;
    stream_fpu_op2_d  <= 'd0;
    stream_fpu_op3_d  <= 'd0;
    stream_fpu_op4_d  <= 'd0;
    stream_active          <= 1'b0;
    stream_l1_fire         <= 1'b0;
    stream_l1_issue_valid  <= 1'b0;
    stream_l2_issue_valid  <= 1'b0;
    stream_l3_issue_valid  <= 1'b0;
    stream_l4_issue_valid  <= 1'b0;
    stream_sum_issue_valid <= 1'b0;
    stream_acc_issue_valid <= 1'b0;
    stream_l1_issue_first  <= 1'b0;
    stream_l2_issue_first  <= 1'b0;
    stream_l3_issue_first  <= 1'b0;
    stream_l4_issue_first  <= 1'b0;
    stream_sum_issue_first <= 1'b0;
    stream_l1_issue_last   <= 1'b0;
    stream_l2_issue_last   <= 1'b0;
    stream_l3_issue_last   <= 1'b0;
    stream_l4_issue_last   <= 1'b0;
    stream_sum_issue_last  <= 1'b0;
    stream_reduce_data_reg <= 'd0;
    stream_reduce_first_reg<= 1'b0;
    stream_reduce_last_reg <= 1'b0;
  end
  else if (!vcu_execute_start) begin
    stream_l1_valid        <= 1'b0;
    stream_l2_valid        <= 1'b0;
    stream_l3_valid        <= 1'b0;
    stream_l4_valid        <= 1'b0;
    stream_l1_first        <= 1'b0;
    stream_l2_first        <= 1'b0;
    stream_l3_first        <= 1'b0;
    stream_l4_first        <= 1'b0;
    stream_l1_last         <= 1'b0;
    stream_l2_last         <= 1'b0;
    stream_l3_last         <= 1'b0;
    stream_l4_last         <= 1'b0;
    stream_acc_busy        <= 1'b0;
    stream_acc_last_pending<= 1'b0;
    stream_done_reg        <= 1'b0;
    stream_ewise_done_reg  <= 1'b0;
    stream_ewise_busy      <= 1'b0;
    stream_ewise_opcode_reg<= ADD;
    stream_ewise_valid_d   <= 1'b0;
    stream_ewise_busy_pipe <= 3'd0;
    stream_ewise_psum_data_d <= 'd0;
    stream_ewise_ifmap_data_d <= 'd0;
    stream_ewise_resadd_data_d <= 'd0;
    stream_ewise_para_data_d <= 'd0;
    stream_ewise_fma_busy_pipe <= 3'd0;
    stream_fpu_op1_d  <= 'd0;
    stream_fpu_op2_d  <= 'd0;
    stream_fpu_op3_d  <= 'd0;
    stream_fpu_op4_d  <= 'd0;
    stream_active          <= 1'b0;
    stream_l1_fire         <= 1'b0;
    stream_l1_issue_valid  <= 1'b0;
    stream_l2_issue_valid  <= 1'b0;
    stream_l3_issue_valid  <= 1'b0;
    stream_l4_issue_valid  <= 1'b0;
    stream_sum_issue_valid <= 1'b0;
    stream_acc_issue_valid <= 1'b0;
    stream_l1_issue_first  <= 1'b0;
    stream_l2_issue_first  <= 1'b0;
    stream_l3_issue_first  <= 1'b0;
    stream_l4_issue_first  <= 1'b0;
    stream_sum_issue_first <= 1'b0;
    stream_l1_issue_last   <= 1'b0;
    stream_l2_issue_last   <= 1'b0;
    stream_l3_issue_last   <= 1'b0;
    stream_l4_issue_last   <= 1'b0;
    stream_sum_issue_last  <= 1'b0;
    stream_reduce_data_reg <= 'd0;
    stream_reduce_first_reg<= 1'b0;
    stream_reduce_last_reg <= 1'b0;
  end
  else begin
    stream_done_reg  <= 1'b0;
    stream_l1_fire   <= 1'b0;
    stream_ewise_done_reg <= 1'b0;
    stream_ewise_valid_d <= stream_ewise_valid;
    stream_fpu_op1_d <= stream_fpu_op1;
    stream_fpu_op2_d <= stream_fpu_op2;
    stream_fpu_op3_d <= stream_fpu_op3;
    stream_fpu_op4_d <= stream_fpu_op4;
    if (stream_ewise_valid) begin
      stream_ewise_opcode_reg <= stream_ewise_opcode;
      stream_ewise_psum_data_d <= stream_ewise_psum_data;
      stream_ewise_ifmap_data_d <= stream_ewise_ifmap_data;
      stream_ewise_resadd_data_d <= stream_ewise_resadd_data;
      stream_ewise_para_data_d <= stream_ewise_para_data;
    end

    if (stream_reduce_valid) begin
      stream_reduce_data_reg  <= stream_reduce_data;
      stream_reduce_first_reg <= stream_reduce_first;
      stream_reduce_last_reg  <= stream_reduce_last;
      stream_l1_fire          <= 1'b1;
      stream_active           <= 1'b1;
    end

    stream_l1_issue_valid <= stream_l1_fire;
    stream_l1_issue_first <= stream_reduce_first_reg;
    stream_l1_issue_last  <= stream_reduce_last_reg;

    stream_l2_issue_valid <= stream_l1_valid;
    stream_l2_issue_first <= stream_l1_first;
    stream_l2_issue_last  <= stream_l1_last;

    stream_l3_issue_valid <= stream_l2_valid;
    stream_l3_issue_first <= stream_l2_first;
    stream_l3_issue_last  <= stream_l2_last;

    stream_l4_issue_valid <= stream_l3_valid;
    stream_l4_issue_first <= stream_l3_first;
    stream_l4_issue_last  <= stream_l3_last;

    stream_sum_issue_valid <= stream_l4_valid;
    stream_sum_issue_first <= stream_l4_first;
    stream_sum_issue_last  <= stream_l4_last;

    stream_acc_issue_valid <= stream_acc_start;

    stream_l1_valid <= stream_l1_done_fire;
    if (stream_l1_done_fire) begin
      stream_l1_data  <= out[DATA_WIDTH*16-1:0];
      stream_l1_first <= stream_l1_issue_first;
      stream_l1_last  <= stream_l1_issue_last;
    end

    stream_l2_valid <= stream_l2_done_fire;
    if (stream_l2_done_fire) begin
      stream_l2_data  <= out[DATA_WIDTH*24-1:DATA_WIDTH*16];
      stream_l2_first <= stream_l2_issue_first;
      stream_l2_last  <= stream_l2_issue_last;
    end

    stream_l3_valid <= stream_l3_done_fire;
    if (stream_l3_done_fire) begin
      stream_l3_data  <= out[DATA_WIDTH*28-1:DATA_WIDTH*24];
      stream_l3_first <= stream_l3_issue_first;
      stream_l3_last  <= stream_l3_issue_last;
    end

    stream_l4_valid <= stream_l4_done_fire;
    if (stream_l4_done_fire) begin
      stream_l4_data  <= out[DATA_WIDTH*30-1:DATA_WIDTH*28];
      stream_l4_first <= stream_l4_issue_first;
      stream_l4_last  <= stream_l4_issue_last;
    end

    if (stream_acc_done_fire && stream_acc_busy) begin
      stream_acc_reg  <= out[31*DATA_WIDTH +: DATA_WIDTH];
      stream_acc_busy <= 1'b0;
      if (stream_acc_last_pending) begin
        stream_done_reg         <= 1'b1;
        stream_acc_last_pending <= 1'b0;
        stream_active           <= 1'b0;
      end
    end

    if (stream_acc_start) begin
      stream_acc_busy         <= 1'b1;
      stream_acc_last_pending <= stream_sum_issue_last;
    end

    if ((stream_ewise_fma && stream_ewise_fma_busy_pipe[1] && &stream_fuse_done) ||
        (!stream_ewise_fma && (|stream_ewise_busy_pipe) && &done)) begin
      stream_ewise_out_reg  <= stream_ewise_fma ? stream_fuse_out : out;
      stream_ewise_done_reg <= 1'b1;
    end

    stream_ewise_busy <= stream_ewise_valid_d;
    stream_ewise_busy_pipe <= {stream_ewise_busy_pipe[1:0], stream_ewise_valid_d && !stream_ewise_fma};
    stream_ewise_fma_busy_pipe <= {stream_ewise_fma_busy_pipe[1:0], stream_ewise_valid_d && stream_ewise_fma};
  end
end

endmodule

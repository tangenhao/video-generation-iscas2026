module activation_func(
  clk, rst_n,
  execute_start,
  done,
  next_state, config_sign, store_sign, config_data, register_change_sign,
  compute_done, copy_sign, reduce_out,

  out, reduce_done, fpu_done, reduce_op1, reduce_op2, reduce_op3, reduce_op4,

  operation_fpu, reduce_sign, reduce_operation, operation,

  current_state,

  source_1, source_2, source_3, source_4, imm_use_sign, imm,
  psum_data, ifmap_data, resadd_data, para_data,
  add_op1, add_op2, mul_op1, mul_op2, fma_op1, fma_op2, fma_op3, fast_func_op1, fast_func_op2, srt16_op1, srt16_op2, comp_op1, comp_op2, comp_op3, comp_op4, bit_op1, other_op1,

  operator_out, reduce_data
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

localparam IDLE       = 4'b0000;
localparam DECODE     = 4'b0001;
localparam COMPUTE    = 4'b0010;
localparam DONE       = 4'b0011;
localparam REDUCE     = 4'b0101;


parameter DATA_WIDTH = 16;
parameter REG_NUM = 8;

input                     clk;
input                     rst_n;
input                     execute_start;
input                     done;
input       [6:0]         source_1;
input       [6:0]         source_2;
input       [6:0]         source_3;
input       [6:0]         source_4;
input                     imm_use_sign;
input       [DATA_WIDTH-1:0] psum_data;
input       [DATA_WIDTH-1:0] ifmap_data;
input       [DATA_WIDTH-1:0] resadd_data;
input       [DATA_WIDTH-1:0] para_data;
input       [DATA_WIDTH-1:0] imm;
input                     reduce_sign;
input       [5:0]         reduce_operation;
input       [5:0]         operation;
input       [DATA_WIDTH-1:0] out;
input       [3:0]         current_state;

input                     fpu_done;
input       [DATA_WIDTH-1:0] reduce_op1;
input       [DATA_WIDTH-1:0] reduce_op2;
input       [DATA_WIDTH-1:0] reduce_op3;
input       [DATA_WIDTH-1:0] reduce_op4;
input                     reduce_done;
input       [3:0]         next_state;
input                     config_sign;
input       [REG_NUM-1:0] store_sign;
input       [DATA_WIDTH-1:0] config_data;
input                     compute_done;
input                     copy_sign;
input       [DATA_WIDTH-1:0] reduce_out;
input                     register_change_sign;

output wire [5:0]         operation_fpu;
output reg  [DATA_WIDTH-1:0] add_op1;
output reg  [DATA_WIDTH-1:0] add_op2;
output reg  [DATA_WIDTH-1:0] mul_op1;
output reg  [DATA_WIDTH-1:0] mul_op2;
output reg  [DATA_WIDTH-1:0] fma_op1;
output reg  [DATA_WIDTH-1:0] fma_op2;
output reg  [DATA_WIDTH-1:0] fma_op3;
output reg  [DATA_WIDTH-1:0] fast_func_op1;
output reg  [DATA_WIDTH-1:0] fast_func_op2;
output reg  [DATA_WIDTH-1:0] srt16_op1;
output reg  [DATA_WIDTH-1:0] srt16_op2;
output reg  [DATA_WIDTH-1:0] comp_op1;
output reg  [DATA_WIDTH-1:0] comp_op2;
output reg  [DATA_WIDTH-1:0] comp_op3;
output reg  [DATA_WIDTH-1:0] comp_op4;
output reg  [DATA_WIDTH-1:0] bit_op1;
output wire [DATA_WIDTH-1:0] other_op1;
output reg  [DATA_WIDTH-1:0] reduce_data;
output reg  [DATA_WIDTH-1:0] operator_out;

reg [DATA_WIDTH-1:0] iteration_reg[0:REG_NUM-1];

reg [DATA_WIDTH-1:0] op1_init;
reg [DATA_WIDTH-1:0] op2_init;
reg [DATA_WIDTH-1:0] op3_init;
reg [DATA_WIDTH-1:0] op4_init;

always @(*) begin
  case(source_1)
    7'b0000000: begin
      op1_init = iteration_reg[0];
    end
    7'b0000001: begin
      op1_init = iteration_reg[1];
    end
    7'b0000010: begin
      op1_init = iteration_reg[2];
    end
    7'b0000011: begin
      op1_init = iteration_reg[3];
    end
    7'b0000100: begin
      op1_init = iteration_reg[4];
    end
    7'b0000101: begin
      op1_init = iteration_reg[5];
    end
    7'b0000110: begin
      op1_init = iteration_reg[6];
    end
    7'b0000111: begin
      op1_init = iteration_reg[7];
    end
    7'b1000000: begin
      op1_init = psum_data;
    end
    7'b1000001: begin
      op1_init = resadd_data;
    end
    7'b1000010: begin
      op1_init = para_data;
    end
    7'b1000011: begin
      op1_init = ifmap_data;
    end
    default: begin
      op1_init = {DATA_WIDTH{1'b0}};
    end
  endcase
end

always @(*) begin
  if (imm_use_sign) begin
    op2_init = imm;
  end
  else begin
    case(source_2)
      7'b0000000: begin
        op2_init = iteration_reg[0];
      end
      7'b0000001: begin
        op2_init = iteration_reg[1];
      end
      7'b0000010: begin
        op2_init = iteration_reg[2];
      end
      7'b0000011: begin
        op2_init = iteration_reg[3];
      end
      7'b0000100: begin
        op2_init = iteration_reg[4];
      end
      7'b0000101: begin
        op2_init = iteration_reg[5];
      end
      7'b0000110: begin
        op2_init = iteration_reg[6];
      end
      7'b0000111: begin
        op2_init = iteration_reg[7];
      end
      7'b1000000: begin
        op2_init = psum_data;
      end
      7'b1000001: begin
        op2_init = resadd_data;
      end
      7'b1000010: begin
        op2_init = para_data;
      end
      7'b1000011: begin
        op2_init = ifmap_data;
      end
      default: begin
        op2_init = {DATA_WIDTH{1'b0}};
      end
    endcase
  end
end

always @(*) begin
  case(source_3)
    7'b0000000: begin
      op3_init = iteration_reg[0];
    end
    7'b0000001: begin
      op3_init = iteration_reg[1];
    end
    7'b0000010: begin
      op3_init = iteration_reg[2];
    end
    7'b0000011: begin
      op3_init = iteration_reg[3];
    end
    7'b0000100: begin
      op3_init = iteration_reg[4];
    end
    7'b0000101: begin
      op3_init = iteration_reg[5];
    end
    7'b0000110: begin
      op3_init = iteration_reg[6];
    end
    7'b0000111: begin
      op3_init = iteration_reg[7];
    end
    7'b1000000: begin
      op3_init = psum_data;
    end
    7'b1000001: begin
      op3_init = resadd_data;
    end
    7'b1000010: begin
      op3_init = para_data;
    end
    7'b1000011: begin
      op3_init = ifmap_data;
    end
    default: begin
      op3_init = {DATA_WIDTH{1'b0}};
    end
  endcase
end

always @(*) begin
  case(source_4)
    7'b0000000: begin
      op4_init = iteration_reg[0];
    end
    7'b0000001: begin
      op4_init = iteration_reg[1];
    end
    7'b0000010: begin
      op4_init = iteration_reg[2];
    end
    7'b0000011: begin
      op4_init = iteration_reg[3];
    end
    7'b0000100: begin
      op4_init = iteration_reg[4];
    end
    7'b0000101: begin
      op4_init = iteration_reg[5];
    end
    7'b0000110: begin
      op4_init = iteration_reg[6];
    end
    7'b0000111: begin
      op4_init = iteration_reg[7];
    end
    7'b1000000: begin
      op4_init = psum_data;
    end
    7'b1000001: begin
      op4_init = resadd_data;
    end
    7'b1000010: begin
      op4_init = para_data;
    end
    7'b1000011: begin
      op4_init = ifmap_data;
    end
    default: begin
      op4_init = {DATA_WIDTH{1'b0}};
    end
  endcase
end

wire [DATA_WIDTH-1:0] op1;
wire [DATA_WIDTH-1:0] op2;
wire [DATA_WIDTH-1:0] op3;
wire [DATA_WIDTH-1:0] op4;

assign operation_fpu = reduce_sign ? reduce_operation : operation;

assign op1 = (current_state != REDUCE)  ? op1_init :
             (current_state == REDUCE) ? reduce_op1 : {DATA_WIDTH{1'b0}};

assign op2 = (current_state != REDUCE)  ? op2_init :
             (current_state == REDUCE) ? reduce_op2 : {DATA_WIDTH{1'b0}};

assign op3 = (current_state != REDUCE) ? op3_init :
             (current_state == REDUCE) ? reduce_op3 : {DATA_WIDTH{1'b0}};

assign op4 = (current_state != REDUCE) ? op4_init :
             (current_state == REDUCE) ? reduce_op4 : {DATA_WIDTH{1'b0}};

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    add_op1       <= {DATA_WIDTH{1'b0}};
    add_op2       <= {DATA_WIDTH{1'b0}};
    mul_op1       <= {DATA_WIDTH{1'b0}};
    mul_op2       <= {DATA_WIDTH{1'b0}};
    fma_op1       <= {DATA_WIDTH{1'b0}};
    fma_op2       <= {DATA_WIDTH{1'b0}};
    fma_op3       <= {DATA_WIDTH{1'b0}};
    fast_func_op1 <= {DATA_WIDTH{1'b0}};
    fast_func_op2 <= {DATA_WIDTH{1'b0}};
    srt16_op1     <= {DATA_WIDTH{1'b0}};
    srt16_op2     <= {DATA_WIDTH{1'b0}};
    comp_op1      <= {DATA_WIDTH{1'b0}};
    comp_op2      <= {DATA_WIDTH{1'b0}};
    comp_op3      <= {DATA_WIDTH{1'b0}};
    comp_op4      <= {DATA_WIDTH{1'b0}};
    bit_op1       <= {DATA_WIDTH{1'b0}};
  end
  else begin
    if (execute_start) begin
      case(operation_fpu)
        ADD: begin
          add_op1 <= op1;
          add_op2 <= op2;
        end
        MUL: begin
          mul_op1 <= op1;
          mul_op2 <= op2;
        end
        FMA: begin
          fma_op1 <= op1;
          fma_op2 <= op2;
          fma_op3 <= op3;
        end
        COMP_GEQ: begin
          comp_op1 <= op1;
          comp_op2 <= op2;
          comp_op3 <= op3;
          comp_op4 <= op4;
        end
        COMP_LES: begin
          comp_op1 <= op1;
          comp_op2 <= op2;
          comp_op3 <= op3;
          comp_op4 <= op4;
        end
        COMP_GRE: begin
          comp_op1 <= op1;
          comp_op2 <= op2;
          comp_op3 <= op3;
          comp_op4 <= op4;
        end
        COMP_LEQ: begin
          comp_op1 <= op1;
          comp_op2 <= op2;
          comp_op3 <= op3;
          comp_op4 <= op4;
        end
        DIV: begin
          srt16_op1 <= op1;
          srt16_op2 <= op2;
        end
        SQRT: begin
          srt16_op1 <= op1;
          srt16_op2 <= op2;
        end
        REC: begin
          fast_func_op1 <= op1;
          fast_func_op2 <= op2;
        end
        EXP: begin
          fast_func_op1 <= op1;
          fast_func_op2 <= op2;
        end
        RSQRT: begin
          fast_func_op1 <= op1;
          fast_func_op2 <= op2;
        end
        INV: begin
          bit_op1 <= op1;
        end
        ABS: begin
          bit_op1 <= op1;
        end
        FSIWSH: begin
          fast_func_op1 <= op1;
          fast_func_op2 <= op2;
        end
        FGELU: begin
          fast_func_op1 <= op1;
          fast_func_op2 <= op2;
        end
        ADD_CONST: begin
          add_op1 <= op1;
          add_op2 <= op2;
        end
        MUL_CONST: begin
          mul_op1 <= op1;
          mul_op2 <= op2;
        end
        DIV_CONST: begin
          srt16_op1 <= op1;
          srt16_op2 <= op2;
        end
      endcase
    end
    else begin
      add_op1       <= add_op1;
      add_op2       <= add_op2;
      mul_op1       <= mul_op1;
      mul_op2       <= mul_op2;
      fma_op1       <= fma_op1;
      fma_op2       <= fma_op2;
      fma_op3       <= fma_op3;
      fast_func_op1 <= fast_func_op1;
      fast_func_op2 <= fast_func_op2;
      srt16_op1     <= srt16_op1;
      srt16_op2     <= srt16_op2;
      comp_op1      <= comp_op1;
      comp_op2      <= comp_op2;
      comp_op3      <= comp_op3;
      comp_op4      <= comp_op4;
      bit_op1       <= bit_op1;
    end
  end
end

assign other_op1 = op1;

integer iteration_reg_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (iteration_reg_i=0; iteration_reg_i<REG_NUM; iteration_reg_i=iteration_reg_i+1) begin
      iteration_reg[iteration_reg_i] <= {DATA_WIDTH{1'b0}};
    end
  end
  else begin
    if ((next_state == DONE) | (compute_done & (~reduce_sign)) | register_change_sign  | reduce_done) begin
      for (iteration_reg_i = 0; iteration_reg_i < REG_NUM; iteration_reg_i = iteration_reg_i+1) begin
        if (store_sign[iteration_reg_i]) begin
          if (config_sign) begin
            iteration_reg[iteration_reg_i] <= config_data;
          end
          else if (compute_done && (!reduce_done)) begin
            iteration_reg[iteration_reg_i] <= out;
          end
          else if (copy_sign) begin
            iteration_reg[iteration_reg_i] <= other_op1;
          end
          else if (reduce_done) begin
            iteration_reg[iteration_reg_i] <= reduce_out;
          end
          else begin
            iteration_reg[iteration_reg_i] <= iteration_reg[iteration_reg_i];
          end
        end
      end
    end
    else begin
      for (iteration_reg_i=0; iteration_reg_i<REG_NUM; iteration_reg_i=iteration_reg_i+1) begin
        iteration_reg[iteration_reg_i] <= iteration_reg[iteration_reg_i];
      end
    end
  end
end

reg [REG_NUM-1:0] store_sign_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    store_sign_reg <= 0;
  end
  else begin
    store_sign_reg <= store_sign;
  end
end

always @(*) begin
  case(store_sign_reg)
    8'h01: begin
      operator_out = iteration_reg[0];
    end
    8'h02: begin
      operator_out = iteration_reg[1];
    end
    8'h04: begin
      operator_out = iteration_reg[2];
    end
    8'h08: begin
      operator_out = iteration_reg[3];
    end
    8'h10: begin
      operator_out = iteration_reg[4];
    end
    8'h20: begin
      operator_out = iteration_reg[5];
    end
    8'h40: begin
      operator_out = iteration_reg[6];
    end
    8'h80: begin
      operator_out = iteration_reg[7];
    end
    default: begin
      operator_out = {DATA_WIDTH{1'b0}};
    end
  endcase
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    reduce_data <= {DATA_WIDTH{1'b0}};
  end
  else begin
    reduce_data <= op1_init;
  end
end

endmodule

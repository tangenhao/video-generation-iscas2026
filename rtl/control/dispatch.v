module dispatch(
  clk, rst_n,

  insn_M_raddr, insn_M_rlen, insn_M_raddr_ready, insn_M_raddr_valid,
  insn_M_rdata, insn_M_rdata_valid, insn_M_rdata_ready,

  synchronize_fifo_full, synchronize_fifo_wen, synchronize_fifo_wdata,
  load_0_fifo_full, load_0_fifo_wen, load_0_fifo_wdata,
  load_1_fifo_full, load_1_fifo_wen, load_1_fifo_wdata,
  load_2_fifo_full, load_2_fifo_wen, load_2_fifo_wdata,
  load_3_fifo_full, load_3_fifo_wen, load_3_fifo_wdata,
  load_4_fifo_full, load_4_fifo_wen, load_4_fifo_wdata,
  load_5_fifo_full, load_5_fifo_wen, load_5_fifo_wdata,
  load_6_fifo_full, load_6_fifo_wen, load_6_fifo_wdata,
  load_7_fifo_full, load_7_fifo_wen, load_7_fifo_wdata,
  store_0_fifo_full, store_0_fifo_wen, store_0_fifo_wdata,
  store_1_fifo_full, store_1_fifo_wen, store_1_fifo_wdata,
  store_2_fifo_full, store_2_fifo_wen, store_2_fifo_wdata,
  store_3_fifo_full, store_3_fifo_wen, store_3_fifo_wdata,
  store_4_fifo_full, store_4_fifo_wen, store_4_fifo_wdata,
  store_5_fifo_full, store_5_fifo_wen, store_5_fifo_wdata,
  store_6_fifo_full, store_6_fifo_wen, store_6_fifo_wdata,
  store_7_fifo_full, store_7_fifo_wen, store_7_fifo_wdata,
  pea_0_fifo_full, pea_0_fifo_wen, pea_0_fifo_wdata,
  pea_1_fifo_full, pea_1_fifo_wen, pea_1_fifo_wdata,
  pea_2_fifo_full, pea_2_fifo_wen, pea_2_fifo_wdata,
  pea_3_fifo_full, pea_3_fifo_wen, pea_3_fifo_wdata,
  pea_4_fifo_full, pea_4_fifo_wen, pea_4_fifo_wdata,
  pea_5_fifo_full, pea_5_fifo_wen, pea_5_fifo_wdata,
  pea_6_fifo_full, pea_6_fifo_wen, pea_6_fifo_wdata,
  pea_7_fifo_full, pea_7_fifo_wen, pea_7_fifo_wdata,
  vcu_0_fifo_full, vcu_0_fifo_wen, vcu_0_fifo_wdata,
  vcu_1_fifo_full, vcu_1_fifo_wen, vcu_1_fifo_wdata,
  vcu_2_fifo_full, vcu_2_fifo_wen, vcu_2_fifo_wdata,
  vcu_3_fifo_full, vcu_3_fifo_wen, vcu_3_fifo_wdata,
  vcu_4_fifo_full, vcu_4_fifo_wen, vcu_4_fifo_wdata,
  vcu_5_fifo_full, vcu_5_fifo_wen, vcu_5_fifo_wdata,
  vcu_6_fifo_full, vcu_6_fifo_wen, vcu_6_fifo_wdata,
  vcu_7_fifo_full, vcu_7_fifo_wen, vcu_7_fifo_wdata,

  insn_number, insn_addr, insn_burstlen, config_start, cmd_start,
  dispatch_empty, insn_done
);

parameter integer INSN_R_ADDR_WIDTH    = 64;
parameter integer INSN_R_BUSRSTS_WIDTH = 8;
parameter integer INSN_R_DATA_WIDTH    = 256;
parameter integer INSN_WIDTH           = 128;
parameter integer INSN_FIFO_DEPTH      = 128;

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction  

localparam integer INSN_R_DATA_BYTES = INSN_R_DATA_WIDTH / 8;
localparam integer INSN_R_DATA_BYTES_SHIFTNUMBER = clogb2(INSN_R_DATA_BYTES - 1);

input clk;
input rst_n;

output reg  [INSN_R_ADDR_WIDTH-1:0]    insn_M_raddr;
output reg  [INSN_R_BUSRSTS_WIDTH-1:0] insn_M_rlen;
output reg                             insn_M_raddr_valid;
input                                  insn_M_raddr_ready;
input       [INSN_R_DATA_WIDTH-1:0]    insn_M_rdata;
output reg                             insn_M_rdata_valid;
input                                  insn_M_rdata_ready;

input                                  synchronize_fifo_full;
output wire                            synchronize_fifo_wen;
output wire [INSN_WIDTH-1:0]           synchronize_fifo_wdata;
input                                  load_0_fifo_full;
output wire                            load_0_fifo_wen;
output wire [INSN_WIDTH-1:0]           load_0_fifo_wdata;
input                                  load_1_fifo_full;
output wire                            load_1_fifo_wen;
output wire [INSN_WIDTH-1:0]           load_1_fifo_wdata;
input                                  load_2_fifo_full;
output wire                            load_2_fifo_wen;
output wire [INSN_WIDTH-1:0]           load_2_fifo_wdata;
input                                  load_3_fifo_full;
output wire                            load_3_fifo_wen;
output wire [INSN_WIDTH-1:0]           load_3_fifo_wdata;
input                                  load_4_fifo_full;
output wire                            load_4_fifo_wen;
output wire [INSN_WIDTH-1:0]           load_4_fifo_wdata;
input                                  load_5_fifo_full;
output wire                            load_5_fifo_wen;
output wire [INSN_WIDTH-1:0]           load_5_fifo_wdata;
input                                  load_6_fifo_full;
output wire                            load_6_fifo_wen;
output wire [INSN_WIDTH-1:0]           load_6_fifo_wdata;
input                                  load_7_fifo_full;
output wire                            load_7_fifo_wen;
output wire [INSN_WIDTH-1:0]           load_7_fifo_wdata;
input                                  pea_0_fifo_full;
input                                  pea_1_fifo_full;
input                                  pea_2_fifo_full;
input                                  pea_3_fifo_full;
input                                  pea_4_fifo_full;
input                                  pea_5_fifo_full;
input                                  pea_6_fifo_full;
input                                  pea_7_fifo_full;
output wire                            pea_0_fifo_wen;
output wire                            pea_1_fifo_wen;
output wire                            pea_2_fifo_wen;
output wire                            pea_3_fifo_wen;
output wire                            pea_4_fifo_wen;
output wire                            pea_5_fifo_wen;
output wire                            pea_6_fifo_wen;
output wire                            pea_7_fifo_wen;
output wire [INSN_WIDTH-1:0]           pea_0_fifo_wdata;
output wire [INSN_WIDTH-1:0]           pea_1_fifo_wdata;
output wire [INSN_WIDTH-1:0]           pea_2_fifo_wdata;
output wire [INSN_WIDTH-1:0]           pea_3_fifo_wdata;
output wire [INSN_WIDTH-1:0]           pea_4_fifo_wdata;
output wire [INSN_WIDTH-1:0]           pea_5_fifo_wdata;
output wire [INSN_WIDTH-1:0]           pea_6_fifo_wdata;
output wire [INSN_WIDTH-1:0]           pea_7_fifo_wdata;
input                                  vcu_0_fifo_full;
input                                  vcu_1_fifo_full;
input                                  vcu_2_fifo_full;
input                                  vcu_3_fifo_full;
input                                  vcu_4_fifo_full;
input                                  vcu_5_fifo_full;
input                                  vcu_6_fifo_full;
input                                  vcu_7_fifo_full;
output wire                            vcu_0_fifo_wen;
output wire                            vcu_1_fifo_wen;
output wire                            vcu_2_fifo_wen;
output wire                            vcu_3_fifo_wen;
output wire                            vcu_4_fifo_wen;
output wire                            vcu_5_fifo_wen;
output wire                            vcu_6_fifo_wen;
output wire                            vcu_7_fifo_wen;
output wire [INSN_WIDTH-1:0]           vcu_0_fifo_wdata;
output wire [INSN_WIDTH-1:0]           vcu_1_fifo_wdata;
output wire [INSN_WIDTH-1:0]           vcu_2_fifo_wdata;
output wire [INSN_WIDTH-1:0]           vcu_3_fifo_wdata;
output wire [INSN_WIDTH-1:0]           vcu_4_fifo_wdata;
output wire [INSN_WIDTH-1:0]           vcu_5_fifo_wdata;
output wire [INSN_WIDTH-1:0]           vcu_6_fifo_wdata;
output wire [INSN_WIDTH-1:0]           vcu_7_fifo_wdata;
input                                  store_0_fifo_full;
output wire                            store_0_fifo_wen;
output wire [INSN_WIDTH-1:0]           store_0_fifo_wdata;
input                                  store_1_fifo_full;
output wire                            store_1_fifo_wen;
output wire [INSN_WIDTH-1:0]           store_1_fifo_wdata;
input                                  store_2_fifo_full;
output wire                            store_2_fifo_wen;
output wire [INSN_WIDTH-1:0]           store_2_fifo_wdata;
input                                  store_3_fifo_full;
output wire                            store_3_fifo_wen;
output wire [INSN_WIDTH-1:0]           store_3_fifo_wdata;
input                                  store_4_fifo_full;
output wire                            store_4_fifo_wen;
output wire [INSN_WIDTH-1:0]           store_4_fifo_wdata;
input                                  store_5_fifo_full;
output wire                            store_5_fifo_wen;
output wire [INSN_WIDTH-1:0]           store_5_fifo_wdata;
input                                  store_6_fifo_full;
output wire                            store_6_fifo_wen;
output wire [INSN_WIDTH-1:0]           store_6_fifo_wdata;
input                                  store_7_fifo_full;
output wire                            store_7_fifo_wen;
output wire [INSN_WIDTH-1:0]           store_7_fifo_wdata;

input [31:0]                           insn_number;
input [63:0]                           insn_addr;
input [7:0]                            insn_burstlen;
input [31:0]                           config_start;
input                                  cmd_start;

output wire                            dispatch_empty;
output wire                            insn_done;

reg                  synchronize_fifo_wen_reg;
reg [INSN_WIDTH-1:0] synchronize_fifo_wdata_reg;

reg                  load_0_fifo_wen_reg;
reg [INSN_WIDTH-1:0] load_0_fifo_wdata_reg;

reg                  load_1_fifo_wen_reg;
reg [INSN_WIDTH-1:0] load_1_fifo_wdata_reg;

reg                  load_2_fifo_wen_reg;
reg [INSN_WIDTH-1:0] load_2_fifo_wdata_reg;

reg                  load_3_fifo_wen_reg;
reg [INSN_WIDTH-1:0] load_3_fifo_wdata_reg;

reg                  load_4_fifo_wen_reg;
reg [INSN_WIDTH-1:0] load_4_fifo_wdata_reg;

reg                  load_5_fifo_wen_reg;
reg [INSN_WIDTH-1:0] load_5_fifo_wdata_reg;

reg                  load_6_fifo_wen_reg;
reg [INSN_WIDTH-1:0] load_6_fifo_wdata_reg;

reg                  load_7_fifo_wen_reg;
reg [INSN_WIDTH-1:0] load_7_fifo_wdata_reg;

reg                  pea_0_fifo_wen_reg;
reg [INSN_WIDTH-1:0] pea_0_fifo_wdata_reg;

reg                  pea_1_fifo_wen_reg;
reg [INSN_WIDTH-1:0] pea_1_fifo_wdata_reg;

reg                  pea_2_fifo_wen_reg;
reg [INSN_WIDTH-1:0] pea_2_fifo_wdata_reg;

reg                  pea_3_fifo_wen_reg;
reg [INSN_WIDTH-1:0] pea_3_fifo_wdata_reg;

reg                  pea_4_fifo_wen_reg;
reg [INSN_WIDTH-1:0] pea_4_fifo_wdata_reg;

reg                  pea_5_fifo_wen_reg;
reg [INSN_WIDTH-1:0] pea_5_fifo_wdata_reg;

reg                  pea_6_fifo_wen_reg;
reg [INSN_WIDTH-1:0] pea_6_fifo_wdata_reg;

reg                  pea_7_fifo_wen_reg;
reg [INSN_WIDTH-1:0] pea_7_fifo_wdata_reg;

reg                  vcu_0_fifo_wen_reg;
reg [INSN_WIDTH-1:0] vcu_0_fifo_wdata_reg;

reg                  vcu_1_fifo_wen_reg;
reg [INSN_WIDTH-1:0] vcu_1_fifo_wdata_reg;

reg                  vcu_2_fifo_wen_reg;
reg [INSN_WIDTH-1:0] vcu_2_fifo_wdata_reg;

reg                  vcu_3_fifo_wen_reg;
reg [INSN_WIDTH-1:0] vcu_3_fifo_wdata_reg;

reg                  vcu_4_fifo_wen_reg;
reg [INSN_WIDTH-1:0] vcu_4_fifo_wdata_reg;

reg                  vcu_5_fifo_wen_reg;
reg [INSN_WIDTH-1:0] vcu_5_fifo_wdata_reg;

reg                  vcu_6_fifo_wen_reg;
reg [INSN_WIDTH-1:0] vcu_6_fifo_wdata_reg;

reg                  vcu_7_fifo_wen_reg;
reg [INSN_WIDTH-1:0] vcu_7_fifo_wdata_reg;

reg                  store_0_fifo_wen_reg;
reg [INSN_WIDTH-1:0] store_0_fifo_wdata_reg;

reg                  store_1_fifo_wen_reg;
reg [INSN_WIDTH-1:0] store_1_fifo_wdata_reg;

reg                  store_2_fifo_wen_reg;
reg [INSN_WIDTH-1:0] store_2_fifo_wdata_reg;

reg                  store_3_fifo_wen_reg;
reg [INSN_WIDTH-1:0] store_3_fifo_wdata_reg;

reg                  store_4_fifo_wen_reg;
reg [INSN_WIDTH-1:0] store_4_fifo_wdata_reg;

reg                  store_5_fifo_wen_reg;
reg [INSN_WIDTH-1:0] store_5_fifo_wdata_reg;

reg                  store_6_fifo_wen_reg;
reg [INSN_WIDTH-1:0] store_6_fifo_wdata_reg;

reg                  store_7_fifo_wen_reg;
reg [INSN_WIDTH-1:0] store_7_fifo_wdata_reg;

assign store_0_fifo_wen   = store_0_fifo_wen_reg;
assign store_0_fifo_wdata = store_0_fifo_wdata_reg;

assign store_1_fifo_wen   = store_1_fifo_wen_reg;
assign store_1_fifo_wdata = store_1_fifo_wdata_reg;

assign store_2_fifo_wen   = store_2_fifo_wen_reg;
assign store_2_fifo_wdata = store_2_fifo_wdata_reg;

assign store_3_fifo_wen   = store_3_fifo_wen_reg;
assign store_3_fifo_wdata = store_3_fifo_wdata_reg;

assign store_4_fifo_wen   = store_4_fifo_wen_reg;
assign store_4_fifo_wdata = store_4_fifo_wdata_reg;

assign store_5_fifo_wen   = store_5_fifo_wen_reg;
assign store_5_fifo_wdata = store_5_fifo_wdata_reg;

assign store_6_fifo_wen   = store_6_fifo_wen_reg;
assign store_6_fifo_wdata = store_6_fifo_wdata_reg;

assign store_7_fifo_wen   = store_7_fifo_wen_reg;
assign store_7_fifo_wdata = store_7_fifo_wdata_reg;

assign synchronize_fifo_wen   = synchronize_fifo_wen_reg;
assign synchronize_fifo_wdata = synchronize_fifo_wdata_reg;

assign load_0_fifo_wen   = load_0_fifo_wen_reg;
assign load_0_fifo_wdata = load_0_fifo_wdata_reg;

assign load_1_fifo_wen   = load_1_fifo_wen_reg;
assign load_1_fifo_wdata = load_1_fifo_wdata_reg;

assign load_2_fifo_wen   = load_2_fifo_wen_reg;
assign load_2_fifo_wdata = load_2_fifo_wdata_reg;

assign load_3_fifo_wen   = load_3_fifo_wen_reg;
assign load_3_fifo_wdata = load_3_fifo_wdata_reg;

assign load_4_fifo_wen   = load_4_fifo_wen_reg;
assign load_4_fifo_wdata = load_4_fifo_wdata_reg;

assign load_5_fifo_wen   = load_5_fifo_wen_reg;
assign load_5_fifo_wdata = load_5_fifo_wdata_reg;

assign load_6_fifo_wen   = load_6_fifo_wen_reg;
assign load_6_fifo_wdata = load_6_fifo_wdata_reg;

assign load_7_fifo_wen   = load_7_fifo_wen_reg;
assign load_7_fifo_wdata = load_7_fifo_wdata_reg;

assign pea_0_fifo_wen = pea_0_fifo_wen_reg;
assign pea_1_fifo_wen = pea_1_fifo_wen_reg;
assign pea_2_fifo_wen = pea_2_fifo_wen_reg;
assign pea_3_fifo_wen = pea_3_fifo_wen_reg;
assign pea_4_fifo_wen = pea_4_fifo_wen_reg;
assign pea_5_fifo_wen = pea_5_fifo_wen_reg;
assign pea_6_fifo_wen = pea_6_fifo_wen_reg;
assign pea_7_fifo_wen = pea_7_fifo_wen_reg;

assign vcu_0_fifo_wen = vcu_0_fifo_wen_reg;
assign vcu_1_fifo_wen = vcu_1_fifo_wen_reg;
assign vcu_2_fifo_wen = vcu_2_fifo_wen_reg;
assign vcu_3_fifo_wen = vcu_3_fifo_wen_reg;
assign vcu_4_fifo_wen = vcu_4_fifo_wen_reg;
assign vcu_5_fifo_wen = vcu_5_fifo_wen_reg;
assign vcu_6_fifo_wen = vcu_6_fifo_wen_reg;
assign vcu_7_fifo_wen = vcu_7_fifo_wen_reg;

assign pea_0_fifo_wdata = pea_0_fifo_wdata_reg;
assign pea_1_fifo_wdata = pea_1_fifo_wdata_reg;
assign pea_2_fifo_wdata = pea_2_fifo_wdata_reg;
assign pea_3_fifo_wdata = pea_3_fifo_wdata_reg;
assign pea_4_fifo_wdata = pea_4_fifo_wdata_reg;
assign pea_5_fifo_wdata = pea_5_fifo_wdata_reg;
assign pea_6_fifo_wdata = pea_6_fifo_wdata_reg;
assign pea_7_fifo_wdata = pea_7_fifo_wdata_reg;

assign vcu_0_fifo_wdata = vcu_0_fifo_wdata_reg;
assign vcu_1_fifo_wdata = vcu_1_fifo_wdata_reg;
assign vcu_2_fifo_wdata = vcu_2_fifo_wdata_reg;
assign vcu_3_fifo_wdata = vcu_3_fifo_wdata_reg;
assign vcu_4_fifo_wdata = vcu_4_fifo_wdata_reg;
assign vcu_5_fifo_wdata = vcu_5_fifo_wdata_reg;
assign vcu_6_fifo_wdata = vcu_6_fifo_wdata_reg;
assign vcu_7_fifo_wdata = vcu_7_fifo_wdata_reg;

localparam integer INSN_FIFO_ADDRBIT = clogb2(INSN_FIFO_DEPTH-1);

reg                          local_fifo_wen;
reg                          local_fifo_ren;
reg  [INSN_R_DATA_WIDTH-1:0] local_fifo_wdata;
wire [INSN_R_DATA_WIDTH-1:0] local_fifo_rdata;
wire                         local_fifo_empty;
wire                         local_fifo_full;

reg [31:0] insn_number_addr_handshake_reg;
reg [31:0] insn_number_data_handshake_reg;
reg [63:0] insn_raddr_reg;
reg [31:0] insn_burstlen_reg;

wire                       insn_zero;
wire                       read_burst_up;
wire [7:0]                 insn_len;
wire                       len_choose;
wire                       fifo_enough;
reg  [INSN_FIFO_ADDRBIT:0] local_fifo_precnt;
reg                        local_fifo_rvalid;
wire                       orient_fifo_wen;
reg                        insn_buffer_valid;

localparam integer INSN_BUFFER_NUM = (INSN_R_DATA_WIDTH/INSN_WIDTH);
localparam integer INSN_BUFFER_ADDRBIT = clogb2(INSN_BUFFER_NUM-1);

reg  [INSN_BUFFER_ADDRBIT-1:0] insn_buffer_index;
wire [INSN_WIDTH-1:0]          insn_buffer_wire [0:INSN_BUFFER_NUM-1];
reg  [INSN_R_DATA_WIDTH-1:0]   insn_buffer_reg;

reg                            insn_nonew;

assign len_choose = (insn_burstlen_reg < insn_number_addr_handshake_reg)? 1'b1: 1'b0;
assign insn_len = (len_choose)? (insn_burstlen_reg - 1): (insn_number_addr_handshake_reg[7:0] - 1);
assign insn_zero = (!(|insn_number_addr_handshake_reg));
assign fifo_enough = (local_fifo_precnt > insn_len)? 1'b1: 1'b0;
assign read_burst_up = (!insn_zero) & fifo_enough;
assign insn_done = (!(|insn_number_data_handshake_reg));
assign dispatch_empty = insn_nonew;

assign orient_fifo_wen = insn_buffer_valid & ((insn_buffer_wire[insn_buffer_index][5:0] == 6'b000000)? ((!synchronize_fifo_full) ? 1'b1 : 1'b0) : 
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b000001)? ((!load_0_fifo_full) ? 1'b1 : 1'b0) : 
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b000010)? ((!load_1_fifo_full) ? 1'b1 : 1'b0) : 
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b000011)? ((!load_2_fifo_full) ? 1'b1 : 1'b0) : 
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b000100)? ((!load_3_fifo_full) ? 1'b1 : 1'b0) : 
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b000101)? ((!load_4_fifo_full) ? 1'b1 : 1'b0) : 
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b000110)? ((!load_5_fifo_full) ? 1'b1 : 1'b0) : 
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b000111)? ((!load_6_fifo_full) ? 1'b1 : 1'b0) : 
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b001000)? ((!load_7_fifo_full) ? 1'b1 : 1'b0) : 
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b001001)? ((!store_0_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b001010)? ((!store_1_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b001011)? ((!store_2_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b001100)? ((!store_3_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b001101)? ((!store_4_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b001110)? ((!store_5_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b001111)? ((!store_6_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b010000)? ((!store_7_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b010001)? ((!pea_0_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b010010)? ((!pea_1_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b010011)? ((!pea_2_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b010100)? ((!pea_3_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b010101)? ((!pea_4_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b010110)? ((!pea_5_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b010111)? ((!pea_6_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b011000)? ((!pea_7_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b011001)? ((!vcu_0_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b011010)? ((!vcu_1_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b011011)? ((!vcu_2_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b011100)? ((!vcu_3_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b011101)? ((!vcu_4_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b011110)? ((!vcu_5_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b011111)? ((!vcu_6_fifo_full) ? 1'b1 : 1'b0) :
                                              (insn_buffer_wire[insn_buffer_index][5:0] == 6'b100000)? ((!vcu_7_fifo_full) ? 1'b1 : 1'b0) : 1'b0);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    insn_M_raddr_valid <= 1'b0;
    insn_M_raddr       <= 'd0;
    insn_M_rlen        <= 'd31;
  end
  else begin
    if (cmd_start && read_burst_up && !insn_M_raddr_valid) begin
      insn_M_raddr_valid <= 1'b1;
      insn_M_raddr       <= insn_raddr_reg;
      insn_M_rlen        <= insn_len;
    end
    else if (insn_M_raddr_valid && insn_M_raddr_ready) begin
      insn_M_raddr_valid <= 1'b0;
      insn_M_raddr       <= insn_raddr_reg;
      insn_M_rlen        <= insn_M_rlen;
    end
    else begin
      insn_M_raddr_valid <= insn_M_raddr_valid;
      insn_M_raddr       <= insn_M_raddr;
      insn_M_rlen        <= insn_M_rlen;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    insn_number_addr_handshake_reg <= 32'd0;
    insn_number_data_handshake_reg <= 32'd0;
    insn_raddr_reg                 <= 64'd0;
    insn_burstlen_reg              <= 32'd0;
  end
  else begin
    if (config_start == 'd2 && !cmd_start) begin
      insn_number_addr_handshake_reg <= insn_number;
      insn_number_data_handshake_reg <= insn_number;
      insn_raddr_reg                 <= insn_addr;
      insn_burstlen_reg              <= insn_burstlen;
    end
    else begin
      insn_burstlen_reg <= insn_burstlen;
      if (insn_M_raddr_valid && insn_M_raddr_ready) begin
        insn_number_addr_handshake_reg <= insn_number_addr_handshake_reg - 1 - insn_M_rlen;
      end
      else begin
        insn_number_addr_handshake_reg <= insn_number_addr_handshake_reg;
      end

      if (insn_M_rdata_valid && insn_M_rdata_ready) begin
        insn_number_data_handshake_reg <= insn_number_data_handshake_reg - 1;
      end
      else begin
        insn_number_data_handshake_reg <= insn_number_data_handshake_reg;
      end

      
      if (insn_M_raddr_valid && insn_M_raddr_ready) begin
        insn_raddr_reg <= insn_raddr_reg + ((insn_M_rlen + 1) << INSN_R_DATA_BYTES_SHIFTNUMBER);
      end
      else begin
        insn_raddr_reg <= insn_raddr_reg;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    local_fifo_precnt <= INSN_FIFO_DEPTH;
  end
  else begin
    if (insn_M_raddr_valid && insn_M_raddr_ready && local_fifo_ren) begin
      local_fifo_precnt <= local_fifo_precnt - insn_M_rlen;
    end
    else if (insn_M_raddr_valid && insn_M_raddr_ready) begin
      local_fifo_precnt <= local_fifo_precnt - insn_M_rlen - 1;
    end
    else begin
      if (local_fifo_ren) begin
        local_fifo_precnt <= local_fifo_precnt + 1;
      end
      else begin
        local_fifo_precnt <= local_fifo_precnt;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    local_fifo_wen <= 1'b0;
    local_fifo_wdata <= 512'b0;
  end
  else begin
    if (insn_M_rdata_valid && insn_M_rdata_ready) begin
      local_fifo_wen <= 1'b1;
      local_fifo_wdata <= insn_M_rdata;
    end
    else begin
      local_fifo_wen <= 1'b0;
      local_fifo_wdata <= 512'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    local_fifo_ren <= 1'b0;
    local_fifo_rvalid <= 1'b0;
  end
  else begin
    if ((!local_fifo_empty) && (((!local_fifo_rvalid) && (!insn_buffer_valid) && (!local_fifo_ren)) || (insn_buffer_valid && orient_fifo_wen && (& insn_buffer_index)))) begin
	    local_fifo_ren <= 1'b1;
    end
    else begin
      local_fifo_ren <= 1'b0;
    end
    local_fifo_rvalid <= local_fifo_ren;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    insn_M_rdata_valid <= 1'b0;
  end
  else begin
    if (insn_done) begin
      insn_M_rdata_valid <= 1'b0;
    end
    else begin
      if (!local_fifo_full) begin
        insn_M_rdata_valid <= 1'b1;
      end
      else begin
        insn_M_rdata_valid <= 1'b0;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    insn_buffer_valid <= 1'b0;
    insn_buffer_reg <= 'd0;
  end
  else begin
    if (local_fifo_rvalid) begin
      insn_buffer_valid <= 1'b1;
      insn_buffer_reg <= local_fifo_rdata;
    end
    else begin
      if (orient_fifo_wen && (& insn_buffer_index)) begin
        insn_buffer_valid <= 1'b0;
      end
      else begin
        insn_buffer_valid <= insn_buffer_valid;
      end
      insn_buffer_reg <= insn_buffer_reg;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    synchronize_fifo_wdata_reg <= 512'b0;
    synchronize_fifo_wen_reg   <= 1'b0;
    load_0_fifo_wdata_reg      <= 512'b0;
    load_0_fifo_wen_reg        <= 1'b0;
    store_0_fifo_wdata_reg     <= 512'b0;
    store_0_fifo_wen_reg       <= 1'b0;
    load_1_fifo_wdata_reg      <= 512'b0;
    load_1_fifo_wen_reg        <= 1'b0;
    store_1_fifo_wdata_reg     <= 512'b0;
    store_1_fifo_wen_reg       <= 1'b0;
    pea_0_fifo_wdata_reg       <= 512'b0;
    pea_0_fifo_wen_reg         <= 1'b0;
    pea_1_fifo_wdata_reg       <= 512'b0;
    pea_1_fifo_wen_reg         <= 1'b0;
    vcu_0_fifo_wdata_reg       <= 512'b0;
    vcu_0_fifo_wen_reg         <= 1'b0;
    vcu_1_fifo_wdata_reg       <= 512'b0;
    vcu_1_fifo_wen_reg         <= 1'b0;
    insn_nonew                 <= 1'b0;
    insn_buffer_index          <= 0;
  end
  else begin
    if (insn_buffer_valid) begin
      case(insn_buffer_wire[insn_buffer_index][5:0])
        6'b000000: begin
          if (!synchronize_fifo_full) begin
            synchronize_fifo_wen_reg   <= 1'b1;
            synchronize_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            synchronize_fifo_wen_reg   <= 1'b0;
            synchronize_fifo_wdata_reg <= 0;
          end
          load_0_fifo_wen_reg    <= 0;
          load_0_fifo_wdata_reg  <= 0;
          load_1_fifo_wen_reg    <= 0;
          load_1_fifo_wdata_reg  <= 0;
          load_2_fifo_wen_reg    <= 0;
          load_2_fifo_wdata_reg  <= 0;
          load_3_fifo_wen_reg    <= 0;
          load_3_fifo_wdata_reg  <= 0;
          load_4_fifo_wen_reg    <= 0;
          load_4_fifo_wdata_reg  <= 0;
          load_5_fifo_wen_reg    <= 0;
          load_5_fifo_wdata_reg  <= 0;
          load_6_fifo_wen_reg    <= 0;
          load_6_fifo_wdata_reg  <= 0;
          load_7_fifo_wen_reg    <= 0;
          load_7_fifo_wdata_reg  <= 0;
          store_0_fifo_wen_reg   <= 0;
          store_0_fifo_wdata_reg <= 0;
          store_1_fifo_wen_reg   <= 0;
          store_1_fifo_wdata_reg <= 0;
          store_2_fifo_wen_reg   <= 0;
          store_2_fifo_wdata_reg <= 0;
          store_3_fifo_wen_reg   <= 0;
          store_3_fifo_wdata_reg <= 0;
          store_4_fifo_wen_reg   <= 0;
          store_4_fifo_wdata_reg <= 0;
          store_5_fifo_wen_reg   <= 0;
          store_5_fifo_wdata_reg <= 0;
          store_6_fifo_wen_reg   <= 0;
          store_6_fifo_wdata_reg <= 0;
          store_7_fifo_wen_reg   <= 0;
          store_7_fifo_wdata_reg <= 0;
          pea_0_fifo_wen_reg     <= 0;
          pea_0_fifo_wdata_reg   <= 0;
          pea_1_fifo_wen_reg     <= 0;
          pea_1_fifo_wdata_reg   <= 0;
          pea_2_fifo_wen_reg     <= 0;
          pea_2_fifo_wdata_reg   <= 0;
          pea_3_fifo_wen_reg     <= 0;
          pea_3_fifo_wdata_reg   <= 0;
          pea_4_fifo_wen_reg     <= 0;
          pea_4_fifo_wdata_reg   <= 0;
          pea_5_fifo_wen_reg     <= 0;
          pea_5_fifo_wdata_reg   <= 0;
          pea_6_fifo_wen_reg     <= 0;
          pea_6_fifo_wdata_reg   <= 0;
          pea_7_fifo_wen_reg     <= 0;
          pea_7_fifo_wdata_reg   <= 0;
          vcu_0_fifo_wen_reg     <= 0;
          vcu_0_fifo_wdata_reg   <= 0;
          vcu_1_fifo_wen_reg     <= 0;
          vcu_1_fifo_wdata_reg   <= 0;
          vcu_2_fifo_wen_reg     <= 0;
          vcu_2_fifo_wdata_reg   <= 0;
          vcu_3_fifo_wen_reg     <= 0;
          vcu_3_fifo_wdata_reg   <= 0;
          vcu_4_fifo_wen_reg     <= 0;
          vcu_4_fifo_wdata_reg   <= 0;
          vcu_5_fifo_wen_reg     <= 0;
          vcu_5_fifo_wdata_reg   <= 0;
          vcu_6_fifo_wen_reg     <= 0;
          vcu_6_fifo_wdata_reg   <= 0;
          vcu_7_fifo_wen_reg     <= 0;
          vcu_7_fifo_wdata_reg   <= 0;
        end
        6'b000001: begin
          if (!load_0_fifo_full) begin
            load_0_fifo_wen_reg   <= 1'b1;
            load_0_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            load_0_fifo_wen_reg   <= 1'b0;
            load_0_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b000010: begin
          if (!load_1_fifo_full) begin
            load_1_fifo_wen_reg   <= 1'b1;
            load_1_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            load_1_fifo_wen_reg   <= 1'b0;
            load_1_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b000011: begin
          if (!load_2_fifo_full) begin
            load_2_fifo_wen_reg   <= 1'b1;
            load_2_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            load_2_fifo_wen_reg   <= 1'b0;
            load_2_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b000100: begin
          if (!load_3_fifo_full) begin
            load_3_fifo_wen_reg   <= 1'b1;
            load_3_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            load_3_fifo_wen_reg   <= 1'b0;
            load_3_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b000101: begin
          if (!load_4_fifo_full) begin
            load_4_fifo_wen_reg   <= 1'b1;
            load_4_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            load_4_fifo_wen_reg   <= 1'b0;
            load_4_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b000110: begin
          if (!load_5_fifo_full) begin
            load_5_fifo_wen_reg   <= 1'b1;
            load_5_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            load_5_fifo_wen_reg   <= 1'b0;
            load_5_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 1'b0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg   <= 0;
          load_0_fifo_wdata_reg <= 0;
          load_1_fifo_wen_reg   <= 0;
          load_1_fifo_wdata_reg <= 0;
          load_2_fifo_wen_reg   <= 0;
          load_2_fifo_wdata_reg <= 0;
          load_3_fifo_wen_reg   <= 0;
          load_3_fifo_wdata_reg <= 0;
          load_4_fifo_wen_reg   <= 0;
          load_4_fifo_wdata_reg <= 0;
          load_6_fifo_wen_reg   <= 0;
          load_6_fifo_wdata_reg <= 0;
          load_7_fifo_wen_reg   <= 0;
          load_7_fifo_wdata_reg <= 0;
          store_0_fifo_wen_reg   <= 1'b0;
          store_0_fifo_wdata_reg <= 0;
          store_1_fifo_wen_reg   <= 1'b0;
          store_1_fifo_wdata_reg <= 0;
          store_2_fifo_wen_reg   <= 1'b0;
          store_2_fifo_wdata_reg <= 0;
          store_3_fifo_wen_reg   <= 1'b0;
          store_3_fifo_wdata_reg <= 0;
          store_4_fifo_wen_reg   <= 1'b0;
          store_4_fifo_wdata_reg <= 0;
          store_5_fifo_wen_reg   <= 1'b0;
          store_5_fifo_wdata_reg <= 0;
          store_6_fifo_wen_reg   <= 1'b0;
          store_6_fifo_wdata_reg <= 0;
          store_7_fifo_wen_reg   <= 1'b0;
          store_7_fifo_wdata_reg <= 0;
          pea_0_fifo_wen_reg    <= 1'b0;
          pea_0_fifo_wdata_reg  <= 0;
          pea_1_fifo_wen_reg    <= 1'b0;
          pea_1_fifo_wdata_reg  <= 0;
          pea_2_fifo_wen_reg    <= 1'b0;
          pea_2_fifo_wdata_reg  <= 0;
          pea_3_fifo_wen_reg    <= 1'b0;
          pea_3_fifo_wdata_reg  <= 0;
          pea_4_fifo_wen_reg    <= 1'b0;
          pea_4_fifo_wdata_reg  <= 0;
          pea_5_fifo_wen_reg    <= 1'b0;
          pea_5_fifo_wdata_reg  <= 0;
          pea_6_fifo_wen_reg    <= 1'b0;
          pea_6_fifo_wdata_reg  <= 0;
          pea_7_fifo_wen_reg    <= 1'b0;
          pea_7_fifo_wdata_reg  <= 0;
          vcu_0_fifo_wen_reg    <= 1'b0;
          vcu_0_fifo_wdata_reg  <= 0;
          vcu_1_fifo_wen_reg    <= 1'b0;
          vcu_1_fifo_wdata_reg  <= 0;
          vcu_2_fifo_wen_reg    <= 1'b0;
          vcu_2_fifo_wdata_reg  <= 0;
          vcu_3_fifo_wen_reg    <= 1'b0;
          vcu_3_fifo_wdata_reg  <= 0;
          vcu_4_fifo_wen_reg    <= 1'b0;
          vcu_4_fifo_wdata_reg  <= 0;
          vcu_5_fifo_wen_reg    <= 1'b0;
          vcu_5_fifo_wdata_reg  <= 0;
          vcu_6_fifo_wen_reg    <= 1'b0;
          vcu_6_fifo_wdata_reg  <= 0;
          vcu_7_fifo_wen_reg    <= 1'b0;
          vcu_7_fifo_wdata_reg  <= 0;
        end
        6'b000111: begin
          if (!load_6_fifo_full) begin
            load_6_fifo_wen_reg   <= 1'b1;
            load_6_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            load_6_fifo_wen_reg   <= 1'b0;
            load_6_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 1'b0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg   <= 0;
          load_0_fifo_wdata_reg <= 0;
          load_1_fifo_wen_reg   <= 0;
          load_1_fifo_wdata_reg <= 0;
          load_2_fifo_wen_reg   <= 0;
          load_2_fifo_wdata_reg <= 0;
          load_3_fifo_wen_reg   <= 0;
          load_3_fifo_wdata_reg <= 0;
          load_4_fifo_wen_reg   <= 0;
          load_4_fifo_wdata_reg <= 0;
          load_5_fifo_wen_reg   <= 0;
          load_5_fifo_wdata_reg <= 0;
          load_7_fifo_wen_reg   <= 0;
          load_7_fifo_wdata_reg <= 0;
          store_0_fifo_wen_reg   <= 1'b0;
          store_0_fifo_wdata_reg <= 0;
          store_1_fifo_wen_reg   <= 1'b0;
          store_1_fifo_wdata_reg <= 0;
          store_2_fifo_wen_reg   <= 1'b0;
          store_2_fifo_wdata_reg <= 0;
          store_3_fifo_wen_reg   <= 1'b0;
          store_3_fifo_wdata_reg <= 0;
          store_4_fifo_wen_reg   <= 1'b0;
          store_4_fifo_wdata_reg <= 0;
          store_5_fifo_wen_reg   <= 1'b0;
          store_5_fifo_wdata_reg <= 0;
          store_6_fifo_wen_reg   <= 1'b0;
          store_6_fifo_wdata_reg <= 0;
          store_7_fifo_wen_reg   <= 1'b0;
          store_7_fifo_wdata_reg <= 0;
          pea_0_fifo_wen_reg    <= 1'b0;
          pea_0_fifo_wdata_reg  <= 0;
          pea_1_fifo_wen_reg    <= 1'b0;
          pea_1_fifo_wdata_reg  <= 0;
          pea_2_fifo_wen_reg    <= 1'b0;
          pea_2_fifo_wdata_reg  <= 0;
          pea_3_fifo_wen_reg    <= 1'b0;
          pea_3_fifo_wdata_reg  <= 0;
          pea_4_fifo_wen_reg    <= 1'b0;
          pea_4_fifo_wdata_reg  <= 0;
          pea_5_fifo_wen_reg    <= 1'b0;
          pea_5_fifo_wdata_reg  <= 0;
          pea_6_fifo_wen_reg    <= 1'b0;
          pea_6_fifo_wdata_reg  <= 0;
          pea_7_fifo_wen_reg    <= 1'b0;
          pea_7_fifo_wdata_reg  <= 0;
          vcu_0_fifo_wen_reg    <= 1'b0;
          vcu_0_fifo_wdata_reg  <= 0;
          vcu_1_fifo_wen_reg    <= 1'b0;
          vcu_1_fifo_wdata_reg  <= 0;
          vcu_2_fifo_wen_reg    <= 1'b0;
          vcu_2_fifo_wdata_reg  <= 0;
          vcu_3_fifo_wen_reg    <= 1'b0;
          vcu_3_fifo_wdata_reg  <= 0;
          vcu_4_fifo_wen_reg    <= 1'b0;
          vcu_4_fifo_wdata_reg  <= 0;
          vcu_5_fifo_wen_reg    <= 1'b0;
          vcu_5_fifo_wdata_reg  <= 0;
          vcu_6_fifo_wen_reg    <= 1'b0;
          vcu_6_fifo_wdata_reg  <= 0;
          vcu_7_fifo_wen_reg    <= 1'b0;
          vcu_7_fifo_wdata_reg  <= 0;
        end
        6'b001000: begin
          if (!load_7_fifo_full) begin
            load_7_fifo_wen_reg   <= 1'b1;
            load_7_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            load_7_fifo_wen_reg   <= 1'b0;
            load_7_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 1'b0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg   <= 0;
          load_0_fifo_wdata_reg <= 0;
          load_1_fifo_wen_reg   <= 0;
          load_1_fifo_wdata_reg <= 0;
          load_2_fifo_wen_reg   <= 0;
          load_2_fifo_wdata_reg <= 0;
          load_3_fifo_wen_reg   <= 0;
          load_3_fifo_wdata_reg <= 0;
          load_4_fifo_wen_reg   <= 0;
          load_4_fifo_wdata_reg <= 0;
          load_5_fifo_wen_reg   <= 0;
          load_5_fifo_wdata_reg <= 0;
          load_6_fifo_wen_reg   <= 0;
          load_6_fifo_wdata_reg <= 0;
          store_0_fifo_wen_reg   <= 1'b0;
          store_0_fifo_wdata_reg <= 0;
          store_1_fifo_wen_reg   <= 1'b0;
          store_1_fifo_wdata_reg <= 0;
          store_2_fifo_wen_reg   <= 1'b0;
          store_2_fifo_wdata_reg <= 0;
          store_3_fifo_wen_reg   <= 1'b0;
          store_3_fifo_wdata_reg <= 0;
          store_4_fifo_wen_reg   <= 1'b0;
          store_4_fifo_wdata_reg <= 0;
          store_5_fifo_wen_reg   <= 1'b0;
          store_5_fifo_wdata_reg <= 0;
          store_6_fifo_wen_reg   <= 1'b0;
          store_6_fifo_wdata_reg <= 0;
          store_7_fifo_wen_reg   <= 1'b0;
          store_7_fifo_wdata_reg <= 0;
          pea_0_fifo_wen_reg    <= 1'b0;
          pea_0_fifo_wdata_reg  <= 0;
          pea_1_fifo_wen_reg    <= 1'b0;
          pea_1_fifo_wdata_reg  <= 0;
          pea_2_fifo_wen_reg    <= 1'b0;
          pea_2_fifo_wdata_reg  <= 0;
          pea_3_fifo_wen_reg    <= 1'b0;
          pea_3_fifo_wdata_reg  <= 0;
          pea_4_fifo_wen_reg    <= 1'b0;
          pea_4_fifo_wdata_reg  <= 0;
          pea_5_fifo_wen_reg    <= 1'b0;
          pea_5_fifo_wdata_reg  <= 0;
          pea_6_fifo_wen_reg    <= 1'b0;
          pea_6_fifo_wdata_reg  <= 0;
          pea_7_fifo_wen_reg    <= 1'b0;
          pea_7_fifo_wdata_reg  <= 0;
          vcu_0_fifo_wen_reg    <= 1'b0;
          vcu_0_fifo_wdata_reg  <= 0;
          vcu_1_fifo_wen_reg    <= 1'b0;
          vcu_1_fifo_wdata_reg  <= 0;
          vcu_2_fifo_wen_reg    <= 1'b0;
          vcu_2_fifo_wdata_reg  <= 0;
          vcu_3_fifo_wen_reg    <= 1'b0;
          vcu_3_fifo_wdata_reg  <= 0;
          vcu_4_fifo_wen_reg    <= 1'b0;
          vcu_4_fifo_wdata_reg  <= 0;
          vcu_5_fifo_wen_reg    <= 1'b0;
          vcu_5_fifo_wdata_reg  <= 0;
          vcu_6_fifo_wen_reg    <= 1'b0;
          vcu_6_fifo_wdata_reg  <= 0;
          vcu_7_fifo_wen_reg    <= 1'b0;
          vcu_7_fifo_wdata_reg  <= 0;
        end
        6'b001001: begin
          if (!store_0_fifo_full) begin
            store_0_fifo_wen_reg   <= 1'b1;
            store_0_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            store_0_fifo_wen_reg   <= 1'b0;
            store_0_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 1'b0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg   <= 1'b0;
          load_0_fifo_wdata_reg <= 0;
          load_1_fifo_wen_reg   <= 1'b0;
          load_1_fifo_wdata_reg <= 0;
          load_2_fifo_wen_reg   <= 1'b0;
          load_2_fifo_wdata_reg <= 0;
          load_3_fifo_wen_reg   <= 1'b0;
          load_3_fifo_wdata_reg <= 0;
          load_4_fifo_wen_reg   <= 1'b0;
          load_4_fifo_wdata_reg <= 0;
          load_5_fifo_wen_reg   <= 1'b0;
          load_5_fifo_wdata_reg <= 0;
          load_6_fifo_wen_reg   <= 1'b0;
          load_6_fifo_wdata_reg <= 0;
          load_7_fifo_wen_reg   <= 1'b0;
          load_7_fifo_wdata_reg <= 0;
          store_1_fifo_wen_reg   <= 0;
          store_1_fifo_wdata_reg <= 0;
          store_2_fifo_wen_reg   <= 0;
          store_2_fifo_wdata_reg <= 0;
          store_3_fifo_wen_reg   <= 0;
          store_3_fifo_wdata_reg <= 0;
          store_4_fifo_wen_reg   <= 0;
          store_4_fifo_wdata_reg <= 0;
          store_5_fifo_wen_reg   <= 0;
          store_5_fifo_wdata_reg <= 0;
          store_6_fifo_wen_reg   <= 0;
          store_6_fifo_wdata_reg <= 0;
          store_7_fifo_wen_reg   <= 0;
          store_7_fifo_wdata_reg <= 0;
          pea_0_fifo_wen_reg    <= 1'b0;
          pea_0_fifo_wdata_reg  <= 0;
          pea_1_fifo_wen_reg    <= 1'b0;
          pea_1_fifo_wdata_reg  <= 0;
          pea_2_fifo_wen_reg    <= 1'b0;
          pea_2_fifo_wdata_reg  <= 0;
          pea_3_fifo_wen_reg    <= 1'b0;
          pea_3_fifo_wdata_reg  <= 0;
          pea_4_fifo_wen_reg    <= 1'b0;
          pea_4_fifo_wdata_reg  <= 0;
          pea_5_fifo_wen_reg    <= 1'b0;
          pea_5_fifo_wdata_reg  <= 0;
          pea_6_fifo_wen_reg    <= 1'b0;
          pea_6_fifo_wdata_reg  <= 0;
          pea_7_fifo_wen_reg    <= 1'b0;
          pea_7_fifo_wdata_reg  <= 0;
          vcu_0_fifo_wen_reg    <= 1'b0;
          vcu_0_fifo_wdata_reg  <= 0;
          vcu_1_fifo_wen_reg    <= 1'b0;
          vcu_1_fifo_wdata_reg  <= 0;
          vcu_2_fifo_wen_reg    <= 1'b0;
          vcu_2_fifo_wdata_reg  <= 0;
          vcu_3_fifo_wen_reg    <= 1'b0;
          vcu_3_fifo_wdata_reg  <= 0;
          vcu_4_fifo_wen_reg    <= 1'b0;
          vcu_4_fifo_wdata_reg  <= 0;
          vcu_5_fifo_wen_reg    <= 1'b0;
          vcu_5_fifo_wdata_reg  <= 0;
          vcu_6_fifo_wen_reg    <= 1'b0;
          vcu_6_fifo_wdata_reg  <= 0;
          vcu_7_fifo_wen_reg    <= 1'b0;
          vcu_7_fifo_wdata_reg  <= 0;
        end
        6'b001010: begin
          if (!store_1_fifo_full) begin
            store_1_fifo_wen_reg   <= 1'b1;
            store_1_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            store_1_fifo_wen_reg   <= 1'b0;
            store_1_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 1'b0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg   <= 1'b0;
          load_0_fifo_wdata_reg <= 0;
          load_1_fifo_wen_reg   <= 1'b0;
          load_1_fifo_wdata_reg <= 0;
          load_2_fifo_wen_reg   <= 1'b0;
          load_2_fifo_wdata_reg <= 0;
          load_3_fifo_wen_reg   <= 1'b0;
          load_3_fifo_wdata_reg <= 0;
          load_4_fifo_wen_reg   <= 1'b0;
          load_4_fifo_wdata_reg <= 0;
          load_5_fifo_wen_reg   <= 1'b0;
          load_5_fifo_wdata_reg <= 0;
          load_6_fifo_wen_reg   <= 1'b0;
          load_6_fifo_wdata_reg <= 0;
          load_7_fifo_wen_reg   <= 1'b0;
          load_7_fifo_wdata_reg <= 0;
          store_0_fifo_wen_reg   <= 0;
          store_0_fifo_wdata_reg <= 0;
          store_2_fifo_wen_reg   <= 0;
          store_2_fifo_wdata_reg <= 0;
          store_3_fifo_wen_reg   <= 0;
          store_3_fifo_wdata_reg <= 0;
          store_4_fifo_wen_reg   <= 0;
          store_4_fifo_wdata_reg <= 0;
          store_5_fifo_wen_reg   <= 0;
          store_5_fifo_wdata_reg <= 0;
          store_6_fifo_wen_reg   <= 0;
          store_6_fifo_wdata_reg <= 0;
          store_7_fifo_wen_reg   <= 0;
          store_7_fifo_wdata_reg <= 0;
          pea_0_fifo_wen_reg    <= 1'b0;
          pea_0_fifo_wdata_reg  <= 0;
          pea_1_fifo_wen_reg    <= 1'b0;
          pea_1_fifo_wdata_reg  <= 0;
          pea_2_fifo_wen_reg    <= 1'b0;
          pea_2_fifo_wdata_reg  <= 0;
          pea_3_fifo_wen_reg    <= 1'b0;
          pea_3_fifo_wdata_reg  <= 0;
          pea_4_fifo_wen_reg    <= 1'b0;
          pea_4_fifo_wdata_reg  <= 0;
          pea_5_fifo_wen_reg    <= 1'b0;
          pea_5_fifo_wdata_reg  <= 0;
          pea_6_fifo_wen_reg    <= 1'b0;
          pea_6_fifo_wdata_reg  <= 0;
          pea_7_fifo_wen_reg    <= 1'b0;
          pea_7_fifo_wdata_reg  <= 0;
          vcu_0_fifo_wen_reg    <= 1'b0;
          vcu_0_fifo_wdata_reg  <= 0;
          vcu_1_fifo_wen_reg    <= 1'b0;
          vcu_1_fifo_wdata_reg  <= 0;
          vcu_2_fifo_wen_reg    <= 1'b0;
          vcu_2_fifo_wdata_reg  <= 0;
          vcu_3_fifo_wen_reg    <= 1'b0;
          vcu_3_fifo_wdata_reg  <= 0;
          vcu_4_fifo_wen_reg    <= 1'b0;
          vcu_4_fifo_wdata_reg  <= 0;
          vcu_5_fifo_wen_reg    <= 1'b0;
          vcu_5_fifo_wdata_reg  <= 0;
          vcu_6_fifo_wen_reg    <= 1'b0;
          vcu_6_fifo_wdata_reg  <= 0;
          vcu_7_fifo_wen_reg    <= 1'b0;
          vcu_7_fifo_wdata_reg  <= 0;
        end
        6'b001011: begin
          if (!store_2_fifo_full) begin
            store_2_fifo_wen_reg   <= 1'b1;
            store_2_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            store_2_fifo_wen_reg   <= 1'b0;
            store_2_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 1'b0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg   <= 1'b0;
          load_0_fifo_wdata_reg <= 0;
          load_1_fifo_wen_reg   <= 1'b0;
          load_1_fifo_wdata_reg <= 0;
          load_2_fifo_wen_reg   <= 1'b0;
          load_2_fifo_wdata_reg <= 0;
          load_3_fifo_wen_reg   <= 1'b0;
          load_3_fifo_wdata_reg <= 0;
          load_4_fifo_wen_reg   <= 1'b0;
          load_4_fifo_wdata_reg <= 0;
          load_5_fifo_wen_reg   <= 1'b0;
          load_5_fifo_wdata_reg <= 0;
          load_6_fifo_wen_reg   <= 1'b0;
          load_6_fifo_wdata_reg <= 0;
          load_7_fifo_wen_reg   <= 1'b0;
          load_7_fifo_wdata_reg <= 0;
          store_0_fifo_wen_reg   <= 0;
          store_0_fifo_wdata_reg <= 0;
          store_1_fifo_wen_reg   <= 0;
          store_1_fifo_wdata_reg <= 0;
          store_3_fifo_wen_reg   <= 0;
          store_3_fifo_wdata_reg <= 0;
          store_4_fifo_wen_reg   <= 0;
          store_4_fifo_wdata_reg <= 0;
          store_5_fifo_wen_reg   <= 0;
          store_5_fifo_wdata_reg <= 0;
          store_6_fifo_wen_reg   <= 0;
          store_6_fifo_wdata_reg <= 0;
          store_7_fifo_wen_reg   <= 0;
          store_7_fifo_wdata_reg <= 0;
          pea_0_fifo_wen_reg    <= 1'b0;
          pea_0_fifo_wdata_reg  <= 0;
          pea_1_fifo_wen_reg    <= 1'b0;
          pea_1_fifo_wdata_reg  <= 0;
          pea_2_fifo_wen_reg    <= 1'b0;
          pea_2_fifo_wdata_reg  <= 0;
          pea_3_fifo_wen_reg    <= 1'b0;
          pea_3_fifo_wdata_reg  <= 0;
          pea_4_fifo_wen_reg    <= 1'b0;
          pea_4_fifo_wdata_reg  <= 0;
          pea_5_fifo_wen_reg    <= 1'b0;
          pea_5_fifo_wdata_reg  <= 0;
          pea_6_fifo_wen_reg    <= 1'b0;
          pea_6_fifo_wdata_reg  <= 0;
          pea_7_fifo_wen_reg    <= 1'b0;
          pea_7_fifo_wdata_reg  <= 0;
          vcu_0_fifo_wen_reg    <= 1'b0;
          vcu_0_fifo_wdata_reg  <= 0;
          vcu_1_fifo_wen_reg    <= 1'b0;
          vcu_1_fifo_wdata_reg  <= 0;
          vcu_2_fifo_wen_reg    <= 1'b0;
          vcu_2_fifo_wdata_reg  <= 0;
          vcu_3_fifo_wen_reg    <= 1'b0;
          vcu_3_fifo_wdata_reg  <= 0;
          vcu_4_fifo_wen_reg    <= 1'b0;
          vcu_4_fifo_wdata_reg  <= 0;
          vcu_5_fifo_wen_reg    <= 1'b0;
          vcu_5_fifo_wdata_reg  <= 0;
          vcu_6_fifo_wen_reg    <= 1'b0;
          vcu_6_fifo_wdata_reg  <= 0;
          vcu_7_fifo_wen_reg    <= 1'b0;
          vcu_7_fifo_wdata_reg  <= 0;
        end
        6'b001100: begin
          if (!store_3_fifo_full) begin
            store_3_fifo_wen_reg   <= 1'b1;
            store_3_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            store_3_fifo_wen_reg   <= 1'b0;
            store_3_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 1'b0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg   <= 1'b0;
          load_0_fifo_wdata_reg <= 0;
          load_1_fifo_wen_reg   <= 1'b0;
          load_1_fifo_wdata_reg <= 0;
          load_2_fifo_wen_reg   <= 1'b0;
          load_2_fifo_wdata_reg <= 0;
          load_3_fifo_wen_reg   <= 1'b0;
          load_3_fifo_wdata_reg <= 0;
          load_4_fifo_wen_reg   <= 1'b0;
          load_4_fifo_wdata_reg <= 0;
          load_5_fifo_wen_reg   <= 1'b0;
          load_5_fifo_wdata_reg <= 0;
          load_6_fifo_wen_reg   <= 1'b0;
          load_6_fifo_wdata_reg <= 0;
          load_7_fifo_wen_reg   <= 1'b0;
          load_7_fifo_wdata_reg <= 0;
          store_0_fifo_wen_reg   <= 0;
          store_0_fifo_wdata_reg <= 0;
          store_1_fifo_wen_reg   <= 0;
          store_1_fifo_wdata_reg <= 0;
          store_2_fifo_wen_reg   <= 0;
          store_2_fifo_wdata_reg <= 0;
          store_4_fifo_wen_reg   <= 0;
          store_4_fifo_wdata_reg <= 0;
          store_5_fifo_wen_reg   <= 0;
          store_5_fifo_wdata_reg <= 0;
          store_6_fifo_wen_reg   <= 0;
          store_6_fifo_wdata_reg <= 0;
          store_7_fifo_wen_reg   <= 0;
          store_7_fifo_wdata_reg <= 0;
          pea_0_fifo_wen_reg    <= 1'b0;
          pea_0_fifo_wdata_reg  <= 0;
          pea_1_fifo_wen_reg    <= 1'b0;
          pea_1_fifo_wdata_reg  <= 0;
          pea_2_fifo_wen_reg    <= 1'b0;
          pea_2_fifo_wdata_reg  <= 0;
          pea_3_fifo_wen_reg    <= 1'b0;
          pea_3_fifo_wdata_reg  <= 0;
          pea_4_fifo_wen_reg    <= 1'b0;
          pea_4_fifo_wdata_reg  <= 0;
          pea_5_fifo_wen_reg    <= 1'b0;
          pea_5_fifo_wdata_reg  <= 0;
          pea_6_fifo_wen_reg    <= 1'b0;
          pea_6_fifo_wdata_reg  <= 0;
          pea_7_fifo_wen_reg    <= 1'b0;
          pea_7_fifo_wdata_reg  <= 0;
          vcu_0_fifo_wen_reg    <= 1'b0;
          vcu_0_fifo_wdata_reg  <= 0;
          vcu_1_fifo_wen_reg    <= 1'b0;
          vcu_1_fifo_wdata_reg  <= 0;
          vcu_2_fifo_wen_reg    <= 1'b0;
          vcu_2_fifo_wdata_reg  <= 0;
          vcu_3_fifo_wen_reg    <= 1'b0;
          vcu_3_fifo_wdata_reg  <= 0;
          vcu_4_fifo_wen_reg    <= 1'b0;
          vcu_4_fifo_wdata_reg  <= 0;
          vcu_5_fifo_wen_reg    <= 1'b0;
          vcu_5_fifo_wdata_reg  <= 0;
          vcu_6_fifo_wen_reg    <= 1'b0;
          vcu_6_fifo_wdata_reg  <= 0;
          vcu_7_fifo_wen_reg    <= 1'b0;
          vcu_7_fifo_wdata_reg  <= 0;
        end
        6'b001101: begin
          if (!store_4_fifo_full) begin
            store_4_fifo_wen_reg   <= 1'b1;
            store_4_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            store_4_fifo_wen_reg   <= 1'b0;
            store_4_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 1'b0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg   <= 1'b0;
          load_0_fifo_wdata_reg <= 0;
          load_1_fifo_wen_reg   <= 1'b0;
          load_1_fifo_wdata_reg <= 0;
          load_2_fifo_wen_reg   <= 1'b0;
          load_2_fifo_wdata_reg <= 0;
          load_3_fifo_wen_reg   <= 1'b0;
          load_3_fifo_wdata_reg <= 0;
          load_4_fifo_wen_reg   <= 1'b0;
          load_4_fifo_wdata_reg <= 0;
          load_5_fifo_wen_reg   <= 1'b0;
          load_5_fifo_wdata_reg <= 0;
          load_6_fifo_wen_reg   <= 1'b0;
          load_6_fifo_wdata_reg <= 0;
          load_7_fifo_wen_reg   <= 1'b0;
          load_7_fifo_wdata_reg <= 0;
          store_0_fifo_wen_reg   <= 0;
          store_0_fifo_wdata_reg <= 0;
          store_1_fifo_wen_reg   <= 0;
          store_1_fifo_wdata_reg <= 0;
          store_2_fifo_wen_reg   <= 0;
          store_2_fifo_wdata_reg <= 0;
          store_3_fifo_wen_reg   <= 0;
          store_3_fifo_wdata_reg <= 0;
          store_5_fifo_wen_reg   <= 0;
          store_5_fifo_wdata_reg <= 0;
          store_6_fifo_wen_reg   <= 0;
          store_6_fifo_wdata_reg <= 0;
          store_7_fifo_wen_reg   <= 0;
          store_7_fifo_wdata_reg <= 0;
          pea_0_fifo_wen_reg    <= 1'b0;
          pea_0_fifo_wdata_reg  <= 0;
          pea_1_fifo_wen_reg    <= 1'b0;
          pea_1_fifo_wdata_reg  <= 0;
          pea_2_fifo_wen_reg    <= 1'b0;
          pea_2_fifo_wdata_reg  <= 0;
          pea_3_fifo_wen_reg    <= 1'b0;
          pea_3_fifo_wdata_reg  <= 0;
          pea_4_fifo_wen_reg    <= 1'b0;
          pea_4_fifo_wdata_reg  <= 0;
          pea_5_fifo_wen_reg    <= 1'b0;
          pea_5_fifo_wdata_reg  <= 0;
          pea_6_fifo_wen_reg    <= 1'b0;
          pea_6_fifo_wdata_reg  <= 0;
          pea_7_fifo_wen_reg    <= 1'b0;
          pea_7_fifo_wdata_reg  <= 0;
          vcu_0_fifo_wen_reg    <= 1'b0;
          vcu_0_fifo_wdata_reg  <= 0;
          vcu_1_fifo_wen_reg    <= 1'b0;
          vcu_1_fifo_wdata_reg  <= 0;
          vcu_2_fifo_wen_reg    <= 1'b0;
          vcu_2_fifo_wdata_reg  <= 0;
          vcu_3_fifo_wen_reg    <= 1'b0;
          vcu_3_fifo_wdata_reg  <= 0;
          vcu_4_fifo_wen_reg    <= 1'b0;
          vcu_4_fifo_wdata_reg  <= 0;
          vcu_5_fifo_wen_reg    <= 1'b0;
          vcu_5_fifo_wdata_reg  <= 0;
          vcu_6_fifo_wen_reg    <= 1'b0;
          vcu_6_fifo_wdata_reg  <= 0;
          vcu_7_fifo_wen_reg    <= 1'b0;
          vcu_7_fifo_wdata_reg  <= 0;
        end
        6'b001110: begin
          if (!store_5_fifo_full) begin
            store_5_fifo_wen_reg   <= 1'b1;
            store_5_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            store_5_fifo_wen_reg   <= 1'b0;
            store_5_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 1'b0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg   <= 1'b0;
          load_0_fifo_wdata_reg <= 0;
          load_1_fifo_wen_reg   <= 1'b0;
          load_1_fifo_wdata_reg <= 0;
          load_2_fifo_wen_reg   <= 1'b0;
          load_2_fifo_wdata_reg <= 0;
          load_3_fifo_wen_reg   <= 1'b0;
          load_3_fifo_wdata_reg <= 0;
          load_4_fifo_wen_reg   <= 1'b0;
          load_4_fifo_wdata_reg <= 0;
          load_5_fifo_wen_reg   <= 1'b0;
          load_5_fifo_wdata_reg <= 0;
          load_6_fifo_wen_reg   <= 1'b0;
          load_6_fifo_wdata_reg <= 0;
          load_7_fifo_wen_reg   <= 1'b0;
          load_7_fifo_wdata_reg <= 0;
          store_0_fifo_wen_reg   <= 0;
          store_0_fifo_wdata_reg <= 0;
          store_1_fifo_wen_reg   <= 0;
          store_1_fifo_wdata_reg <= 0;
          store_2_fifo_wen_reg   <= 0;
          store_2_fifo_wdata_reg <= 0;
          store_3_fifo_wen_reg   <= 0;
          store_3_fifo_wdata_reg <= 0;
          store_4_fifo_wen_reg   <= 0;
          store_4_fifo_wdata_reg <= 0;
          store_6_fifo_wen_reg   <= 0;
          store_6_fifo_wdata_reg <= 0;
          store_7_fifo_wen_reg   <= 0;
          store_7_fifo_wdata_reg <= 0;
          pea_0_fifo_wen_reg    <= 1'b0;
          pea_0_fifo_wdata_reg  <= 0;
          pea_1_fifo_wen_reg    <= 1'b0;
          pea_1_fifo_wdata_reg  <= 0;
          pea_2_fifo_wen_reg    <= 1'b0;
          pea_2_fifo_wdata_reg  <= 0;
          pea_3_fifo_wen_reg    <= 1'b0;
          pea_3_fifo_wdata_reg  <= 0;
          pea_4_fifo_wen_reg    <= 1'b0;
          pea_4_fifo_wdata_reg  <= 0;
          pea_5_fifo_wen_reg    <= 1'b0;
          pea_5_fifo_wdata_reg  <= 0;
          pea_6_fifo_wen_reg    <= 1'b0;
          pea_6_fifo_wdata_reg  <= 0;
          pea_7_fifo_wen_reg    <= 1'b0;
          pea_7_fifo_wdata_reg  <= 0;
          vcu_0_fifo_wen_reg    <= 1'b0;
          vcu_0_fifo_wdata_reg  <= 0;
          vcu_1_fifo_wen_reg    <= 1'b0;
          vcu_1_fifo_wdata_reg  <= 0;
          vcu_2_fifo_wen_reg    <= 1'b0;
          vcu_2_fifo_wdata_reg  <= 0;
          vcu_3_fifo_wen_reg    <= 1'b0;
          vcu_3_fifo_wdata_reg  <= 0;
          vcu_4_fifo_wen_reg    <= 1'b0;
          vcu_4_fifo_wdata_reg  <= 0;
          vcu_5_fifo_wen_reg    <= 1'b0;
          vcu_5_fifo_wdata_reg  <= 0;
          vcu_6_fifo_wen_reg    <= 1'b0;
          vcu_6_fifo_wdata_reg  <= 0;
          vcu_7_fifo_wen_reg    <= 1'b0;
          vcu_7_fifo_wdata_reg  <= 0;
        end
        6'b001111: begin
          if (!store_6_fifo_full) begin
            store_6_fifo_wen_reg   <= 1'b1;
            store_6_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            store_6_fifo_wen_reg   <= 1'b0;
            store_6_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 1'b0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg   <= 1'b0;
          load_0_fifo_wdata_reg <= 0;
          load_1_fifo_wen_reg   <= 1'b0;
          load_1_fifo_wdata_reg <= 0;
          load_2_fifo_wen_reg   <= 1'b0;
          load_2_fifo_wdata_reg <= 0;
          load_3_fifo_wen_reg   <= 1'b0;
          load_3_fifo_wdata_reg <= 0;
          load_4_fifo_wen_reg   <= 1'b0;
          load_4_fifo_wdata_reg <= 0;
          load_5_fifo_wen_reg   <= 1'b0;
          load_5_fifo_wdata_reg <= 0;
          load_6_fifo_wen_reg   <= 1'b0;
          load_6_fifo_wdata_reg <= 0;
          load_7_fifo_wen_reg   <= 1'b0;
          load_7_fifo_wdata_reg <= 0;
          store_0_fifo_wen_reg   <= 0;
          store_0_fifo_wdata_reg <= 0;
          store_1_fifo_wen_reg   <= 0;
          store_1_fifo_wdata_reg <= 0;
          store_2_fifo_wen_reg   <= 0;
          store_2_fifo_wdata_reg <= 0;
          store_3_fifo_wen_reg   <= 0;
          store_3_fifo_wdata_reg <= 0;
          store_4_fifo_wen_reg   <= 0;
          store_4_fifo_wdata_reg <= 0;
          store_5_fifo_wen_reg   <= 0;
          store_5_fifo_wdata_reg <= 0;
          store_7_fifo_wen_reg   <= 0;
          store_7_fifo_wdata_reg <= 0;
          pea_0_fifo_wen_reg    <= 1'b0;
          pea_0_fifo_wdata_reg  <= 0;
          pea_1_fifo_wen_reg    <= 1'b0;
          pea_1_fifo_wdata_reg  <= 0;
          pea_2_fifo_wen_reg    <= 1'b0;
          pea_2_fifo_wdata_reg  <= 0;
          pea_3_fifo_wen_reg    <= 1'b0;
          pea_3_fifo_wdata_reg  <= 0;
          pea_4_fifo_wen_reg    <= 1'b0;
          pea_4_fifo_wdata_reg  <= 0;
          pea_5_fifo_wen_reg    <= 1'b0;
          pea_5_fifo_wdata_reg  <= 0;
          pea_6_fifo_wen_reg    <= 1'b0;
          pea_6_fifo_wdata_reg  <= 0;
          pea_7_fifo_wen_reg    <= 1'b0;
          pea_7_fifo_wdata_reg  <= 0;
          vcu_0_fifo_wen_reg    <= 1'b0;
          vcu_0_fifo_wdata_reg  <= 0;
          vcu_1_fifo_wen_reg    <= 1'b0;
          vcu_1_fifo_wdata_reg  <= 0;
          vcu_2_fifo_wen_reg    <= 1'b0;
          vcu_2_fifo_wdata_reg  <= 0;
          vcu_3_fifo_wen_reg    <= 1'b0;
          vcu_3_fifo_wdata_reg  <= 0;
          vcu_4_fifo_wen_reg    <= 1'b0;
          vcu_4_fifo_wdata_reg  <= 0;
          vcu_5_fifo_wen_reg    <= 1'b0;
          vcu_5_fifo_wdata_reg  <= 0;
          vcu_6_fifo_wen_reg    <= 1'b0;
          vcu_6_fifo_wdata_reg  <= 0;
          vcu_7_fifo_wen_reg    <= 1'b0;
          vcu_7_fifo_wdata_reg  <= 0;
        end
        6'b010000: begin
          if (!store_7_fifo_full) begin
            store_7_fifo_wen_reg   <= 1'b1;
            store_7_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            store_7_fifo_wen_reg   <= 1'b0;
            store_7_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b010001: begin
          if (!pea_0_fifo_full) begin
            pea_0_fifo_wen_reg   <= 1'b1;
            pea_0_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            pea_0_fifo_wen_reg   <= 1'b0;
            pea_0_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b010010: begin
          if (!pea_1_fifo_full) begin
            pea_1_fifo_wen_reg   <= 1'b1;
            pea_1_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            pea_1_fifo_wen_reg   <= 1'b0;
            pea_1_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b010011: begin
          if (!pea_2_fifo_full) begin
            pea_2_fifo_wen_reg   <= 1'b1;
            pea_2_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            pea_2_fifo_wen_reg   <= 1'b0;
            pea_2_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b010100: begin
          if (!pea_3_fifo_full) begin
            pea_3_fifo_wen_reg   <= 1'b1;
            pea_3_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            pea_3_fifo_wen_reg   <= 1'b0;
            pea_3_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b010101: begin
          if (!pea_4_fifo_full) begin
            pea_4_fifo_wen_reg   <= 1'b1;
            pea_4_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            pea_4_fifo_wen_reg   <= 1'b0;
            pea_4_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b010110: begin
          if (!pea_5_fifo_full) begin
            pea_5_fifo_wen_reg   <= 1'b1;
            pea_5_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            pea_5_fifo_wen_reg   <= 1'b0;
            pea_5_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b010111: begin
          if (!pea_6_fifo_full) begin
            pea_6_fifo_wen_reg   <= 1'b1;
            pea_6_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            pea_6_fifo_wen_reg   <= 1'b0;
            pea_6_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b011000: begin
          if (!pea_7_fifo_full) begin
            pea_7_fifo_wen_reg   <= 1'b1;
            pea_7_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            pea_7_fifo_wen_reg   <= 1'b0;
            pea_7_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b011001: begin
          if (!vcu_0_fifo_full) begin
            vcu_0_fifo_wen_reg   <= 1'b1;
            vcu_0_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            vcu_0_fifo_wen_reg   <= 1'b0;
            vcu_0_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b011010: begin
          if (!vcu_1_fifo_full) begin
            vcu_1_fifo_wen_reg   <= 1'b1;
            vcu_1_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            vcu_1_fifo_wen_reg   <= 1'b0;
            vcu_1_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b011011: begin
          if (!vcu_2_fifo_full) begin
            vcu_2_fifo_wen_reg   <= 1'b1;
            vcu_2_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            vcu_2_fifo_wen_reg   <= 1'b0;
            vcu_2_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b011100: begin
          if (!vcu_3_fifo_full) begin
            vcu_3_fifo_wen_reg   <= 1'b1;
            vcu_3_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            vcu_3_fifo_wen_reg   <= 1'b0;
            vcu_3_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b011101: begin
          if (!vcu_4_fifo_full) begin
            vcu_4_fifo_wen_reg   <= 1'b1;
            vcu_4_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            vcu_4_fifo_wen_reg   <= 1'b0;
            vcu_4_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b011110: begin
          if (!vcu_5_fifo_full) begin
            vcu_5_fifo_wen_reg   <= 1'b1;
            vcu_5_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            vcu_5_fifo_wen_reg   <= 1'b0;
            vcu_5_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b011111: begin
          if (!vcu_6_fifo_full) begin
            vcu_6_fifo_wen_reg   <= 1'b1;
            vcu_6_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            vcu_6_fifo_wen_reg   <= 1'b0;
            vcu_6_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
        end
        6'b100000: begin
          if (!vcu_7_fifo_full) begin
            vcu_7_fifo_wen_reg   <= 1'b1;
            vcu_7_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];
            insn_buffer_index <= insn_buffer_index + 1;
          end
          else begin
            vcu_7_fifo_wen_reg   <= 1'b0;
            vcu_7_fifo_wdata_reg <= 0;
          end
          synchronize_fifo_wen_reg   <= 0;
          synchronize_fifo_wdata_reg <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
        end
        6'b100001: begin
          insn_nonew <= 1'b1;
          synchronize_fifo_wdata_reg <= 0;
          synchronize_fifo_wen_reg   <= 0;
          load_0_fifo_wdata_reg      <= 0;
          load_0_fifo_wen_reg        <= 0;
          load_1_fifo_wdata_reg      <= 0;
          load_1_fifo_wen_reg        <= 0;
          load_2_fifo_wdata_reg      <= 0;
          load_2_fifo_wen_reg        <= 0;
          load_3_fifo_wdata_reg      <= 0;
          load_3_fifo_wen_reg        <= 0;
          load_4_fifo_wdata_reg      <= 0;
          load_4_fifo_wen_reg        <= 0;
          load_5_fifo_wdata_reg      <= 0;
          load_5_fifo_wen_reg        <= 0;
          load_6_fifo_wdata_reg      <= 0;
          load_6_fifo_wen_reg        <= 0;
          load_7_fifo_wdata_reg      <= 0;
          load_7_fifo_wen_reg        <= 0;
          store_0_fifo_wdata_reg     <= 0;
          store_0_fifo_wen_reg       <= 0;
          store_1_fifo_wdata_reg     <= 0;
          store_1_fifo_wen_reg       <= 0;
          store_2_fifo_wdata_reg     <= 0;
          store_2_fifo_wen_reg       <= 0;
          store_3_fifo_wdata_reg     <= 0;
          store_3_fifo_wen_reg       <= 0;
          store_4_fifo_wdata_reg     <= 0;
          store_4_fifo_wen_reg       <= 0;
          store_5_fifo_wdata_reg     <= 0;
          store_5_fifo_wen_reg       <= 0;
          store_6_fifo_wdata_reg     <= 0;
          store_6_fifo_wen_reg       <= 0;
          store_7_fifo_wdata_reg     <= 0;
          store_7_fifo_wen_reg       <= 0;
          pea_0_fifo_wdata_reg       <= 0;
          pea_0_fifo_wen_reg         <= 0;
          pea_1_fifo_wdata_reg       <= 0;
          pea_1_fifo_wen_reg         <= 0;
          pea_2_fifo_wdata_reg       <= 0;
          pea_2_fifo_wen_reg         <= 0;
          pea_3_fifo_wdata_reg       <= 0;
          pea_3_fifo_wen_reg         <= 0;
          pea_4_fifo_wdata_reg       <= 0;
          pea_4_fifo_wen_reg         <= 0;
          pea_5_fifo_wdata_reg       <= 0;
          pea_5_fifo_wen_reg         <= 0;
          pea_6_fifo_wdata_reg       <= 0;
          pea_6_fifo_wen_reg         <= 0;
          pea_7_fifo_wdata_reg       <= 0;
          pea_7_fifo_wen_reg         <= 0;
          vcu_0_fifo_wdata_reg       <= 0;
          vcu_0_fifo_wen_reg         <= 0;
          vcu_1_fifo_wdata_reg       <= 0;
          vcu_1_fifo_wen_reg         <= 0;
          vcu_2_fifo_wdata_reg       <= 0;
          vcu_2_fifo_wen_reg         <= 0;
          vcu_3_fifo_wdata_reg       <= 0;
          vcu_3_fifo_wen_reg         <= 0;
          vcu_4_fifo_wdata_reg       <= 0;
          vcu_4_fifo_wen_reg         <= 0;
          vcu_5_fifo_wdata_reg       <= 0;
          vcu_5_fifo_wen_reg         <= 0;
          vcu_6_fifo_wdata_reg       <= 0;
          vcu_6_fifo_wen_reg         <= 0;
          vcu_7_fifo_wdata_reg       <= 0;
          vcu_7_fifo_wen_reg         <= 0;
          insn_nonew                 <= 0;
        end
      endcase
    end
    else begin
      synchronize_fifo_wdata_reg <= 0;
      synchronize_fifo_wen_reg   <= 0;
      load_0_fifo_wdata_reg      <= 0;
      load_0_fifo_wen_reg        <= 0;
      load_1_fifo_wdata_reg      <= 0;
      load_1_fifo_wen_reg        <= 0;
      load_2_fifo_wdata_reg      <= 0;
      load_2_fifo_wen_reg        <= 0;
      load_3_fifo_wdata_reg      <= 0;
      load_3_fifo_wen_reg        <= 0;
      load_4_fifo_wdata_reg      <= 0;
      load_4_fifo_wen_reg        <= 0;
      load_5_fifo_wdata_reg      <= 0;
      load_5_fifo_wen_reg        <= 0;
      load_6_fifo_wdata_reg      <= 0;
      load_6_fifo_wen_reg        <= 0;
      load_7_fifo_wdata_reg      <= 0;
      load_7_fifo_wen_reg        <= 0;
      store_0_fifo_wdata_reg     <= 0;
      store_0_fifo_wen_reg       <= 0;
      store_1_fifo_wdata_reg     <= 0;
      store_1_fifo_wen_reg       <= 0;
      store_2_fifo_wdata_reg     <= 0;
      store_2_fifo_wen_reg       <= 0;
      store_3_fifo_wdata_reg     <= 0;
      store_3_fifo_wen_reg       <= 0;
      store_4_fifo_wdata_reg     <= 0;
      store_4_fifo_wen_reg       <= 0;
      store_5_fifo_wdata_reg     <= 0;
      store_5_fifo_wen_reg       <= 0;
      store_6_fifo_wdata_reg     <= 0;
      store_6_fifo_wen_reg       <= 0;
      store_7_fifo_wdata_reg     <= 0;
      store_7_fifo_wen_reg       <= 0;
      pea_0_fifo_wdata_reg       <= 0;
      pea_0_fifo_wen_reg         <= 0;
      pea_1_fifo_wdata_reg       <= 0;
      pea_1_fifo_wen_reg         <= 0;
      pea_2_fifo_wdata_reg       <= 0;
      pea_2_fifo_wen_reg         <= 0;
      pea_3_fifo_wdata_reg       <= 0;
      pea_3_fifo_wen_reg         <= 0;
      pea_4_fifo_wdata_reg       <= 0;
      pea_4_fifo_wen_reg         <= 0;
      pea_5_fifo_wdata_reg       <= 0;
      pea_5_fifo_wen_reg         <= 0;
      pea_6_fifo_wdata_reg       <= 0;
      pea_6_fifo_wen_reg         <= 0;
      pea_7_fifo_wdata_reg       <= 0;
      pea_7_fifo_wen_reg         <= 0;
      vcu_0_fifo_wdata_reg       <= 0;
      vcu_0_fifo_wen_reg         <= 0;
      vcu_1_fifo_wdata_reg       <= 0;
      vcu_1_fifo_wen_reg         <= 0;
      vcu_2_fifo_wdata_reg       <= 0;
      vcu_2_fifo_wen_reg         <= 0;
      vcu_3_fifo_wdata_reg       <= 0;
      vcu_3_fifo_wen_reg         <= 0;
      vcu_4_fifo_wdata_reg       <= 0;
      vcu_4_fifo_wen_reg         <= 0;
      vcu_5_fifo_wdata_reg       <= 0;
      vcu_5_fifo_wen_reg         <= 0;
      vcu_6_fifo_wdata_reg       <= 0;
      vcu_6_fifo_wen_reg         <= 0;
      vcu_7_fifo_wdata_reg       <= 0;
      vcu_7_fifo_wen_reg         <= 0;
      insn_nonew                 <= 0;
    end
  end
end

dispatch_local_fifo u_dispatch_local_fifo(
  .clk      ( clk                 ),
  .rst_n    ( rst_n               ),
  .w_en     ( local_fifo_wen      ),
  .r_en     ( local_fifo_ren      ),
  .w_data   ( local_fifo_wdata    ),
  .full     (                     ),
  .empty    ( local_fifo_empty    ),
  .afull    ( local_fifo_full     ),
  .aempty   (                     ),
  .hfull    (                     ),
  .hempty   (                     ),
  .r_data   ( local_fifo_rdata    ),
  .capacity (                     )
);

genvar insn_buffer_var;
generate
for (insn_buffer_var=0; insn_buffer_var<INSN_BUFFER_NUM; insn_buffer_var=insn_buffer_var+1) begin:insn_buffer_allocate
	assign insn_buffer_wire[insn_buffer_var] = insn_buffer_reg[(INSN_WIDTH*insn_buffer_var+INSN_WIDTH-1)-:INSN_WIDTH];
end
endgenerate


endmodule
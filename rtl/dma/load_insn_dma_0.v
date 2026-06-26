module load_insn_dma_0(
  clk, rst_n, 
  work_en, insn, insn_read,
  local_done, global_done, 
  peripheral_M_raddr, peripheral_M_rlen, peripheral_M_raddr_valid, peripheral_M_raddr_ready, 
  peripheral_M_rdata, peripheral_M_rdata_ready, peripheral_M_rdata_valid, 

  ifmap_wvalid, ifmap_waddr, ifmap_wdata,
  qact_wvalid, qact_waddr, qact_wdata,
  vcucode_wvalid, vcucode_waddr, vcucode_wdata,
  vcupara_wvalid, vcupara_waddr, vcupara_wdata,
  vcures_wvalid, vcures_waddr, vcures_wdata,
  weight_wvalid, weight_wdata,

  regfile_wvalid, regfile_waddr, regfile_wdata
);

parameter integer LOAD_INSNBITS      = 128;

parameter integer PERI_ADDR_WIDTH    = 38;
parameter integer PERI_BUSRSTS_WIDTH = 8;
parameter integer PERI_DATA_WIDTH    = 256;
parameter integer SRAM_ADDR_WIDTH    = 20;

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction  

localparam integer PERI_DATA_BYTES = PERI_DATA_WIDTH / 8;
localparam integer PERI_DATA_BYTES_SHIFTNUMBER = clogb2(PERI_DATA_BYTES - 1);

localparam integer LOAD_ITERATION_4_INSN_ID = 0;
localparam integer LOAD_ITERATION_3_INSN_ID = 1;
localparam integer LOAD_ITERATION_2_INSN_ID = 2;

localparam integer LOAD_INSN_OPCODE_ID      = 1;
localparam integer LOAD_INSN_OPCODE_ID_BITS = 5;
localparam integer LOAD_INSN_ID_BITS        = 2;

parameter IFMAP_WIDTH             = 576;
parameter QACT_WIDTH              = 288;
parameter VCUCODE_WIDTH           = 64;
parameter VCUPARA_WIDTH           = 576;
parameter VCULUT_WIDTH            = 64;
parameter VCURES_WIDTH            = 576;
parameter WEIGHT_WIDTH            = 288;

parameter IFMAP_ADDR_BITS         = 9;  //bank:4,2bits; addr:6bits, 36 depth, highaddr:1bits
parameter QACT_ADDR_BITS          = 9;  //bank:4,2bits; addr:6bits, 36 depth, highaddr:1bits
parameter VCUPARA_ADDR_BITS       = 9;  //vector_mul, fp16
parameter VCURES_ADDR_BITS        = 9;  //vector_add, fp16
parameter VCUCODE_ADDR_BITS       = 7;
parameter VCULUT_ADDR_BITS        = 9;

//Define pins:
input                                     clk;
input                                     rst_n;
input                                     work_en;
output reg                                insn_read;
input       [LOAD_INSNBITS-1:0]           insn;
output reg                                local_done;
output reg                                global_done;
output wire [PERI_ADDR_WIDTH-1:0]         peripheral_M_raddr;
output wire [PERI_BUSRSTS_WIDTH-1:0]      peripheral_M_rlen;
output wire                               peripheral_M_raddr_valid;
input                                     peripheral_M_raddr_ready;
input [PERI_DATA_WIDTH-1:0]               peripheral_M_rdata;
input                                     peripheral_M_rdata_ready;
output wire                               peripheral_M_rdata_valid;

output reg  [IFMAP_ADDR_BITS-1:0]         ifmap_waddr;
output reg  [IFMAP_WIDTH-1:0]             ifmap_wdata;
output reg                                ifmap_wvalid;

output reg  [QACT_ADDR_BITS-1:0]          qact_waddr;
output reg  [QACT_WIDTH-1:0]              qact_wdata;
output reg                                qact_wvalid;

output reg  [VCUCODE_ADDR_BITS:0]         vcucode_waddr;
output reg  [VCUCODE_WIDTH-1:0]           vcucode_wdata;
output reg                                vcucode_wvalid;

output reg  [VCUPARA_ADDR_BITS-1:0]       vcupara_waddr;
output reg  [VCUPARA_WIDTH-1:0]           vcupara_wdata;
output reg                                vcupara_wvalid;

output reg  [VCURES_ADDR_BITS-1:0]        vcures_waddr;
output reg  [VCURES_WIDTH-1:0]            vcures_wdata;
output reg                                vcures_wvalid;

output reg  [WEIGHT_WIDTH-1:0]            weight_wdata;
output reg                                weight_wvalid;

output reg  [31:0]                        regfile_waddr;
output reg  [31:0]                        regfile_wdata;
output reg                                regfile_wvalid;

reg                                insn_valid;
reg                                load_start;
reg                                execute_done;
reg [LOAD_INSN_OPCODE_ID_BITS-1:0] load_insn_opcode;
reg [LOAD_INSN_ID_BITS-1:0]        load_insns;
reg [PERI_ADDR_WIDTH-1:0]          ddr_baseaddr;
reg [23:0]                         sequ_burst_0;
reg [SRAM_ADDR_WIDTH-1:0]          sram_baseaddr;
reg [22:0]                         sequ_burst_1;
reg [10:0]                         sequ_burst_2;
reg [3:0]                          sequ_burst_3;
reg                                all_done;

reg [PERI_ADDR_WIDTH-1:0] ddr_offset_0;
reg [PERI_ADDR_WIDTH-1:0] ddr_offset_1;
reg [PERI_ADDR_WIDTH-1:0] ddr_offset_2;
reg [PERI_ADDR_WIDTH-1:0] ddr_offset_3;

reg [PERI_ADDR_WIDTH-1:0] ddr_offset_iter_0;
reg [PERI_ADDR_WIDTH-1:0] ddr_offset_iter_1;
reg [PERI_ADDR_WIDTH-1:0] ddr_offset_iter_2;
reg [PERI_ADDR_WIDTH-1:0] ddr_offset_iter_3;

reg [PERI_BUSRSTS_WIDTH-1:0] ddr_burst_cnt_0;
reg [PERI_BUSRSTS_WIDTH-1:0] ddr_burst_cnt_1;
reg [PERI_BUSRSTS_WIDTH-1:0] ddr_burst_cnt_2;
reg [PERI_BUSRSTS_WIDTH-1:0] ddr_burst_cnt_3;

wire burst_0_done;
wire burst_1_done;
wire burst_2_done;
wire burst_3_done;
wire burst_done;

reg [PERI_BUSRSTS_WIDTH-1:0] sram_burst_cnt_0;
reg [PERI_BUSRSTS_WIDTH-1:0] sram_burst_cnt_1;
reg [PERI_BUSRSTS_WIDTH-1:0] sram_burst_cnt_2;
reg [PERI_BUSRSTS_WIDTH-1:0] sram_burst_cnt_3;

wire sram_0_done;
wire sram_1_done;
wire sram_2_done;
wire sram_3_done;
wire sram_done;

wire [287:0]                 data_out_288b;
wire                         valid_data_out_288b;
wire                         need_256_to_288_conversion;


reg                          load_working;

reg [PERI_ADDR_WIDTH-1:0]    request_address;
reg [PERI_BUSRSTS_WIDTH-1:0] request_length;
reg                          request_valid;

assign peripheral_M_raddr       = request_address;
assign peripheral_M_rlen        = request_length;
assign peripheral_M_raddr_valid = request_valid;
wire data_fifo_hfull;
wire data_fifo_empty;

reg [4:0]  insn_number;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    local_done <= 1'b0;
    global_done <= 1'b0;
  end
  else begin
    if (execute_done && (~|insn_number)) begin
      local_done <= 1'b1;
    end
    else begin
      local_done <= 1'b0;
    end

    if (all_done && execute_done && (~|insn_number)) begin
      global_done <= 1'b1;
    end
    else begin
      global_done <= 1'b0;
    end
  end
end

reg  [SRAM_ADDR_WIDTH-1:0] sram_addr;
wire [PERI_DATA_WIDTH-1:0] sram_wdata;
reg  [PERI_DATA_WIDTH-1:0] sram_wdata_reg;
reg                        local_fifo_ren;

assign sram_wvalid              = local_fifo_ren & (!data_fifo_empty);
assign sram_waddr               = sram_addr;
assign peripheral_M_rdata_valid = !data_fifo_hfull;


localparam REGFILE_ID       = 4'b0000;
localparam IFMAP_ID         = 4'b0001;
localparam WEIGHT_ID        = 4'b0011;
localparam QACT_ID          = 4'b1100;
localparam VCUCODE_ID       = 4'b1000;
localparam VCULUT_ID        = 4'b1001;
localparam VCUPARA_ID       = 4'b1010;
localparam VCURES_ID        = 4'b1011;

wire [3:0] write_high_addr;
assign write_high_addr = sram_addr[19:16];

reg       split_block;

reg [1:0] one_split_four_cnt;
reg [1:0] four_cat_one_cnt;
reg       one_split_two_cnt;
reg       two_cat_one_cnt;

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    insn_valid <= 1'b0;
    insn_read  <= 1'b0;
	end
	else begin
    if (work_en) begin
      insn_read <= work_en;
    end
    else begin
      if (execute_done && |insn_number) begin
        insn_read <= 1'b1;
      end
      else begin
        insn_read <= 1'b0;
      end
    end

    if (insn_read) begin
      insn_valid <= 1'b1;
    end
    else begin
      insn_valid <= 1'b0;
    end
	end
end

reg insn_valid_reg;
reg [127:0] insn_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    insn_valid_reg <= 1'b0;
    insn_reg       <= 128'b0;
  end
  else begin
    if (insn_valid) begin
      insn_valid_reg <= 1'b1;
      insn_reg       <= insn;
    end
    else begin
      insn_valid_reg <= 1'b0;
      insn_reg       <= insn_reg;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    load_start       <= 1'b0;
    load_working     <= 1'b0;
    load_insn_opcode <= LOAD_INSN_OPCODE_ID;
    ddr_baseaddr     <= 'd0;
    ddr_offset_0     <= PERI_DATA_BYTES;
    sequ_burst_0     <= 'd0;
    sram_baseaddr    <= 'd0;
    ddr_offset_1     <= 'd0;
    sequ_burst_1     <= 'd0;
    ddr_offset_2     <= 'd0;
    sequ_burst_2     <= 'd0;
    ddr_offset_3     <= 'd0;
    sequ_burst_3     <= 'd0;
    all_done         <= 1'b0;
  end
  else if (execute_done || local_done) begin
    load_start       <= 1'b0;
    load_working     <= 1'b0;
    load_insn_opcode <= LOAD_INSN_OPCODE_ID;
    ddr_baseaddr     <= 'd0;
    ddr_offset_0     <= PERI_DATA_BYTES;
    sequ_burst_0     <= 'd0;
    sram_baseaddr    <= 'd0;
    ddr_offset_1     <= 'd0;
    sequ_burst_1     <= 'd0;
    ddr_offset_2     <= 'd0;
    sequ_burst_2     <= 'd0;
    ddr_offset_3     <= 'd0;
    sequ_burst_3     <= 'd0;
    all_done         <= 1'b0;
  end
  else begin
    ddr_offset_0 <= ddr_offset_0;

    if (insn_valid_reg) begin
      load_insn_opcode <= insn_reg[5:0];
      load_start       <= 1'b1;
    end
    else begin
      load_insn_opcode <= load_insn_opcode;
      load_start       <= 1'b0;
    end

    if (load_start) begin
      load_working <= 1'b1;
    end
    else begin
      load_working <= load_working;
    end

    if (insn_valid_reg && (insn_reg[11:10] == LOAD_ITERATION_3_INSN_ID)) begin
      ddr_baseaddr  <= insn_reg[49:12];
      sequ_burst_0  <= insn_reg[60:50];
      ddr_offset_1  <= (insn_reg[73:66] << insn_reg[65:61]);
      sequ_burst_1  <= insn_reg[83:74];
      ddr_offset_2  <= (insn_reg[96:89] << insn_reg[88:84]);
      sequ_burst_2  <= insn_reg[106:97];
      ddr_offset_3  <= 'd0;
      sequ_burst_3  <= 'd0;
      sram_baseaddr <= insn_reg[126:107];
      all_done      <= insn_reg[127];
    end
    else if (insn_valid_reg && (insn_reg[11:10] == LOAD_ITERATION_2_INSN_ID)) begin
      ddr_baseaddr  <= insn_reg[49:12];
      sequ_burst_0  <= insn_reg[71:50];
      ddr_offset_1  <= (insn_reg[84:77] << insn_reg[76:72]);
      sequ_burst_1  <= insn_reg[106:85];
      ddr_offset_2  <= 'd0;
      sequ_burst_2  <= 'd0;
      ddr_offset_3  <= 'd0;
      sequ_burst_3  <= 'd0;
      sram_baseaddr <= insn_reg[126:107];
      all_done      <= insn_reg[127];
    end
    else begin
      ddr_baseaddr  <= ddr_baseaddr;
      sequ_burst_0  <= sequ_burst_0;
      sram_baseaddr <= sram_baseaddr;
      ddr_offset_1  <= ddr_offset_1;
      sequ_burst_1  <= sequ_burst_1;
      ddr_offset_2  <= ddr_offset_2;
      sequ_burst_2  <= sequ_burst_2;
      ddr_offset_3  <= ddr_offset_3;
      sequ_burst_3  <= sequ_burst_3;
      all_done      <= insn_reg[127];
    end
  end
end

wire one_burst;
wire one_burst_0;

assign burst_0_done = ((ddr_burst_cnt_0 == 1) & !one_burst_0) | 
                      (one_burst_0 & (ddr_burst_cnt_0 == sequ_burst_0 + 1)) & load_working;
assign burst_1_done = (ddr_burst_cnt_1 == sequ_burst_1) & load_working;
assign burst_2_done = (ddr_burst_cnt_2 == sequ_burst_2) & load_working;
assign burst_3_done = (ddr_burst_cnt_3 == sequ_burst_3) & load_working;
assign burst_done = burst_0_done & burst_1_done & burst_2_done & burst_3_done;
assign one_burst = (!(|sequ_burst_0)) & (!(|sequ_burst_1)) & (!(|sequ_burst_2)) & (!(|sequ_burst_3));
assign one_burst_0 = (!(|sequ_burst_0));

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    request_address   <= 'd0;
    request_length    <= 'd0;
    request_valid     <= 1'b0;
    ddr_burst_cnt_0   <= 'd0;
    ddr_burst_cnt_1   <= 'd0;
    ddr_burst_cnt_2   <= 'd0;
    ddr_burst_cnt_3   <= 'd0;
    ddr_offset_iter_0 <= 'd0;
    ddr_offset_iter_1 <= 'd0;
    ddr_offset_iter_2 <= 'd0;
    ddr_offset_iter_3 <= 'd0;
  end
  else if (execute_done || local_done) begin
    request_address   <= 'd0;
    request_length    <= 'd0;
    request_valid     <= 1'b0;
    ddr_burst_cnt_0   <= 'd0;
    ddr_burst_cnt_1   <= 'd0;
    ddr_burst_cnt_2   <= 'd0;
    ddr_burst_cnt_3   <= 'd0;
    ddr_offset_iter_0 <= 'd0;
    ddr_offset_iter_1 <= 'd0;
    ddr_offset_iter_2 <= 'd0;
    ddr_offset_iter_3 <= 'd0;
  end
  else begin
    if (!burst_done && load_working) begin
      request_address <= ddr_offset_iter_0 + ddr_baseaddr;
      request_length <= sequ_burst_0;
      if (peripheral_M_raddr_ready) begin
        if (burst_2_done && burst_1_done && burst_0_done) begin 
          request_valid     <= 1'b0;
          ddr_offset_iter_3 <= ddr_offset_iter_3 + ddr_offset_3;
          ddr_burst_cnt_3   <= ddr_burst_cnt_3 + 1'b1;
          ddr_offset_iter_2 <= ddr_offset_iter_3 + ddr_offset_3;
          ddr_burst_cnt_2   <= 'd0;
          ddr_offset_iter_1 <= ddr_offset_iter_3 + ddr_offset_3;
          ddr_burst_cnt_1   <= 'd0;
          ddr_offset_iter_0 <= ddr_offset_iter_3 + ddr_offset_3;
          ddr_burst_cnt_0   <= 'd0;
        end
        else if (burst_1_done && burst_0_done) begin 
          request_valid     <= 1'b0;
          ddr_offset_iter_3 <= ddr_offset_iter_3;
          ddr_burst_cnt_3   <= ddr_burst_cnt_3;
          ddr_offset_iter_2 <= ddr_offset_iter_2 + ddr_offset_2;
          ddr_burst_cnt_2   <= ddr_burst_cnt_2 + 1'b1;
          ddr_offset_iter_1 <= ddr_offset_iter_2 + ddr_offset_2;
          ddr_burst_cnt_1   <= 'd0;
          ddr_offset_iter_0 <= ddr_offset_iter_2 + ddr_offset_2;
          ddr_burst_cnt_0   <= 'd0;
        end
        else if (burst_0_done) begin 
          request_valid     <= 1'b0;
          ddr_offset_iter_3 <= ddr_offset_iter_3;
          ddr_burst_cnt_3   <= ddr_burst_cnt_3;
          ddr_offset_iter_2 <= ddr_offset_iter_2;
          ddr_burst_cnt_2   <= ddr_burst_cnt_2;
          ddr_offset_iter_1 <= ddr_offset_iter_1 + ddr_offset_1;
          ddr_burst_cnt_1   <= ddr_burst_cnt_1 + 1'b1;
          ddr_offset_iter_0 <= ddr_offset_iter_1 + ddr_offset_1;
          ddr_burst_cnt_0   <= 'd0;
        end
        else begin 
          request_valid     <= 1'b1;
          ddr_offset_iter_3 <= ddr_offset_iter_3;
          ddr_burst_cnt_3   <= ddr_burst_cnt_3;
          ddr_offset_iter_2 <= ddr_offset_iter_2;
          ddr_burst_cnt_2   <= ddr_burst_cnt_2;
          ddr_offset_iter_1 <= ddr_offset_iter_1;
          ddr_burst_cnt_1   <= ddr_burst_cnt_1;
          ddr_offset_iter_0 <= ddr_offset_iter_0 + ddr_offset_0;
          ddr_burst_cnt_0   <= ddr_burst_cnt_0 + 1'b1;
        end
      end
    end
    else begin
      request_address   <= 'd0;
      request_length    <= 'd0;
      request_valid     <= 'd0;
      ddr_burst_cnt_0   <= ddr_burst_cnt_0;
      ddr_burst_cnt_1   <= ddr_burst_cnt_1;
      ddr_burst_cnt_2   <= ddr_burst_cnt_2;
      ddr_burst_cnt_3   <= ddr_burst_cnt_3;
      ddr_offset_iter_0 <= ddr_offset_iter_0;
      ddr_offset_iter_1 <= ddr_offset_iter_1;
      ddr_offset_iter_2 <= ddr_offset_iter_2;
      ddr_offset_iter_3 <= ddr_offset_iter_3;
    end
  end
end

reg one_burst_0_resp_done;
wire real_sram_en;

assign sram_0_done = ((sram_burst_cnt_0 == sequ_burst_0)) & load_working;
assign sram_1_done = (sram_burst_cnt_1 == sequ_burst_1) & load_working;
assign sram_2_done = (sram_burst_cnt_2 == sequ_burst_2) & load_working;
assign sram_3_done = (sram_burst_cnt_3 == sequ_burst_3) & load_working;
assign sram_done = (sram_0_done & sram_1_done & sram_2_done & sram_3_done & (!one_burst & real_sram_en)) | (one_burst & one_burst_0_resp_done);


assign real_sram_en = write_high_addr == VCUCODE_ID ? (&one_split_four_cnt) :
                      write_high_addr == VCULUT_ID ? (&one_split_four_cnt) : sram_wvalid;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sram_burst_cnt_0 <= 'd0;
    sram_burst_cnt_1 <= 'd0;
    sram_burst_cnt_2 <= 'd0;
    sram_burst_cnt_3 <= 'd0;
    one_burst_0_resp_done <= 1'b0;
  end
  else if (execute_done || local_done) begin
    sram_burst_cnt_0 <= 'd0;
    sram_burst_cnt_1 <= 'd0;
    sram_burst_cnt_2 <= 'd0;
    sram_burst_cnt_3 <= 'd0;
    one_burst_0_resp_done <= 1'b0;
  end
  else begin
    if (real_sram_en) begin
      if (!one_burst_0_resp_done) begin
        one_burst_0_resp_done <= 1'b1;
      end
      else begin
        one_burst_0_resp_done <= 1'b0;
      end
      if (sram_2_done && sram_1_done && sram_0_done) begin
        sram_burst_cnt_3 <= sram_burst_cnt_3 + 1'b1;
        sram_burst_cnt_2 <= 'd0;
        sram_burst_cnt_1 <= 'd0;
        sram_burst_cnt_0 <= 'd0;
      end
      else if (sram_1_done && sram_0_done) begin
        sram_burst_cnt_3 <= sram_burst_cnt_3;
        sram_burst_cnt_2 <= sram_burst_cnt_2 + 1'b1;
        sram_burst_cnt_1 <= 'd0;
        sram_burst_cnt_0 <= 'd0;
      end
      else if (sram_0_done) begin
        sram_burst_cnt_3 <= sram_burst_cnt_3;
        sram_burst_cnt_2 <= sram_burst_cnt_2;
        sram_burst_cnt_1 <= sram_burst_cnt_1 + 1'b1;
        sram_burst_cnt_0 <= 'd0;
      end
      else begin
        sram_burst_cnt_3 <= sram_burst_cnt_3;
        sram_burst_cnt_2 <= sram_burst_cnt_2;
        sram_burst_cnt_1 <= sram_burst_cnt_1;
        sram_burst_cnt_0 <= sram_burst_cnt_0 + 1'b1;
      end
    end
    else begin
      sram_burst_cnt_3 <= sram_burst_cnt_3;
      sram_burst_cnt_2 <= sram_burst_cnt_2;
      sram_burst_cnt_1 <= sram_burst_cnt_1;
      sram_burst_cnt_0 <= sram_burst_cnt_0;
      one_burst_0_resp_done <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    execute_done <= 1'b0;
  end
  else begin
    if (execute_done || local_done) begin
      execute_done <= 1'b0;
    end
    else if (burst_done && sram_done && load_working) begin
      execute_done <= 1'b1;
    end
    else begin
      execute_done <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    insn_number <= 'd0;
  end
  else begin
    if (insn_valid_reg) begin
      insn_number <= |insn_reg[9:6] ? insn_reg[9:6] : insn_number;
    end
    else begin
      if (execute_done && |insn_number) begin
        insn_number <= insn_number - 1;
      end
    end
  end
end

sync_fifo_regfile #(
  .width ( PERI_DATA_WIDTH ),
  .depth ( 4                       )
) u_data_fifo(
  .clk      ( clk                                                  ),
  .rst_n    ( rst_n                                                ),
  .w_en     ( peripheral_M_rdata_valid && peripheral_M_rdata_ready ),
  .w_data   ( peripheral_M_rdata                                   ),
  .r_en     ( local_fifo_ren                                       ),
  .r_data   ( sram_wdata                                           ),
  .hfull    ( data_fifo_hfull                                      ),
  .hempty   (                                                      ),
  .afull    (                                                      ),
  .aempty   (                                                      ),
  .full     (                                                      ),
  .empty    ( data_fifo_empty                                      ),
  .capacity (                                                      )
);

/* -------------------------------------------------------------------------------------------------------- */
/*                                            sram write signals                                            */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    split_block <= 1'b0;
  end
  else if (execute_done || local_done) begin
    split_block <= 1'b0;
  end
  else begin
    if (sram_wvalid) begin
      if ((write_high_addr == VCULUT_ID) || (write_high_addr == VCUCODE_ID))
      split_block <= 1'b1;
    end
    else begin
      if (write_high_addr == VCULUT_ID && (&one_split_four_cnt)) begin
        split_block <= 1'b0;
      end
      else if (write_high_addr == VCUCODE_ID && (&one_split_four_cnt)) begin
        split_block <= 1'b0;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    one_split_four_cnt <= 2'b0;
  end
  else if (execute_done || local_done) begin
    one_split_four_cnt <= 2'b0;
  end
  else begin
    if ((write_high_addr == VCULUT_ID) || (write_high_addr == VCUCODE_ID)) begin
      if (sram_wvalid || split_block) begin
        one_split_four_cnt <= one_split_four_cnt + 1'b1;
      end
      else begin
        one_split_four_cnt <= one_split_four_cnt;
      end
    end
    else begin
      one_split_four_cnt <= 2'b0;
    end
  end
end


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    two_cat_one_cnt <= 1'b0;
  end
  else begin
    if ((write_high_addr == IFMAP_ID) ||
        (write_high_addr == VCUPARA_ID) ||
        (write_high_addr == VCURES_ID)) begin
      if (valid_data_out_288b) begin
        two_cat_one_cnt <= two_cat_one_cnt + 1'b1;
      end
      else begin
        two_cat_one_cnt <= two_cat_one_cnt;
      end
    end
    else begin
      two_cat_one_cnt <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    local_fifo_ren <= 1'b0;
  end
  else if (execute_done || local_done) begin
    local_fifo_ren <= 1'b0;
  end
  else begin
    if (!data_fifo_empty) begin
      if (write_high_addr == VCUCODE_ID) begin
        if (!local_fifo_ren) begin
          if ((!split_block) && (!(|one_split_four_cnt)) || (split_block && (&one_split_four_cnt))) begin
            local_fifo_ren <= 1'b1;
          end
          else begin
            local_fifo_ren <= 1'b0;
          end
        end
        else begin
          local_fifo_ren <= 1'b0;
        end
      end
      else begin
        local_fifo_ren <= 1'b1;
      end
    end
    else begin
      local_fifo_ren <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sram_wdata_reg <= 'd0;
  end
  else begin
    if (sram_wvalid) begin
      sram_wdata_reg <= sram_wdata;
    end
    else begin
      sram_wdata_reg <= sram_wdata_reg;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sram_addr <= 'd0;
  end
  else begin
    if (load_start) begin
      sram_addr <= sram_baseaddr;
    end
    else if (sram_wvalid && !need_256_to_288_conversion) begin
      sram_addr <= sram_addr + 1;
    end
    else if (valid_data_out_288b && need_256_to_288_conversion) begin
      sram_addr <= sram_addr + 1;
    end
    else begin
      sram_addr <= sram_addr;
    end
  end
end

assign need_256_to_288_conversion = (write_high_addr == IFMAP_ID) || (write_high_addr == VCUPARA_ID) || (write_high_addr == VCURES_ID ) || (write_high_addr == QACT_ID) || (write_high_addr == WEIGHT_ID);

// assign need_256_to_288_conversion = (write_high_addr == QACT_ID) || (write_high_addr == WEIGHT_ID);

gearbox_256_to_288 u_cb_pp_256_to_288(
  .clk              (clk                                      ),
  .rst_n            (rst_n                                    ),
  .restart          (1'b0                                     ),
    
  .valid_data_in    (sram_wvalid && need_256_to_288_conversion),
  .data_in          (sram_wdata                               ),

  .valid_data_out   (valid_data_out_288b                      ),
  .data_out         (data_out_288b                            )
);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_wvalid <= 1'b0;
    ifmap_waddr  <= 'd0;
    ifmap_wdata  <= 'd0;
  end
  else begin
    if (write_high_addr == IFMAP_ID) begin
      if (valid_data_out_288b) begin
        case(two_cat_one_cnt)
          1'b0: begin
            ifmap_wvalid <= 1'b0;
            ifmap_waddr  <= sram_addr[IFMAP_ADDR_BITS:1];
            ifmap_wdata  <= {data_out_288b, 288'd0};
          end
          1'b1: begin
            ifmap_wvalid <= 1'b1;
            ifmap_waddr  <= sram_addr[IFMAP_ADDR_BITS:1];
            ifmap_wdata  <= {data_out_288b, ifmap_wdata[575:288]};
          end
        endcase
      end
      else begin
        ifmap_wvalid <= 1'b0;
        ifmap_waddr  <= ifmap_waddr;
        ifmap_wdata  <= ifmap_wdata;
      end
    end
    else begin
      ifmap_wvalid <= 1'b0;
      ifmap_waddr  <= 'd0;
      ifmap_wdata  <= 'd0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    qact_wvalid <= 1'b0;
    qact_waddr  <= 'd0;
    qact_wdata  <= 'd0;
  end
  else begin
    if (write_high_addr == QACT_ID) begin
      if (valid_data_out_288b) begin
        qact_wvalid <= 1'b1;
        qact_waddr  <= sram_addr[QACT_ADDR_BITS-1:0];
        qact_wdata  <= data_out_288b;
      end
      else begin
        qact_wvalid <= 1'b0;
        qact_waddr  <= qact_waddr;
        qact_wdata  <= qact_wdata;
      end
    end
    else begin
      qact_wvalid <= 1'b0;
      qact_waddr  <= 'd0;
      qact_wdata  <= 'd0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_wvalid <= 1'b0;
    weight_wdata  <= 'd0;
  end
  else begin
    if (write_high_addr == WEIGHT_ID) begin
      if (valid_data_out_288b) begin
        weight_wvalid <= 1'b1;
        weight_wdata  <= data_out_288b;
      end
      else begin
        weight_wvalid <= 1'b0;
        weight_wdata  <= weight_wdata;
      end
    end
    else begin
      weight_wvalid <= 1'b0;
      weight_wdata  <= 'd0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcucode_wvalid <= 1'b0;
    vcucode_waddr  <= 'd0;
    vcucode_wdata  <= 'd0;
  end
  else begin
    if (write_high_addr == VCUCODE_ID) begin
      if (sram_wvalid || split_block) begin
        case(one_split_four_cnt) 
          2'b00: begin
            vcucode_wvalid <= 1'b1;
            vcucode_waddr  <= {sram_addr[VCUCODE_ADDR_BITS-2:0], 2'b00};
            vcucode_wdata  <= sram_wdata[VCUCODE_WIDTH-1:0];
          end
          2'b01: begin
            vcucode_wvalid <= 1'b1;
            vcucode_waddr  <= vcucode_waddr + 1;
            vcucode_wdata  <= sram_wdata_reg[2*VCUCODE_WIDTH-1:VCUCODE_WIDTH];
          end
          2'b10: begin
            vcucode_wvalid <= 1'b1;
            vcucode_waddr  <= vcucode_waddr + 1;
            vcucode_wdata  <= sram_wdata_reg[3*VCUCODE_WIDTH-1:2*VCUCODE_WIDTH];
          end
          2'b11: begin
            vcucode_wvalid <= 1'b1;
            vcucode_waddr  <= vcucode_waddr + 1;
            vcucode_wdata  <= sram_wdata_reg[4*VCUCODE_WIDTH-1:3*VCUCODE_WIDTH];
          end
        endcase
      end
      else begin
        vcucode_wvalid <= 1'b0;
        vcucode_waddr  <= vcucode_waddr;
        vcucode_wdata  <= vcucode_wdata;
      end
    end
    else begin
      vcucode_wvalid <= 1'b0;
      vcucode_waddr  <= 'd0;
      vcucode_wdata  <= 'd0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcures_wvalid <= 1'b0;
    vcures_waddr  <= 'd0;
    vcures_wdata  <= 'd0;
  end
  else begin
    if (write_high_addr == VCURES_ID) begin
      if (valid_data_out_288b) begin
        case(two_cat_one_cnt)
          1'b0: begin
            vcures_wvalid <= 1'b0;
            vcures_waddr  <= sram_addr[VCURES_ADDR_BITS:1];
            vcures_wdata  <= {data_out_288b, 288'd0};
          end
          1'b1: begin
            vcures_wvalid <= 1'b1;
            vcures_waddr  <= sram_addr[VCURES_ADDR_BITS:1];
            vcures_wdata  <= {data_out_288b, vcures_wdata[575:288]};
          end
        endcase
      end
      else begin
        vcures_wvalid <= 1'b0;
        vcures_waddr  <= vcures_waddr;
        vcures_wdata  <= vcures_wdata;
      end
    end
    else begin
      vcures_wvalid <= 1'b0;
      vcures_waddr  <= 'd0;
      vcures_wdata  <= 'd0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcupara_wvalid <= 1'b0;
    vcupara_waddr  <= 'd0;
    vcupara_wdata  <= 'd0;
  end
  else begin
    if (write_high_addr == VCUPARA_ID) begin
      if (valid_data_out_288b) begin
        case(two_cat_one_cnt)
          1'b0: begin
            vcupara_wvalid <= 1'b0;
            vcupara_waddr  <= sram_addr[VCUPARA_ADDR_BITS:1];
            vcupara_wdata  <= {data_out_288b, 288'd0};
          end
          1'b1: begin
            vcupara_wvalid <= 1'b1;
            vcupara_waddr  <= sram_addr[VCUPARA_ADDR_BITS:1];
            vcupara_wdata  <= {data_out_288b, vcupara_wdata[575:288]};
          end
        endcase
      end
      else begin
        vcupara_wvalid <= 1'b0;
        vcupara_waddr  <= vcupara_waddr;
        vcupara_wdata  <= vcupara_wdata;
      end
    end
    else begin
      vcupara_wvalid <= 1'b0;
      vcupara_waddr  <= 'd0;
      vcupara_wdata  <= 'd0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    regfile_wvalid <= 1'b0;
    regfile_waddr  <= 'd0;
    regfile_wdata  <= 'd0;
  end
  else begin
    if (write_high_addr == REGFILE_ID) begin
      if (sram_wvalid) begin
        regfile_wvalid <= 1'b1;
        regfile_waddr  <= {25'd0, sram_addr[10:5]};
        regfile_wdata  <= sram_wdata[31:0];
      end
      else begin
        regfile_wvalid <= 1'b0;
        regfile_waddr  <= regfile_waddr;
        regfile_wdata  <= regfile_wdata;
      end
    end
    else begin
      regfile_wvalid <= 1'b0;
      regfile_waddr  <= 'd0;
      regfile_wdata  <= 'd0;
    end
  end
end
endmodule

module store_insn_dma_1(
  clk, rst_n,
  work_en, insn, insn_read,
  local_done, global_done, 
  peripheral_M_waddr, peripheral_M_wlen, peripheral_M_waddr_valid, peripheral_M_waddr_ready, 
  peripheral_M_wdata, peripheral_M_wdata_valid, peripheral_M_wdata_ready, 
  peripheral_M_bready, axi_aw_handshake, axi_transfer_done,

  ofmap_rvalid, ofmap_raddr, ofmap_rdata
);

parameter integer STORE_INSNBITS = 128;

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

localparam integer STORE_INSN_OPCODE_ID = 2;
localparam integer STORE_ITERATION_4_INSN_ID = 0;
localparam integer STORE_ITERATION_3_INSN_ID = 1;
localparam integer STORE_ITERATION_2_INSN_ID = 2;

localparam integer STORE_INSN_OPCODE_ID_BITS = 5;
localparam integer STORE_INCREMENT_INSN_ID_BITS = 2;

parameter PSUM_WIDTH      = 1024;
parameter OFMAP_WIDTH     = 256;

parameter PSUM_ADDR_BITS  = 12;
parameter OFMAP_ADDR_BITS = 12;

input                                clk;
input                                rst_n;
input                                work_en;
output reg                           insn_read;
input       [STORE_INSNBITS-1:0]     insn;
output reg                           local_done;
output reg                           global_done;
output wire [PERI_ADDR_WIDTH-1:0]    peripheral_M_waddr;
output wire [PERI_BUSRSTS_WIDTH-1:0] peripheral_M_wlen;
output wire                          peripheral_M_waddr_valid;
input                                peripheral_M_waddr_ready;
output wire [PERI_DATA_WIDTH-1:0]    peripheral_M_wdata;
output wire                          peripheral_M_wdata_valid;
input                                peripheral_M_wdata_ready;
input                                peripheral_M_bready;
input                                axi_aw_handshake;
input                                axi_transfer_done;

output reg                            ofmap_rvalid;
output reg  [OFMAP_ADDR_BITS-1:0]     ofmap_raddr;
input       [OFMAP_WIDTH-1:0]         ofmap_rdata;

reg                                    insn_valid;
reg                                    store_start;
reg [STORE_INSN_OPCODE_ID_BITS-1:0]    store_insn_opcode;
reg [STORE_INCREMENT_INSN_ID_BITS-1:0] store_insns;
reg [PERI_ADDR_WIDTH-1:0]              ddr_baseaddr;
reg [21:0]                             sequ_burst_0;
reg [SRAM_ADDR_WIDTH-1:0]              sram_baseaddr;
reg [21:0]                             sequ_burst_1;
reg [10:0]                             sequ_burst_2;
reg [3:0]                              sequ_burst_3;
reg                                    all_done;

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

reg [PERI_ADDR_WIDTH-1:0]    request_address;
reg [PERI_BUSRSTS_WIDTH-1:0] request_length;
reg                          request_valid;

assign peripheral_M_waddr       = request_address;
assign peripheral_M_wlen        = request_length;
assign peripheral_M_waddr_valid = request_valid;

reg [4:0] insn_number;
reg [31:0] write_burst_cnt_0;
reg [31:0] write_burst_cnt_1;
reg [31:0] write_burst_cnt_2;
reg [31:0] write_burst_cnt_3;

wire write_burst_done_0;
wire write_burst_done_1;
wire write_burst_done_2;
wire write_burst_done_3;
wire write_burst_done;

reg [31:0] sram_read_cnt_0;
reg [31:0] sram_read_cnt_1;
reg [31:0] sram_read_cnt_2;
reg [31:0] sram_read_cnt_3;

wire sram_read_done_0;
wire sram_read_done_1;
wire sram_read_done_2;
wire sram_read_done_3;
wire sram_read_done;

reg  store_working;
reg  execute_done;
reg  write_execute_done;
reg  write_burst_done_level;
wire data_fifo_hfull;
wire data_fifo_empty;
reg  first_write;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    global_done <= 1'b0;
    local_done  <= 1'b0;
  end
  else begin
    if (execute_done && (~(|insn_number))) begin
      local_done <= 1'b1;
    end
    else begin
      local_done <= 1'b0;
    end

    if (execute_done && (~(|insn_number)) && all_done) begin
      global_done <= 1'b1;
    end
    else begin
      global_done <= 1'b0;
    end
  end
end

reg  [SRAM_ADDR_WIDTH-1:0] sram_addr;
wire                       sram_en;
reg                        sram_valid_delay;
reg                        sram_valid_delay_1;
reg                        local_fifo_wen;
reg  [PERI_DATA_WIDTH-1:0] local_fifo_wdata;

assign sram_raddr = sram_addr;
assign sram_rvalid = sram_en;

assign peripheral_M_wdata_valid = !data_fifo_empty;

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    insn_valid <= 1'b0;
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
    insn_reg <= 128'b0;
  end
  else begin
    if (insn_valid) begin
      insn_valid_reg <= 1'b1;
      insn_reg <= insn;
    end
    else begin
      insn_valid_reg <= 1'b0;
      insn_reg <= insn_reg;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    store_start       <= 1'b0;
    store_working     <= 1'b0;
    store_insn_opcode <= STORE_INSN_OPCODE_ID;
    ddr_baseaddr      <= 'd0;
    ddr_offset_0      <= PERI_DATA_BYTES;
    sequ_burst_0      <= 'd0;
    sram_baseaddr     <= 'd0;
    ddr_offset_1      <= 'd0;
    sequ_burst_1      <= 'd0;
    ddr_offset_2      <= 'd0;
    sequ_burst_2      <= 'd0;
    ddr_offset_3      <= 'd0;
    sequ_burst_3      <= 'd0;
    all_done          <= 1'b0;
    first_write        <= 1'b0;
  end
  else if (execute_done || local_done) begin
    store_start       <= 1'b0;
    store_working     <= 1'b0;
    store_insn_opcode <= STORE_INSN_OPCODE_ID;
    ddr_baseaddr      <= 'd0;
    ddr_offset_0      <= PERI_DATA_BYTES;
    sequ_burst_0      <= 'd0;
    sram_baseaddr     <= 'd0;
    ddr_offset_1      <= 'd0;
    sequ_burst_1      <= 'd0;
    ddr_offset_2      <= 'd0;
    sequ_burst_2      <= 'd0;
    ddr_offset_3      <= 'd0;
    sequ_burst_3      <= 'd0;
    all_done          <= 1'b0;
    first_write       <= 1'b0;
  end 
  else begin

    if (!first_write && axi_aw_handshake) begin
      first_write <= 1'b1;
    end
    else if (execute_done || local_done) begin
      first_write <= 1'b0;
    end

    ddr_offset_0 <= ddr_offset_0;

    if (insn_valid_reg) begin
      store_insn_opcode <= insn_reg[5:0];
      store_start <= 1'b1;
    end
    else begin
      store_insn_opcode <= store_insn_opcode;
      store_start <= 1'b0;
    end

    if (store_start) begin
      store_working  <= 1'b1;
    end
    else begin
      store_working  <= store_working;
    end

    if (insn_valid_reg && (insn_reg[11:10] == STORE_ITERATION_4_INSN_ID)) begin
      ddr_baseaddr  <= insn_reg[49:12];
      sequ_burst_0  <= insn_reg[58:50];
      ddr_offset_1  <= (insn_reg[69:62] << insn_reg[61:59]);
      sequ_burst_1  <= insn_reg[74:70];
      ddr_offset_2  <= (insn_reg[86:79] << insn_reg[78:75]);
      sequ_burst_2  <= insn_reg[90:87];
      ddr_offset_3  <= (insn_reg[103:96] << insn_reg[95:91]);
      sequ_burst_3  <= insn_reg[106:104];
      sram_baseaddr <= insn_reg[126:107];
      all_done      <= insn_reg[127];
    end
    else if (insn_valid_reg && (insn_reg[11:10] == STORE_ITERATION_3_INSN_ID)) begin
      ddr_baseaddr <= insn_reg[49:12];
      sequ_burst_0 <= insn_reg[60:50];
      ddr_offset_1 <= (insn_reg[73:66] << insn_reg[65:61]);
      sequ_burst_1 <= insn_reg[83:74];
      ddr_offset_2 <= (insn_reg[96:89] << insn_reg[88:84]);
      sequ_burst_2 <= insn_reg[106:97];
      ddr_offset_3 <= 'd0;
      sequ_burst_3 <= 'd0;
      sram_baseaddr <= insn_reg[126:107];
      all_done <= insn_reg[127];
    end
    else if (insn_valid_reg && (insn_reg[11:10] == STORE_ITERATION_2_INSN_ID)) begin
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
      all_done      <= all_done;
    end
  end
end

wire one_burst;
wire one_burst_0;

assign burst_0_done = ((ddr_burst_cnt_0 == 1) & !one_burst_0) | 
                      (one_burst_0 & (ddr_burst_cnt_0 == sequ_burst_0 + 1)) & store_working;
assign burst_1_done = (ddr_burst_cnt_1 == sequ_burst_1) & store_working;
assign burst_2_done = (ddr_burst_cnt_2 == sequ_burst_2) & store_working;
assign burst_3_done = (ddr_burst_cnt_3 == sequ_burst_3) & store_working;
assign burst_done = burst_0_done & burst_1_done & burst_2_done & burst_3_done;
assign one_burst = (!(|sequ_burst_0)) & (!(|sequ_burst_1)) & (!(|sequ_burst_2)) & (!(|sequ_burst_3));
assign one_burst_0 = (!(|sequ_burst_0));

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    request_address <= 'd0;
    request_length <= 'd0;
    request_valid <= 1'b0;
    ddr_burst_cnt_0 <= 'd0;
    ddr_burst_cnt_1 <= 'd0;
    ddr_burst_cnt_2 <= 'd0;
    ddr_burst_cnt_3 <= 'd0;
    ddr_offset_iter_0 <= 'd0;
    ddr_offset_iter_1 <= 'd0;
    ddr_offset_iter_2 <= 'd0;
    ddr_offset_iter_3 <= 'd0;
  end
  else if (execute_done || local_done) begin
    request_address   <= ddr_baseaddr;
    request_length    <= sequ_burst_0;
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

    request_address <= ddr_offset_iter_0 + ddr_baseaddr;
    request_length <= sequ_burst_0;
    if (!burst_done && store_working) begin
      if (peripheral_M_waddr_ready) begin
        if (burst_2_done && burst_1_done && burst_0_done) begin 
          request_valid <= 1'b0;
          ddr_offset_iter_3 <= ddr_offset_iter_3 + ddr_offset_3;
          ddr_burst_cnt_3 <= ddr_burst_cnt_3 + 1'b1;
          ddr_offset_iter_2 <= ddr_offset_iter_3 + ddr_offset_3;
          ddr_burst_cnt_2 <= 'd0;
          ddr_offset_iter_1 <= ddr_offset_iter_3 + ddr_offset_3;
          ddr_burst_cnt_1 <= 'd0;
          ddr_offset_iter_0 <= ddr_offset_iter_3 + ddr_offset_3;
          ddr_burst_cnt_0 <= 'd0;
        end
        else if (burst_1_done && burst_0_done) begin 
          request_valid <= 1'b0;
          ddr_offset_iter_3 <= ddr_offset_iter_3;
          ddr_burst_cnt_3 <= ddr_burst_cnt_3;
          ddr_offset_iter_2 <= ddr_offset_iter_2 + ddr_offset_2;
          ddr_burst_cnt_2 <= ddr_burst_cnt_2 + 1'b1;
          ddr_offset_iter_1 <= ddr_offset_iter_2 + ddr_offset_2;
          ddr_burst_cnt_1 <= 'd0;
          ddr_offset_iter_0 <= ddr_offset_iter_2 + ddr_offset_2;
          ddr_burst_cnt_0 <= 'd0;
        end
        else if (burst_0_done) begin 
          request_valid <= 1'b0;
          ddr_offset_iter_3 <= ddr_offset_iter_3;
          ddr_burst_cnt_3 <= ddr_burst_cnt_3;
          ddr_offset_iter_2 <= ddr_offset_iter_2;
          ddr_burst_cnt_2 <= ddr_burst_cnt_2;
          ddr_offset_iter_1 <= ddr_offset_iter_1 + ddr_offset_1;
          ddr_burst_cnt_1 <= ddr_burst_cnt_1 + 1'b1;
          ddr_offset_iter_0 <= ddr_offset_iter_1 + ddr_offset_1;
          ddr_burst_cnt_0 <= 'd0;
        end
        else begin 
          request_valid <= 1'b1;
          ddr_offset_iter_3 <= ddr_offset_iter_3;
          ddr_burst_cnt_3 <= ddr_burst_cnt_3;
          ddr_offset_iter_2 <= ddr_offset_iter_2;
          ddr_burst_cnt_2 <= ddr_burst_cnt_2;
          ddr_offset_iter_1 <= ddr_offset_iter_1;
          ddr_burst_cnt_1 <= ddr_burst_cnt_1;
          ddr_offset_iter_0 <= ddr_offset_iter_0 + ddr_offset_0;
          ddr_burst_cnt_0 <= ddr_burst_cnt_0 + 1'b1;
        end
      end
    end
    else begin
      request_valid <= 'd0;
      ddr_burst_cnt_0 <= ddr_burst_cnt_0;
      ddr_burst_cnt_1 <= ddr_burst_cnt_1;
      ddr_burst_cnt_2 <= ddr_burst_cnt_2;
      ddr_burst_cnt_3 <= ddr_burst_cnt_3;
      ddr_offset_iter_0 <= ddr_offset_iter_0;
      ddr_offset_iter_1 <= ddr_offset_iter_1;
      ddr_offset_iter_2 <= ddr_offset_iter_2;
      ddr_offset_iter_3 <= ddr_offset_iter_3;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    write_burst_cnt_0 <= 'd0;
    write_burst_cnt_1 <= 'd0;
    write_burst_cnt_2 <= 'd0;
    write_burst_cnt_3 <= 'd0;
  end
  else if (execute_done || local_done) begin
    write_burst_cnt_0 <= 'd0;
    write_burst_cnt_1 <= 'd0;
    write_burst_cnt_2 <= 'd0;
    write_burst_cnt_3 <= 'd0;
  end
  else begin
    if (peripheral_M_wdata_valid && peripheral_M_wdata_ready && !write_burst_done) begin
        if (write_burst_done_0 && write_burst_done_1 && write_burst_done_2) begin
          write_burst_cnt_3 <= write_burst_cnt_3 + 1'b1;
          write_burst_cnt_2 <= 'd0;
          write_burst_cnt_1 <= 'd0;
          write_burst_cnt_0 <= 'd0;
        end
        else if (write_burst_done_0 && write_burst_done_1) begin
          write_burst_cnt_3 <= write_burst_cnt_3;
          write_burst_cnt_2 <= write_burst_cnt_2 + 1'b1;
          write_burst_cnt_1 <= 'd0;
          write_burst_cnt_0 <= 'd0;
        end
        else if (write_burst_done_0) begin
          write_burst_cnt_3 <= write_burst_cnt_3;
          write_burst_cnt_2 <= write_burst_cnt_2;
          write_burst_cnt_1 <= write_burst_cnt_1 + 1'b1;
          write_burst_cnt_0 <= 'd0;
        end
        else begin
          write_burst_cnt_3 <= write_burst_cnt_3;
          write_burst_cnt_2 <= write_burst_cnt_2;
          write_burst_cnt_1 <= write_burst_cnt_1;
          write_burst_cnt_0 <= write_burst_cnt_0 + 1'b1;
        end
    end
  end
end

assign write_burst_done_0 = (write_burst_cnt_0 == sequ_burst_0) & store_working & peripheral_M_wdata_ready;
assign write_burst_done_1 = (write_burst_cnt_1 == sequ_burst_1) & store_working;
assign write_burst_done_2 = (write_burst_cnt_2 == sequ_burst_2) & store_working;
assign write_burst_done_3 = (write_burst_cnt_3 == sequ_burst_3) & store_working;
assign write_burst_done = (write_burst_done_0 & write_burst_done_1 & write_burst_done_2 & write_burst_done_3 & (!one_burst)) | (one_burst & sram_valid_delay) & store_working;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    write_burst_done_level <= 1'b0;
  end
  else if (execute_done || local_done) begin
    write_burst_done_level <= 1'b0;
  end
  else begin
    if (write_burst_done) begin
      write_burst_done_level <= 1'b1;
    end
    else begin
      write_burst_done_level <= write_burst_done_level;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sram_read_cnt_0 <= 'd0;
    sram_read_cnt_1 <= 'd0;
    sram_read_cnt_2 <= 'd0;
    sram_read_cnt_3 <= 'd0;
  end
  else if (execute_done || local_done) begin
    sram_read_cnt_0 <= 'd0;
    sram_read_cnt_1 <= 'd0;
    sram_read_cnt_2 <= 'd0;
    sram_read_cnt_3 <= 'd0;
  end
  else begin
    if (sram_rvalid && !sram_read_done) begin
        if (sram_read_done_0 && sram_read_done_1 && sram_read_done_2) begin
          sram_read_cnt_3 <= sram_read_cnt_3 + 1'b1;
          sram_read_cnt_2 <= 'd0;
          sram_read_cnt_1 <= 'd0;
          sram_read_cnt_0 <= 'd0;
        end
        else if (sram_read_done_0 && sram_read_done_1) begin
          sram_read_cnt_3 <= sram_read_cnt_3;
          sram_read_cnt_2 <= sram_read_cnt_2 + 1'b1;
          sram_read_cnt_1 <= 'd0;
          sram_read_cnt_0 <= 'd0;
        end
        else if (sram_read_done_0) begin
          sram_read_cnt_3 <= sram_read_cnt_3;
          sram_read_cnt_2 <= sram_read_cnt_2;
          sram_read_cnt_1 <= sram_read_cnt_1 + 1'b1;
          sram_read_cnt_0 <= 'd0;
        end
        else begin
          sram_read_cnt_3 <= sram_read_cnt_3;
          sram_read_cnt_2 <= sram_read_cnt_2;
          sram_read_cnt_1 <= sram_read_cnt_1;
          sram_read_cnt_0 <= sram_read_cnt_0 + 1'b1;
        end
    end
  end
end

assign sram_read_done_0 = (sram_read_cnt_0 == sequ_burst_0) & store_working & sram_rvalid;
assign sram_read_done_1 = (sram_read_cnt_1 == sequ_burst_1) & store_working;
assign sram_read_done_2 = (sram_read_cnt_2 == sequ_burst_2) & store_working;
assign sram_read_done_3 = (sram_read_cnt_3 == sequ_burst_3) & store_working;
assign sram_read_done = (sram_read_done_0 & sram_read_done_1 & sram_read_done_2 & sram_read_done_3 & (!one_burst)) | (one_burst & sram_rvalid) & store_working;

reg sram_done_level;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sram_done_level <= 1'b0;
  end
  else if (execute_done || local_done) begin
    sram_done_level <= 1'b0;
  end
  else begin
    if (sram_read_done) begin
      sram_done_level <= 1'b1;
    end
    else begin
      sram_done_level <= sram_done_level;
    end
  end
end

assign sram_en = store_working & (!write_burst_done) & (!write_burst_done_level) & (!sram_done_level) & (!data_fifo_hfull);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sram_valid_delay <= 1'b0;
    sram_valid_delay_1 <= 1'b0;
  end
  else begin
    if (sram_en) begin
      sram_valid_delay <= 1'b1;
    end
    else begin
      sram_valid_delay <= 1'b0;
    end

    if (sram_valid_delay) begin
      sram_valid_delay_1 <= 1'b1;
    end
    else begin
      sram_valid_delay_1 <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sram_addr <= 'd0;
  end
  else begin
    if (store_start) begin
      sram_addr <= sram_baseaddr;
    end
    else if (sram_en) begin
      sram_addr <= sram_addr + 1;
    end
    else begin
      sram_addr <= sram_addr;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    execute_done       <= 1'b0;
    write_execute_done <= 1'b0;
  end
  else if (execute_done || local_done) begin
    execute_done       <= 1'b0;
    write_execute_done <= 1'b0;
  end
  else begin
    if (burst_done && (write_burst_done_level || write_burst_done) && store_working) begin
      write_execute_done <= 1'b1;
    end
    else begin
      write_execute_done <= 1'b0;
    end

    if (burst_done && (write_burst_done_level || write_burst_done) && store_working && first_write && axi_transfer_done) begin
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
      insn_number <= (~(|insn_reg[9:6])) ? insn_reg[9:6] : insn_number;
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
  .depth ( 16               )
) u_data_fifo(
  .clk      ( clk                                                  ),
  .rst_n    ( rst_n                                                ),
  .w_en     ( local_fifo_wen                                       ),
  .w_data   ( local_fifo_wdata                                     ),
  .r_en     ( peripheral_M_wdata_valid && peripheral_M_wdata_ready ),
  .r_data   ( peripheral_M_wdata                                   ),
  .hfull    ( data_fifo_hfull                                      ),
  .hempty   (                                                      ),
  .afull    (                                                      ),
  .aempty   (                                                      ),
  .full     (                                                      ),
  .empty    ( data_fifo_empty                                      ),
  .capacity (                                                      )
);

/* -------------------------------------------------------------------------------------------------------- */
/*                                                 sram read                                                */
/* -------------------------------------------------------------------------------------------------------- */

localparam PSUM_ID          = 4'b0110;
localparam OFMAP_ID         = 4'b0111;

wire [3:0] read_high_addr;
assign read_high_addr = sram_addr[19:16];

reg                   ofmap_data_valid;
reg [OFMAP_WIDTH-1:0] ofmap_local_data;
reg [OFMAP_WIDTH-1:0] ofmap_local_data_delay;


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    local_fifo_wen   <= 1'b0;
  end
  else begin
    if (read_high_addr == OFMAP_ID) begin
      if (ofmap_data_valid) begin
        local_fifo_wen <= 1'b1;
      end
      else begin
        local_fifo_wen <= 1'b0;
      end
    end
    else begin
      local_fifo_wen <= 1'b0;
    end
  end
end

always @(*) begin
  if (sram_rvalid) begin
    if (read_high_addr == OFMAP_ID) begin
      ofmap_rvalid = 1'b1;
      ofmap_raddr  = sram_addr[OFMAP_ADDR_BITS-1:0];
    end
    else begin
      ofmap_rvalid = 1'b0;
      ofmap_raddr  = 'd0;
    end
  end
  else begin
    ofmap_rvalid = 1'b0;
    ofmap_raddr  = 'd0;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ofmap_data_valid <= 1'b0;
    ofmap_local_data <= 'd0;
    ofmap_local_data_delay <= 'd0;
  end
  else begin
    if (sram_valid_delay_1 && read_high_addr == OFMAP_ID) begin
      ofmap_data_valid <= 1'b1;
      ofmap_local_data <= ofmap_rdata;
    end
    else begin
      ofmap_data_valid <= 1'b0;
      ofmap_local_data <= ofmap_local_data;
    end

    ofmap_local_data_delay <= ofmap_local_data;
  end
end

always @(*) begin
  if (read_high_addr == OFMAP_ID) begin
    local_fifo_wdata = ofmap_local_data_delay;
  end
  else begin
    local_fifo_wdata = 'd0;
  end
end

endmodule


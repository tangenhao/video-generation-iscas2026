module synchronize (
  clk, rst_n, 
  cmd_start,
  sync_insn_ready, sync_insn, sync_insn_read,
  collect_insn_ready, collect_worken, collect_done,
 
  load_highaddr_sync, load_highaddr_sel,
  store_highaddr_sync, store_highaddr_sel,

  word_cnt_debug, done_reg_debug, word_reg_debug
);

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction 

parameter integer SYNCHRONIZE_INSNBITS   = 128;
parameter integer SYNCHRONIZE_FIFO_DEPTH = 128;
parameter integer HIGHADDR_BITS          = 24;
parameter integer REG_WIDTH              = 32;
parameter integer NEXT_WORD_BITS         = 8;

localparam integer word_bits         = 32;
localparam integer word_num          = 3;
localparam integer word_num_bits     = clogb2(word_num - 1);
localparam integer word_in_insn_bits = word_bits * word_num;

localparam integer SYNCHRONIZE_FIFO_ADDR_WIDTH = clogb2(SYNCHRONIZE_FIFO_DEPTH - 1);
// [cross_die_store_config, cross_die_load_config, store_highaddr, store_highaddr_sel, load_highaddr_local, load_highaddr_sel, sync_word] = 1 + 1 + 24 + 1 + 24 + 1 + 32 = 84
localparam integer SYNCHRONIZE_FIFO_WIDTH      = HIGHADDR_BITS + 1 + HIGHADDR_BITS + 1 + word_bits + 1 + 1;
localparam integer SYNCHRONIZE_FIFO_WIDTH_BITS = clogb2(SYNCHRONIZE_FIFO_WIDTH - 1);
localparam integer SYNCHRONIZE_FIFO_WIDTH_PAD  = 1 << SYNCHRONIZE_FIFO_WIDTH_BITS;

localparam integer SYNCHRONIZE_INSN_OPCODE_ID      = 31;
localparam integer SYNCHRONIZE_INDIE_INSN_ID       = 0;
localparam integer SYNCHRONIZE_CROSS_LOAD_INSN_ID  = 1;
localparam integer SYNCHRONIZE_CROSS_STORE_INSN_ID = 2;

input                                  clk;
input                                  rst_n;
input                                  cmd_start;
input                                  sync_insn_ready;
input       [SYNCHRONIZE_INSNBITS-1:0] sync_insn;
output wire                            sync_insn_read;
input       [word_bits-1:0]            collect_insn_ready;
output wire [word_bits-1:0]            collect_worken;
input       [word_bits-1:0]            collect_done;

output wire [HIGHADDR_BITS-1:0]        load_highaddr_sync;
output wire                            load_highaddr_sel;
output wire [HIGHADDR_BITS-1:0]        store_highaddr_sync;
output wire                            store_highaddr_sel;

output wire [word_bits-1:0]            word_cnt_debug;
output wire [word_bits-1:0]            done_reg_debug;
output wire [word_bits-1:0]            word_reg_debug;

reg sync_insn_valid;
reg sync_insn_read_reg;

reg [word_in_insn_bits-1:0] word_buffer;
reg [word_num_bits-1:0]     word_cnt;
reg                         word_buffer_valid;

reg                     load_highaddr_config;
reg                     store_highaddr_config;
reg [HIGHADDR_BITS-1:0] load_highaddr;
reg [HIGHADDR_BITS-1:0] store_highaddr;

assign sync_insn_read = sync_insn_read_reg;

reg                                   local_fifo_wen;
reg                                   local_fifo_ren;
reg                                   local_fifo_ren_delay;
reg  [SYNCHRONIZE_FIFO_WIDTH_PAD-1:0] local_fifo_wdata;
wire [SYNCHRONIZE_FIFO_WIDTH_PAD-1:0] local_fifo_rdata;
wire                                  local_fifo_hfull;
wire                                  local_fifo_hempty;
wire                                  local_fifo_afull;
wire                                  local_fifo_aempty;
wire                                  local_fifo_full;
wire                                  local_fifo_empty;
wire [SYNCHRONIZE_FIFO_ADDR_WIDTH:0]  local_fifo_capacity;

reg                  watch_flag;
reg  [word_bits-1:0] word_reg;
reg  [word_bits-1:0] enable_reg;
reg  [word_bits-1:0] done_reg;
wire                 watch_done;
wire [word_bits-1:0] inner_collect_work_en;

assign inner_collect_work_en = ((word_reg & collect_insn_ready) == word_reg) ? enable_reg : 'd0;
assign watch_done            = ((word_reg & done_reg) == word_reg) & (| word_reg);
assign collect_worken        = (inner_collect_work_en);

wire [word_bits-1:0]     word_wire;
wire                     load_highaddr_sel_wire;
wire [HIGHADDR_BITS-1:0] load_highaddr_wire;
wire                     store_highaddr_sel_wire;
wire [HIGHADDR_BITS-1:0] store_highaddr_wire;
wire                     cross_die_load_config_wire;
wire                     cross_die_store_config_wire;

reg [HIGHADDR_BITS-1:0] load_highaddr_sync_reg;
reg                     load_highaddr_sel_reg;
reg [HIGHADDR_BITS-1:0] store_highaddr_sync_reg;
reg                     store_highaddr_sel_reg;

assign load_highaddr_sync    = load_highaddr_sync_reg;
assign load_highaddr_sel     = load_highaddr_sel_reg;
assign store_highaddr_sync   = store_highaddr_sync_reg;
assign store_highaddr_sel    = store_highaddr_sel_reg;

reg cross_die_load_config;
reg cross_die_store_config;

reg set_local_execute_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sync_insn_read_reg <= 1'b0;
    sync_insn_valid <= 1'b0;
  end
  else begin
    if (cmd_start && (!sync_insn_read_reg) && (!sync_insn_valid) && sync_insn_ready && (local_fifo_capacity > word_num) && ((!word_buffer_valid) || (word_buffer_valid && (!(| word_cnt))))) begin
      sync_insn_read_reg <= 1'b1;
    end
    else begin
      sync_insn_read_reg <= 1'b0;
    end
    sync_insn_valid <= sync_insn_read_reg;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    word_buffer               <= 'd0;
    word_cnt                  <= 'd0;
    load_highaddr_config      <= 1'b0;
    store_highaddr_config     <= 1'b0;
    load_highaddr             <= 'd0;
    store_highaddr            <= 'd0;
    word_buffer_valid         <= 1'b0;
    local_fifo_wdata          <= 'd0;
    local_fifo_wen            <= 1'b0;
    cross_die_load_config     <= 1'b0;
    cross_die_store_config    <= 1'b0;
  end
  else begin
    if (sync_insn_valid) begin
      if (sync_insn[7:6] == SYNCHRONIZE_INDIE_INSN_ID) begin
        store_highaddr_config     <= sync_insn[107];
        load_highaddr_config      <= sync_insn[106];
        load_highaddr             <= load_highaddr;
        store_highaddr            <= store_highaddr;
        word_buffer               <= sync_insn[105:10];
        word_cnt                  <= sync_insn[9:8];
        cross_die_load_config     <= 1'b0;
        cross_die_store_config    <= 1'b0;
      end
      else if (sync_insn[7:6] == SYNCHRONIZE_CROSS_LOAD_INSN_ID) begin
        store_highaddr_config     <= sync_insn[65];
        load_highaddr_config      <= 1'b1;
        load_highaddr             <= sync_insn[63:40];
        store_highaddr            <= 24'd0;
        word_buffer               <= {sync_insn[39:8], {(word_bits*2){1'b0}}};
        word_cnt                  <= 'd1;
        cross_die_load_config     <= 1'b1;
        cross_die_store_config    <= 1'b0;
      end
      else if (sync_insn[7:6] == SYNCHRONIZE_CROSS_STORE_INSN_ID) begin
        store_highaddr_config     <= 1'b1;
        load_highaddr_config      <= sync_insn[65];
        load_highaddr             <= 24'd0;
        store_highaddr            <= sync_insn[63:40];
        word_buffer               <= {sync_insn[39:8], {(word_bits*2){1'b0}}};
        word_cnt                  <= 'd1;
        cross_die_load_config     <= 1'b0;
        cross_die_store_config    <= 1'b1;
      end
      word_buffer_valid <= 1'b1;
      local_fifo_wdata  <= 'd0;
      local_fifo_wen    <= 1'b0;
    end
    else if (word_buffer_valid && (!local_fifo_afull) && (| word_cnt)) begin
      store_highaddr_config <= store_highaddr_config;
      load_highaddr_config  <= load_highaddr_config;  
      store_highaddr        <= store_highaddr;
      load_highaddr         <= load_highaddr;
      word_buffer           <= (word_buffer << word_bits);
      word_cnt              <= (word_cnt - 1);
      word_buffer_valid     <= 1'b1;
      local_fifo_wdata      <= {{(SYNCHRONIZE_FIFO_WIDTH_PAD-SYNCHRONIZE_FIFO_WIDTH){1'b0}}, 
                                  cross_die_store_config, 
                                  cross_die_load_config, 
                                  store_highaddr, 
                                  store_highaddr_config, 
                                  load_highaddr, 
                                  load_highaddr_config, 
                                  word_buffer[(word_in_insn_bits-1)-:word_bits]};
      local_fifo_wen        <= 1'b1;
    end
    else begin
      store_highaddr_config <= store_highaddr_config;
      load_highaddr_config  <= load_highaddr_config;  
      store_highaddr        <= store_highaddr;
      load_highaddr         <= load_highaddr;
      word_buffer           <= word_buffer;
      word_cnt              <= word_cnt;
      word_buffer_valid     <= 1'b0;
      local_fifo_wdata      <= local_fifo_wdata;
      local_fifo_wen        <= 1'b0;
    end
  end
end


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    local_fifo_ren <= 1'b0;
    watch_flag     <= 1'b0;
  end
  else begin
    if ((!local_fifo_empty) && ((!watch_flag) || (watch_flag && watch_done))) begin
      local_fifo_ren <= 1'b1;
      watch_flag     <= 1'b1;
    end
    else if (watch_flag) begin
      local_fifo_ren <= 1'b0;
      if (watch_done) begin
        watch_flag <= 1'b0;
      end
      else begin
        watch_flag <= watch_flag;
      end
    end
  end
end


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    done_reg <= 'd0;
  end
  else begin
    if (watch_flag) begin
      if (|collect_done) begin
        done_reg <= done_reg | collect_done;
      end
      else begin
        if (watch_done) begin
          done_reg <= 'd0;
        end
        else begin
          done_reg <= done_reg;
        end
      end
    end
    else begin
      done_reg <= 'd0;
    end
  end
end

assign word_wire                   = local_fifo_rdata[word_bits-1:0];
assign load_highaddr_sel_wire      = local_fifo_rdata[word_bits];
assign load_highaddr_wire          = local_fifo_rdata[word_bits+HIGHADDR_BITS:word_bits+1];
assign store_highaddr_sel_wire     = local_fifo_rdata[word_bits+HIGHADDR_BITS+1];
assign store_highaddr_wire         = local_fifo_rdata[word_bits+HIGHADDR_BITS*2+2-1:word_bits+HIGHADDR_BITS+2];
assign cross_die_load_config_wire  = local_fifo_rdata[word_bits+HIGHADDR_BITS*2+2];
assign cross_die_store_config_wire = local_fifo_rdata[word_bits+HIGHADDR_BITS*2+3];

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    load_highaddr_sync_reg       <= 'd0;
    load_highaddr_sel_reg        <= 1'b0;
    store_highaddr_sync_reg      <= 'd0;
    store_highaddr_sel_reg       <= 1'b0;
    word_reg                     <= 'd0;
    enable_reg                   <= 'd0;
    local_fifo_ren_delay         <= 'd0;
    set_local_execute_reg        <= 1'b0;
  end
  else begin
    local_fifo_ren_delay <= local_fifo_ren;
    if (local_fifo_ren_delay) begin
      store_highaddr_sel_reg <= store_highaddr_sel_wire;
      load_highaddr_sel_reg  <= load_highaddr_sel_wire;
      if (cross_die_load_config_wire) begin
        load_highaddr_sync_reg  <= load_highaddr_wire;
        store_highaddr_sync_reg <= store_highaddr_sync_reg;
        set_local_execute_reg   <= 1'b0;
      end
      else if (cross_die_store_config_wire) begin
        load_highaddr_sync_reg  <= load_highaddr_sync_reg;
        store_highaddr_sync_reg <= store_highaddr_wire;
        set_local_execute_reg   <= 1'b0;
      end
      word_reg                     <= word_wire;
    end
    else begin
      load_highaddr_sync_reg       <= load_highaddr_sync_reg;
      load_highaddr_sel_reg        <= load_highaddr_sel_reg;
      store_highaddr_sync_reg      <= store_highaddr_sync_reg;
      store_highaddr_sel_reg       <= store_highaddr_sel_reg;
      word_reg                     <= word_reg;
    end

    if (local_fifo_ren_delay) begin
      if ((cross_die_load_config_wire || cross_die_store_config_wire)) begin
        enable_reg <= word_wire;
      end
      else begin
        enable_reg <= word_wire;
      end
    end
    else if (watch_flag) begin
      if ((word_reg & collect_insn_ready) == word_reg) begin
        enable_reg <= 'd0;
      end
      else begin
        enable_reg <= enable_reg;
      end
    end
  end
end

assign word_cnt_debug = word_cnt;
assign done_reg_debug = done_reg;
assign word_reg_debug = word_reg;

sync_fifo_sram_128x128 words_fifo(
  .clk      ( clk                 ),
  .rst_n    ( rst_n               ),
  .w_en     ( local_fifo_wen      ),
  .r_en     ( local_fifo_ren      ),
  .w_data   ( local_fifo_wdata    ),
  .full     ( local_fifo_full     ),
  .empty    ( local_fifo_empty    ),
  .afull    ( local_fifo_afull    ),
  .aempty   ( local_fifo_aempty   ),
  .hfull    ( local_fifo_hfull    ),
  .hempty   ( local_fifo_hempty   ),
  .r_data   ( local_fifo_rdata    ),
  .capacity ( local_fifo_capacity )
);

endmodule


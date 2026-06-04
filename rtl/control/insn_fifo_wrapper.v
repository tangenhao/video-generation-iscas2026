module insn_fifo_wrapper(
  clk, rst_n,

  load_0_fifo_full, load_0_fifo_wen, load_0_fifo_wdata, load_0_fifo_ren, load_0_fifo_rdata, load_0_fifo_empty,
  load_1_fifo_full, load_1_fifo_wen, load_1_fifo_wdata, load_1_fifo_ren, load_1_fifo_rdata, load_1_fifo_empty,
  store_0_fifo_full, store_0_fifo_wen, store_0_fifo_wdata, store_0_fifo_ren, store_0_fifo_rdata, store_0_fifo_empty,
  store_1_fifo_full, store_1_fifo_wen, store_1_fifo_wdata, store_1_fifo_ren, store_1_fifo_rdata, store_1_fifo_empty,

  pea_0_fifo_full, pea_0_fifo_wen, pea_0_fifo_wdata, pea_0_fifo_ren, pea_0_fifo_rdata, pea_0_fifo_empty,
  pea_1_fifo_full, pea_1_fifo_wen, pea_1_fifo_wdata, pea_1_fifo_ren, pea_1_fifo_rdata, pea_1_fifo_empty,

  vcu_0_fifo_full, vcu_0_fifo_wen, vcu_0_fifo_wdata, vcu_0_fifo_ren, vcu_0_fifo_rdata, vcu_0_fifo_empty,
  vcu_1_fifo_full, vcu_1_fifo_wen, vcu_1_fifo_wdata, vcu_1_fifo_ren, vcu_1_fifo_rdata, vcu_1_fifo_empty
);

parameter INSN_WIDTH                      = 128;
parameter INSN_FIFO_DEPTH                 = 128;

input wire                  clk;
input wire                  rst_n;

output wire                  load_0_fifo_full;
input  wire                  load_0_fifo_wen;
input  wire [INSN_WIDTH-1:0] load_0_fifo_wdata;
input  wire                  load_0_fifo_ren;
output wire [INSN_WIDTH-1:0] load_0_fifo_rdata;
output wire                  load_0_fifo_empty;

output wire                  load_1_fifo_full;
input  wire                  load_1_fifo_wen;
input  wire [INSN_WIDTH-1:0] load_1_fifo_wdata;
input  wire                  load_1_fifo_ren;
output wire [INSN_WIDTH-1:0] load_1_fifo_rdata;
output wire                  load_1_fifo_empty;

output wire                  store_0_fifo_full;
input  wire                  store_0_fifo_wen;
input  wire [INSN_WIDTH-1:0] store_0_fifo_wdata;
input  wire                  store_0_fifo_ren;
output wire [INSN_WIDTH-1:0] store_0_fifo_rdata;
output wire                  store_0_fifo_empty;

output wire                  store_1_fifo_full;
input  wire                  store_1_fifo_wen;
input  wire [INSN_WIDTH-1:0] store_1_fifo_wdata;
input  wire                  store_1_fifo_ren;
output wire [INSN_WIDTH-1:0] store_1_fifo_rdata;
output wire                  store_1_fifo_empty;

output wire                  pea_0_fifo_full;
input  wire                  pea_0_fifo_wen;
input  wire [INSN_WIDTH-1:0] pea_0_fifo_wdata;
input  wire                  pea_0_fifo_ren;
output wire [INSN_WIDTH-1:0] pea_0_fifo_rdata;
output wire                  pea_0_fifo_empty;

output wire                  pea_1_fifo_full;
input  wire                  pea_1_fifo_wen;
input  wire [INSN_WIDTH-1:0] pea_1_fifo_wdata;
input  wire                  pea_1_fifo_ren;
output wire [INSN_WIDTH-1:0] pea_1_fifo_rdata;
output wire                  pea_1_fifo_empty;

output wire                  vcu_0_fifo_full;
input  wire                  vcu_0_fifo_wen;
input  wire [INSN_WIDTH-1:0] vcu_0_fifo_wdata;
input  wire                  vcu_0_fifo_ren;
output wire [INSN_WIDTH-1:0] vcu_0_fifo_rdata;
output wire                  vcu_0_fifo_empty;

output wire                  vcu_1_fifo_full;
input  wire                  vcu_1_fifo_wen;
input  wire [INSN_WIDTH-1:0] vcu_1_fifo_wdata;
input  wire                  vcu_1_fifo_ren;
output wire [INSN_WIDTH-1:0] vcu_1_fifo_rdata;
output wire                  vcu_1_fifo_empty;

insn_fifo #(
  .width ( INSN_WIDTH      ),
  .depth ( INSN_FIFO_DEPTH )
) u_load_0_insn_fifo(
  .clk      ( clk               ),
  .rst_n    ( rst_n             ),
  .w_en     ( load_0_fifo_wen   ),
  .r_en     ( load_0_fifo_ren   ),
  .w_data   ( load_0_fifo_wdata ),
  .full     (                   ),
  .empty    ( load_0_fifo_empty ),
  .afull    ( load_0_fifo_full  ),
  .aempty   (                   ),
  .hfull    (                   ),
  .hempty   (                   ),
  .r_data   ( load_0_fifo_rdata ),
  .capacity (                   )
);

insn_fifo #(
  .width ( INSN_WIDTH      ),
  .depth ( INSN_FIFO_DEPTH )
) u_load_1_insn_fifo(
  .clk      ( clk               ),
  .rst_n    ( rst_n             ),
  .w_en     ( load_1_fifo_wen   ),
  .r_en     ( load_1_fifo_ren   ),
  .w_data   ( load_1_fifo_wdata ),
  .full     (                   ),
  .empty    ( load_1_fifo_empty ),
  .afull    ( load_1_fifo_full  ),
  .aempty   (                   ),
  .hfull    (                   ),
  .hempty   (                   ),
  .r_data   ( load_1_fifo_rdata ),
  .capacity (                   )
);

insn_fifo #(
  .width ( INSN_WIDTH      ),
  .depth ( INSN_FIFO_DEPTH )
) u_store_0_insn_fifo(
  .clk      ( clk                ),
  .rst_n    ( rst_n              ),
  .w_en     ( store_0_fifo_wen   ),
  .r_en     ( store_0_fifo_ren   ),
  .w_data   ( store_0_fifo_wdata ),
  .full     (                    ),
  .empty    ( store_0_fifo_empty ),
  .afull    ( store_0_fifo_full  ),
  .aempty   (                    ),
  .hfull    (                    ),
  .hempty   (                    ),
  .r_data   ( store_0_fifo_rdata ),
  .capacity (                    )
);

insn_fifo #(
  .width ( INSN_WIDTH      ),
  .depth ( INSN_FIFO_DEPTH )
) u_store_1_insn_fifo(
  .clk      ( clk                ),
  .rst_n    ( rst_n              ),
  .w_en     ( store_1_fifo_wen   ),
  .r_en     ( store_1_fifo_ren   ),
  .w_data   ( store_1_fifo_wdata ),
  .full     (                    ),
  .empty    ( store_1_fifo_empty ),
  .afull    ( store_1_fifo_full  ),
  .aempty   (                    ),
  .hfull    (                    ),
  .hempty   (                    ),
  .r_data   ( store_1_fifo_rdata ),
  .capacity (                    )
);

insn_fifo #(
  .width ( INSN_WIDTH      ),
  .depth ( INSN_FIFO_DEPTH )
) u_pea_0_insn_fifo(
  .clk      ( clk              ),
  .rst_n    ( rst_n            ),
  .w_en     ( pea_0_fifo_wen   ),
  .r_en     ( pea_0_fifo_ren   ),
  .w_data   ( pea_0_fifo_wdata ),
  .full     (                  ),
  .empty    ( pea_0_fifo_empty ),
  .afull    ( pea_0_fifo_full  ),
  .aempty   (                  ),
  .hfull    (                  ),
  .hempty   (                  ),
  .r_data   (pea_0_fifo_rdata ),
  .capacity (                  )
);

insn_fifo #(
  .width ( INSN_WIDTH      ),
  .depth ( INSN_FIFO_DEPTH )
) u_pea_1_insn_fifo(
  .clk      ( clk              ),
  .rst_n    ( rst_n            ),
  .w_en     ( pea_1_fifo_wen   ),
  .r_en     ( pea_1_fifo_ren   ),
  .w_data   ( pea_1_fifo_wdata ),
  .full     (                  ),
  .empty    ( pea_1_fifo_empty ),
  .afull    ( pea_1_fifo_full  ),
  .aempty   (                  ),
  .hfull    (                  ),
  .hempty   (                  ),
  .r_data   (pea_1_fifo_rdata ),
  .capacity (                  )
);

insn_fifo #(
  .width ( INSN_WIDTH      ),
  .depth ( INSN_FIFO_DEPTH )
) u_vcu_0_insn_fifo(
  .clk      ( clk              ),
  .rst_n    ( rst_n            ),
  .w_en     ( vcu_0_fifo_wen   ),
  .r_en     ( vcu_0_fifo_ren   ),
  .w_data   ( vcu_0_fifo_wdata ),
  .full     (                  ),
  .empty    ( vcu_0_fifo_empty ),
  .afull    ( vcu_0_fifo_full  ),
  .aempty   (                  ),
  .hfull    (                  ),
  .hempty   (                  ),
  .r_data   ( vcu_0_fifo_rdata ),
  .capacity (                  )
);

insn_fifo #(
  .width ( INSN_WIDTH      ),
  .depth ( INSN_FIFO_DEPTH )
) u_vcu_1_insn_fifo(
  .clk      ( clk              ),
  .rst_n    ( rst_n            ),
  .w_en     ( vcu_1_fifo_wen   ),
  .r_en     ( vcu_1_fifo_ren   ),
  .w_data   ( vcu_1_fifo_wdata ),
  .full     (                  ),
  .empty    ( vcu_1_fifo_empty ),
  .afull    ( vcu_1_fifo_full  ),
  .aempty   (                  ),
  .hfull    (                  ),
  .hempty   (                  ),
  .r_data   ( vcu_1_fifo_rdata ),
  .capacity (                  )
);

endmodule
module apb
#(
  parameter RD_FLAG        = 1'b0           ,
  parameter WR_FLAG        = 1'b1           ,
  parameter CMD_RW_WIDTH   = 1              ,
  parameter CMD_ADDR_WIDTH = 32             ,
  parameter CMD_DATA_WIDTH = 32             ,
  parameter CMD_WIDTH      = CMD_RW_WIDTH   + 
                             CMD_ADDR_WIDTH + 
                             CMD_DATA_WIDTH
)(
//-- clkrst signal
  input                           pclk       ,
  input                           prst_n     ,

//-- cmd_in
  input      [CMD_WIDTH-1:0]      cmd        ,
  input                           cmd_vld    ,
  output reg [CMD_DATA_WIDTH-1:0] cmd_rd_data,

//-- apb interface
  output reg [CMD_ADDR_WIDTH-1:0] paddr      ,
  output reg                      pwrite     ,
  output reg                      psel       ,
  output reg                      penable    ,
  output reg [CMD_DATA_WIDTH-1:0] pwdata     ,
  input      [CMD_DATA_WIDTH-1:0] prdata     ,
  input                           pready     ,
  input                           pslverr
);

//-- FSM state
parameter IDLE   = 3'b001;
parameter SETUP  = 3'b010;
parameter ACCESS = 3'b100;

//-- current state and next state
reg [2:0] cur_state;
reg [2:0] nxt_state;

//-- data buf
reg                      start_flag     ;
reg [CMD_WIDTH-1:0]      cmd_in_buf     ;
reg [CMD_DATA_WIDTH-1:0] cmd_rd_data_buf;


/*-----------------------------------------------
 --             update cmd_in_buf              --
-----------------------------------------------*/
always @ (posedge pclk or negedge prst_n) begin
  if (!prst_n) begin
    cmd_in_buf <= {(CMD_WIDTH){1'b0}};
  end
  else if (cmd_vld) begin
    cmd_in_buf <= cmd;
  end
end

/*-----------------------------------------------
 --             start flag of transfer         --
-----------------------------------------------*/
always @ (posedge pclk or negedge prst_n) begin
  if (!prst_n) begin
    start_flag <= 1'b0;
  end
  else if (cmd_vld) begin
    start_flag <= 1'b1;
  end
  else begin
    start_flag <= 1'b0;
  end
end

/*-----------------------------------------------
 --           update current state             --
-----------------------------------------------*/
always @ (posedge pclk or negedge prst_n) begin
  if (!prst_n) begin
    cur_state <= IDLE;
  end
  else begin
    cur_state <= nxt_state;
  end
end

/*-----------------------------------------------
 --               update next state            --
-----------------------------------------------*/
always @ (*) begin
  case(cur_state)
    IDLE  :if(start_flag)begin
             nxt_state = SETUP;
           end
           else begin
             nxt_state = IDLE;
           end

    SETUP :nxt_state = ACCESS;
          
    ACCESS:if (!pready)begin
             nxt_state = ACCESS;
           end
           else if(start_flag)begin
             nxt_state = SETUP;
           end
           else if(!cmd_vld && pready)begin
             nxt_state = IDLE;
           end
  endcase
end

/*-----------------------------------------------
 --         update signal of output            --
-----------------------------------------------*/
always @ (posedge pclk or negedge prst_n) begin
  if (!prst_n) begin
    pwrite  <= 1'b0;
    psel    <= 1'b0;
    penable <= 1'b0;
    paddr   <= {(CMD_ADDR_WIDTH){1'b0}};
    pwdata  <= {(CMD_DATA_WIDTH){1'b0}};
  end
  
  else if (nxt_state == IDLE) begin
    psel    <= 1'b0;
    penable <= 1'b0;
  end

  else if(nxt_state == SETUP)begin
    psel    <= 1'b1;
    penable <= 1'b0;
    paddr   <= cmd_in_buf[CMD_WIDTH-CMD_RW_WIDTH-1:CMD_DATA_WIDTH];
    //-- read
    if(cmd_in_buf[CMD_WIDTH-1:CMD_WIDTH-CMD_RW_WIDTH] == RD_FLAG)begin
      pwrite <= 1'b0;
    end
    //-- write
    else begin
      pwrite  <= 1'b1;
      pwdata  <= cmd_in_buf[CMD_DATA_WIDTH-1:0];
    end
  end

  else if(nxt_state == ACCESS)begin
    penable <= 1'b1;
  end
end

/*-----------------------------------------------
 --            update cmd_rd_data_buf          --
-----------------------------------------------*/
always @ (posedge pclk or negedge prst_n) begin
  if (!prst_n) begin
    cmd_rd_data_buf <= {(CMD_DATA_WIDTH){1'b0}};
  end
  else if (pready && psel && penable) begin
    cmd_rd_data_buf <= prdata;
  end
end

/*-----------------------------------------------
 --            update cmd_rd_data            --
-----------------------------------------------*/
always @ (posedge pclk or negedge prst_n) begin
  if (!prst_n) begin
    cmd_rd_data <= {(CMD_DATA_WIDTH){1'b0}};
  end
  else begin
    cmd_rd_data <= cmd_rd_data_buf;
  end
end

endmodule
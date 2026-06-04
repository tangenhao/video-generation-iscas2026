/*Copyright 2019-2021 T-Head Semiconductor Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// &Depend("cpu_cfig.h"); @22
// &ModuleBeg; @23
module vfdsu_ctrl(
  rst_n,
  in_valid,
  ex1_data_clk,
  ex1_pipedown,
  ex2_data_clk,
  ex2_pipedown,
  ex2_srt_first_round,
  ex3_data_clk,
  ex3_pipedown,
  clk,
  out_valid,
  srt_ctrl_rem_zero,
  srt_ctrl_skip_srt,
  srt_secd_round,
  srt_sm_on,
  busy
);

input          rst_n;   
input          in_valid;                 
input          clk;             
input          srt_ctrl_rem_zero;          
input          srt_ctrl_skip_srt;            
output         ex1_data_clk;               
output         ex1_pipedown;               
output         ex2_data_clk;               
output         ex2_pipedown;               
output         ex2_srt_first_round;        
output         ex3_data_clk;               
output         ex3_pipedown;               
output         out_valid;    
output         srt_secd_round;             
output         srt_sm_on;                  
output         busy;         

// &Regs; @25
reg     [3:0]  div_cur_state;              
reg     [3:0]  div_next_state;             
reg            ex2_srt_first_round;        
reg            ex2_srt_secd_round;         
reg     [4:0]  srt_cnt;                    
reg            srt_cur_state;              
reg            srt_nxt_state;              
reg            vfdsu_ex3_vld;              
reg            vfdsu_ex4_vld;  

reg            ex1_pipedown_reg;
          
wire           rst_n;          
wire           div_sm_clk;                 
wire           div_sm_clk_en;              
wire           div_st_ex2;                 
wire           in_valid;    
wire           ex1_data_clk;               
wire           ex1_data_clk_en;                 
wire           ex1_pipedown;                 
wire           ex2_data_clk;               
wire           ex2_data_clk_en;            
wire           ex2_pipe_clk;               
wire           ex2_pipe_clk_en;            
wire           ex2_pipedown;               
wire           ex2_srt_secd_round_pre;     
wire           ex3_data_clk;               
wire           ex3_data_clk_en;            
wire           ex3_pipe_clk;               
wire           ex3_pipe_clk_en;            
wire           ex3_pipedown;               
wire           ex4_pipedown;               
wire           clk;            
wire           out_valid;      
wire           skip_srt;                   
wire    [4:0]  srt_cnt_ini;                
wire           srt_cnt_zero;               
wire           srt_ctrl_rem_zero;          
wire           srt_ctrl_skip_srt;          
wire           srt_last_round;             
wire           srt_secd_round;             
wire           srt_secd_round_pre;         
wire           srt_sm_clk;                 
wire           srt_sm_clk_en;              
wire           srt_sm_on;                  
wire           busy;           
wire           vfdsu_ex2_vld;              


//==========================================================
//              EX1 Stage Control Signal
//==========================================================

//vfdsu ex1 pipedown signal
assign ex1_pipedown       = ex1_pipedown_reg;

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    ex1_pipedown_reg <= 0;
  else if (ex1_pipedown_reg) 
    ex1_pipedown_reg <= 0;
  else if (in_valid)
    ex1_pipedown_reg <= in_valid;
  else
    ex1_pipedown_reg <= ex1_pipedown_reg;
end

// &Force("output","ex1_pipedown"); @34
//==========================================================
//              EX2 Stage Control Signal
//==========================================================
//state parameter
parameter SRT_IDLE = 1'b0;
parameter SRT_BUSY = 1'b1;

assign srt_sm_clk = clk;

//state machine
always @(posedge srt_sm_clk or negedge rst_n)
begin
  if(!rst_n)
    srt_cur_state <= SRT_IDLE;
  else
    srt_cur_state <= srt_nxt_state;
end


// &CombBeg; @66
always @( ex1_pipedown
       or srt_last_round
       or srt_cur_state)
begin
case(srt_cur_state)
SRT_IDLE : if(ex1_pipedown)
             srt_nxt_state = SRT_BUSY;
           else
             srt_nxt_state = SRT_IDLE;
SRT_BUSY : if(srt_last_round)
             srt_nxt_state = SRT_IDLE;
           else
             srt_nxt_state = SRT_BUSY;
default  :   srt_nxt_state = SRT_IDLE;
endcase
// &CombEnd; @78
end

//srt sm state
//assign srt_sm_idle = ~srt_cur_state;
assign srt_sm_on   =  srt_cur_state;
// &Force("output","srt_sm_on"); @83
//state machine control signal
//srt_last_round on three condition : 
//  1.srt need not execute
//  2.srt rem is zero 
//  3.srt cnt zero
assign srt_last_round = (skip_srt || 
                         srt_ctrl_rem_zero || 
                         srt_cnt_zero)      && 
                         srt_sm_on;
assign skip_srt       =  srt_ctrl_skip_srt;
assign srt_cnt_zero   = ~(|srt_cnt[4:0]);
//srt counter
always @(posedge srt_sm_clk or negedge rst_n)
begin
  if(!rst_n)
    srt_cnt[4:0] <= 5'b0;
  else if(ex1_pipedown)
    srt_cnt[4:0] <= srt_cnt_ini[4:0];
  else if(srt_sm_on)
    srt_cnt[4:0] <= srt_cnt[4:0] - 5'b1;
  else
    srt_cnt[4:0] <= srt_cnt[4:0];
end

//srt_cnt_ini[4:0]
//For Double, initial is 5'b11100('d28), calculate 29 round
//For Single, initial is 5'b01110('d14), calculate 15 round
assign srt_cnt_ini[4:0] = 5'b00110;

//vfdsu ex2 pipedown signal
assign ex2_pipedown = srt_last_round && div_st_ex2;
// &Force("output","ex2_pipedown"); @157
// &Force("output","ex2_srt_first_round"); @172
always @(posedge srt_sm_clk or negedge rst_n)
begin
  if(!rst_n)
    ex2_srt_first_round <= 1'b0;
  else if(ex1_pipedown)
    ex2_srt_first_round <= 1'h1;
  else
    ex2_srt_first_round <= 1'b0;
end
// &Force("output","ex2_srt_first_round"); @195
always @(posedge srt_sm_clk or negedge rst_n)
begin
  if(!rst_n)
    ex2_srt_secd_round <= 1'b0;
  else
    ex2_srt_secd_round <= {1{ex2_srt_secd_round_pre}};
end
assign srt_secd_round  = ex2_srt_secd_round;


assign ex2_srt_secd_round_pre  = srt_sm_on && srt_secd_round_pre;
assign srt_secd_round_pre      = srt_cnt[4:0]==5'b00110;

//==========================================================
//              EX3 Stage Control Signal
//==========================================================

assign ex2_pipe_clk = clk;

assign vfdsu_ex2_vld = ex2_pipedown;
//EX2 to EX3 pipedown
always @(posedge ex2_pipe_clk or negedge rst_n)
begin
  if(!rst_n)
    vfdsu_ex3_vld <= 1'b0;
  else if(ex2_pipedown)
    vfdsu_ex3_vld <= 1'b1;
  else
    vfdsu_ex3_vld <= 1'b0;
end
assign ex3_pipedown  = vfdsu_ex3_vld;
// &Force("output","ex3_pipedown"); @242

//==========================================================
//              EX4 Stage Control Signal
//==========================================================

assign ex3_pipe_clk = clk;

//EX3 to EX4 pipedown
always @(posedge ex3_pipe_clk or negedge rst_n)
begin
  if(!rst_n)
    vfdsu_ex4_vld <= 1'b0;
  else if(ex3_pipedown)
    vfdsu_ex4_vld <= 1'b1;
  else
    vfdsu_ex4_vld <= 1'b0;
end
assign ex4_pipedown = vfdsu_ex4_vld;


//Div Write Back State Machine
parameter IDLE      = 4'b0000;
parameter EX1       = 4'b0101;
parameter EX2       = 4'b0110;
parameter WB_REQ    = 4'b0111;
parameter WB        = 4'b1000;

assign div_sm_clk = clk;
                    
//State Trans
always @(posedge div_sm_clk or negedge rst_n)
begin
  if(!rst_n)
    div_cur_state[3:0] <= IDLE;
  else
    div_cur_state[3:0] <= div_next_state[3:0];
end
// &CombBeg; @304
always @( in_valid
       or ex4_pipedown
       or srt_last_round
       or div_cur_state[3:0]
       or ex3_pipedown)
begin
  case(div_cur_state[3:0])
  IDLE       : if(in_valid)
                 div_next_state[3:0] = EX1;
               else
                 div_next_state[3:0] = IDLE;
  EX1        : div_next_state[3:0] = EX2;
  EX2        : if(srt_last_round)
                 div_next_state[3:0] = WB_REQ;
               else 
                 div_next_state[3:0] = EX2;
  WB_REQ   :   if(ex3_pipedown)
                 div_next_state[3:0] = WB;
               else
                 div_next_state[3:0] = WB_REQ;
  WB         : if(in_valid)
                 div_next_state[3:0] = EX1;
               else
                 div_next_state[3:0] = IDLE;
  default    :   div_next_state[3:0] = IDLE;
  endcase
// &CombEnd; @329
end
//Control Signal
assign div_st_ex2             = (div_cur_state[3:0] == EX2);

//Div Rdy Signal
//assign vfdsu_vfpu_gateclk_en   = div_cur_state[2] || div_cur_state[3] || 
//                                 ex4_pipedown;


assign ex1_data_clk = clk;

assign ex2_data_clk = clk;

assign ex3_data_clk = clk;

assign out_valid           = div_cur_state[3:0] == WB;

assign busy     = div_cur_state[2];

endmodule



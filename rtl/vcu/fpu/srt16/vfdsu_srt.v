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

// &ModuleBeg; @22
module vfdsu_srt(
  rst_n,
  ex1_div,
  ex1_divisor,
  ex1_pipedown,
  ex1_remainder,
  ex1_sqrt,
  ex2_pipedown,
  ex2_srt_first_round,
  clk,
  srt_ctrl_rem_zero,
  srt_ctrl_skip_srt,
  srt_secd_round,
  srt_sm_on,
  total_qt_rt_58,
  vfdsu_ex2_div,
  vfdsu_ex2_dz,
  vfdsu_ex2_expnt_add0,
  vfdsu_ex2_expnt_add1,
  vfdsu_ex2_nv,
  vfdsu_ex2_of_rm_lfn,
  vfdsu_ex2_op0_norm,
  vfdsu_ex2_op1_norm,
  vfdsu_ex2_qnan_f,
  vfdsu_ex2_qnan_sign,
  vfdsu_ex2_result_inf,
  vfdsu_ex2_result_qnan,
  vfdsu_ex2_result_sign,
  vfdsu_ex2_result_zero,
  vfdsu_ex2_rm,
  vfdsu_ex2_sqrt,
  vfdsu_ex2_srt_skip,
  vfdsu_ex3_dz,
  vfdsu_ex3_expnt_rst,
  vfdsu_ex3_id_srt_skip,
  vfdsu_ex3_nv,
  vfdsu_ex3_of,
  vfdsu_ex3_potnt_of,
  vfdsu_ex3_potnt_uf,
  vfdsu_ex3_qnan_f,
  vfdsu_ex3_qnan_sign,
  vfdsu_ex3_rem_sign,
  vfdsu_ex3_rem_zero,
  vfdsu_ex3_result_denorm_round_add_num,
  vfdsu_ex3_result_inf,
  vfdsu_ex3_result_lfn,
  vfdsu_ex3_result_qnan,
  vfdsu_ex3_result_sign,
  vfdsu_ex3_result_zero,
  vfdsu_ex3_rm,
  vfdsu_ex3_rslt_denorm,
  vfdsu_ex3_uf
);
                                             
input           rst_n;     
input           ex1_div;                               
input   [23:0]  ex1_divisor;                           
input           ex1_pipedown;                          
input   [30:0]  ex1_remainder;                         
input           ex1_sqrt;                              
input           ex2_pipedown;                          
input           ex2_srt_first_round;                   
input           clk;                        
input           srt_secd_round;                        
input           srt_sm_on;                             
input           vfdsu_ex2_div;                         
input           vfdsu_ex2_dz;                          
input   [9 :0]  vfdsu_ex2_expnt_add0;                  
input   [9 :0]  vfdsu_ex2_expnt_add1;                  
input           vfdsu_ex2_nv;                          
input           vfdsu_ex2_of_rm_lfn;                   
input           vfdsu_ex2_op0_norm;                    
input           vfdsu_ex2_op1_norm;                    
input   [22:0]  vfdsu_ex2_qnan_f;                      
input           vfdsu_ex2_qnan_sign;                   
input           vfdsu_ex2_result_inf;                  
input           vfdsu_ex2_result_qnan;                 
input           vfdsu_ex2_result_sign;                 
input           vfdsu_ex2_result_zero;                 
input   [2 :0]  vfdsu_ex2_rm;                         
input           vfdsu_ex2_sqrt;                        
input           vfdsu_ex2_srt_skip;                    
output          srt_ctrl_rem_zero;                     
output          srt_ctrl_skip_srt;                     
output  [31:0]  total_qt_rt_58;                         
output          vfdsu_ex3_dz; 
output  [9 :0]  vfdsu_ex3_expnt_rst;                       
output          vfdsu_ex3_id_srt_skip;                 
output          vfdsu_ex3_nv;                          
output          vfdsu_ex3_of;                          
output          vfdsu_ex3_potnt_of;                    
output          vfdsu_ex3_potnt_uf;                    
output  [22:0]  vfdsu_ex3_qnan_f;                      
output          vfdsu_ex3_qnan_sign;                   
output          vfdsu_ex3_rem_sign;                    
output          vfdsu_ex3_rem_zero;                    
output  [23:0]  vfdsu_ex3_result_denorm_round_add_num; 
output          vfdsu_ex3_result_inf;                  
output          vfdsu_ex3_result_lfn;                  
output          vfdsu_ex3_result_qnan;                 
output          vfdsu_ex3_result_sign;                 
output          vfdsu_ex3_result_zero;                 
output  [2 :0]  vfdsu_ex3_rm;                          
output          vfdsu_ex3_rslt_denorm;                  
output          vfdsu_ex3_uf;                          

// &Regs; @24
reg     [23:0]  ex2_result_denorm_round_add_num_reg;     
reg             vfdsu_ex3_dz;
reg     [9 :0]  vfdsu_ex3_expnt_rst;                         
reg             vfdsu_ex3_id_srt_skip;                 
reg             vfdsu_ex3_nv;                          
reg             vfdsu_ex3_of;                          
reg             vfdsu_ex3_potnt_of;                    
reg             vfdsu_ex3_potnt_uf;                    
reg     [22:0]  vfdsu_ex3_qnan_f;                      
reg             vfdsu_ex3_qnan_sign;                   
reg             vfdsu_ex3_rem_sign;                    
reg     [23:0]  vfdsu_ex3_result_denorm_round_add_num; 
reg             vfdsu_ex3_result_inf;                  
reg             vfdsu_ex3_result_lfn;                  
reg             vfdsu_ex3_result_qnan;                 
reg             vfdsu_ex3_result_sign;                 
reg             vfdsu_ex3_result_zero;                 
reg     [2 :0]  vfdsu_ex3_rm;                          
reg             vfdsu_ex3_rslt_denorm;                  
reg             vfdsu_ex3_uf;                          
                                              
wire            rst_n; 
wire            ex1_div;                               
wire    [23:0]  ex1_divisor;                           
wire            ex1_pipedown;                          
wire    [30:0]  ex1_remainder;                         
wire            ex1_sqrt;                              
wire            ex2_div_of;                            
wire            ex2_div_uf;                           
wire            ex2_expnt_of;                          
wire    [9 :0]  ex2_expnt_result;                      
wire            ex2_expnt_uf;                           
wire            ex2_id_nor_srt_skip;                   
wire            ex2_of;                                
wire            ex2_of_plus;                           
wire            ex2_pipe_clk;                          
wire            ex2_pipe_clk_en;                       
wire            ex2_pipedown;                          
wire            ex2_potnt_of;                          
wire            ex2_potnt_of_pre;                      
wire            ex2_potnt_uf;                          
wire            ex2_potnt_uf_pre;                      
wire    [23:0]  ex2_result_denorm_round_add_num;       
wire            ex2_result_inf;                        
wire            ex2_result_lfn;                        
wire            ex2_result_qnan;                       
wire            ex2_result_zero;                       
wire            ex2_rslt_denorm;                        
wire    [9 :0]  ex2_sqrt_expnt_result;                 
wire            ex2_srt_first_round;                   
wire            ex2_uf;                                
wire            ex2_uf_plus;                           
wire            clk;                        
wire    [6 :0]  initial_bound_sel_in;                  
wire    [29:0]  initial_divisor_in;                    
wire    [34:0]  initial_remainder_in;                  
wire            initial_srt_en;                        
wire            initial_srt_sel_div_in;                
wire            initial_srt_sel_sqrt_in;                    
wire            srt_ctrl_rem_zero;                     
wire            srt_ctrl_skip_srt;                     
wire            srt_first_round;                       
wire    [34:0]  srt_remainder;                         
wire    [33:0]  srt_remainder_out;                     
wire            srt_remainder_sign;                    
wire            srt_secd_round;                        
wire            srt_sm_on;                             
wire    [31:0]  total_qt_rt;                           
wire    [31:0]  total_qt_rt_58;                        
wire    [31:0]  vdiv_qt_rt;                            
wire            vfdsu_ex2_div;                        
wire            vfdsu_ex2_dz;                          
wire    [9 :0]  vfdsu_ex2_expnt_add0;                  
wire    [9 :0]  vfdsu_ex2_expnt_add1;                  
wire    [9 :0]  vfdsu_ex2_expnt_rst;                   
wire            vfdsu_ex2_nv;                          
wire            vfdsu_ex2_of_rm_lfn;                   
wire            vfdsu_ex2_op0_norm;                    
wire            vfdsu_ex2_op1_norm;                    
wire    [22:0]  vfdsu_ex2_qnan_f;                      
wire            vfdsu_ex2_qnan_sign;                   
wire            vfdsu_ex2_result_inf;                  
wire            vfdsu_ex2_result_qnan;                 
wire            vfdsu_ex2_result_sign;                 
wire            vfdsu_ex2_result_zero;                 
wire    [2 :0]  vfdsu_ex2_rm;                          
wire            vfdsu_ex2_sqrt;                        
wire            vfdsu_ex2_srt_skip;                    
wire            vfdsu_ex3_rem_zero;                    


//====================EX2 out_expt info=========================
//EX1 only detect of/uf under id condition
//EX2 will deal with other condition

//When input is normal, overflow when E1-E2 > 128/1024
//here we mov the expnt result calculation into second stage

assign vfdsu_ex2_expnt_rst[9:0] =  (vfdsu_ex2_sqrt)
                                    ? ex2_sqrt_expnt_result[9:0]
                                    : ex2_expnt_result[9:0];
assign ex2_sqrt_expnt_result[9:0] = {ex2_expnt_result[9],
                                      ex2_expnt_result[9:1]};
assign ex2_expnt_result[9:0]  = vfdsu_ex2_expnt_add0[9:0] - vfdsu_ex2_expnt_add1[9:0];

assign ex2_expnt_of      = ~vfdsu_ex2_expnt_rst[9] && (vfdsu_ex2_expnt_rst[8] 
                                                      || (vfdsu_ex2_expnt_rst[7]  &&
                                                          |vfdsu_ex2_expnt_rst[6:0]));
assign ex2_potnt_of_pre  = ~vfdsu_ex2_expnt_rst[9]  &&
                           ~vfdsu_ex2_expnt_rst[8]  &&
                            vfdsu_ex2_expnt_rst[7]  &&
                          ~|vfdsu_ex2_expnt_rst[6:0];   
assign ex2_potnt_uf_pre  = &vfdsu_ex2_expnt_rst[9:7]   &&
                          ~|vfdsu_ex2_expnt_rst[6:2]   &&
                            vfdsu_ex2_expnt_rst[1]     &&
                           !vfdsu_ex2_expnt_rst[0];
assign ex2_expnt_uf      = vfdsu_ex2_expnt_rst[9] && (vfdsu_ex2_expnt_rst[8:0] <= 9'h181);
assign ex2_id_nor_srt_skip   = vfdsu_ex2_expnt_rst[9] 
                                     && (vfdsu_ex2_expnt_rst[8:0] < 9'h16a); 
assign ex2_result_denorm_round_add_num[23:0] = ex2_result_denorm_round_add_num_reg[23:0];
                                                                  
//potential overflow when E1-E2 = 128/1024

assign ex2_potnt_of      = ex2_potnt_of_pre && 
                           vfdsu_ex2_op0_norm && 
                           vfdsu_ex2_op1_norm && 
                           vfdsu_ex2_div;

//potential underflow when E1-E2 = -126/-1022

assign ex2_potnt_uf      = (ex2_potnt_uf_pre && 
                            vfdsu_ex2_op0_norm && 
                            vfdsu_ex2_op1_norm &&
                            vfdsu_ex2_div)     ||
                           (ex2_potnt_uf_pre   && 
                            vfdsu_ex2_op0_norm);

//========================EX2 Overflow======================
//ex2 overflow when 
//  1.op0 & op1 both norm && expnt overflow
//  2.ex1_id_of
assign ex2_of      = ex2_of_plus;
assign ex2_of_plus = ex2_div_of  && vfdsu_ex2_div; 
assign ex2_div_of  = vfdsu_ex2_op0_norm && 
                     vfdsu_ex2_op1_norm && 
                     ex2_expnt_of;

//=======================EX2 Underflow======================
//ex2 underflow when 
//  1.op0 & op1 both norm && expnt underflow
//  2.ex1_id_uf
//  and detect when to skip the srt, here, we have further optmization
assign ex2_uf      = ex2_uf_plus;
assign ex2_uf_plus = ex2_div_uf  && vfdsu_ex2_div; 
assign ex2_div_uf  = vfdsu_ex2_op0_norm && 
                     vfdsu_ex2_op1_norm && 
                     ex2_expnt_uf;

assign ex2_rslt_denorm            = ex2_uf;

//=======================EX2 skip srt iteration======================
assign srt_ctrl_skip_srt   =  ex2_of || ex2_id_nor_srt_skip
                                     || vfdsu_ex2_srt_skip;
//===============ex2 round prepare for denormal round======

always @( vfdsu_ex2_expnt_rst[9:0])
begin
case(vfdsu_ex2_expnt_rst[9:0])
  10'h382:ex2_result_denorm_round_add_num_reg[23:0] = 24'h1; //-126 1
  10'h381:ex2_result_denorm_round_add_num_reg[23:0] = 24'h2; //-127 0
  10'h380:ex2_result_denorm_round_add_num_reg[23:0] = 24'h4; //-128 -1
  10'h37f:ex2_result_denorm_round_add_num_reg[23:0] = 24'h8; //-129 -2
  10'h37e:ex2_result_denorm_round_add_num_reg[23:0] = 24'h10; //-130 -3
  10'h37d:ex2_result_denorm_round_add_num_reg[23:0] = 24'h20; //-131 -4
  10'h37c:ex2_result_denorm_round_add_num_reg[23:0] = 24'h40; //-132 -5
  10'h37b:ex2_result_denorm_round_add_num_reg[23:0] = 24'h80; //-133 -6
  10'h37a:ex2_result_denorm_round_add_num_reg[23:0] = 24'h100; //-134 -7
  10'h379:ex2_result_denorm_round_add_num_reg[23:0] = 24'h200; //-135 -8
  10'h378:ex2_result_denorm_round_add_num_reg[23:0] = 24'h400; //-136 -9
  10'h377:ex2_result_denorm_round_add_num_reg[23:0] = 24'h800; //-137 -10
  10'h376:ex2_result_denorm_round_add_num_reg[23:0] = 24'h1000; //-138 -11
  10'h375:ex2_result_denorm_round_add_num_reg[23:0] = 24'h2000; //-139 -12
  10'h374:ex2_result_denorm_round_add_num_reg[23:0] = 24'h4000; //-140 -13   
  10'h373:ex2_result_denorm_round_add_num_reg[23:0] = 24'h8000; // -141 -14
  10'h372:ex2_result_denorm_round_add_num_reg[23:0] = 24'h10000;//-142  -15
  10'h371:ex2_result_denorm_round_add_num_reg[23:0] = 24'h20000;//-143 -16
  10'h370:ex2_result_denorm_round_add_num_reg[23:0] = 24'h40000; //-144 -17
  10'h36f:ex2_result_denorm_round_add_num_reg[23:0] = 24'h80000; //-145 -18
  10'h36e:ex2_result_denorm_round_add_num_reg[23:0] = 24'h100000; //-146 -19
  10'h36d:ex2_result_denorm_round_add_num_reg[23:0] = 24'h200000; //-147 -20
  10'h36c:ex2_result_denorm_round_add_num_reg[23:0] = 24'h400000; //-148 -21
  10'h36b:ex2_result_denorm_round_add_num_reg[23:0] = 24'h800000; //-148 -22
  default: ex2_result_denorm_round_add_num_reg[23:0] = 24'h0;  // -23
endcase
end


//===================special result========================
assign ex2_result_zero = vfdsu_ex2_result_zero;
assign ex2_result_qnan = vfdsu_ex2_result_qnan;
assign ex2_result_inf  = vfdsu_ex2_result_inf || 
                         ex2_of_plus && !vfdsu_ex2_of_rm_lfn;
assign ex2_result_lfn  =  
                         ex2_of_plus &&  vfdsu_ex2_of_rm_lfn;



//====================Pipe to EX3===========================

assign ex2_pipe_clk = clk;

always @(posedge ex2_pipe_clk or negedge rst_n)
begin
  if(!rst_n)
  begin
    vfdsu_ex3_result_zero     <= 1'b0;
    vfdsu_ex3_result_qnan     <= 1'b0;
    vfdsu_ex3_result_inf      <= 1'b0;
    vfdsu_ex3_result_lfn      <= 1'b0;
    vfdsu_ex3_of              <= 1'b0;
    vfdsu_ex3_uf              <= 1'b0;
    vfdsu_ex3_nv              <= 1'b0;
    vfdsu_ex3_dz              <= 1'b0;
    vfdsu_ex3_expnt_rst       <= 10'b0;
    vfdsu_ex3_potnt_of        <= 1'b0;
    vfdsu_ex3_potnt_uf        <= 1'b0;
    vfdsu_ex3_rem_sign        <= 1'b0;
    vfdsu_ex3_result_sign     <= 1'b0;
    vfdsu_ex3_qnan_sign       <= 1'b0;    
    vfdsu_ex3_qnan_f[22:0]    <= 23'b0;
    vfdsu_ex3_rm[2:0]         <= 3'b0;
    vfdsu_ex3_result_denorm_round_add_num[23:0] 
                              <= 24'b0;
    vfdsu_ex3_rslt_denorm     <= 1'b0;
    vfdsu_ex3_id_srt_skip     <= 1'b0;
  end
  else if(ex2_pipedown)
  begin
    vfdsu_ex3_result_zero     <= ex2_result_zero; 
    vfdsu_ex3_result_qnan     <= ex2_result_qnan;
    vfdsu_ex3_result_inf      <= ex2_result_inf;
    vfdsu_ex3_result_lfn      <= ex2_result_lfn; 
    vfdsu_ex3_of              <= ex2_of;
    vfdsu_ex3_uf              <= ex2_uf;
    vfdsu_ex3_nv              <= vfdsu_ex2_nv;
    vfdsu_ex3_dz              <= vfdsu_ex2_dz;
    vfdsu_ex3_expnt_rst       <= vfdsu_ex2_expnt_rst;
    vfdsu_ex3_potnt_of        <= ex2_potnt_of;
    vfdsu_ex3_potnt_uf        <= ex2_potnt_uf;
    vfdsu_ex3_rem_sign        <= srt_remainder_sign;
    vfdsu_ex3_result_sign     <= vfdsu_ex2_result_sign;
    vfdsu_ex3_qnan_sign       <= vfdsu_ex2_qnan_sign;    
    vfdsu_ex3_qnan_f[22:0]    <= vfdsu_ex2_qnan_f[22:0];
    vfdsu_ex3_rm[2:0]         <= vfdsu_ex2_rm[2:0];
    vfdsu_ex3_result_denorm_round_add_num[23:0] 
                              <= ex2_result_denorm_round_add_num[23:0];
    vfdsu_ex3_rslt_denorm     <= ex2_rslt_denorm;
    vfdsu_ex3_id_srt_skip     <= ex2_id_nor_srt_skip;
  end
  else
  begin
    vfdsu_ex3_result_zero     <= vfdsu_ex3_result_zero; 
    vfdsu_ex3_result_qnan     <= vfdsu_ex3_result_qnan;
    vfdsu_ex3_result_inf      <= vfdsu_ex3_result_inf;
    vfdsu_ex3_result_lfn      <= vfdsu_ex3_result_lfn;
    vfdsu_ex3_of              <= vfdsu_ex3_of;
    vfdsu_ex3_uf              <= vfdsu_ex3_uf;
    vfdsu_ex3_nv              <= vfdsu_ex3_nv;
    vfdsu_ex3_dz              <= vfdsu_ex3_dz;
    vfdsu_ex3_expnt_rst       <= vfdsu_ex3_expnt_rst;
    vfdsu_ex3_potnt_of        <= vfdsu_ex3_potnt_of;
    vfdsu_ex3_potnt_uf        <= vfdsu_ex3_potnt_uf;
    vfdsu_ex3_rem_sign        <= vfdsu_ex3_rem_sign;
    vfdsu_ex3_result_sign     <= vfdsu_ex3_result_sign;
    vfdsu_ex3_qnan_sign       <= vfdsu_ex3_qnan_sign;     
    vfdsu_ex3_qnan_f[22:0]    <= vfdsu_ex3_qnan_f[22:0];
    vfdsu_ex3_rm[2:0]         <= vfdsu_ex3_rm[2:0];
    vfdsu_ex3_result_denorm_round_add_num[23:0] 
                              <= vfdsu_ex3_result_denorm_round_add_num[23:0];
    vfdsu_ex3_rslt_denorm     <=  vfdsu_ex3_rslt_denorm;
    vfdsu_ex3_id_srt_skip     <=  vfdsu_ex3_id_srt_skip;
  end
end
assign vfdsu_ex3_rem_zero       =  ~|srt_remainder[34:0];
assign srt_ctrl_rem_zero        =  vfdsu_ex3_rem_zero;


//==========================================================
//    SRT Remainder & Divisor for Quotient/Root Generate
//==========================================================

assign initial_divisor_in[29:0]   = {ex1_divisor[23:0],6'b0};

assign initial_remainder_in[34:0] = {2'b00, ex1_remainder[30:1], 3'b0};

assign initial_bound_sel_in[6:0]  = ex1_div ? initial_divisor_in[29:23]:{7{1'b0}};

assign initial_srt_en             = ex1_pipedown;
assign initial_srt_sel_div_in     = ex1_div;
assign initial_srt_sel_sqrt_in    = ex1_sqrt;

assign srt_first_round            = ex2_srt_first_round;

vfdsu_srt_radix16_with_sqrt  x_vfdsu_srt_radix16_with_sqrt (
  .rst_n                (rst_n               ),
  .clk          (clk         ),
  .initial_bound_sel_in    (initial_bound_sel_in   ),
  .initial_divisor_in      (initial_divisor_in     ),
  .initial_remainder_in    (initial_remainder_in   ),
  .initial_srt_en          (initial_srt_en         ),
  .initial_srt_sel_div_in  (initial_srt_sel_div_in ),
  .initial_srt_sel_sqrt_in (initial_srt_sel_sqrt_in),
  .srt_first_round         (srt_first_round        ),
  .srt_remainder           (srt_remainder          ),
  .srt_remainder_out       (srt_remainder_out      ),
  .srt_remainder_sign      (srt_remainder_sign     ),
  .srt_secd_round          (srt_secd_round         ),
  .srt_sm_on               (srt_sm_on              ),
  .total_qt_rt             (total_qt_rt            ),
  .vdiv_qt_rt              (vdiv_qt_rt             )
);

assign total_qt_rt_58[31:0] = {total_qt_rt[31:2],2'b00};

// &ModuleEnd; @443
endmodule



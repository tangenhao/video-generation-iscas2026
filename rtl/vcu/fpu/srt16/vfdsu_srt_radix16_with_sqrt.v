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
module vfdsu_srt_radix16_with_sqrt(
  rst_n,
  clk,
  initial_bound_sel_in,
  initial_divisor_in,
  initial_remainder_in,
  initial_srt_en,
  initial_srt_sel_div_in,
  initial_srt_sel_sqrt_in,
  srt_first_round,
  srt_remainder,
  srt_remainder_out,
  srt_remainder_sign,
  srt_secd_round,
  srt_sm_on,
  total_qt_rt,
  vdiv_qt_rt
);
                 
input           rst_n;  
input           clk;            
input   [6 :0]  initial_bound_sel_in;      
input   [29:0]  initial_divisor_in;        
input   [34:0]  initial_remainder_in;      
input           initial_srt_en;            
input           initial_srt_sel_div_in;    
input           initial_srt_sel_sqrt_in;          
input           srt_first_round;           
input           srt_secd_round;            
input           srt_sm_on;                 
output  [34:0]  srt_remainder;             
output  [33:0]  srt_remainder_out;         
output          srt_remainder_sign;        
output  [31:0]  total_qt_rt;               
output  [31:0]  vdiv_qt_rt;                

// &Regs; @24
reg     [6 :0]  bound_sel;                 
reg     [34:0]  cur_rem;                   
reg     [31:0]  qt_rt_const_shift_std;     
reg     [29:0]  srt_divisor;               
reg     [34:0]  srt_remainder;             
reg     [34:0]  srt_remainder_minus;       
reg     [34:0]  srt_remainder_minus_nxt;   
reg             srt_sel_div;               
reg             srt_sel_sqrt;              
reg     [31:0]  total_qt_rt;               
reg     [31:0]  total_qt_rt_minus;         
reg     [31:0]  total_qt_rt_minus_next;    
reg     [31:0]  total_qt_rt_next;          

// &Wires; @25
wire            bound1_cmp_sign;           
wire            bound2_cmp_sign;           
wire            bound3_cmp_sign;           
wire            bound4_cmp_sign;           
wire            bound5_cmp_sign;           
wire            bound6_cmp_sign;           
wire            bound7_cmp_sign;           
wire            bound8_cmp_sign;           
wire            bound9_cmp_sign;           
wire    [8 :0]  bound_cmp_sign;            
wire            rst_n;  
wire    [34:0]  cur_rem_1;                 
wire    [34:0]  cur_rem_2;                 
wire    [34:0]  cur_rem_3;                 
wire    [34:0]  cur_rem_4;                 
wire    [34:0]  cur_rem_5;                 
wire    [34:0]  cur_rem_6;                 
wire    [34:0]  cur_rem_7;                 
wire    [34:0]  cur_rem_8;                 
wire    [34:0]  cur_rem_9;                 
wire    [11:0]  digit_bound_1;             
wire    [11:0]  digit_bound_2;             
wire    [11:0]  digit_bound_3;             
wire    [11:0]  digit_bound_4;             
wire    [11:0]  digit_bound_5;             
wire    [11:0]  digit_bound_6;             
wire    [11:0]  digit_bound_7;             
wire    [11:0]  digit_bound_8;             
wire    [11:0]  digit_bound_9;             
wire    [34:0]  div_qt_1_rem_add_op1;      
wire    [34:0]  div_qt_2_rem_add_op1;      
wire    [34:0]  div_qt_3_rem_add_op1_0;    
wire    [34:0]  div_qt_3_rem_add_op1_1;    
wire    [34:0]  div_qt_4_rem_add_op1;      
wire    [34:0]  div_qt_5_rem_add_op1_0;    
wire    [34:0]  div_qt_5_rem_add_op1_1;    
wire    [34:0]  div_qt_6_rem_add_op1_0;    
wire    [34:0]  div_qt_6_rem_add_op1_1;    
wire    [34:0]  div_qt_7_rem_add_op1_0;    
wire    [34:0]  div_qt_7_rem_add_op1_1;    
wire    [34:0]  div_qt_8_rem_add_op1;      
wire    [34:0]  div_qt_9_rem_add_op1_0;    
wire    [34:0]  div_qt_9_rem_add_op1_1;    
wire    [34:0]  div_qt_r1_rem_add_op1;     
wire    [34:0]  div_qt_r2_rem_add_op1;     
wire    [34:0]  div_qt_r3_rem_add_op1_0;   
wire    [34:0]  div_qt_r3_rem_add_op1_1;   
wire    [34:0]  div_qt_r4_rem_add_op1;     
wire    [34:0]  div_qt_r5_rem_add_op1_0;   
wire    [34:0]  div_qt_r5_rem_add_op1_1;   
wire    [34:0]  div_qt_r6_rem_add_op1_0;   
wire    [34:0]  div_qt_r6_rem_add_op1_1;   
wire    [34:0]  div_qt_r7_rem_add_op1_0;   
wire    [34:0]  div_qt_r7_rem_add_op1_1;   
wire    [34:0]  div_qt_r8_rem_add_op1;     
wire    [34:0]  div_qt_r9_rem_add_op1_0;   
wire    [34:0]  div_qt_r9_rem_add_op1_1;   
wire    [34:0]  div_rem_add1_op1;          
wire    [34:0]  div_rem_add2_op1;          
wire    [34:0]  div_rem_add3_op1_0;        
wire    [34:0]  div_rem_add3_op1_1;        
wire    [34:0]  div_rem_add4_op1;          
wire    [34:0]  div_rem_add5_op1_0;        
wire    [34:0]  div_rem_add5_op1_1;        
wire    [34:0]  div_rem_add6_op1_0;        
wire    [34:0]  div_rem_add6_op1_1;        
wire    [34:0]  div_rem_add7_op1_0;        
wire    [34:0]  div_rem_add7_op1_1;        
wire    [34:0]  div_rem_add8_op1;          
wire    [34:0]  div_rem_add9_op1_0;        
wire    [34:0]  div_rem_add9_op1_1;        
wire            clk;            
wire    [6 :0]  initial_bound_sel_in;      
wire    [29:0]  initial_divisor_in;        
wire    [34:0]  initial_remainder_in;      
wire            initial_srt_en;            
wire            initial_srt_sel_div_in;    
wire            initial_srt_sel_sqrt_in;       
wire    [11:0]  part_rem;                  
wire    [36:0]  qt_rt_const_q1;            
wire    [36:0]  qt_rt_const_q10;           
wire    [36:0]  qt_rt_const_q11;           
wire    [36:0]  qt_rt_const_q112;          
wire    [36:0]  qt_rt_const_q12;           
wire    [36:0]  qt_rt_const_q128;          
wire    [36:0]  qt_rt_const_q13;           
wire    [36:0]  qt_rt_const_q14;           
wire    [36:0]  qt_rt_const_q15;           
wire    [36:0]  qt_rt_const_q16;           
wire    [36:0]  qt_rt_const_q17;           
wire    [36:0]  qt_rt_const_q192;          
wire    [36:0]  qt_rt_const_q2;            
wire    [36:0]  qt_rt_const_q23;           
wire    [36:0]  qt_rt_const_q24;           
wire    [36:0]  qt_rt_const_q27;           
wire    [36:0]  qt_rt_const_q3;            
wire    [36:0]  qt_rt_const_q31;           
wire    [36:0]  qt_rt_const_q32;           
wire    [36:0]  qt_rt_const_q4;            
wire    [36:0]  qt_rt_const_q44;           
wire    [36:0]  qt_rt_const_q5;            
wire    [36:0]  qt_rt_const_q56;           
wire    [36:0]  qt_rt_const_q6;            
wire    [36:0]  qt_rt_const_q60;           
wire    [36:0]  qt_rt_const_q64;           
wire    [36:0]  qt_rt_const_q7;            
wire    [36:0]  qt_rt_const_q8;            
wire    [36:0]  qt_rt_const_q80;           
wire    [36:0]  qt_rt_const_q9;            
wire    [34:0]  qt_rt_const_shift_std_next; 
wire    [34:0]  rem_add1_op1;              
wire    [34:0]  rem_add2_op1;              
wire    [34:0]  rem_add3_op1_0;            
wire    [34:0]  rem_add3_op1_1;            
wire    [34:0]  rem_add4_op1;              
wire    [34:0]  rem_add5_op1_0;            
wire    [34:0]  rem_add5_op1_1;            
wire    [34:0]  rem_add6_op1_0;            
wire    [34:0]  rem_add6_op1_1;            
wire    [34:0]  rem_add7_op1_0;            
wire    [34:0]  rem_add7_op1_1;            
wire    [34:0]  rem_add8_op1;              
wire    [34:0]  rem_add9_op1_0;            
wire    [34:0]  rem_add9_op1_1;            
wire    [34:0]  rem_minus_minus_6;         
wire            rem_sign;                  
wire    [34:0]  remainder_minus_nor_nxt_0; 
wire    [34:0]  remainder_minus_nor_nxt_1; 
wire    [34:0]  remainder_minus_nor_nxt_2; 
wire    [34:0]  remainder_minus_nor_nxt_3; 
wire    [34:0]  remainder_minus_nor_nxt_4; 
wire    [34:0]  remainder_minus_nor_nxt_5; 
wire    [34:0]  remainder_minus_nor_nxt_6; 
wire    [34:0]  remainder_minus_nor_nxt_7; 
wire    [34:0]  remainder_minus_nor_nxt_8; 
wire    [34:0]  remainder_minus_nor_nxt_9; 
wire    [34:0]  remainder_minus_shift;     
wire    [34:0]  remainder_shift;           
wire            sqrt_first_round;          
wire    [34:0]  sqrt_qt_1_rem_add_op1;     
wire    [34:0]  sqrt_qt_2_rem_add_op1;     
wire    [34:0]  sqrt_qt_3_rem_add_op1_0;   
wire    [34:0]  sqrt_qt_3_rem_add_op1_1;   
wire    [34:0]  sqrt_qt_4_rem_add_op1;     
wire    [34:0]  sqrt_qt_5_rem_add_op1_0;   
wire    [34:0]  sqrt_qt_5_rem_add_op1_1;   
wire    [34:0]  sqrt_qt_6_rem_add_op1_0;   
wire    [34:0]  sqrt_qt_6_rem_add_op1_1;   
wire    [34:0]  sqrt_qt_7_rem_add_op1_0;   
wire    [34:0]  sqrt_qt_7_rem_add_op1_1;   
wire    [34:0]  sqrt_qt_8_rem_add_op1;     
wire    [34:0]  sqrt_qt_9_rem_add_op1_0;   
wire    [34:0]  sqrt_qt_9_rem_add_op1_1;   
wire    [34:0]  sqrt_qt_r1_rem_add_op1;    
wire    [34:0]  sqrt_qt_r2_rem_add_op1;    
wire    [34:0]  sqrt_qt_r3_rem_add_op1_0;  
wire    [34:0]  sqrt_qt_r3_rem_add_op1_1;  
wire    [34:0]  sqrt_qt_r4_rem_add_op1;    
wire    [34:0]  sqrt_qt_r5_rem_add_op1_0;  
wire    [34:0]  sqrt_qt_r5_rem_add_op1_1;  
wire    [34:0]  sqrt_qt_r6_rem_add_op1_0;  
wire    [34:0]  sqrt_qt_r6_rem_add_op1_1;  
wire    [34:0]  sqrt_qt_r7_rem_add_op1_0;  
wire    [34:0]  sqrt_qt_r7_rem_add_op1_1;  
wire    [34:0]  sqrt_qt_r8_rem_add_op1;    
wire    [34:0]  sqrt_qt_r9_rem_add_op1_0;  
wire    [34:0]  sqrt_qt_r9_rem_add_op1_1;  
wire    [34:0]  sqrt_rem_add1_op1;         
wire    [34:0]  sqrt_rem_add2_op1;         
wire    [34:0]  sqrt_rem_add3_op1_0;       
wire    [34:0]  sqrt_rem_add3_op1_1;       
wire    [34:0]  sqrt_rem_add4_op1;         
wire    [34:0]  sqrt_rem_add5_op1_0;       
wire    [34:0]  sqrt_rem_add5_op1_1;       
wire    [34:0]  sqrt_rem_add6_op1_0;       
wire    [34:0]  sqrt_rem_add6_op1_1;       
wire    [34:0]  sqrt_rem_add7_op1_0;       
wire    [34:0]  sqrt_rem_add7_op1_1;       
wire    [34:0]  sqrt_rem_add8_op1;         
wire    [34:0]  sqrt_rem_add9_op1_0;       
wire    [34:0]  sqrt_rem_add9_op1_1;       
wire            sqrt_secd_round;           
wire            sqrt_secd_round_sign;      
wire            srt_div_clk;               
wire            srt_div_clk_en;            
wire            srt_first_round;           
wire            srt_qt_rem_clk;            
wire            srt_qt_rem_clk_en;         
wire    [34:0]  srt_remainder_nxt;         
wire    [33:0]  srt_remainder_out;         
wire            srt_remainder_sign;        
wire            srt_secd_round;            
wire            srt_sm_on;                 
wire    [31:0]  vdiv_qt_rt;                


parameter  DATA_WIDTH = 30;
parameter  REM_WIDTH  = 35;
parameter  QT_WIDTH   = 32;
//==========================================================
//    SRT Remainder & Divisor for Quotient/Root Generate
//==========================================================
assign srt_qt_rem_clk_en = initial_srt_en || srt_sm_on;

assign srt_qt_rem_clk = clk;

assign srt_div_clk = clk;

always @(posedge srt_qt_rem_clk or negedge rst_n)
begin
  if(!rst_n)
    srt_remainder[REM_WIDTH-1:0] <= {REM_WIDTH{1'b0}};
  else if(initial_srt_en)
    srt_remainder[REM_WIDTH-1:0] <= initial_remainder_in[REM_WIDTH-1:0];
  else if(srt_sm_on)
    srt_remainder[REM_WIDTH-1:0] <= srt_remainder_nxt[REM_WIDTH-1:0];
  else
    srt_remainder[REM_WIDTH-1:0] <= srt_remainder[REM_WIDTH-1:0];
end

always @(posedge srt_div_clk or negedge rst_n)
begin
  if(!rst_n)
    srt_divisor[DATA_WIDTH-1:0] <= {DATA_WIDTH{1'b0}};
  else if(initial_srt_en)
    srt_divisor[DATA_WIDTH-1:0] <= initial_divisor_in[DATA_WIDTH-1:0];
  else
    srt_divisor[DATA_WIDTH-1:0] <= srt_divisor[DATA_WIDTH-1:0];
end

always @(posedge srt_qt_rem_clk or negedge rst_n)
begin
  if(!rst_n)
    bound_sel[6:0] <= {7{1'b0}};
  else if(initial_srt_en)
    bound_sel[6:0] <= initial_bound_sel_in[6:0];
  else if(srt_sm_on && srt_sel_sqrt)
    bound_sel[6:0] <= total_qt_rt_next[QT_WIDTH-2:QT_WIDTH-8];
  else
    bound_sel[6:0] <= bound_sel[6:0];
end

always @(posedge srt_div_clk or negedge rst_n)
begin
  if(!rst_n)
    srt_sel_div <= 1'b0;
  else if(initial_srt_en)
    srt_sel_div <= initial_srt_sel_div_in;
  else
    srt_sel_div <= srt_sel_div;
end

always @(posedge srt_div_clk or negedge rst_n)
begin
  if(!rst_n)
    srt_sel_sqrt <= 1'b0;
  else if(initial_srt_en)
    srt_sel_sqrt <= initial_srt_sel_sqrt_in;
  else
    srt_sel_sqrt <= srt_sel_sqrt;
end

always @(posedge srt_qt_rem_clk or negedge rst_n)
begin
  if(!rst_n)
  begin
    qt_rt_const_shift_std[QT_WIDTH-1:0] <= {QT_WIDTH{1'b0}};
    total_qt_rt[QT_WIDTH-1:0]           <= {QT_WIDTH{1'b0}};
    total_qt_rt_minus[QT_WIDTH-1:0]     <= {QT_WIDTH{1'b0}};
  end
  else if(initial_srt_en)
  begin
    qt_rt_const_shift_std[QT_WIDTH-1:0] <= {4'b0001,{(QT_WIDTH-4){1'b0}}};
    total_qt_rt[QT_WIDTH-1:0]           <= {QT_WIDTH{1'b0}};
    total_qt_rt_minus[QT_WIDTH-1:0]     <= {QT_WIDTH{1'b0}};
  end
  else if(srt_sm_on)
  begin
    qt_rt_const_shift_std[QT_WIDTH-1:0] <= qt_rt_const_shift_std_next[QT_WIDTH-1:0];
    total_qt_rt[QT_WIDTH-1:0]           <= total_qt_rt_next[QT_WIDTH-1:0];
    total_qt_rt_minus[QT_WIDTH-1:0]     <= total_qt_rt_minus_next[QT_WIDTH-1:0];
  end
  else
  begin
    qt_rt_const_shift_std[QT_WIDTH-1:0] <= qt_rt_const_shift_std[QT_WIDTH-1:0];
    total_qt_rt[QT_WIDTH-1:0]           <= total_qt_rt[QT_WIDTH-1:0];
    total_qt_rt_minus[QT_WIDTH-1:0]     <= total_qt_rt_minus[QT_WIDTH-1:0];
  end
end


assign vdiv_qt_rt[QT_WIDTH-1:0] = srt_remainder[REM_WIDTH-1] 
                                  ? total_qt_rt_minus[QT_WIDTH-1:0]
                                  : total_qt_rt[QT_WIDTH-1:0];

assign qt_rt_const_shift_std_next[QT_WIDTH-1:0] = {4'b0, qt_rt_const_shift_std[QT_WIDTH-1:4]};

//====================================================
//  boundary  calculation
//====================================================

vfdsu_srt_radix16_bound_table  x_vfdsu_srt_radix16_bound_table (
  .bound_sel            (bound_sel           ),
  .digit_bound_1        (digit_bound_1       ),
  .digit_bound_2        (digit_bound_2       ),
  .digit_bound_3        (digit_bound_3       ),
  .digit_bound_4        (digit_bound_4       ),
  .digit_bound_5        (digit_bound_5       ),
  .digit_bound_6        (digit_bound_6       ),
  .digit_bound_7        (digit_bound_7       ),
  .digit_bound_8        (digit_bound_8       ),
  .digit_bound_9        (digit_bound_9       ),
  .sqrt_first_round     (sqrt_first_round    ),
  .sqrt_secd_round      (sqrt_secd_round     ),
  .sqrt_secd_round_sign (sqrt_secd_round_sign)
);

assign sqrt_first_round = srt_sel_sqrt && srt_first_round;
assign sqrt_secd_round  = srt_sel_sqrt && srt_secd_round;
assign sqrt_secd_round_sign = rem_sign;
assign rem_sign                = srt_remainder[REM_WIDTH-1];
assign part_rem[11:0]          = rem_sign
                                 ? ~srt_remainder[REM_WIDTH-5:REM_WIDTH-16]
                                 : srt_remainder[REM_WIDTH-5:REM_WIDTH-16];

assign bound1_cmp_sign         = part_rem[11:0] < digit_bound_1[11:0];
assign bound2_cmp_sign         = part_rem[11:0] < digit_bound_2[11:0];
assign bound3_cmp_sign         = part_rem[11:0] < digit_bound_3[11:0];
assign bound4_cmp_sign         = part_rem[11:0] < digit_bound_4[11:0];
assign bound5_cmp_sign         = part_rem[11:0] < digit_bound_5[11:0];
assign bound6_cmp_sign         = part_rem[11:0] < digit_bound_6[11:0];
assign bound7_cmp_sign         = part_rem[11:0] < digit_bound_7[11:0];
assign bound8_cmp_sign         = part_rem[11:0] < digit_bound_8[11:0];
assign bound9_cmp_sign         = part_rem[11:0] < digit_bound_9[11:0];
//====================================================
//  remainder calculation
//====================================================
// the root preparation
assign qt_rt_const_q1[REM_WIDTH+1:0]   = {5'b0,qt_rt_const_shift_std[QT_WIDTH-1:0]};
assign qt_rt_const_q2[REM_WIDTH+1:0]   = {4'b0,qt_rt_const_shift_std[QT_WIDTH-1:0],1'b0};
assign qt_rt_const_q4[REM_WIDTH+1:0]   = {3'b0,qt_rt_const_shift_std[QT_WIDTH-1:0],2'b0};
assign qt_rt_const_q8[REM_WIDTH+1:0]   = {2'b0,qt_rt_const_shift_std[QT_WIDTH-1:0],3'b0};
assign qt_rt_const_q16[REM_WIDTH+1:0]  = {1'b0,qt_rt_const_shift_std[QT_WIDTH-1:0],4'b0};
assign qt_rt_const_q32[REM_WIDTH+1:0]  =      {qt_rt_const_shift_std[QT_WIDTH-1:0],5'b0};
assign qt_rt_const_q64[REM_WIDTH+1:0]  =      {qt_rt_const_shift_std[QT_WIDTH-2:0],6'b0};
assign qt_rt_const_q128[REM_WIDTH+1:0] =      {qt_rt_const_shift_std[QT_WIDTH-3:0],7'b0};
assign qt_rt_const_q3[REM_WIDTH+1:0]          =  qt_rt_const_q1[REM_WIDTH+1:0]   
                                                |qt_rt_const_q2[REM_WIDTH+1:0];
assign qt_rt_const_q5[REM_WIDTH+1:0]          =  qt_rt_const_q1[REM_WIDTH+1:0]   
                                                |qt_rt_const_q4[REM_WIDTH+1:0];
assign qt_rt_const_q6[REM_WIDTH+1:0]          =  qt_rt_const_q2[REM_WIDTH+1:0]   
                                                |qt_rt_const_q4[REM_WIDTH+1:0];
assign qt_rt_const_q7[REM_WIDTH+1:0]          =  qt_rt_const_q1[REM_WIDTH+1:0]
                                                |qt_rt_const_q2[REM_WIDTH+1:0]   
                                                |qt_rt_const_q4[REM_WIDTH+1:0];
assign qt_rt_const_q9[REM_WIDTH+1:0]          =  qt_rt_const_q1[REM_WIDTH+1:0]
                                                |qt_rt_const_q8[REM_WIDTH+1:0];
assign qt_rt_const_q10[REM_WIDTH+1:0]         =  qt_rt_const_q2[REM_WIDTH+1:0]   
                                                |qt_rt_const_q8[REM_WIDTH+1:0];
assign qt_rt_const_q11[REM_WIDTH+1:0]         =  qt_rt_const_q1[REM_WIDTH+1:0]
                                                |qt_rt_const_q2[REM_WIDTH+1:0]   
                                                |qt_rt_const_q8[REM_WIDTH+1:0];
assign qt_rt_const_q12[REM_WIDTH+1:0]         =  qt_rt_const_q4[REM_WIDTH+1:0]
                                                |qt_rt_const_q8[REM_WIDTH+1:0];              
assign qt_rt_const_q13[REM_WIDTH+1:0]         =  qt_rt_const_q1[REM_WIDTH+1:0]
                                                |qt_rt_const_q4[REM_WIDTH+1:0]
                                                |qt_rt_const_q8[REM_WIDTH+1:0]; 
assign qt_rt_const_q14[REM_WIDTH+1:0]         =  qt_rt_const_q2[REM_WIDTH+1:0]
                                                |qt_rt_const_q4[REM_WIDTH+1:0]
                                                |qt_rt_const_q8[REM_WIDTH+1:0];
assign qt_rt_const_q15[REM_WIDTH+1:0]         =  qt_rt_const_q1[REM_WIDTH+1:0]
                                                |qt_rt_const_q2[REM_WIDTH+1:0]   
                                                |qt_rt_const_q4[REM_WIDTH+1:0]   
                                                |qt_rt_const_q8[REM_WIDTH+1:0]; 
assign qt_rt_const_q17[REM_WIDTH+1:0]         =  qt_rt_const_q1[REM_WIDTH+1:0]
                                               |qt_rt_const_q16[REM_WIDTH+1:0];
assign qt_rt_const_q23[REM_WIDTH+1:0]         =  qt_rt_const_q1[REM_WIDTH+1:0]   
                                                |qt_rt_const_q2[REM_WIDTH+1:0]   
                                                |qt_rt_const_q4[REM_WIDTH+1:0] 
                                               |qt_rt_const_q16[REM_WIDTH+1:0];
assign qt_rt_const_q24[REM_WIDTH+1:0]         =  qt_rt_const_q8[REM_WIDTH+1:0]   
                                               |qt_rt_const_q16[REM_WIDTH+1:0];
assign qt_rt_const_q27[REM_WIDTH+1:0]         =  qt_rt_const_q1[REM_WIDTH+1:0]   
                                                |qt_rt_const_q2[REM_WIDTH+1:0]   
                                                |qt_rt_const_q8[REM_WIDTH+1:0]   
                                               |qt_rt_const_q16[REM_WIDTH+1:0];  
assign qt_rt_const_q31[REM_WIDTH+1:0]         =  qt_rt_const_q1[REM_WIDTH+1:0]
                                                |qt_rt_const_q2[REM_WIDTH+1:0]   
                                                |qt_rt_const_q4[REM_WIDTH+1:0]   
                                                |qt_rt_const_q8[REM_WIDTH+1:0]   
                                               |qt_rt_const_q16[REM_WIDTH+1:0];
assign qt_rt_const_q44[REM_WIDTH+1:0]         =  qt_rt_const_q4[REM_WIDTH+1:0]
                                                |qt_rt_const_q8[REM_WIDTH+1:0]   
                                               |qt_rt_const_q32[REM_WIDTH+1:0]; 
assign qt_rt_const_q56[REM_WIDTH+1:0]         =  qt_rt_const_q8[REM_WIDTH+1:0]
                                               |qt_rt_const_q16[REM_WIDTH+1:0]   
                                               |qt_rt_const_q32[REM_WIDTH+1:0]; 
assign qt_rt_const_q60[REM_WIDTH+1:0]         =  qt_rt_const_q4[REM_WIDTH+1:0]   
                                                |qt_rt_const_q8[REM_WIDTH+1:0]   
                                               |qt_rt_const_q16[REM_WIDTH+1:0]   
                                               |qt_rt_const_q32[REM_WIDTH+1:0]; 
assign  qt_rt_const_q80[REM_WIDTH+1:0]       =  qt_rt_const_q16[REM_WIDTH+1:0]
                                               |qt_rt_const_q64[REM_WIDTH+1:0]; 
assign qt_rt_const_q112[REM_WIDTH+1:0]       =  qt_rt_const_q16[REM_WIDTH+1:0]   
                                               |qt_rt_const_q32[REM_WIDTH+1:0]
                                               |qt_rt_const_q64[REM_WIDTH+1:0]; 
assign qt_rt_const_q192[REM_WIDTH+1:0]       =  qt_rt_const_q64[REM_WIDTH+1:0]
                                              |qt_rt_const_q128[REM_WIDTH+1:0];
//=====================================
// the sqrt current remainder oprand b
//=====================================
// the root is negative
// -1
assign sqrt_qt_r1_rem_add_op1[REM_WIDTH-1:0]  = {4'b0,total_qt_rt_minus[QT_WIDTH-1:1]}
                                                |qt_rt_const_q31[REM_WIDTH+1:2];
//-2                                            
assign sqrt_qt_r2_rem_add_op1[REM_WIDTH-1:0]  =  {3'b0,total_qt_rt_minus[QT_WIDTH-1:0]}
                                                |qt_rt_const_q60[REM_WIDTH+1:2];
//-4
assign sqrt_qt_r4_rem_add_op1[REM_WIDTH-1:0]   = {2'b0,total_qt_rt_minus[QT_WIDTH-1:0],1'b0}
                                                |qt_rt_const_q112[REM_WIDTH+1:2]; 
//-8                                                
assign sqrt_qt_r8_rem_add_op1[REM_WIDTH-1:0]   = {1'b0,total_qt_rt_minus[QT_WIDTH-1:0],2'b0}
                                                |qt_rt_const_q192[REM_WIDTH+1:2]; 
//-3
assign sqrt_qt_r3_rem_add_op1_0[REM_WIDTH-1:0] = sqrt_qt_r2_rem_add_op1[REM_WIDTH-1:0];
assign sqrt_qt_r3_rem_add_op1_1[REM_WIDTH-1:0] = {4'b0,total_qt_rt_minus[QT_WIDTH-1:1]}
                                                |qt_rt_const_q27[REM_WIDTH+1:2];
//-5 112+23q-i-1
assign sqrt_qt_r5_rem_add_op1_0[REM_WIDTH-1:0] = sqrt_qt_r4_rem_add_op1[REM_WIDTH-1:0];
assign sqrt_qt_r5_rem_add_op1_1[REM_WIDTH-1:0] = {4'b0,total_qt_rt_minus[QT_WIDTH-1:1]}
                                                |qt_rt_const_q23[REM_WIDTH+1:2];
//-6                                                
assign sqrt_qt_r6_rem_add_op1_0[REM_WIDTH-1:0] = sqrt_qt_r4_rem_add_op1[REM_WIDTH-1:0];
assign sqrt_qt_r6_rem_add_op1_1[REM_WIDTH-1:0] = {3'b0,total_qt_rt_minus[QT_WIDTH-1:0]}
                                                |qt_rt_const_q44[REM_WIDTH+1:2];
//-7  
assign sqrt_qt_r7_rem_add_op1_0[REM_WIDTH-1:0] = sqrt_qt_r8_rem_add_op1[REM_WIDTH-1:0];
assign sqrt_qt_r7_rem_add_op1_1[REM_WIDTH-1:0] = ~({4'b0,total_qt_rt_minus[QT_WIDTH-1:1]}
                                                   |qt_rt_const_q17[REM_WIDTH+1:2]);
//-9
assign sqrt_qt_r9_rem_add_op1_0[REM_WIDTH-1:0] = sqrt_qt_r8_rem_add_op1[REM_WIDTH-1:0];
assign sqrt_qt_r9_rem_add_op1_1[REM_WIDTH-1:0] = {4'b0,total_qt_rt_minus[QT_WIDTH-1:1]}
                                                | qt_rt_const_q15[REM_WIDTH+1:2];
// the root is positive
// 1
assign sqrt_qt_1_rem_add_op1[REM_WIDTH-1:0]    =  ~({4'b0,total_qt_rt[QT_WIDTH-1:1]} 
                                                  | qt_rt_const_q1[REM_WIDTH+1:2]);           
// 2
assign sqrt_qt_2_rem_add_op1[REM_WIDTH-1:0]    = ~({3'b0,total_qt_rt[QT_WIDTH-1:0]} 
                                                  | qt_rt_const_q4[REM_WIDTH+1:2]);
// 4
assign sqrt_qt_4_rem_add_op1[REM_WIDTH-1:0]    = ~({2'b0,total_qt_rt[QT_WIDTH-1:0],1'b0} 
                                                  | qt_rt_const_q16[REM_WIDTH+1:2]);
// 8
assign sqrt_qt_8_rem_add_op1[REM_WIDTH-1:0]    = ~({1'b0,total_qt_rt[QT_WIDTH-1:0],2'b0} 
                                                  | qt_rt_const_q64[REM_WIDTH+1:2]);  
// 3
assign sqrt_qt_3_rem_add_op1_0[REM_WIDTH-1:0]  = ~({3'b0,total_qt_rt[QT_WIDTH-1:0]}
                                                  |qt_rt_const_q8[REM_WIDTH+1:2]);
assign sqrt_qt_3_rem_add_op1_1[REM_WIDTH-1:0]  = sqrt_qt_1_rem_add_op1[REM_WIDTH-1:0];
//5
assign sqrt_qt_5_rem_add_op1_0[REM_WIDTH-1:0]  = ~({2'b0,total_qt_rt[QT_WIDTH-1:0],1'b0} 
                                                  | qt_rt_const_q24[REM_WIDTH+1:2]);
assign sqrt_qt_5_rem_add_op1_1[REM_WIDTH-1:0]  = sqrt_qt_1_rem_add_op1[REM_WIDTH-1:0];
//6
assign sqrt_qt_6_rem_add_op1_0[REM_WIDTH-1:0]  = ~({2'b0,total_qt_rt[QT_WIDTH-1:0],1'b0} 
                                                  | qt_rt_const_q32[REM_WIDTH+1:2]);
assign sqrt_qt_6_rem_add_op1_1[REM_WIDTH-1:0]  = sqrt_qt_2_rem_add_op1[REM_WIDTH-1:0];
//7
assign sqrt_qt_7_rem_add_op1_0[REM_WIDTH-1:0]  = ~({1'b0,total_qt_rt[QT_WIDTH-1:0],2'b0} 
                                                  | qt_rt_const_q56[REM_WIDTH+1:2]);
assign sqrt_qt_7_rem_add_op1_1[REM_WIDTH-1:0]  = {4'b0,total_qt_rt[QT_WIDTH-1:1]} 
                                                  | qt_rt_const_q7[REM_WIDTH+1:2];
//9
assign sqrt_qt_9_rem_add_op1_0[REM_WIDTH-1:0]  = ~({1'b0,total_qt_rt[QT_WIDTH-1:0],2'b0} 
                                                  | qt_rt_const_q80[REM_WIDTH+1:2]);
assign sqrt_qt_9_rem_add_op1_1[REM_WIDTH-1:0]  = sqrt_qt_1_rem_add_op1[REM_WIDTH-1:0];

assign sqrt_rem_add1_op1[REM_WIDTH-1:0]        = rem_sign 
                                                 ? sqrt_qt_r1_rem_add_op1[REM_WIDTH-1:0]
                                                 : sqrt_qt_1_rem_add_op1[REM_WIDTH-1:0];
assign sqrt_rem_add2_op1[REM_WIDTH-1:0]        = rem_sign
                                                 ? sqrt_qt_r2_rem_add_op1[REM_WIDTH-1:0]
                                                 : sqrt_qt_2_rem_add_op1[REM_WIDTH-1:0];
assign sqrt_rem_add4_op1[REM_WIDTH-1:0]        = rem_sign 
                                                 ? sqrt_qt_r4_rem_add_op1[REM_WIDTH-1:0]
                                                 : sqrt_qt_4_rem_add_op1[REM_WIDTH-1:0];
assign sqrt_rem_add8_op1[REM_WIDTH-1:0]        = rem_sign
                                                 ? sqrt_qt_r8_rem_add_op1[REM_WIDTH-1:0]
                                                 : sqrt_qt_8_rem_add_op1[REM_WIDTH-1:0];     
assign sqrt_rem_add3_op1_0[REM_WIDTH-1:0]      = rem_sign 
                                                ? sqrt_qt_r3_rem_add_op1_0[REM_WIDTH-1:0]
                                                : sqrt_qt_3_rem_add_op1_0[REM_WIDTH-1:0];
assign sqrt_rem_add3_op1_1[REM_WIDTH-1:0]      = rem_sign 
                                                ? sqrt_qt_r3_rem_add_op1_1[REM_WIDTH-1:0]
                                                : sqrt_qt_3_rem_add_op1_1[REM_WIDTH-1:0];
assign sqrt_rem_add5_op1_0[REM_WIDTH-1:0]      = rem_sign 
                                                ? sqrt_qt_r5_rem_add_op1_0[REM_WIDTH-1:0]
                                                : sqrt_qt_5_rem_add_op1_0[REM_WIDTH-1:0];
assign sqrt_rem_add5_op1_1[REM_WIDTH-1:0]      = rem_sign 
                                                ? sqrt_qt_r5_rem_add_op1_1[REM_WIDTH-1:0]
                                                : sqrt_qt_5_rem_add_op1_1[REM_WIDTH-1:0];
assign sqrt_rem_add6_op1_0[REM_WIDTH-1:0]      = rem_sign 
                                                ? sqrt_qt_r6_rem_add_op1_0[REM_WIDTH-1:0]
                                                : sqrt_qt_6_rem_add_op1_0[REM_WIDTH-1:0];
assign sqrt_rem_add6_op1_1[REM_WIDTH-1:0]      = rem_sign 
                                                ? sqrt_qt_r6_rem_add_op1_1[REM_WIDTH-1:0]
                                                : sqrt_qt_6_rem_add_op1_1[REM_WIDTH-1:0];
assign sqrt_rem_add7_op1_0[REM_WIDTH-1:0]      = rem_sign 
                                                ? sqrt_qt_r7_rem_add_op1_0[REM_WIDTH-1:0]
                                                : sqrt_qt_7_rem_add_op1_0[REM_WIDTH-1:0];
assign sqrt_rem_add7_op1_1[REM_WIDTH-1:0]      = rem_sign 
                                                ? sqrt_qt_r7_rem_add_op1_1[REM_WIDTH-1:0]
                                                : sqrt_qt_7_rem_add_op1_1[REM_WIDTH-1:0];
assign sqrt_rem_add9_op1_0[REM_WIDTH-1:0]      = rem_sign 
                                                ? sqrt_qt_r9_rem_add_op1_0[REM_WIDTH-1:0]
                                                : sqrt_qt_9_rem_add_op1_0[REM_WIDTH-1:0];
assign sqrt_rem_add9_op1_1[REM_WIDTH-1:0]      = rem_sign 
                                                ? sqrt_qt_r9_rem_add_op1_1[REM_WIDTH-1:0]
                                                : sqrt_qt_9_rem_add_op1_1[REM_WIDTH-1:0];

//=====================================
// the div current remainder oprand b
//=====================================
//negative
assign div_qt_r1_rem_add_op1[REM_WIDTH-1:0]    = {5'b0,srt_divisor[DATA_WIDTH-1:0]};
assign div_qt_r2_rem_add_op1[REM_WIDTH-1:0]    = {4'b0,srt_divisor[DATA_WIDTH-1:0],1'b0};
assign div_qt_r4_rem_add_op1[REM_WIDTH-1:0]    = {3'b0,srt_divisor[DATA_WIDTH-1:0],2'b0};
assign div_qt_r8_rem_add_op1[REM_WIDTH-1:0]    = {2'b0,srt_divisor[DATA_WIDTH-1:0],3'b0};
assign div_qt_r3_rem_add_op1_0[REM_WIDTH-1:0]  = div_qt_r2_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_r3_rem_add_op1_1[REM_WIDTH-1:0]  = div_qt_r1_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_r5_rem_add_op1_0[REM_WIDTH-1:0]  = div_qt_r4_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_r5_rem_add_op1_1[REM_WIDTH-1:0]  = div_qt_r1_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_r6_rem_add_op1_0[REM_WIDTH-1:0]  = div_qt_r4_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_r6_rem_add_op1_1[REM_WIDTH-1:0]  = div_qt_r2_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_r7_rem_add_op1_0[REM_WIDTH-1:0]  = div_qt_r8_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_r7_rem_add_op1_1[REM_WIDTH-1:0]  =~div_qt_r1_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_r9_rem_add_op1_0[REM_WIDTH-1:0]  = div_qt_r8_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_r9_rem_add_op1_1[REM_WIDTH-1:0]  = div_qt_r1_rem_add_op1[REM_WIDTH-1:0];
//positive 
assign div_qt_1_rem_add_op1[REM_WIDTH-1:0]     =~div_qt_r1_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_2_rem_add_op1[REM_WIDTH-1:0]     =~div_qt_r2_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_4_rem_add_op1[REM_WIDTH-1:0]     =~div_qt_r4_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_8_rem_add_op1[REM_WIDTH-1:0]     =~div_qt_r8_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_3_rem_add_op1_0[REM_WIDTH-1:0]   = div_qt_2_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_3_rem_add_op1_1[REM_WIDTH-1:0]   = div_qt_1_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_5_rem_add_op1_0[REM_WIDTH-1:0]   = div_qt_4_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_5_rem_add_op1_1[REM_WIDTH-1:0]   = div_qt_1_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_6_rem_add_op1_0[REM_WIDTH-1:0]   = div_qt_4_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_6_rem_add_op1_1[REM_WIDTH-1:0]   = div_qt_2_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_7_rem_add_op1_0[REM_WIDTH-1:0]   = div_qt_8_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_7_rem_add_op1_1[REM_WIDTH-1:0]   = ~div_qt_1_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_9_rem_add_op1_0[REM_WIDTH-1:0]   = div_qt_8_rem_add_op1[REM_WIDTH-1:0];
assign div_qt_9_rem_add_op1_1[REM_WIDTH-1:0]   = div_qt_1_rem_add_op1[REM_WIDTH-1:0];
assign div_rem_add1_op1[REM_WIDTH-1:0]         = rem_sign ? div_qt_r1_rem_add_op1[REM_WIDTH-1:0]
                                                          : div_qt_1_rem_add_op1[REM_WIDTH-1:0];
assign div_rem_add2_op1[REM_WIDTH-1:0]         = rem_sign ? div_qt_r2_rem_add_op1[REM_WIDTH-1:0]
                                                          : div_qt_2_rem_add_op1[REM_WIDTH-1:0];
assign div_rem_add4_op1[REM_WIDTH-1:0]         = rem_sign ? div_qt_r4_rem_add_op1[REM_WIDTH-1:0]
                                                          : div_qt_4_rem_add_op1[REM_WIDTH-1:0];
assign div_rem_add8_op1[REM_WIDTH-1:0]         = rem_sign ? div_qt_r8_rem_add_op1[REM_WIDTH-1:0]
                                                          : div_qt_8_rem_add_op1[REM_WIDTH-1:0];
assign div_rem_add3_op1_0[REM_WIDTH-1:0]       = rem_sign 
                                                 ? div_qt_r3_rem_add_op1_0[REM_WIDTH-1:0]
                                                 : div_qt_3_rem_add_op1_0[REM_WIDTH-1:0];
assign div_rem_add3_op1_1[REM_WIDTH-1:0]       = rem_sign 
                                                 ? div_qt_r3_rem_add_op1_1[REM_WIDTH-1:0]
                                                 : div_qt_3_rem_add_op1_1[REM_WIDTH-1:0];
assign div_rem_add5_op1_0[REM_WIDTH-1:0]       = rem_sign 
                                                 ? div_qt_r5_rem_add_op1_0[REM_WIDTH-1:0]
                                                 : div_qt_5_rem_add_op1_0[REM_WIDTH-1:0];
assign div_rem_add5_op1_1[REM_WIDTH-1:0]       = rem_sign 
                                                 ? div_qt_r5_rem_add_op1_1[REM_WIDTH-1:0]
                                                 : div_qt_5_rem_add_op1_1[REM_WIDTH-1:0];
assign div_rem_add6_op1_0[REM_WIDTH-1:0]       = rem_sign 
                                                 ? div_qt_r6_rem_add_op1_0[REM_WIDTH-1:0]
                                                 : div_qt_6_rem_add_op1_0[REM_WIDTH-1:0];
assign div_rem_add6_op1_1[REM_WIDTH-1:0]       = rem_sign 
                                                 ? div_qt_r6_rem_add_op1_1[REM_WIDTH-1:0]
                                                 : div_qt_6_rem_add_op1_1[REM_WIDTH-1:0];
assign div_rem_add7_op1_0[REM_WIDTH-1:0]       = rem_sign 
                                                 ? div_qt_r7_rem_add_op1_0[REM_WIDTH-1:0]
                                                 : div_qt_7_rem_add_op1_0[REM_WIDTH-1:0];
assign div_rem_add7_op1_1[REM_WIDTH-1:0]       = rem_sign 
                                                 ? div_qt_r7_rem_add_op1_1[REM_WIDTH-1:0]
                                                 : div_qt_7_rem_add_op1_1[REM_WIDTH-1:0];
assign div_rem_add9_op1_0[REM_WIDTH-1:0]       = rem_sign 
                                                 ? div_qt_r9_rem_add_op1_0[REM_WIDTH-1:0]
                                                 : div_qt_9_rem_add_op1_0[REM_WIDTH-1:0];
assign div_rem_add9_op1_1[REM_WIDTH-1:0]       = rem_sign 
                                                 ? div_qt_r9_rem_add_op1_1[REM_WIDTH-1:0]
                                                 : div_qt_9_rem_add_op1_1[REM_WIDTH-1:0];
//=====================================
// the remainder calculation
//=====================================
assign rem_add1_op1[REM_WIDTH-1:0]     = ({REM_WIDTH{srt_sel_div}}  &  div_rem_add1_op1[REM_WIDTH-1:0])
                                        |({REM_WIDTH{srt_sel_sqrt}} & sqrt_rem_add1_op1[REM_WIDTH-1:0]);
assign rem_add2_op1[REM_WIDTH-1:0]     = ({REM_WIDTH{srt_sel_div}}  &  div_rem_add2_op1[REM_WIDTH-1:0])
                                        |({REM_WIDTH{srt_sel_sqrt}} & sqrt_rem_add2_op1[REM_WIDTH-1:0]);
assign rem_add4_op1[REM_WIDTH-1:0]     = ({REM_WIDTH{srt_sel_div}}  &  div_rem_add4_op1[REM_WIDTH-1:0])
                                        |({REM_WIDTH{srt_sel_sqrt}} & sqrt_rem_add4_op1[REM_WIDTH-1:0]);
assign rem_add8_op1[REM_WIDTH-1:0]     = ({REM_WIDTH{srt_sel_div}}  &  div_rem_add8_op1[REM_WIDTH-1:0])
                                        |({REM_WIDTH{srt_sel_sqrt}} & sqrt_rem_add8_op1[REM_WIDTH-1:0]);
assign rem_add3_op1_0[REM_WIDTH-1:0]   = ({REM_WIDTH{srt_sel_div}}  &  div_rem_add3_op1_0[REM_WIDTH-1:0])
                                        |({REM_WIDTH{srt_sel_sqrt}} & sqrt_rem_add3_op1_0[REM_WIDTH-1:0]);
assign rem_add3_op1_1[REM_WIDTH-1:0]   = ({REM_WIDTH{srt_sel_div}}  &  div_rem_add3_op1_1[REM_WIDTH-1:0])
                                        |({REM_WIDTH{srt_sel_sqrt}} & sqrt_rem_add3_op1_1[REM_WIDTH-1:0]);
assign rem_add5_op1_0[REM_WIDTH-1:0]   = ({REM_WIDTH{srt_sel_div}}  &  div_rem_add5_op1_0[REM_WIDTH-1:0])
                                        |({REM_WIDTH{srt_sel_sqrt}} & sqrt_rem_add5_op1_0[REM_WIDTH-1:0]);
assign rem_add5_op1_1[REM_WIDTH-1:0]   = ({REM_WIDTH{srt_sel_div}}  &  div_rem_add5_op1_1[REM_WIDTH-1:0])
                                        |({REM_WIDTH{srt_sel_sqrt}} & sqrt_rem_add5_op1_1[REM_WIDTH-1:0]);
assign rem_add6_op1_0[REM_WIDTH-1:0]   = ({REM_WIDTH{srt_sel_div}}  &  div_rem_add6_op1_0[REM_WIDTH-1:0])
                                        |({REM_WIDTH{srt_sel_sqrt}} & sqrt_rem_add6_op1_0[REM_WIDTH-1:0]);
assign rem_add6_op1_1[REM_WIDTH-1:0]   = ({REM_WIDTH{srt_sel_div}}  &  div_rem_add6_op1_1[REM_WIDTH-1:0])
                                        |({REM_WIDTH{srt_sel_sqrt}} & sqrt_rem_add6_op1_1[REM_WIDTH-1:0]);
assign rem_add7_op1_0[REM_WIDTH-1:0]   = ({REM_WIDTH{srt_sel_div}}  &  div_rem_add7_op1_0[REM_WIDTH-1:0])
                                        |({REM_WIDTH{srt_sel_sqrt}} & sqrt_rem_add7_op1_0[REM_WIDTH-1:0]);
assign rem_add7_op1_1[REM_WIDTH-1:0]   = ({REM_WIDTH{srt_sel_div}}  &  div_rem_add7_op1_1[REM_WIDTH-1:0])
                                        |({REM_WIDTH{srt_sel_sqrt}} & sqrt_rem_add7_op1_1[REM_WIDTH-1:0]);
assign rem_add9_op1_0[REM_WIDTH-1:0]   = ({REM_WIDTH{srt_sel_div}}  &  div_rem_add9_op1_0[REM_WIDTH-1:0])
                                        |({REM_WIDTH{srt_sel_sqrt}} & sqrt_rem_add9_op1_0[REM_WIDTH-1:0]);
assign rem_add9_op1_1[REM_WIDTH-1:0]   = ({REM_WIDTH{srt_sel_div}}  &  div_rem_add9_op1_1[REM_WIDTH-1:0])
                                        |({REM_WIDTH{srt_sel_sqrt}} & sqrt_rem_add9_op1_1[REM_WIDTH-1:0]);
// remainder calculation for all of the remainders
assign remainder_shift[REM_WIDTH-1:0]  = {srt_remainder[REM_WIDTH-5:0],4'b0};

assign cur_rem_1[REM_WIDTH-1:0]        = $unsigned($signed(remainder_shift[REM_WIDTH-1:0])
                                         + $signed(rem_add1_op1[REM_WIDTH-1:0])
                                         + $signed({{REM_WIDTH-1{1'b0}},~rem_sign}));   
assign cur_rem_2[REM_WIDTH-1:0]        = $unsigned($signed(remainder_shift[REM_WIDTH-1:0])
                                         + $signed(rem_add2_op1[REM_WIDTH-1:0])
                                         + $signed({{REM_WIDTH-1{1'b0}},~rem_sign}));  
assign cur_rem_4[REM_WIDTH-1:0]        = $unsigned($signed(remainder_shift[REM_WIDTH-1:0])
                                         + $signed(rem_add4_op1[REM_WIDTH-1:0])
                                         + $signed({{REM_WIDTH-1{1'b0}},~rem_sign}));   
assign cur_rem_8[REM_WIDTH-1:0]        = $unsigned($signed(remainder_shift[REM_WIDTH-1:0])
                                         + $signed(rem_add8_op1[REM_WIDTH-1:0])
                                         + $signed({{REM_WIDTH-1{1'b0}},~rem_sign}));  
assign cur_rem_3[REM_WIDTH-1:0]        = $unsigned($signed(remainder_shift[REM_WIDTH-1:0])
                                         + $signed(rem_add3_op1_0[REM_WIDTH-1:0])
                                         + $signed(rem_add3_op1_1[REM_WIDTH-1:0])
                                         + $signed({{REM_WIDTH-2{1'b0}},~rem_sign,1'b0}));
assign cur_rem_5[REM_WIDTH-1:0]        = $unsigned($signed(remainder_shift[REM_WIDTH-1:0])
                                         + $signed(rem_add5_op1_0[REM_WIDTH-1:0])
                                         + $signed(rem_add5_op1_1[REM_WIDTH-1:0])
                                         + $signed({{REM_WIDTH-2{1'b0}},~rem_sign,1'b0}));
assign cur_rem_6[REM_WIDTH-1:0]        = $unsigned($signed(remainder_shift[REM_WIDTH-1:0])
                                         + $signed(rem_add6_op1_0[REM_WIDTH-1:0])
                                         + $signed(rem_add6_op1_1[REM_WIDTH-1:0])
                                         + $signed({{REM_WIDTH-2{1'b0}},~rem_sign,1'b0}));
assign cur_rem_7[REM_WIDTH-1:0]        = $unsigned($signed(remainder_shift[REM_WIDTH-1:0])
                                         + $signed(rem_add7_op1_0[REM_WIDTH-1:0])
                                         + $signed(rem_add7_op1_1[REM_WIDTH-1:0])
                                         + $signed({{REM_WIDTH-1{1'b0}},1'b1}));
assign cur_rem_9[REM_WIDTH-1:0]        = $unsigned($signed(remainder_shift[REM_WIDTH-1:0])
                                         + $signed(rem_add9_op1_0[REM_WIDTH-1:0])
                                         + $signed(rem_add9_op1_1[REM_WIDTH-1:0])
                                         + $signed({{REM_WIDTH-2{1'b0}},~rem_sign,1'b0}));
//csky vperl_on
//====================================================
//  quotient selection
//==================================================== 
assign bound_cmp_sign[8:0] =  {bound1_cmp_sign,bound2_cmp_sign,bound3_cmp_sign,bound4_cmp_sign,
             bound5_cmp_sign,bound6_cmp_sign,bound7_cmp_sign,bound8_cmp_sign,bound9_cmp_sign};

// &CombBeg; @582
always @( rem_sign
       or bound_cmp_sign[8:0]
       or qt_rt_const_q10[31:0]
       or qt_rt_const_q6[31:0]
       or qt_rt_const_q12[31:0]
       or qt_rt_const_q13[31:0]
       or qt_rt_const_q5[31:0]
       or qt_rt_const_q9[31:0]
       or qt_rt_const_q8[31:0]
       or total_qt_rt_minus[31:0]
       or qt_rt_const_q4[31:0]
       or qt_rt_const_q2[31:0]
       or qt_rt_const_q15[31:0]
       or qt_rt_const_q1[31:0]
       or qt_rt_const_q7[31:0]
       or qt_rt_const_q14[31:0]
       or qt_rt_const_q3[31:0]
       or qt_rt_const_q11[31:0]
       or total_qt_rt[31:0])
begin
case({rem_sign,bound_cmp_sign[8:0]})
  10'b0111111111: //0
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q15[QT_WIDTH-1:0];
  end
  10'b0011111111: //1
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q1[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt[QT_WIDTH-1:0];
  end
  10'b0001111111://2
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q2[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q1[QT_WIDTH-1:0];
  end
  10'b0000111111://3
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q3[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q2[QT_WIDTH-1:0];
  end
  10'b0000011111://4
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q4[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q3[QT_WIDTH-1:0];
  end
  10'b0000001111://5
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q5[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q4[QT_WIDTH-1:0];
  end
  10'b0000000111://6
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q6[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q5[QT_WIDTH-1:0];
  end
  10'b0000000011://7
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q7[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q6[QT_WIDTH-1:0];
  end
  10'b0000000001://8
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q8[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q7[QT_WIDTH-1:0];
  end
  10'b0000000000://9
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q9[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt[QT_WIDTH-1:0]
                                            |qt_rt_const_q8[QT_WIDTH-1:0];
  end
  10'b1111111111: //0
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q15[QT_WIDTH-1:0];
  end
  10'b1011111111: //-1
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q15[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q14[QT_WIDTH-1:0];
  end
  10'b1001111111://-2
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q14[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q13[QT_WIDTH-1:0];
  end
  10'b1000111111://-3
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q13[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q12[QT_WIDTH-1:0];
  end
  10'b1000011111://-4
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q12[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q11[QT_WIDTH-1:0];
  end
  10'b1000001111://-5
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q11[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q10[QT_WIDTH-1:0];
  end
  10'b1000000111://-6
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q10[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q9[QT_WIDTH-1:0];
  end
  10'b1000000011://-7
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q9[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q8[QT_WIDTH-1:0];
  end
  10'b1000000001://-8
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q8[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q7[QT_WIDTH-1:0];
  end
  10'b1000000000://-9
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q7[QT_WIDTH-1:0];
    total_qt_rt_minus_next[QT_WIDTH-1:0] = total_qt_rt_minus[QT_WIDTH-1:0]
                                            |qt_rt_const_q6[QT_WIDTH-1:0];
  end
  default :
  begin
    total_qt_rt_next[QT_WIDTH-1:0]       = {QT_WIDTH{1'bx}};
    total_qt_rt_minus_next[QT_WIDTH-1:0] = {QT_WIDTH{1'bx}};
  end
endcase
// &CombEnd; @727
end
//====================================================
//  remainder selection
//====================================================
// &CombBeg; @731
always @( cur_rem_2[34:0]
       or remainder_shift[34:0]
       or bound_cmp_sign[8:0]
       or cur_rem_6[34:0]
       or cur_rem_8[34:0]
       or cur_rem_3[34:0]
       or cur_rem_7[34:0]
       or cur_rem_4[34:0]
       or cur_rem_5[34:0]
       or cur_rem_9[34:0]
       or cur_rem_1[34:0])
begin
case(bound_cmp_sign[8:0])
  9'b111111111: cur_rem[REM_WIDTH-1:0]   = remainder_shift[REM_WIDTH-1:0]; //0
  9'b011111111: cur_rem[REM_WIDTH-1:0]   = cur_rem_1[REM_WIDTH-1:0];       //+-1          
  9'b001111111: cur_rem[REM_WIDTH-1:0]   = cur_rem_2[REM_WIDTH-1:0];       //+-2          
  9'b000111111: cur_rem[REM_WIDTH-1:0]   = cur_rem_3[REM_WIDTH-1:0];       //+-3          
  9'b000011111: cur_rem[REM_WIDTH-1:0]   = cur_rem_4[REM_WIDTH-1:0];       //+-4          
  9'b000001111: cur_rem[REM_WIDTH-1:0]   = cur_rem_5[REM_WIDTH-1:0];       //+-5          
  9'b000000111: cur_rem[REM_WIDTH-1:0]   = cur_rem_6[REM_WIDTH-1:0];       //+-6          
  9'b000000011: cur_rem[REM_WIDTH-1:0]   = cur_rem_7[REM_WIDTH-1:0];       //+-7          
  9'b000000001: cur_rem[REM_WIDTH-1:0]   = cur_rem_8[REM_WIDTH-1:0];       //+-8          
  9'b000000000: cur_rem[REM_WIDTH-1:0]   = cur_rem_9[REM_WIDTH-1:0];       //+-9          
  default :     cur_rem[REM_WIDTH-1:0]   = {REM_WIDTH{1'bx}};
endcase
// &CombEnd; @745
end
assign srt_remainder_nxt[REM_WIDTH-1:0]   = cur_rem[REM_WIDTH-1:0];
//assign srt_remainder_zero                 = ~|srt_remainder_nxt[REM_WIDTH-1:0];
assign srt_remainder_sign                 = srt_remainder_nxt[REM_WIDTH-1];

//====================================================
//  remainder logic for integer VREM/VREMU inst
//====================================================
always @(posedge srt_qt_rem_clk or negedge rst_n)
begin
  if(!rst_n)begin
    srt_remainder_minus[REM_WIDTH-1:0]  <= {REM_WIDTH{1'b0}};
  end
  else if(srt_sm_on)begin
    srt_remainder_minus[REM_WIDTH-1:0]  <= srt_remainder_minus_nxt[REM_WIDTH-1:0];
  end
  else begin
    srt_remainder_minus[REM_WIDTH-1:0]  <= srt_remainder_minus[REM_WIDTH-1:0];
  end
end

assign srt_remainder_out[REM_WIDTH-2:0] = srt_remainder[REM_WIDTH-1] ? srt_remainder_minus[REM_WIDTH-2:0]
                                                                     : srt_remainder[REM_WIDTH-2:0];

assign remainder_minus_shift[REM_WIDTH-1:0] = {srt_remainder_minus[REM_WIDTH-5:0],4'b0};
//csky vperl_off
assign rem_minus_minus_6[REM_WIDTH-1:0]      = $unsigned($signed(remainder_minus_shift[REM_WIDTH-1:0])
                                             - $signed({div_qt_r4_rem_add_op1[REM_WIDTH-1:0]})
                                             - $signed({div_qt_r2_rem_add_op1[REM_WIDTH-1:0]}));
//assign rem_minus_minus_4[REM_WIDTH-1:0]      = $unsigned($signed(remainder_minus_shift[REM_WIDTH-1:0])
//                                             - $signed({div_qt_r4_rem_add_op1[REM_WIDTH-1:0]}));
//csky vperl_on

// &Force("nonport","rem_minus_minus_6"); @778
// //&Force("nonport","rem_minus_minus_4"); @779

// here add for positive remainder calculation
assign remainder_minus_nor_nxt_0[REM_WIDTH-1:0]  = rem_sign ? cur_rem_1[REM_WIDTH-1:0]
						            : remainder_minus_shift[REM_WIDTH-1:0];
assign remainder_minus_nor_nxt_1[REM_WIDTH-1:0]  = rem_sign ? cur_rem_2[REM_WIDTH-1:0]
                                                            : remainder_shift[REM_WIDTH-1:0];
assign remainder_minus_nor_nxt_2[REM_WIDTH-1:0]  = rem_sign ? cur_rem_3[REM_WIDTH-1:0]
                                                            : cur_rem_1[REM_WIDTH-1:0];
assign remainder_minus_nor_nxt_3[REM_WIDTH-1:0]  = rem_sign ? cur_rem_4[REM_WIDTH-1:0]
                                                            : cur_rem_2[REM_WIDTH-1:0];
assign remainder_minus_nor_nxt_4[REM_WIDTH-1:0]  = rem_sign ? cur_rem_5[REM_WIDTH-1:0]
                                                            : cur_rem_3[REM_WIDTH-1:0];
assign remainder_minus_nor_nxt_5[REM_WIDTH-1:0]  = rem_sign ? cur_rem_6[REM_WIDTH-1:0]
                                                            : cur_rem_4[REM_WIDTH-1:0];
assign remainder_minus_nor_nxt_6[REM_WIDTH-1:0]  = rem_sign ? cur_rem_7[REM_WIDTH-1:0]
                                                            : cur_rem_5[REM_WIDTH-1:0];
assign remainder_minus_nor_nxt_7[REM_WIDTH-1:0]  = rem_sign ? cur_rem_8[REM_WIDTH-1:0]
                                                            : cur_rem_6[REM_WIDTH-1:0];
assign remainder_minus_nor_nxt_8[REM_WIDTH-1:0]  = rem_sign ? cur_rem_9[REM_WIDTH-1:0]
                                                            : cur_rem_7[REM_WIDTH-1:0];
assign remainder_minus_nor_nxt_9[REM_WIDTH-1:0]  = rem_sign ? rem_minus_minus_6[REM_WIDTH-1:0]
                                                            : cur_rem_8[REM_WIDTH-1:0];
// &CombBeg;                       @802
always @( bound_cmp_sign[8:0]
       or remainder_minus_nor_nxt_7[34:0]
       or remainder_minus_nor_nxt_1[34:0]
       or remainder_minus_nor_nxt_4[34:0]
       or remainder_minus_nor_nxt_5[34:0]
       or remainder_minus_nor_nxt_2[34:0]
       or remainder_minus_nor_nxt_9[34:0]
       or remainder_minus_nor_nxt_8[34:0]
       or remainder_minus_nor_nxt_0[34:0]
       or remainder_minus_nor_nxt_3[34:0]
       or remainder_minus_nor_nxt_6[34:0])
begin
case({bound_cmp_sign[8:0]})
  9'b111111111: srt_remainder_minus_nxt[REM_WIDTH-1:0] = remainder_minus_nor_nxt_0[REM_WIDTH-1:0];//0
  9'b011111111: srt_remainder_minus_nxt[REM_WIDTH-1:0] = remainder_minus_nor_nxt_1[REM_WIDTH-1:0];//+-1
  9'b001111111: srt_remainder_minus_nxt[REM_WIDTH-1:0] = remainder_minus_nor_nxt_2[REM_WIDTH-1:0];//+-2
  9'b000111111: srt_remainder_minus_nxt[REM_WIDTH-1:0] = remainder_minus_nor_nxt_3[REM_WIDTH-1:0];//+-3
  9'b000011111: srt_remainder_minus_nxt[REM_WIDTH-1:0] = remainder_minus_nor_nxt_4[REM_WIDTH-1:0];//+-4
  9'b000001111: srt_remainder_minus_nxt[REM_WIDTH-1:0] = remainder_minus_nor_nxt_5[REM_WIDTH-1:0];//+-5
  9'b000000111: srt_remainder_minus_nxt[REM_WIDTH-1:0] = remainder_minus_nor_nxt_6[REM_WIDTH-1:0];//+-6
  9'b000000011: srt_remainder_minus_nxt[REM_WIDTH-1:0] = remainder_minus_nor_nxt_7[REM_WIDTH-1:0];//+-7
  9'b000000001: srt_remainder_minus_nxt[REM_WIDTH-1:0] = remainder_minus_nor_nxt_8[REM_WIDTH-1:0];//+-8
  9'b000000000: srt_remainder_minus_nxt[REM_WIDTH-1:0] = remainder_minus_nor_nxt_9[REM_WIDTH-1:0];//+-9
  default :     srt_remainder_minus_nxt[REM_WIDTH-1:0] = {REM_WIDTH{1'bx}};
endcase
// &CombEnd; @816
end

// &ModuleEnd; @818
endmodule



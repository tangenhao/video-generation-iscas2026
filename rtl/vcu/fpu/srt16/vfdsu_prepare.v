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
module vfdsu_prepare(
  rst_n,
  ex1_div,
  ex1_divisor,
  ex1_pipedown,
  ex1_remainder,
  ex1_scalar,
  ex1_sqrt,
  ex1_src0,
  ex1_src1,
  clk,
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
  vfdsu_ex2_srt_skip
);
                   
input           rst_n;     
input           ex1_div;                  
input           ex1_pipedown;             
input           ex1_scalar;               
input           ex1_sqrt;                 
input   [31:0]  ex1_src0;                 
input   [31:0]  ex1_src1;                  
input           clk;               
output  [23:0]  ex1_divisor;              
output  [30:0]  ex1_remainder;            
output          vfdsu_ex2_div;            
output          vfdsu_ex2_dz;             
output  [9 :0]  vfdsu_ex2_expnt_add0;     
output  [9 :0]  vfdsu_ex2_expnt_add1;     
output          vfdsu_ex2_nv;             
output          vfdsu_ex2_of_rm_lfn;      
output          vfdsu_ex2_op0_norm;       
output          vfdsu_ex2_op1_norm;       
output  [22:0]  vfdsu_ex2_qnan_f;         
output          vfdsu_ex2_qnan_sign;      
output          vfdsu_ex2_result_inf;     
output          vfdsu_ex2_result_qnan;    
output          vfdsu_ex2_result_sign;    
output          vfdsu_ex2_result_zero;    
output  [2 :0]  vfdsu_ex2_rm;             
output          vfdsu_ex2_sqrt;           
output          vfdsu_ex2_srt_skip;       

// &Regs; @24
reg     [9 :0]  ex1_expnt_adder_op1;      
reg             ex1_of_result_lfn;        
reg     [22:0]  ex1_qnan_f;               
reg             ex1_qnan_sign;            
reg             vfdsu_ex2_div;             
reg             vfdsu_ex2_dz;             
reg     [9 :0]  vfdsu_ex2_expnt_add0;     
reg     [9 :0]  vfdsu_ex2_expnt_add1;     
reg             vfdsu_ex2_nv;             
reg             vfdsu_ex2_of_rm_lfn;      
reg             vfdsu_ex2_op0_norm;       
reg             vfdsu_ex2_op1_norm;       
reg     [22:0]  vfdsu_ex2_qnan_f;         
reg             vfdsu_ex2_qnan_sign;      
reg             vfdsu_ex2_result_inf;     
reg             vfdsu_ex2_result_qnan;    
reg             vfdsu_ex2_result_sign;    
reg             vfdsu_ex2_result_zero;    
reg     [2 :0]  vfdsu_ex2_rm;             
reg             vfdsu_ex2_sqrt;           
reg             vfdsu_ex2_srt_skip;       
                   
wire            rst_n;     
wire            div_sign;                 
wire            ex1_div;                  
wire            ex1_div_dz;               
wire    [23:0]  ex1_div_noid_nor_srt_op0; 
wire    [23:0]  ex1_div_noid_nor_srt_op1; 
wire    [23:0]  ex1_div_nor_srt_op0;      
wire    [23:0]  ex1_div_nor_srt_op1;      
wire            ex1_div_nv;               
wire    [9 :0]  ex1_div_op0_expnt;        
wire    [9 :0]  ex1_div_op1_expnt;        
wire            ex1_div_rst_inf;          
wire            ex1_div_rst_qnan;         
wire            ex1_div_rst_zero;         
wire    [23:0]  ex1_div_srt_op0;          
wire    [23:0]  ex1_div_srt_op1;          
wire    [23:0]  ex1_divisor;                
wire            ex1_dz;                   
wire            ex1_expnt0_max;           
wire            ex1_expnt0_zero;          
wire            ex1_expnt1_max;           
wire            ex1_expnt1_zero;          
wire    [9 :0]  ex1_expnt_adder_op0;      
wire            ex1_frac0_all0;           
wire            ex1_frac0_msb;            
wire            ex1_frac1_all0;           
wire            ex1_frac1_msb;              
wire            ex1_nv;                   
wire    [22:0]  ex1_op0_f;                
wire            ex1_op0_id;               
wire            ex1_op0_id_nor;           
wire            ex1_op0_inf;              
wire            ex1_op0_is_qnan;          
wire            ex1_op0_is_snan;          
wire            ex1_op0_norm;             
wire            ex1_op0_qnan;             
wire            ex1_op0_sign;             
wire            ex1_op0_snan;             
wire            ex1_op0_tt_zero;          
wire            ex1_op0_zero;             
wire    [22:0]  ex1_op1_f;                
wire            ex1_op1_id;               
wire            ex1_op1_id_nor;           
wire            ex1_op1_inf;              
wire            ex1_op1_is_qnan;          
wire            ex1_op1_is_snan;          
wire            ex1_op1_norm;             
wire            ex1_op1_qnan;             
wire            ex1_op1_sign;             
wire            ex1_op1_snan;             
wire            ex1_op1_tt_zero;          
wire            ex1_op1_zero;             
wire    [31:0]  ex1_oper0;                
wire    [22:0]  ex1_oper0_frac;           
wire            ex1_oper0_high_all1;      
wire    [9 :0]  ex1_oper0_id_expnt;       
wire    [22:0]  ex1_oper0_id_frac;        
wire    [31:0]  ex1_oper1;                
wire    [22:0]  ex1_oper1_frac;           
wire            ex1_oper1_high_all1;      
wire    [9 :0]  ex1_oper1_id_expnt;       
wire    [22:0]  ex1_oper1_id_frac;        
wire            ex1_pipe_clk;             
wire            ex1_pipe_clk_en;          
wire            ex1_pipedown;             
wire    [30:0]  ex1_remainder;            
wire            ex1_result_inf;           
wire            ex1_result_qnan;          
wire            ex1_result_sign;          
wire            ex1_result_zero;          
wire    [2 :0]  ex1_rm;                   
wire            ex1_rst_default_qnan;     
wire            ex1_scalar;               
wire            ex1_sqrt;                 
wire            ex1_sqrt_expnt_odd;       
wire            ex1_sqrt_expnt_result_odd; 
wire            ex1_sqrt_nv;              
wire    [9 :0]  ex1_sqrt_op1_expnt;       
wire            ex1_sqrt_rst_inf;         
wire            ex1_sqrt_rst_qnan;        
wire            ex1_sqrt_rst_zero;        
wire    [23:0]  ex1_sqrt_srt_op0;         
wire    [31:0]  ex1_src0;                 
wire    [31:0]  ex1_src1;                 
wire            ex1_srt_skip;             
wire            clk;           
wire    [30:0]  sqrt_remainder;           
wire            sqrt_sign;                  


//======================Operator prepare====================
//VECTOR_SIMD

assign ex1_oper0[31:0]             = ex1_src0[31:0];
assign ex1_oper1[31:0]             = ex1_src1[31:0];


//Sign bit prepare
assign ex1_op0_sign                =  ex1_oper0[31]; 
assign ex1_op1_sign                =  ex1_oper1[31]; 
assign div_sign                    = ex1_op0_sign ^ ex1_op1_sign;
assign sqrt_sign                   = ex1_op0_sign;
assign ex1_result_sign             = (ex1_div)
                                   ? div_sign 
                                   : sqrt_sign;
//exponent max
assign ex1_expnt0_max              = &ex1_oper0[30:23];
assign ex1_expnt1_max              = &ex1_oper1[30:23];
             
//exponent zero
assign ex1_expnt0_zero             = ~(|ex1_oper0[30:23]);
assign ex1_expnt1_zero             = ~(|ex1_oper1[30:23]);

//fraction zero
assign ex1_frac0_all0              = ~(|ex1_oper0[22:0]);   
assign ex1_frac1_all0              = ~(|ex1_oper1[22:0]); 
assign ex1_frac0_msb               = ex1_oper0[22];
assign ex1_frac1_msb               = ex1_oper1[22]; 
assign ex1_oper0_high_all1         = 1'b1; 
assign ex1_oper1_high_all1         = 1'b1;

//infinity number
assign  ex1_op0_inf                = ex1_expnt0_max && 
                                     ex1_frac0_all0;
assign  ex1_op1_inf                = ex1_expnt1_max && 
                                     ex1_frac1_all0;
//zero
assign ex1_op0_zero                = ex1_expnt0_zero && 
                                     ex1_frac0_all0;
assign ex1_op1_zero                = ex1_expnt1_zero && 
                                     ex1_frac1_all0;
//denormalize number
assign ex1_op0_id                  =  ex1_expnt0_zero && 
                                     ~ex1_frac0_all0;
assign ex1_op1_id                  =  ex1_expnt1_zero && 
                                     ~ex1_frac1_all0;
assign ex1_op0_id_nor              = ex1_op0_id;
assign ex1_op1_id_nor              = ex1_op1_id;

//sNaN
assign ex1_op0_snan                =  ex1_expnt0_max &&
                                     ~ex1_frac0_all0 &&
                                     ~ex1_frac0_msb;
assign ex1_op1_snan                =  ex1_expnt1_max &&
                                     ~ex1_frac1_all0 &&
                                     ~ex1_frac1_msb;

//qNaN
assign ex1_op0_qnan                = ex1_expnt0_max && 
                                     ex1_frac0_msb;
assign ex1_op1_qnan                = ex1_expnt1_max && 
                                     ex1_frac1_msb;
//=====================find first one=======================
// this is for the denormal number
vfdsu_ff1  x_frac0_expnt (
  .fanc_shift_num           (ex1_oper0_id_frac[22:0] ),
  .frac_bin_val             (ex1_oper0_id_expnt[9 :0]),
  .frac_num                 (ex1_oper0_frac[22:0]    )
);

vfdsu_ff1  x_frac1_expnt (
  .fanc_shift_num           (ex1_oper1_id_frac[22:0] ),
  .frac_bin_val             (ex1_oper1_id_expnt[9 :0]),
  .frac_num                 (ex1_oper1_frac[22:0]    )
);

assign ex1_oper0_frac[22:0] = ex1_oper0[22:0];
assign ex1_oper1_frac[22:0] = ex1_oper1[22:0];

//=====================exponent add=========================
//exponent number 0
assign ex1_div_op0_expnt[9:0]       = {2'b0, ex1_oper0[30:23]};
assign ex1_expnt_adder_op0[9:0]     = ex1_op0_id_nor ? ex1_oper0_id_expnt[9:0]
                                                    : ex1_div_op0_expnt[9:0];
//exponent number 1
assign ex1_div_op1_expnt[9:0]  = {2'b0,ex1_oper1[30:23]};
assign ex1_sqrt_op1_expnt[9:0] = {3'b0,{7{1'b1}}};

always @( ex1_oper1_id_expnt[9:0]
       or ex1_div
       or ex1_op1_id_nor
       or ex1_sqrt_op1_expnt[9:0]
       or ex1_sqrt
       or ex1_div_op1_expnt[9:0])
begin
case({ex1_div,ex1_sqrt})
  2'b10:   ex1_expnt_adder_op1[9:0] = ex1_op1_id_nor ? ex1_oper1_id_expnt[9:0]
                                                  : ex1_div_op1_expnt[9:0];
  2'b01:   ex1_expnt_adder_op1[9:0] = ex1_sqrt_op1_expnt[9:0];
  default: ex1_expnt_adder_op1[9:0] = 10'b0;
endcase
end
//expnt0 sub expnt1
assign ex1_sqrt_expnt_result_odd =  ex1_expnt_adder_op0[0] ^ ex1_expnt_adder_op1[0];


//======================EX1 out_expt detect=====================
//ex1_id_detect
//any opration is zero
// no input denormalize exception anymore
//
//ex1_nv_detect
//div_nv
//  1.any operation is sNaN
//  2.0/0(include DN flush to zero)
//  3.inf/inf
//sqrt_nv
//  1.any operation is sNaN
//  2.operation sign is 1 && operation is not zero/qNaN
assign ex1_nv      = ex1_div  && ex1_div_nv  || 
                     ex1_sqrt && ex1_sqrt_nv;
//ex1_div_nv
assign ex1_div_nv  = ex1_op0_snan || 
                     ex1_op1_snan || 
                    (ex1_op0_tt_zero && ex1_op1_tt_zero)|| 
                    (ex1_op0_inf && ex1_op1_inf);
assign ex1_op0_tt_zero = ex1_op0_zero;
assign ex1_op1_tt_zero = ex1_op1_zero;
//ex1_sqrt_nv
assign ex1_sqrt_nv = ex1_op0_snan || 
                     ex1_op0_sign && 
                    (ex1_op0_norm || 
                     ex1_op0_inf );
assign ex1_op0_norm = !ex1_expnt0_zero && !ex1_expnt0_max || ex1_op0_id_nor;
assign ex1_op1_norm = !ex1_expnt1_zero && !ex1_expnt1_max || ex1_op1_id_nor; 

//ex1_of_detect
//div_of
//  1.only detect id overflow case
//assign ex1_of      = ex1_div && ex1_div_of;
//assign ex1_div_of  = ex1_op1_id_fm1 && 
//                     ex1_op0_norm && 
//                     ex1_div_id_of;
//
////ex1_uf_detect
////div_uf
////  1.only detect id underflow case
//assign ex1_uf      = ex1_div && ex1_div_uf;
//assign ex1_div_uf  = ex1_op0_id && 
//                     ex1_op1_norm && 
//                     ex1_div_id_uf;
//ex1_dz_detect
//div_dz
//  1.op0 is normal && op1 zero
assign ex1_dz      = ex1_div && ex1_div_dz;
assign ex1_div_dz  = ex1_op1_tt_zero && ex1_op0_norm;

//===================sqrt exponent prepare==================
//sqrt exponent prepare
//afert E sub, div E by 2
//assign ex1_sqrt_expnt_result[12:0] = {ex1_expnt_result[12],
//                                      ex1_expnt_result[12:1]};
//ex1_sqrt_expnt_odd
//fraction will shift left by 1
assign ex1_sqrt_expnt_odd          = ex1_sqrt_expnt_result_odd;

//===================special cal result=====================
//ex1 result is zero
//div_zero
//  1.op0 is zero && op1 is normal
//  2.op0 is zero/normal && op1 is inf
//sqrt_zero
//  1.op0 is zero
assign ex1_result_zero   = ex1_div_rst_zero  && ex1_div  || 
                           ex1_sqrt_rst_zero && ex1_sqrt;
assign ex1_div_rst_zero  = (ex1_op0_tt_zero && ex1_op1_norm ) || 
                           (!ex1_expnt0_max && ex1_op1_inf);
assign ex1_sqrt_rst_zero = ex1_op0_tt_zero;

//ex1 result is qNaN
//ex1_nv
//div_qnan
//  1.op0 is qnan || op1 is qnan
//sqrt_qnan
//  1.op0 is qnan
assign ex1_result_qnan   = ex1_div_rst_qnan  && ex1_div  || 
                           ex1_sqrt_rst_qnan && ex1_sqrt || 
                           ex1_nv;
assign ex1_div_rst_qnan  = ex1_op0_qnan || 
                           ex1_op1_qnan;
assign ex1_sqrt_rst_qnan = ex1_op0_qnan;

//ex1_rst_default_qnan
//0/0, inf/inf, sqrt negative should get default qNaN
assign ex1_rst_default_qnan = (ex1_div && ex1_op0_zero && ex1_op1_zero) || 
                              (ex1_div && ex1_op0_inf  && ex1_op1_inf)  || 
                              (ex1_sqrt&& ex1_op0_sign && (ex1_op0_norm || ex1_op0_inf));

//ex1 result is inf
//ex1_dz
//
//div_inf
//  1.op0 is inf && op1 is normal/zero
//sqrt_inf
//  1.op0 is inf
assign ex1_result_inf    = ex1_div_rst_inf  && ex1_div  || 
                           ex1_sqrt_rst_inf && ex1_sqrt || 
                           ex1_dz ;
assign ex1_div_rst_inf   = ex1_op0_inf && !ex1_expnt1_max;
assign ex1_sqrt_rst_inf  = ex1_op0_inf && !ex1_op0_sign;

//ex1 result is lfn
//ex1_of && round result toward not inc 1

assign ex1_rm[2:0]       = 3'b000; // RNE
//RNE : Always inc 1 because round to nearest of 1.111...11
//RTZ : Always not inc 1
//RUP : Always not inc 1 when posetive
//RDN : Always not inc 1 when negative
//RMM : Always inc 1 because round to max magnitude
// &CombBeg; @308
always @( ex1_rm[2:0]
       or ex1_result_sign)
begin
case(ex1_rm[2:0])
  3'b000  : ex1_of_result_lfn = 1'b0;
  3'b001  : ex1_of_result_lfn = 1'b1;
  3'b010  : ex1_of_result_lfn = !ex1_result_sign;
  3'b011  : ex1_of_result_lfn = ex1_result_sign;
  3'b100  : ex1_of_result_lfn = 1'b0;
  default: ex1_of_result_lfn = 1'b0;
endcase
// &CombEnd; @317
end

//EX1 Remainder
//div  : 1/8  <= x < 1/4
//sqrt : 1/16 <= x < 1/4
assign ex1_remainder[30:0] = {31{ex1_div }} & {5'b0,ex1_div_srt_op0[23:0],2'b0} | 
                             {31{ex1_sqrt}} & sqrt_remainder[30:0];

//EX1 Divisor
//1/2 <= y < 1
assign ex1_divisor[23:0]   = ex1_div_srt_op1[23:0];

//ex1_div_srt_op0
assign ex1_div_srt_op0[23:0]     = ex1_div_nor_srt_op0[23:0];
//ex1_div_srt_op1
assign ex1_div_srt_op1[23:0]     =  ex1_div_nor_srt_op1[23:0];
//ex1_div_nor_srt_op0
assign ex1_div_noid_nor_srt_op0[23:0] = {1'b1,ex1_oper0[22:0]};
assign ex1_div_noid_nor_srt_op1[23:0] = {1'b1,ex1_oper1[22:0]};
assign ex1_div_nor_srt_op0[23:0] = ex1_op0_id_nor ? {ex1_oper0_id_frac[22:0],1'b0} 
                                                  : ex1_div_noid_nor_srt_op0[23:0];
//ex1_div_nor_srt_op1
assign ex1_div_nor_srt_op1[23:0] = ex1_op1_id_nor ? {ex1_oper1_id_frac[22:0],1'b0} 
                                                  : ex1_div_noid_nor_srt_op1[23:0];
//sqrt_remainder
assign sqrt_remainder[30:0]      = (ex1_sqrt_expnt_odd)
                                 ? {5'b0,ex1_sqrt_srt_op0[23:0],2'b0}
                                 : {6'b0,ex1_sqrt_srt_op0[23:0],1'b0};
//ex1_sqrt_srt_op0
assign ex1_sqrt_srt_op0[23:0]    = ex1_div_srt_op0[23:0];

//Default_qnan/Standard_qnan Select
assign ex1_op0_is_snan      = ex1_op0_snan;
assign ex1_op1_is_snan      = ex1_op1_snan && ex1_div;
assign ex1_op0_is_qnan      = ex1_op0_qnan;
assign ex1_op1_is_qnan      = ex1_op1_qnan && ex1_div;
assign ex1_op0_f[22:0]      = ex1_oper0[22:0];
assign ex1_op1_f[22:0]      = ex1_oper1[22:0];
// &CombBeg; @359
always @( ex1_op0_is_snan
       or ex1_op0_is_qnan
       or ex1_op0_f[22:0]
       or ex1_rst_default_qnan
       or ex1_op1_f[22:0]
       or ex1_op1_is_snan
       or ex1_op1_is_qnan)
begin
if(ex1_rst_default_qnan)
  ex1_qnan_f[22:0] = {1'b1, 22'b0};
else if(ex1_op0_is_snan)
  ex1_qnan_f[22:0] = ex1_op0_f[22:0];
else if(ex1_op1_is_snan)
  ex1_qnan_f[22:0] = ex1_op1_f[22:0];
else if(ex1_op0_is_qnan)
  ex1_qnan_f[22:0] = ex1_op0_f[22:0];
else if(ex1_op1_is_qnan)
  ex1_qnan_f[22:0] = ex1_op1_f[22:0];
else
  ex1_qnan_f[22:0] = {1'b1, 22'b0};
// &CombEnd; @372
end

// &CombBeg; @374
always @( ex1_op0_is_snan
       or ex1_op0_is_qnan
       or ex1_op1_sign
       or ex1_op0_sign
       or ex1_rst_default_qnan
       or ex1_op1_is_snan
       or ex1_op1_is_qnan)
begin
if(ex1_rst_default_qnan)
  ex1_qnan_sign = 1'b0;
else if(ex1_op0_is_snan)
  ex1_qnan_sign = ex1_op0_sign;
else if(ex1_op1_is_snan)
  ex1_qnan_sign = ex1_op1_sign;
else if(ex1_op0_is_qnan)
  ex1_qnan_sign = ex1_op0_sign;
else if(ex1_op1_is_qnan)
  ex1_qnan_sign = ex1_op1_sign;
else
  ex1_qnan_sign = 1'b0;
// &CombEnd; @387
end


//========================Pipe to EX2=======================
//exponent register cal result
//assign ex1_srt_expnt_rst[12:0] = (ex1_sqrt)
//                               ? ex1_sqrt_expnt_result[12:0]
//                               : ex1_expnt_result[12:0];
//Special result should skip SRT logic
assign ex1_srt_skip = ex1_result_zero || 
                      ex1_result_qnan || 
                      ex1_result_inf;

assign ex1_pipe_clk = clk;

always @(posedge ex1_pipe_clk or negedge rst_n)
begin
  if(!rst_n)
  begin
    vfdsu_ex2_result_zero     <=  1'b0; 
    vfdsu_ex2_result_qnan     <=  1'b0; 
    vfdsu_ex2_result_inf      <=  1'b0; 
    vfdsu_ex2_result_sign     <=  1'b0; 
    vfdsu_ex2_op0_norm        <=  1'b0; 
    vfdsu_ex2_op1_norm        <=  1'b0; 
    vfdsu_ex2_expnt_add0[9:0] <= 10'b0; 
    vfdsu_ex2_expnt_add1[9:0] <= 10'b0; 
    vfdsu_ex2_nv              <=  1'b0; 
    vfdsu_ex2_dz              <=  1'b0; 
    vfdsu_ex2_srt_skip        <=  1'b0; 
    vfdsu_ex2_of_rm_lfn       <=  1'b0;
    vfdsu_ex2_qnan_sign       <=  1'b0;
    vfdsu_ex2_qnan_f[22:0]    <= 23'b0;
    vfdsu_ex2_rm[2:0]         <=  3'b0;
    vfdsu_ex2_div             <=  1'b0;
    vfdsu_ex2_sqrt            <=  1'b0;
  end
  else if(ex1_pipedown)
  begin
    vfdsu_ex2_result_zero     <= ex1_result_zero; 
    vfdsu_ex2_result_qnan     <= ex1_result_qnan; 
    vfdsu_ex2_result_inf      <= ex1_result_inf; 
    vfdsu_ex2_result_sign     <= ex1_result_sign; 
    vfdsu_ex2_op0_norm        <= ex1_op0_norm; 
    vfdsu_ex2_op1_norm        <= ex1_op1_norm; 
    vfdsu_ex2_expnt_add0[9:0] <= ex1_expnt_adder_op0[9:0];
    vfdsu_ex2_expnt_add1[9:0] <= ex1_expnt_adder_op1[9:0];
    vfdsu_ex2_nv              <= ex1_nv; 
    vfdsu_ex2_dz              <= ex1_dz; 
    vfdsu_ex2_srt_skip        <= ex1_srt_skip; 
    vfdsu_ex2_of_rm_lfn       <= ex1_of_result_lfn;
    vfdsu_ex2_qnan_sign       <= ex1_qnan_sign;
    vfdsu_ex2_qnan_f[22:0]    <= ex1_qnan_f[22:0];
    vfdsu_ex2_rm[2:0]         <= ex1_rm[2:0];
    vfdsu_ex2_div             <= ex1_div;
    vfdsu_ex2_sqrt            <= ex1_sqrt;
  end
  else
  begin
    vfdsu_ex2_result_zero     <= vfdsu_ex2_result_zero; 
    vfdsu_ex2_result_qnan     <= vfdsu_ex2_result_qnan; 
    vfdsu_ex2_result_inf      <= vfdsu_ex2_result_inf; 
    vfdsu_ex2_result_sign     <= vfdsu_ex2_result_sign; 
    vfdsu_ex2_op0_norm        <= vfdsu_ex2_op0_norm; 
    vfdsu_ex2_op1_norm        <= vfdsu_ex2_op1_norm; 
    vfdsu_ex2_expnt_add0[9:0] <= vfdsu_ex2_expnt_add0[9:0]; 
    vfdsu_ex2_expnt_add1[9:0] <= vfdsu_ex2_expnt_add1[9:0]; 
    vfdsu_ex2_nv              <= vfdsu_ex2_nv; 
    vfdsu_ex2_dz              <= vfdsu_ex2_dz; 
    vfdsu_ex2_srt_skip        <= vfdsu_ex2_srt_skip; 
    vfdsu_ex2_of_rm_lfn       <= vfdsu_ex2_of_rm_lfn;
    vfdsu_ex2_qnan_sign       <= vfdsu_ex2_qnan_sign;
    vfdsu_ex2_qnan_f[22:0]    <= vfdsu_ex2_qnan_f[22:0];
    vfdsu_ex2_rm[2:0]         <= vfdsu_ex2_rm[2:0];
    vfdsu_ex2_div             <= vfdsu_ex2_div;
    vfdsu_ex2_sqrt            <= vfdsu_ex2_sqrt;
  end
end

endmodule



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
module vfdsu_round(
  rst_n,
  ex3_pipedown,
  clk,
  total_qt_rt_58,
  vfdsu_ex2_of_rm_lfn,
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
  vfdsu_ex3_uf,
  vfdsu_ex4_denorm_to_tiny_frac,
  vfdsu_ex4_dz,
  vfdsu_ex4_expnt_rst,
  vfdsu_ex4_frac,
  vfdsu_ex4_nv,
  vfdsu_ex4_nx,
  vfdsu_ex4_of,
  vfdsu_ex4_of_rst_lfn,
  vfdsu_ex4_potnt_norm,
  vfdsu_ex4_potnt_of,
  vfdsu_ex4_potnt_uf,
  vfdsu_ex4_qnan_f,
  vfdsu_ex4_qnan_sign,
  vfdsu_ex4_result_inf,
  vfdsu_ex4_result_lfn,
  vfdsu_ex4_result_nor,
  vfdsu_ex4_result_qnan,
  vfdsu_ex4_result_sign,
  vfdsu_ex4_result_zero,
  vfdsu_ex4_rslt_denorm,
  vfdsu_ex4_uf
);
                                           
input           rst_n;   
input           ex3_pipedown;                         
input           clk;                        
input   [31:0]  total_qt_rt_58;                       
input           vfdsu_ex2_of_rm_lfn;                  
input           vfdsu_ex3_dz;
input   [9 :0]  vfdsu_ex3_expnt_rst;                  
input           vfdsu_ex3_id_srt_skip;                
input           vfdsu_ex3_nv;                         
input           vfdsu_ex3_of;                         
input           vfdsu_ex3_potnt_of;                   
input           vfdsu_ex3_potnt_uf;                   
input   [22:0]  vfdsu_ex3_qnan_f;                     
input           vfdsu_ex3_qnan_sign;                  
input           vfdsu_ex3_rem_sign;                   
input           vfdsu_ex3_rem_zero;                   
input   [23:0]  vfdsu_ex3_result_denorm_round_add_num; 
input           vfdsu_ex3_result_inf;                 
input           vfdsu_ex3_result_lfn;                 
input           vfdsu_ex3_result_qnan;                
input           vfdsu_ex3_result_sign;                
input           vfdsu_ex3_result_zero;                
input   [2 :0]  vfdsu_ex3_rm;                         
input           vfdsu_ex3_rslt_denorm;                  
input           vfdsu_ex3_uf;                         
output          vfdsu_ex4_denorm_to_tiny_frac;                    
output          vfdsu_ex4_dz;                         
output  [9 :0]  vfdsu_ex4_expnt_rst;                  
output  [25:0]  vfdsu_ex4_frac;                       
output          vfdsu_ex4_nv;                         
output          vfdsu_ex4_nx;                         
output          vfdsu_ex4_of;                         
output          vfdsu_ex4_of_rst_lfn;                 
output  [1 :0]  vfdsu_ex4_potnt_norm;                 
output          vfdsu_ex4_potnt_of;                   
output          vfdsu_ex4_potnt_uf;                   
output  [22:0]  vfdsu_ex4_qnan_f;                     
output          vfdsu_ex4_qnan_sign;                  
output          vfdsu_ex4_result_inf;                 
output          vfdsu_ex4_result_lfn;                 
output          vfdsu_ex4_result_nor;                 
output          vfdsu_ex4_result_qnan;                
output          vfdsu_ex4_result_sign;                
output          vfdsu_ex4_result_zero;                
output          vfdsu_ex4_rslt_denorm;                 
output          vfdsu_ex4_uf;                         

// &Regs; @24
reg             ex3_denorm_lst_frac_reg;
reg             denorm_to_tiny_frac;                  
reg     [25:0]  frac_add1_op1;                        
reg             frac_add_1;                           
reg             frac_orig;                            
reg     [25:0]  frac_sub1_op1;                        
reg             frac_sub_1;                           
reg             half_denorm_lst_frac;                 
reg     [27:0]  qt_result_double_denorm_for_round;    
reg     [13:0]  qt_result_half_denorm_for_round;      
reg     [30:0]  qt_result_denorm_for_round;        
reg             vfdsu_ex4_denorm_to_tiny_frac;        
reg             vfdsu_ex4_double;                     
reg             vfdsu_ex4_dz;                         
reg     [9 :0]  vfdsu_ex4_expnt_rst;                  
reg     [25:0]  vfdsu_ex4_frac;                       
reg             vfdsu_ex4_nv;                         
reg             vfdsu_ex4_nx;                         
reg             vfdsu_ex4_of;                         
reg             vfdsu_ex4_of_rst_lfn;                 
reg     [1 :0]  vfdsu_ex4_potnt_norm;                 
reg             vfdsu_ex4_potnt_of;                   
reg             vfdsu_ex4_potnt_uf;                   
reg     [22:0]  vfdsu_ex4_qnan_f;                     
reg             vfdsu_ex4_qnan_sign;                  
reg             vfdsu_ex4_result_inf;                 
reg             vfdsu_ex4_result_lfn;                 
reg             vfdsu_ex4_result_nor;                 
reg             vfdsu_ex4_result_qnan;                
reg             vfdsu_ex4_result_sign;                
reg             vfdsu_ex4_result_zero;                
reg             vfdsu_ex4_rslt_denorm;                
reg             vfdsu_ex4_single;                     
reg             vfdsu_ex4_uf;                         
                                        
wire            rst_n;      
wire            ex3_denorm_eq;                        
wire            ex3_denorm_gr;                        
wire            ex3_denorm_lst_frac;                  
wire            ex3_denorm_nx;                        
wire            ex3_denorm_plus;                      
wire            ex3_denorm_potnt_norm;                
wire            ex3_denorm_zero;                                   
wire    [9 :0]  ex3_expnt_adjst;                      
wire    [9 :0]  ex3_expnt_adjust_result;                         
wire            ex3_nx;                               
wire            ex3_pipe_clk;                         
wire            ex3_pipe_clk_en;                      
wire            ex3_pipedown;                         
wire    [1 :0]  ex3_potnt_norm;                      
wire            ex3_qt_eq;                            
wire            ex3_qt_gr;                           
wire            ex3_qt_zero;                          
wire            ex3_rslt_denorm;                      
wire            ex3_rst_eq_1;                         
wire            ex3_rst_nor;                                       
wire            clk;                       
wire    [25:0]  frac_add1_op1_with_denorm;            
wire    [25:0]  frac_add1_rst;                        
wire            frac_denorm_rdn_add_1;                
wire            frac_denorm_rdn_sub_1;                
wire            frac_denorm_rmm_add_1;                
wire            frac_denorm_rne_add_1;                
wire            frac_denorm_rtz_sub_1;                
wire            frac_denorm_rup_add_1;                
wire            frac_denorm_rup_sub_1;                
wire    [25:0]  frac_final_rst;                       
wire            frac_rdn_add_1;                       
wire            frac_rdn_sub_1;                       
wire            frac_rmm_add_1;                       
wire            frac_rne_add_1;                       
wire            frac_rtz_sub_1;                       
wire            frac_rup_add_1;                       
wire            frac_rup_sub_1;                       
wire    [25:0]  frac_sub1_op1_with_denorm;            
wire    [25:0]  frac_sub1_rst;                         
wire    [31:0]  total_qt_rt_58;                       
wire            vfdsu_ex2_of_rm_lfn;                     
wire            vfdsu_ex3_dz;                         
wire    [9 :0]  vfdsu_ex3_expnt_rst;                  
wire            vfdsu_ex3_id_srt_skip;                
wire            vfdsu_ex3_nv;                         
wire            vfdsu_ex3_of;                         
wire            vfdsu_ex3_potnt_of;                   
wire            vfdsu_ex3_potnt_uf;                   
wire    [22:0]  vfdsu_ex3_qnan_f;                     
wire            vfdsu_ex3_qnan_sign;                  
wire            vfdsu_ex3_rem_sign;                   
wire            vfdsu_ex3_rem_zero;                   
wire    [23:0]  vfdsu_ex3_result_denorm_round_add_num; 
wire            vfdsu_ex3_result_inf;                 
wire            vfdsu_ex3_result_lfn;                 
wire            vfdsu_ex3_result_qnan;                
wire            vfdsu_ex3_result_sign;                
wire            vfdsu_ex3_result_zero;                
wire    [2 :0]  vfdsu_ex3_rm;                         
wire            vfdsu_ex3_rslt_denorm;                 
wire            vfdsu_ex3_uf;                         


//=======================Round Rule=========================
//1/8 <= x < 1/4, 1/2 <= y < 1, => 1/8 < z < 1/2
//q[57:0] represent the fraction part result of quotient, q[57] for 1/2
//Thus the first "1" in 58 bit quotient will be in q[56] or q[55]
//For Double Float
//29 round to get 58 bit quotient, 52+1 bit as valid result, other for round
//if q[56] is 1, q[56:4] as 1.xxxx valid result, [3:0] for round
//if q[56] is 0, q[55:3] as 1.xxxx valid result, [2:0] for round
//For Single Float
//15 round to get 30 bit quotient, 23+1 bit as valid result, other for round
//if q[56] is 1, q[56:33] as 1.xxxx valid result, [32:28] for round
//if q[56] is 0, q[55:32] as 1.xxxx valid result, [31:28] for round    

// &Force("bus","total_qt_rt_58",57,0); @54

//the quotient round bits is zero
//quotient is 1.00000..00 need special dealt with in the following
// for denormal result, first select the quotation num for rounding
//  specially for the result e=-126 and e=-1022,the denorm depends on the
//  MSB of the quotient

assign ex3_rslt_denorm            = ex3_denorm_plus || vfdsu_ex3_rslt_denorm;
assign ex3_denorm_potnt_norm      = total_qt_rt_58[30] && (vfdsu_ex3_expnt_rst[9:0] == 10'h381);
assign ex3_rst_eq_1         = total_qt_rt_58[30] && ~|total_qt_rt_58[29:7];
assign ex3_qt_eq            = (total_qt_rt_58[30])
                            ?  total_qt_rt_58[6] && ~|total_qt_rt_58[5:0] 
                            :  total_qt_rt_58[5] && ~|total_qt_rt_58[4:0];
assign ex3_qt_gr            = (total_qt_rt_58[30])
                            ?  total_qt_rt_58[6] && |total_qt_rt_58[5:0]
                            :  total_qt_rt_58[5] && |total_qt_rt_58[4:0];
assign ex3_qt_zero          = (total_qt_rt_58[30])
                            ? ~|total_qt_rt_58[6:0]
                            : ~|total_qt_rt_58[5:0];
assign ex3_denorm_plus      = !total_qt_rt_58[30] && (vfdsu_ex3_expnt_rst[9:0] == 10'h382);
                             
//denomal result, check for rounding further optimization can be done in
//future

// &CombBeg; @285
always @( vfdsu_ex3_expnt_rst[8:0]
       or total_qt_rt_58[30:0])
begin
case(vfdsu_ex3_expnt_rst[8:0])
  9'h182:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[6:0],24'b0}; //-126 1
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[7];
			 		end//-1022 1
  9'h181:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[7:0],23'b0}; //-127 0
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[8];
			 		end//-1022 1
  9'h180:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[8:0],22'b0}; //-128 -1
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[9];
			 		end//-1022 1
  9'h17f:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[9:0],21'b0}; //-129 -2
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[10];
			 		end//-1022 1
  9'h17e:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[10:0],20'b0}; //-90 -3
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[11];
			 		end//-1022 1
  9'h17d:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[11:0],19'b0}; //-91 -4
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[12];
			 		end//-1022 1
  9'h17c:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[12:0],18'b0}; //-92 -5
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[13];
			 		end//-1022 1
  9'h17b:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[13:0],17'b0}; //-93 -6
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[14];
			 		end//-1022 1
  9'h17a:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[14:0],16'b0}; //-94 -7
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[15];
			 		end//-1022 1
  9'h179:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[15:0],15'b0}; //-95 -8
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[16];
			 		end//-1022 1
  9'h178:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[16:0],14'b0}; //-96 -9
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[17];
			 		end//-1022 1
  9'h177:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[17:0],13'b0}; //-97 -10
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[18];
			 		end//-1022 1
  9'h176:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[18:0],12'b0}; //-98 -11
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[19];
			 		end//-1022 1
  9'h175:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[19:0],11'b0}; //-99 -12
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[20];
			 		end//-1022 1
  9'h174:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[20:0],10'b0}; //-140 -9   
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[21];
			 		end//-1022 1
  9'h173:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[21:0],9'b0}; // -141
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[22];
			 		end//-1022 1
  9'h172:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[22:0],8'b0};//-142
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[23];
			 		end//-1022 1
  9'h171:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[23:0],7'b0};//-143
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[24];
			 		end//-1022 1
  9'h170:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[24:0],6'b0}; //-144
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[25];
			 		end//-1022 1
  9'h16f:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[25:0],5'b0}; //-145
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[26];
			 		end//-1022 1
  9'h16e:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[26:0],4'b0}; //-146
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[27];
			 		end//-1022 1
  9'h16d:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[27:0],3'b0}; //-147
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[28];
			 		end//-1022 1
  9'h16c:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[28:0],2'b0}; //-148
                ex3_denorm_lst_frac_reg =  total_qt_rt_58[29];
			 		end//-1022 1
  9'h16b:begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[29:0],1'b0};
                 ex3_denorm_lst_frac_reg = total_qt_rt_58[30];
						end//-1022 1
  default:  begin qt_result_denorm_for_round[30:0] = {total_qt_rt_58[30:0]};
                 ex3_denorm_lst_frac_reg = 1'b0;
						end//-1022 1
endcase
// &CombEnd;  @363
end
//rounding evaluation for single denormalize number 

assign ex3_denorm_eq             = qt_result_denorm_for_round[30] 
                                   &&  ~|qt_result_denorm_for_round[29:0];
assign ex3_denorm_gr             = qt_result_denorm_for_round[30] 
                                   &&  |qt_result_denorm_for_round[29:0];
assign ex3_denorm_zero           = !qt_result_denorm_for_round[30] 
                                   && ~|qt_result_denorm_for_round[29:0];
assign ex3_denorm_lst_frac       = ex3_denorm_lst_frac_reg;
  
//Different Round Mode with different rounding rule
//Here we call rounding bit as "rb", remainder as "rem"
//RNE : 
//  1.+1 : rb>10000 || rb==10000 && rem>0
//  2. 0 : Rest Condition
//  3.-1 : Never occur
//RTZ : 
//  1.+1 : Never occur
//  2. 0 : Rest Condition
//  3.-1 : rb=10000 && rem<0
//RDN : 
//  1.+1 : Q>0 Never occur   ; Q<0 Rest condition
//  2. 0 : Q>0 Rest condition; Q<0 Rem<0 && rb=0 
//  3.-1 : Q>0 Rem<0 && rb=0 ; Q<0 Never occur
//RUP : 
//  1.+1 : Q>0 Rest Condition; Q<0 Never occur
//  2. 0 : Q>0 Rem<0 && rb=0 ; Q<0 Rest condition
//  3.-1 : Q>0 Never occur   ; Q<0 Rem<0 && rb=0 
//RMM : 
//  1.+1 : rb>10000 || rb==10000 && rem>0
//  2. 0 : Rest Condition
//  3.-1 : Never occur
assign frac_rne_add_1 = ex3_qt_gr || 
                       (ex3_qt_eq && !vfdsu_ex3_rem_sign); 
assign frac_rtz_sub_1 = ex3_qt_zero && vfdsu_ex3_rem_sign;
assign frac_rup_add_1 = !vfdsu_ex3_result_sign && 
                       (!ex3_qt_zero || 
                       (!vfdsu_ex3_rem_sign && !vfdsu_ex3_rem_zero)); 
assign frac_rup_sub_1 = vfdsu_ex3_result_sign && 
                       (ex3_qt_zero && vfdsu_ex3_rem_sign);
assign frac_rdn_add_1 = vfdsu_ex3_result_sign && 
                       (!ex3_qt_zero || 
                       (!vfdsu_ex3_rem_sign && !vfdsu_ex3_rem_zero));
assign frac_rdn_sub_1 = !vfdsu_ex3_result_sign &&
                       (ex3_qt_zero && vfdsu_ex3_rem_sign);
assign frac_rmm_add_1 = ex3_qt_gr || 
                       (ex3_qt_eq && !vfdsu_ex3_rem_sign); 
//denormal result 
assign frac_denorm_rne_add_1 = ex3_denorm_gr || 
                               (ex3_denorm_eq && 
                               ((vfdsu_ex3_rem_zero &&
                                ex3_denorm_lst_frac) ||
                               (!vfdsu_ex3_rem_zero && 
                                !vfdsu_ex3_rem_sign)));
assign frac_denorm_rtz_sub_1 = ex3_denorm_zero && vfdsu_ex3_rem_sign;
assign frac_denorm_rup_add_1 = !vfdsu_ex3_result_sign && 
                               (!ex3_denorm_zero || 
                               (!vfdsu_ex3_rem_sign && !vfdsu_ex3_rem_zero)); 
assign frac_denorm_rup_sub_1 = vfdsu_ex3_result_sign && 
                       (ex3_denorm_zero && vfdsu_ex3_rem_sign);
assign frac_denorm_rdn_add_1 = vfdsu_ex3_result_sign && 
                       (!ex3_denorm_zero || 
                       (!vfdsu_ex3_rem_sign && !vfdsu_ex3_rem_zero));
assign frac_denorm_rdn_sub_1 = !vfdsu_ex3_result_sign &&
                       (ex3_denorm_zero && vfdsu_ex3_rem_sign);
assign frac_denorm_rmm_add_1 = ex3_denorm_gr || 
                       (ex3_denorm_eq && !vfdsu_ex3_rem_sign);

//RM select
// &CombBeg; @489
always @( vfdsu_ex3_result_sign
       or frac_rtz_sub_1
       or frac_rdn_add_1
       or frac_denorm_rtz_sub_1
       or frac_rup_sub_1
       or frac_denorm_rmm_add_1
       or frac_denorm_rne_add_1
       or frac_rmm_add_1
       or frac_denorm_rdn_add_1
       or frac_rne_add_1
       or frac_denorm_rdn_sub_1
       or frac_rup_add_1
       or frac_denorm_rup_sub_1
       or frac_rdn_sub_1
       or ex3_rslt_denorm
       or vfdsu_ex3_rm[2:0]
       or frac_denorm_rup_add_1
       or vfdsu_ex3_id_srt_skip)
begin
case(vfdsu_ex3_rm[2:0])
  3'b000://round to nearst,ties to even
  begin 
    frac_add_1          =  ex3_rslt_denorm ? frac_denorm_rne_add_1 : frac_rne_add_1;
    frac_sub_1          =  1'b0;
    frac_orig           =  ex3_rslt_denorm ? !frac_denorm_rne_add_1 : !frac_rne_add_1;
    denorm_to_tiny_frac =  vfdsu_ex3_id_srt_skip ? 1'b0 : frac_denorm_rne_add_1;
  end
  3'b001:// round to 0
  begin 
    frac_add_1           =  1'b0;
    frac_sub_1           =  ex3_rslt_denorm ? frac_denorm_rtz_sub_1 : frac_rtz_sub_1;
    frac_orig            =  ex3_rslt_denorm ? !frac_denorm_rtz_sub_1 : !frac_rtz_sub_1;
    denorm_to_tiny_frac  = 1'b0;
  end
  3'b010://round to -inf
  begin 
    frac_add_1          =  ex3_rslt_denorm ? frac_denorm_rdn_add_1 : frac_rdn_add_1;
    frac_sub_1          =  ex3_rslt_denorm ? frac_denorm_rdn_sub_1 : frac_rdn_sub_1;
    frac_orig           =  ex3_rslt_denorm ? !frac_denorm_rdn_add_1 && !frac_denorm_rdn_sub_1 
                                           : !frac_rdn_add_1 && !frac_rdn_sub_1;
    denorm_to_tiny_frac = vfdsu_ex3_id_srt_skip ? vfdsu_ex3_result_sign 
                                                : frac_denorm_rdn_add_1;
  end
  3'b011://round to +inf
  begin 
    frac_add_1          =  ex3_rslt_denorm ? frac_denorm_rup_add_1 : frac_rup_add_1;
    frac_sub_1          =  ex3_rslt_denorm ? frac_denorm_rup_sub_1 : frac_rup_sub_1; 
    frac_orig           =  ex3_rslt_denorm ? !frac_denorm_rup_add_1 && !frac_denorm_rup_sub_1 
                                           : !frac_rup_add_1 && !frac_rup_sub_1; 
    denorm_to_tiny_frac = vfdsu_ex3_id_srt_skip ? !vfdsu_ex3_result_sign 
                                                : frac_denorm_rup_add_1;
  end
  3'b100://round to nearest,ties to max magnitude
  begin 
    frac_add_1          = ex3_rslt_denorm ? frac_denorm_rmm_add_1 : frac_rmm_add_1;
    frac_sub_1          = 1'b0;
    frac_orig           = ex3_rslt_denorm ? !frac_denorm_rmm_add_1 : !frac_rmm_add_1;
    denorm_to_tiny_frac = vfdsu_ex3_id_srt_skip ? 1'b0 : frac_denorm_rmm_add_1;
  end
  default: 
  begin 
    frac_add_1          = 1'b0;
    frac_sub_1          = 1'b0;
    frac_orig           = 1'b0;
    denorm_to_tiny_frac = 1'b0;
  end
endcase
// &CombEnd; @538
end
//Add 1 or Sub 1 constant
// &CombBeg; @540
always @( total_qt_rt_58[30])
begin
case({total_qt_rt_58[30]})
  1'b0: 
  begin
    frac_add1_op1[25:0] = {2'b0,24'b1};
    frac_sub1_op1[25:0] = {2'b11,{24{1'b1}}};
  end
  1'b1: 
  begin
    frac_add1_op1[25:0] = {25'b1,1'b0};
    frac_sub1_op1[25:0] = {{25{1'b1}},1'b0};
  end
  default:
  begin
    frac_add1_op1[25:0] = 26'b0;
    frac_sub1_op1[25:0] = 26'b0;
  end
endcase
// &CombEnd; @578
end
//Add 1 or Sub1 final result
//Conner case when quotient is 0.010000...00 and remainder is negative,
//The real quotient is actually 0.00fff..ff, 
//The final result will need to sub 1 when
//RN : Never occur
//RP : sign of quotient is -
//RM : sign of quotient is +
assign frac_add1_rst[25:0]             = {1'b0,total_qt_rt_58[30:6]} +
                                         frac_add1_op1_with_denorm[25:0];
assign frac_add1_op1_with_denorm[25:0] = ex3_rslt_denorm ? 
                                  {1'b0,vfdsu_ex3_result_denorm_round_add_num[23:0],1'b0} :
                                  frac_add1_op1[25:0];      
assign frac_sub1_rst[25:0]             = (ex3_rst_eq_1)
                                       ? {2'b0,{24{1'b1}}}
                                       : {1'b0,total_qt_rt_58[30:6]} +
                                         frac_sub1_op1_with_denorm[25:0] + {25'b0,ex3_rslt_denorm};
assign frac_sub1_op1_with_denorm[25:0] = ex3_rslt_denorm ?
                                ~{1'b0,vfdsu_ex3_result_denorm_round_add_num[23:0],1'b0} :
                                frac_sub1_op1[25:0];
assign frac_final_rst[25:0]           = (frac_add1_rst[25:0]         & {26{frac_add_1}}) |
                                        (frac_sub1_rst[25:0]         & {26{frac_sub_1}}) |
                                        ({1'b0,total_qt_rt_58[30:6]} & {26{frac_orig}});

//===============Pipe down signal prepare===================
assign ex3_rst_nor = !vfdsu_ex3_result_zero && 
                     !vfdsu_ex3_result_qnan && 
                     !vfdsu_ex3_result_inf  && 
                     !vfdsu_ex3_result_lfn;
assign ex3_nx      = ex3_rst_nor && 
                    (!ex3_qt_zero || !vfdsu_ex3_rem_zero || ex3_denorm_nx);
assign ex3_denorm_nx = ex3_rslt_denorm && (!ex3_denorm_zero ||  !vfdsu_ex3_rem_zero);
//Adjust expnt
//Div:Actural expnt should plus 1 when op0 is id, sub 1 when op1 id
assign ex3_expnt_adjst[9:0] = 10'h7f;
assign ex3_expnt_adjust_result[9:0] = vfdsu_ex3_expnt_rst[9:0] + 
                                       ex3_expnt_adjst[9:0];
//this information is for the packing, which determin the result is normal
//numer or not;
assign ex3_potnt_norm[1:0]    = {ex3_denorm_plus,ex3_denorm_potnt_norm};
//=======================Pipe to EX4========================

assign ex3_pipe_clk = clk;

always @(posedge ex3_pipe_clk or negedge rst_n)
begin
  if(!rst_n)
  begin
    vfdsu_ex4_result_zero     <=  1'b0;
    vfdsu_ex4_result_qnan     <=  1'b0;
    vfdsu_ex4_result_inf      <=  1'b0;
    vfdsu_ex4_result_lfn      <=  1'b0;
    vfdsu_ex4_result_sign     <=  1'b0;
    vfdsu_ex4_potnt_of        <=  1'b0;
    vfdsu_ex4_potnt_uf        <=  1'b0;
    vfdsu_ex4_result_nor      <=  1'b0;
    vfdsu_ex4_expnt_rst[9 :0] <= 10'b0;
    vfdsu_ex4_nv              <=  1'b0; 
    vfdsu_ex4_nx              <=  1'b0; 
    vfdsu_ex4_uf              <=  1'b0; 
    vfdsu_ex4_of              <=  1'b0; 
    vfdsu_ex4_dz              <=  1'b0; 
    vfdsu_ex4_of_rst_lfn      <=  1'b0;
    vfdsu_ex4_frac[25:0]      <= 26'b0;
    vfdsu_ex4_qnan_sign       <=  1'b0;    
    vfdsu_ex4_qnan_f[22:0]    <= 23'b0;
    vfdsu_ex4_rslt_denorm     <= 1'b0;
    vfdsu_ex4_denorm_to_tiny_frac
                              <= 1'b0;
    vfdsu_ex4_potnt_norm[1:0] <= 2'b0;
  end
  else if(ex3_pipedown)
  begin
    vfdsu_ex4_result_zero     <= vfdsu_ex3_result_zero;
    vfdsu_ex4_result_qnan     <= vfdsu_ex3_result_qnan;
    vfdsu_ex4_result_inf      <= vfdsu_ex3_result_inf;
    vfdsu_ex4_result_lfn      <= vfdsu_ex3_result_lfn;
    vfdsu_ex4_result_sign     <= vfdsu_ex3_result_sign;
    vfdsu_ex4_potnt_of        <= vfdsu_ex3_potnt_of;
    vfdsu_ex4_potnt_uf        <= vfdsu_ex3_potnt_uf;
    vfdsu_ex4_result_nor      <= ex3_rst_nor;
    vfdsu_ex4_expnt_rst[9 :0] <= ex3_expnt_adjust_result[9 :0];
    vfdsu_ex4_nv              <= vfdsu_ex3_nv; 
    vfdsu_ex4_nx              <= ex3_nx; 
    vfdsu_ex4_uf              <= vfdsu_ex3_uf; 
    vfdsu_ex4_of              <= vfdsu_ex3_of; 
    vfdsu_ex4_dz              <= vfdsu_ex3_dz; 
    vfdsu_ex4_of_rst_lfn      <= vfdsu_ex2_of_rm_lfn;
    vfdsu_ex4_frac[25:0]      <= frac_final_rst[25:0];
    vfdsu_ex4_qnan_sign       <= vfdsu_ex3_qnan_sign;    
    vfdsu_ex4_qnan_f[22:0]    <= vfdsu_ex3_qnan_f[22:0];
    vfdsu_ex4_rslt_denorm     <= ex3_rslt_denorm;
    vfdsu_ex4_denorm_to_tiny_frac 
                              <= denorm_to_tiny_frac;
    vfdsu_ex4_potnt_norm[1:0] <= ex3_potnt_norm[1:0];
  end
  else
  begin
    vfdsu_ex4_result_zero     <= vfdsu_ex4_result_zero;
    vfdsu_ex4_result_qnan     <= vfdsu_ex4_result_qnan;
    vfdsu_ex4_result_inf      <= vfdsu_ex4_result_inf;
    vfdsu_ex4_result_lfn      <= vfdsu_ex4_result_lfn;
    vfdsu_ex4_result_sign     <= vfdsu_ex4_result_sign;
    vfdsu_ex4_potnt_of        <= vfdsu_ex4_potnt_of;
    vfdsu_ex4_potnt_uf        <= vfdsu_ex4_potnt_uf;
    vfdsu_ex4_result_nor      <= vfdsu_ex4_result_nor;
    vfdsu_ex4_expnt_rst[9 :0] <= vfdsu_ex4_expnt_rst[9 :0];
    vfdsu_ex4_nv              <= vfdsu_ex4_nv; 
    vfdsu_ex4_nx              <= vfdsu_ex4_nx; 
    vfdsu_ex4_uf              <= vfdsu_ex4_uf; 
    vfdsu_ex4_of              <= vfdsu_ex4_of; 
    vfdsu_ex4_dz              <= vfdsu_ex4_dz; 
    vfdsu_ex4_of_rst_lfn      <= vfdsu_ex4_of_rst_lfn;
    vfdsu_ex4_frac[25:0]      <= vfdsu_ex4_frac[25:0];
    vfdsu_ex4_qnan_sign       <= vfdsu_ex4_qnan_sign;
    vfdsu_ex4_qnan_f[22:0]    <= vfdsu_ex4_qnan_f[22:0];
    vfdsu_ex4_rslt_denorm     <= vfdsu_ex4_rslt_denorm;
    vfdsu_ex4_denorm_to_tiny_frac 
                              <= vfdsu_ex4_denorm_to_tiny_frac;
    vfdsu_ex4_potnt_norm[1:0] <= vfdsu_ex4_potnt_norm[1:0];
  end  
end    

endmodule



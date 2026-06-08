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
module vfdsu_pack(
  ex4_out_out_expt,
  ex4_out_result,
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

// &Ports; @23
input           vfdsu_ex4_denorm_to_tiny_frac;           
input           vfdsu_ex4_dz;                 
input   [9 :0]  vfdsu_ex4_expnt_rst;          
input   [25:0]  vfdsu_ex4_frac;               
input           vfdsu_ex4_nv;                 
input           vfdsu_ex4_nx;                 
input           vfdsu_ex4_of;                 
input           vfdsu_ex4_of_rst_lfn;         
input   [1 :0]  vfdsu_ex4_potnt_norm;         
input           vfdsu_ex4_potnt_of;           
input           vfdsu_ex4_potnt_uf;           
input   [22:0]  vfdsu_ex4_qnan_f;             
input           vfdsu_ex4_qnan_sign;          
input           vfdsu_ex4_result_inf;         
input           vfdsu_ex4_result_lfn;         
input           vfdsu_ex4_result_nor;         
input           vfdsu_ex4_result_qnan;        
input           vfdsu_ex4_result_sign;        
input           vfdsu_ex4_result_zero;        
input           vfdsu_ex4_rslt_denorm;          
input           vfdsu_ex4_uf;                 
output  [4 :0]  ex4_out_out_expt;                 
output  [31:0]  ex4_out_result;               

// &Regs; @24
reg     [22:0]  ex4_denorm_frac;              
reg     [22:0]  ex4_frac_52;                          
reg     [31:0]  ex4_out_result;              
reg     [9 :0]  expnt_add_op1;                

// &Wires; @25
wire            ex4_cor_nx;                   
wire            ex4_cor_uf;                   
wire            ex4_denorm_potnt_norm;        
wire    [31:0]  ex4_denorm_result;                       
wire    [9 :0]  ex4_expnt_rst;                
wire            ex4_final_rst_norm;           
wire    [25:0]  ex4_frac;                                 
wire            ex4_of_plus;                  
wire    [4 :0]  ex4_out_out_expt;                 
wire            ex4_result_inf;               
wire            ex4_result_lfn;               
wire            ex4_rslt_denorm;              
wire    [31:0]  ex4_rst0;                     
wire    [31:0]  ex4_rst_inf;                  
wire    [31:0]  ex4_rst_lfn;                  
wire            ex4_rst_nor;                  
wire    [31:0]  ex4_rst_norm;                 
wire    [31:0]  ex4_rst_qnan;                            
wire            ex4_uf_plus;                  
wire            vfdsu_ex4_denorm_to_tiny_frac;           
wire            vfdsu_ex4_dz;                 
wire    [9 :0]  vfdsu_ex4_expnt_rst;          
wire    [25:0]  vfdsu_ex4_frac;               
wire            vfdsu_ex4_nv;                 
wire            vfdsu_ex4_nx;                 
wire            vfdsu_ex4_of;                 
wire            vfdsu_ex4_of_rst_lfn;         
wire    [1 :0]  vfdsu_ex4_potnt_norm;         
wire            vfdsu_ex4_potnt_of;           
wire            vfdsu_ex4_potnt_uf;           
wire    [22:0]  vfdsu_ex4_qnan_f;             
wire            vfdsu_ex4_qnan_sign;          
wire            vfdsu_ex4_result_inf;         
wire            vfdsu_ex4_result_lfn;         
wire            vfdsu_ex4_result_nor;         
wire            vfdsu_ex4_result_qnan;        
wire            vfdsu_ex4_result_sign;        
wire            vfdsu_ex4_result_zero;        
wire            vfdsu_ex4_rslt_denorm;               
wire            vfdsu_ex4_uf;                 


//============================EX4 STAGE=====================
assign ex4_frac[25:0] = vfdsu_ex4_frac[25:0];
//exponent adder
// &CombBeg; @30
always @( ex4_frac[25:24])
begin
casez(ex4_frac[25:24])
  2'b00   : expnt_add_op1[9:0] = 10'h3ff;  //the expnt sub 1
  2'b01   : expnt_add_op1[9:0] = 10'h0;    //the expnt stay the origi
  2'b1?   : expnt_add_op1[9:0] = 10'h1;    // the out_exptn add 1
  default : expnt_add_op1[9:0] = 10'b0;  
endcase
// &CombEnd; @37
end
assign ex4_expnt_rst[9 :0] = vfdsu_ex4_expnt_rst[9 :0] + 
                             expnt_add_op1[9 :0];

//==========================Result Pack=====================
// result denormal pack 
// shift to the denormal number

always @( vfdsu_ex4_expnt_rst[9 :0]
       or ex4_frac[25:1]
       or vfdsu_ex4_denorm_to_tiny_frac)
begin
case(vfdsu_ex4_expnt_rst[9 :0])
  10'h1:  ex4_denorm_frac[22:0] = {      ex4_frac[23:1]}; //-1022 1
  10'h0:  ex4_denorm_frac[22:0] = {      ex4_frac[24:2]}; //-1023 0
  10'h3ff:ex4_denorm_frac[22:0] = {      ex4_frac[25:3]}; //-1024 -1
  10'h3fe:ex4_denorm_frac[22:0] = {1'b0, ex4_frac[25:4]}; //-1025 -2
  10'h3fd:ex4_denorm_frac[22:0] = {2'b0, ex4_frac[25:5]}; //-1026 -3
  10'h3fc:ex4_denorm_frac[22:0] = {3'b0, ex4_frac[25:6]}; //-1027 -4
  10'h3fb:ex4_denorm_frac[22:0] = {4'b0, ex4_frac[25:7]}; //-1028 -5
  10'h3fa:ex4_denorm_frac[22:0] = {5'b0, ex4_frac[25:8]}; //-1029 -6
  10'h3f9:ex4_denorm_frac[22:0] = {6'b0, ex4_frac[25:9]}; //-1030 -7
  10'h3f8:ex4_denorm_frac[22:0] = {7'b0, ex4_frac[25:10]}; //-1031 -8
  10'h3f7:ex4_denorm_frac[22:0] = {8'b0, ex4_frac[25:11]}; //-1032 -9
  10'h3f6:ex4_denorm_frac[22:0] = {9'b0, ex4_frac[25:12]}; //-1033 -10
  10'h3f5:ex4_denorm_frac[22:0] = {10'b0,ex4_frac[25:13]}; //-1034 -11
  10'h3f4:ex4_denorm_frac[22:0] = {11'b0,ex4_frac[25:14]}; //-1035 -12
  10'h3f3:ex4_denorm_frac[22:0] = {12'b0,ex4_frac[25:15]}; //-1036 -13  
  10'h3f2:ex4_denorm_frac[22:0] = {13'b0,ex4_frac[25:16]}; // -1037
  10'h3f1:ex4_denorm_frac[22:0] = {14'b0,ex4_frac[25:17]}; //-1038
  10'h3f0:ex4_denorm_frac[22:0] = {15'b0,ex4_frac[25:18]}; //-1039
  10'h3ef:ex4_denorm_frac[22:0] = {16'b0,ex4_frac[25:19]}; //-1040
  10'h3ee:ex4_denorm_frac[22:0] = {17'b0,ex4_frac[25:20]}; //-1041
  10'h3ed:ex4_denorm_frac[22:0] = {18'b0,ex4_frac[25:21]}; //-1042
  10'h3ec:ex4_denorm_frac[22:0] = {19'b0,ex4_frac[25:22]}; //-1043
  10'h3eb:ex4_denorm_frac[22:0] = {20'b0,ex4_frac[25:23]}; //-1044
  10'h3ea:ex4_denorm_frac[22:0] = {21'b0,ex4_frac[25:24]}; //-1045
  default: ex4_denorm_frac[22:0] = vfdsu_ex4_denorm_to_tiny_frac ? 23'b1 : 23'b0;
endcase                                                                  
// &CombEnd;    @102
end

//here when denormal number round to add1, it will become normal number
assign ex4_denorm_potnt_norm    = (vfdsu_ex4_potnt_norm[1] && ex4_frac[24]) || 
                                  (vfdsu_ex4_potnt_norm[0] && ex4_frac[25]) ;
assign ex4_rslt_denorm          = !vfdsu_ex4_result_qnan 
                                  && !vfdsu_ex4_result_zero 
                                  && (vfdsu_ex4_rslt_denorm && !ex4_denorm_potnt_norm);
assign ex4_denorm_result[31:0]  = {vfdsu_ex4_result_sign,8'h0,ex4_denorm_frac[22:0]};
                               
//ex4 overflow/underflow plus                                 
assign ex4_rst_nor = vfdsu_ex4_result_nor;                    
assign ex4_of_plus = vfdsu_ex4_potnt_of  && 
                     (|ex4_frac[25:24])  && 
                     ex4_rst_nor;
assign ex4_uf_plus = vfdsu_ex4_potnt_uf  && 
                     (~(|ex4_frac[25:24])) && 
                     ex4_rst_nor;
//ex4 overflow round result
assign ex4_result_lfn = (ex4_of_plus &&  vfdsu_ex4_of_rst_lfn) ||
                        vfdsu_ex4_result_lfn;
assign ex4_result_inf = (ex4_of_plus && !vfdsu_ex4_of_rst_lfn) ||
                        vfdsu_ex4_result_inf;


always @( ex4_frac[25:0])
begin
casez(ex4_frac[25:24])
  2'b00   : ex4_frac_52[22:0]  = ex4_frac[22:0];
  2'b01   : ex4_frac_52[22:0]  = ex4_frac[23:1];
  2'b1?   : ex4_frac_52[22:0]  = ex4_frac[24:2];
  default : ex4_frac_52[22:0]  = 23'b0;
endcase
// &CombEnd; @206
end

assign ex4_rst_lfn[31:0]       = {vfdsu_ex4_result_sign,8'hfe,{23{1'b1}}};

assign ex4_rst0[31:0]          = {vfdsu_ex4_result_sign,31'b0};

assign ex4_rst_qnan[31:0]      = {vfdsu_ex4_qnan_sign, 8'hff,   1'b1, vfdsu_ex4_qnan_f[21:0]};

assign ex4_rst_norm[31:0]      = {vfdsu_ex4_result_sign,
                                  ex4_expnt_rst[7:0],
                                  ex4_frac_52[22:0]};
assign ex4_rst_inf[31:0]       = {vfdsu_ex4_result_sign,8'hff,23'b0};

assign ex4_cor_uf            = (vfdsu_ex4_uf && !ex4_denorm_potnt_norm || ex4_uf_plus)
                               && vfdsu_ex4_nx;
assign ex4_cor_nx            =  vfdsu_ex4_nx 
                                || vfdsu_ex4_of 
                                || ex4_of_plus;
                                        
assign ex4_out_out_expt[4:0]           = {
                                  vfdsu_ex4_nv,
                                  vfdsu_ex4_dz,
                                  vfdsu_ex4_of | ex4_of_plus,
                                  ex4_cor_uf,
                                  ex4_cor_nx};

assign ex4_final_rst_norm      = !vfdsu_ex4_result_qnan && 
                                 !ex4_result_inf        &&
                                 !ex4_result_lfn        &&
                                 !vfdsu_ex4_result_zero &&
                                 !ex4_rslt_denorm; 
// &CombBeg; @249
always @( ex4_rst_norm[31:0]
       or ex4_result_lfn
       or vfdsu_ex4_result_qnan
       or ex4_rst_qnan[31:0]
       or ex4_rst0[31:0]
       or ex4_rslt_denorm
       or ex4_denorm_result[31:0]
       or ex4_result_inf
       or ex4_final_rst_norm
       or ex4_rst_lfn[31:0]
       or vfdsu_ex4_result_zero
       or ex4_rst_inf[31:0])
begin
case({ex4_rslt_denorm,
      vfdsu_ex4_result_qnan,
      ex4_result_inf,
      ex4_result_lfn,
      vfdsu_ex4_result_zero,
      ex4_final_rst_norm})
  6'b100000 : ex4_out_result[31:0]  = ex4_denorm_result[31:0];
  6'b010000 : ex4_out_result[31:0]  = ex4_rst_qnan[31:0]; 
  6'b001000 : ex4_out_result[31:0]  = ex4_rst_inf[31:0];
  6'b000100 : ex4_out_result[31:0]  = ex4_rst_lfn[31:0];
  6'b000010 : ex4_out_result[31:0]  = ex4_rst0[31:0];
  6'b000001 : ex4_out_result[31:0]  = ex4_rst_norm[31:0];
  default   : ex4_out_result[31:0]  = 31'b0;
endcase
// &CombEnd; @264
end

// &ModuleEnd; @266
endmodule



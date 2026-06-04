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
module vfdsu_scalar_dp(
  rst_n,
  op0,
  op1,
  ex1_data_clk,
  ex1_div,
  ex1_pipedown,
  ex1_scalar,
  ex1_sqrt,
  ex1_src0,
  ex1_src1,
  ex2_data_clk,
  ex2_pipedown,
  ex3_data_clk,
  ex3_pipedown,
  ex4_out_out_expt,
  ex4_out_result,
  clk,
  func,
  out_expt,
  out_data
);
                      
input           rst_n;   
input   [31:0]  op0;     
input   [31:0]  op1;     
input           ex1_data_clk;                 
input           ex1_pipedown;                 
input           ex2_data_clk;                 
input           ex2_pipedown;                 
input           ex3_data_clk;                 
input           ex3_pipedown;                 
input   [4 :0]  ex4_out_out_expt;                 
input   [31:0]  ex4_out_result;               
input           clk;               
input   [1 :0]  func;         
output          ex1_div;                      
output          ex1_scalar;                    
output          ex1_sqrt;                     
output  [31:0]  ex1_src0;                     
output  [31:0]  ex1_src1;                      
output  [4 :0]  out_expt;     
output  [31:0]  out_data;             

// &Regs; @25
reg             ex1_div;                     
reg             ex1_sqrt;                     
reg             vfdsu_ex2_div;               
reg             vfdsu_ex2_sqrt;   

reg     [31:0]  ex1_src0_reg;        
reg     [31:0]  ex1_src1_reg; 
                          
wire            rst_n;    
wire    [31:0]  op0;     
wire    [31:0]  op1;     
wire            ex1_data_clk;                 
wire            ex1_pipedown;                 
wire            ex1_scalar;                   
wire    [31:0]  ex1_src0;                     
wire    [31:0]  ex1_src1;                     
wire            ex2_data_clk;                 
wire            ex2_pipedown;                 
wire            ex3_data_clk;                 
wire            ex3_pipedown;                 
wire    [4 :0]  ex4_out_out_expt;                 
wire    [31:0]  ex4_out_result;               
wire            clk;               
wire    [1 :0]  func;        
wire    [4 :0]  out_expt;     
wire    [31:0]  out_data;     
wire            vfdsu_sew_clk;                
wire            vfdsu_sew_clk_en;             


//==========================================================
//              EX1 Stage Control Signal
//==========================================================

assign vfdsu_sew_clk = clk;

always @(posedge vfdsu_sew_clk or negedge rst_n)
begin
  if(!rst_n)
  begin
    ex1_div            <= 1'b0;
    ex1_sqrt           <= 1'b0;
    ex1_src0_reg       <= 31'b0;
    ex1_src1_reg       <= 31'b0;
  end
  else
  begin
    ex1_div            <= func[0];
    ex1_sqrt           <= func[1];
    ex1_src0_reg       <= op0[31:0];
    ex1_src1_reg       <= op1[31:0];
  end
end
assign ex1_scalar         = 1'b1;

assign ex1_src0[31:0]    = ex1_src0_reg[31:0];
assign ex1_src1[31:0]    = ex1_src1_reg[31:0];


always @(posedge ex1_data_clk or negedge rst_n)
begin
  if(!rst_n)
  begin
    vfdsu_ex2_div           <=  1'b0;
    vfdsu_ex2_sqrt          <=  1'b0;
  end
  else if(ex1_pipedown)
  begin
    vfdsu_ex2_div           <= ex1_div;
    vfdsu_ex2_sqrt          <= ex1_sqrt;
  end
  else
  begin
    vfdsu_ex2_div           <= vfdsu_ex2_div;
    vfdsu_ex2_sqrt          <= vfdsu_ex2_sqrt;
  end
end


assign out_expt[4:0]   = ex4_out_out_expt[4:0];
assign out_data[31:0]  = ex4_out_result[31:0];


endmodule


